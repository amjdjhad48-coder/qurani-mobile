package com.amjadjihad.qurani

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class P006SafBridge(
    private val activity: Activity,
) {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null
    private var pendingSuggestedName: String? = null
    private var pendingMimeType: String? = null

    fun handle(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "saveBytes" -> startSave(call, result)
            else -> result.notImplemented()
        }
    }

    @Suppress("DEPRECATION")
    private fun startSave(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        if (pendingResult != null) {
            result.error(
                "P0_06_SAF_BUSY",
                "A SAF document operation is already pending.",
                null,
            )
            return
        }

        try {
            val bytes =
                call.argument<ByteArray>("bytes")
                    ?: throw IllegalArgumentException("Missing bytes.")

            require(bytes.isNotEmpty()) {
                "P0-06 refuses to save an empty file."
            }

            val suggestedName =
                call.argument<String>("suggestedName")
                    ?.trim()
                    ?.takeIf { it.isNotEmpty() }
                    ?: throw IllegalArgumentException(
                        "Missing suggestedName.",
                    )

            require(
                !suggestedName.contains('/') &&
                    !suggestedName.contains('\\'),
            ) {
                "suggestedName must be a file name, not a path."
            }

            val mimeType =
                call.argument<String>("mimeType")
                    ?.trim()
                    ?.takeIf { it.isNotEmpty() }
                    ?: throw IllegalArgumentException(
                        "Missing mimeType.",
                    )

            pendingResult = result
            pendingBytes = bytes
            pendingSuggestedName = suggestedName
            pendingMimeType = mimeType

            val intent =
                Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = mimeType
                    putExtra(Intent.EXTRA_TITLE, suggestedName)
                    addFlags(
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                    )
                }

            activity.startActivityForResult(
                intent,
                REQUEST_CREATE_DOCUMENT,
            )
        } catch (error: Throwable) {
            clearPending()
            result.error(
                "P0_06_SAF_START_ERROR",
                error.message ?: error.javaClass.simpleName,
                error.javaClass.name,
            )
        }
    }

    fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ): Boolean {
        if (requestCode != REQUEST_CREATE_DOCUMENT) {
            return false
        }

        val result = pendingResult ?: return true
        val suggestedName = pendingSuggestedName
        val mimeType = pendingMimeType

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            try {
                result.success(
                    mapOf(
                        "status" to "cancelled",
                        "suggestedName" to suggestedName,
                        "mimeType" to mimeType,
                    ),
                )
            } finally {
                clearPending()
            }
            return true
        }

        val uri = data.data!!

        try {
            val bytes =
                checkNotNull(pendingBytes) {
                    "Missing pending SAF bytes."
                }

            val resolver = activity.contentResolver

            resolver.openOutputStream(uri, "wt")?.use { output ->
                output.write(bytes)
                output.flush()
            } ?: throw IllegalStateException(
                "Could not open SAF output stream.",
            )

            val reopened =
                resolver.openInputStream(uri)?.use { input ->
                    input.readBytes()
                } ?: throw IllegalStateException(
                    "Could not reopen saved SAF document.",
                )

            val sourceSha = sha256(bytes)
            val reopenedSha = sha256(reopened)
            val roundTripMatches = reopened.contentEquals(bytes)

            check(roundTripMatches) {
                "Saved SAF document does not match source bytes."
            }

            result.success(
                mapOf(
                    "status" to "saved",
                    "uri" to uri.toString(),
                    "bytes" to bytes.size,
                    "reopenedBytes" to reopened.size,
                    "sha256" to sourceSha,
                    "reopenedSha256" to reopenedSha,
                    "roundTripMatches" to roundTripMatches,
                    "suggestedName" to suggestedName,
                    "mimeType" to mimeType,
                ),
            )
        } catch (error: Throwable) {
            result.error(
                "P0_06_SAF_WRITE_ERROR",
                error.message ?: error.javaClass.simpleName,
                error.javaClass.name,
            )
        } finally {
            clearPending()
        }

        return true
    }

    private fun clearPending() {
        pendingResult = null
        pendingBytes = null
        pendingSuggestedName = null
        pendingMimeType = null
    }

    private fun sha256(bytes: ByteArray): String {
        return MessageDigest
            .getInstance("SHA-256")
            .digest(bytes)
            .joinToString("") { byte ->
                "%02X".format(byte.toInt() and 0xFF)
            }
    }

    companion object {
        const val CHANNEL = "qurani/p0_06_saf"
        private const val REQUEST_CREATE_DOCUMENT = 6006
    }
}