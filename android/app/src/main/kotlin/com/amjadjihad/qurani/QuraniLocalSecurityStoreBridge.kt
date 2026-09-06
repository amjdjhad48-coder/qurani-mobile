package com.amjadjihad.qurani

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.AtomicFile
import android.util.Base64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.charset.StandardCharsets
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import org.json.JSONObject

class QuraniLocalSecurityStoreBridge(
    context: Context,
) {
    companion object {
        const val CHANNEL = "qurani/local_security_store"

        private const val STORE_VERSION = 1
        private const val FILE_NAME = "local_security_store_v1.json"
        private const val ANDROID_KEY_STORE = "AndroidKeyStore"
        private const val MASTER_KEY_ALIAS = "QuraniMasterKey"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_TAG_BITS = 128
        private const val KEY_SIZE_BITS = 256
        private const val AAD = "qurani:local-security-store:v1"
    }

    private val atomicFile =
        AtomicFile(
            File(
                context.noBackupFilesDir,
                FILE_NAME,
            ),
        )

    private val lock = Any()

    fun handle(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        try {
            synchronized(lock) {
                when (call.method) {
                    "read" -> result.success(read())
                    "write" -> {
                        write(call)
                        result.success(null)
                    }
                    "clear" -> {
                        atomicFile.delete()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        } catch (error: Exception) {
            result.error(
                "QURANI_LOCAL_SECURITY_STORE_ERROR",
                "${error.javaClass.simpleName}: ${error.message}",
                null,
            )
        }
    }

    private fun read(): String? {
        if (!atomicFile.baseFile.exists()) {
            return null
        }

        val encoded =
            atomicFile.openRead().use { input ->
                input.readBytes().toString(StandardCharsets.UTF_8)
            }

        if (encoded.isBlank()) {
            throw IllegalStateException(
                "Local security store file is empty.",
            )
        }

        val envelope = JSONObject(encoded)

        if (envelope.getInt("version") != STORE_VERSION ||
            envelope.getString("alias") != MASTER_KEY_ALIAS ||
            envelope.getString("algorithm") != TRANSFORMATION
        ) {
            throw IllegalStateException(
                "Unsupported local security store envelope metadata.",
            )
        }

        val iv =
            Base64.decode(
                envelope.getString("ivBase64"),
                Base64.NO_WRAP,
            )

        val ciphertext =
            Base64.decode(
                envelope.getString("ciphertextBase64"),
                Base64.NO_WRAP,
            )

        if (iv.isEmpty() || ciphertext.isEmpty()) {
            throw IllegalStateException(
                "Local security store envelope is incomplete.",
            )
        }

        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(
            Cipher.DECRYPT_MODE,
            getExistingMasterKey(),
            GCMParameterSpec(
                GCM_TAG_BITS,
                iv,
            ),
        )
        cipher.updateAAD(AAD.toByteArray(StandardCharsets.UTF_8))

        val plaintext = cipher.doFinal(ciphertext)
        if (plaintext.isEmpty()) {
            throw IllegalStateException(
                "Local security store plaintext is empty.",
            )
        }

        return Base64.encodeToString(
            plaintext,
            Base64.NO_WRAP,
        )
    }

    private fun write(call: MethodCall) {
        val payloadBase64 =
            call.argument<String>("payloadBase64")
                ?: throw IllegalArgumentException(
                    "Missing argument: payloadBase64",
                )

        val plaintext =
            Base64.decode(
                payloadBase64,
                Base64.NO_WRAP,
            )

        if (plaintext.isEmpty()) {
            throw IllegalArgumentException(
                "Local security store payload must not be empty.",
            )
        }

        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(
            Cipher.ENCRYPT_MODE,
            getOrCreateMasterKey(),
        )
        cipher.updateAAD(AAD.toByteArray(StandardCharsets.UTF_8))

        val ciphertext = cipher.doFinal(plaintext)
        val iv =
            cipher.iv
                ?: throw IllegalStateException(
                    "Android Keystore did not provide a GCM IV.",
                )

        val envelope =
            JSONObject()
                .put("version", STORE_VERSION)
                .put("alias", MASTER_KEY_ALIAS)
                .put("algorithm", TRANSFORMATION)
                .put(
                    "ivBase64",
                    Base64.encodeToString(
                        iv,
                        Base64.NO_WRAP,
                    ),
                )
                .put(
                    "ciphertextBase64",
                    Base64.encodeToString(
                        ciphertext,
                        Base64.NO_WRAP,
                    ),
                )
                .toString()
                .toByteArray(StandardCharsets.UTF_8)

        val output = atomicFile.startWrite()

        try {
            output.write(envelope)
            atomicFile.finishWrite(output)
        } catch (error: Exception) {
            atomicFile.failWrite(output)
            throw error
        }
    }

    private fun getOrCreateMasterKey(): SecretKey {
        val keyStore = keyStore()
        val existingKey = keyStore.getKey(MASTER_KEY_ALIAS, null)

        if (existingKey is SecretKey) {
            return existingKey
        }

        if (existingKey != null) {
            throw IllegalStateException(
                "Unexpected key type under QuraniMasterKey alias.",
            )
        }

        val keyGenerator =
            KeyGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_AES,
                ANDROID_KEY_STORE,
            )

        val specification =
            KeyGenParameterSpec.Builder(
                MASTER_KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or
                    KeyProperties.PURPOSE_DECRYPT,
            )
                .setKeySize(KEY_SIZE_BITS)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(
                    KeyProperties.ENCRYPTION_PADDING_NONE,
                )
                .setRandomizedEncryptionRequired(true)
                .setUserAuthenticationRequired(false)
                .build()

        keyGenerator.init(specification)
        return keyGenerator.generateKey()
    }

    private fun getExistingMasterKey(): SecretKey {
        val key = keyStore().getKey(MASTER_KEY_ALIAS, null)

        return key as? SecretKey
            ?: throw IllegalStateException(
                "QuraniMasterKey does not exist.",
            )
    }

    private fun keyStore(): KeyStore {
        return KeyStore.getInstance(ANDROID_KEY_STORE).apply {
            load(null)
        }
    }
}
