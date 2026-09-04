package com.amjadjihad.qurani

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class QuraniKeystoreBridge {
    companion object {
        const val CHANNEL = "qurani/security_keystore"

        private const val ANDROID_KEY_STORE = "AndroidKeyStore"
        private const val MASTER_KEY_ALIAS = "QuraniMasterKey"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_TAG_BITS = 128
        private const val KEY_SIZE_BITS = 256
    }

    fun handle(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        try {
            when (call.method) {
                "ensureMasterKey" -> result.success(describeMasterKey())
                "wrap" -> result.success(wrap(call))
                "unwrap" -> result.success(unwrap(call))
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error(
                "QURANI_KEYSTORE_ERROR",
                "${error.javaClass.simpleName}: ${error.message}",
                null,
            )
        }
    }

    private fun describeMasterKey(): Map<String, Any?> {
        val key = getOrCreateMasterKey()

        return mapOf(
            "alias" to MASTER_KEY_ALIAS,
            "aliasExists" to keyStore().containsAlias(MASTER_KEY_ALIAS),
            "algorithm" to key.algorithm,
            "configuredKeySizeBits" to KEY_SIZE_BITS,
            "transformation" to TRANSFORMATION,
            "encodedIsNull" to (key.encoded == null),
            "userAuthenticationRequired" to false,
        )
    }

    private fun wrap(
        call: MethodCall,
    ): Map<String, Any?> {
        val plaintext = decodeRequiredBase64(call, "plaintextBase64")
        val aad = decodeOptionalBase64(call, "aadBase64")
        val key = getOrCreateMasterKey()

        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, key)

        if (aad.isNotEmpty()) {
            cipher.updateAAD(aad)
        }

        val ciphertext = cipher.doFinal(plaintext)
        val iv =
            cipher.iv
                ?: throw IllegalStateException(
                    "Android Keystore did not provide a GCM IV.",
                )

        return mapOf(
            "version" to 1,
            "alias" to MASTER_KEY_ALIAS,
            "algorithm" to TRANSFORMATION,
            "ivBase64" to encodeBase64(iv),
            "ciphertextBase64" to encodeBase64(ciphertext),
        )
    }

    private fun unwrap(
        call: MethodCall,
    ): String {
        val iv = decodeRequiredBase64(call, "ivBase64")
        val ciphertext = decodeRequiredBase64(call, "ciphertextBase64")
        val aad = decodeOptionalBase64(call, "aadBase64")
        val key = getExistingMasterKey()

        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(
            Cipher.DECRYPT_MODE,
            key,
            GCMParameterSpec(
                GCM_TAG_BITS,
                iv,
            ),
        )

        if (aad.isNotEmpty()) {
            cipher.updateAAD(aad)
        }

        return encodeBase64(cipher.doFinal(ciphertext))
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

    private fun decodeRequiredBase64(
        call: MethodCall,
        name: String,
    ): ByteArray {
        val value =
            call.argument<String>(name)
                ?: throw IllegalArgumentException(
                    "Missing argument: $name",
                )

        return Base64.decode(value, Base64.NO_WRAP)
    }

    private fun decodeOptionalBase64(
        call: MethodCall,
        name: String,
    ): ByteArray {
        val value = call.argument<String>(name) ?: return ByteArray(0)

        if (value.isEmpty()) {
            return ByteArray(0)
        }

        return Base64.decode(value, Base64.NO_WRAP)
    }

    private fun encodeBase64(
        bytes: ByteArray,
    ): String {
        return Base64.encodeToString(bytes, Base64.NO_WRAP)
    }
}