package com.amjadjihad.qurani

import android.app.Activity
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

class P007ExternalSharingBridge(
    private val activity: Activity,
) {
    private data class ExternalActionState(
        var launchCount: Int = 0,
        var pending: Boolean = false,
        var pauseSeen: Boolean = false,
        var returned: Boolean = false,
    )

    private val states =
        mutableMapOf(
            KIND_IMO to ExternalActionState(),
            KIND_WHATSAPP to ExternalActionState(),
            KIND_SMS to ExternalActionState(),
        )

    private var pendingReportArtifactFile: File? = null
    private var reportArtifactPauseSeen = false

    init {
        cleanupStaleReportArtifactsOncePerProcess()
    }

    private fun cleanupStaleReportArtifactsOncePerProcess() {
        synchronized(P007ExternalSharingBridge::class.java) {
            if (reportArtifactStartupCleanupComplete) {
                return@synchronized
            }

            val shareDirectory =
                File(
                    activity.cacheDir,
                    SHARE_CACHE_DIRECTORY,
                )

            if (shareDirectory.exists()) {
                val canonicalShareDirectory = shareDirectory.canonicalFile
                val canonicalCacheRoot = activity.cacheDir.canonicalFile

                check(
                    canonicalShareDirectory.path.startsWith(
                        canonicalCacheRoot.path + File.separator,
                    )
                ) {
                    "Report startup cleanup cache escaped app cache."
                }

                canonicalShareDirectory
                    .listFiles()
                    ?.filter { file ->
                        file.isFile &&
                            REPORT_ARTIFACT_EXTENSIONS.contains(
                                file.extension.lowercase(),
                            )
                    }
                    ?.forEach { file ->
                        check(file.delete() || !file.exists()) {
                            "Could not delete stale report cache artifact."
                        }
                    }
            }

            reportArtifactStartupCleanupComplete = true
        }
    }

    fun handle(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        try {
            when (call.method) {
                "shareImoProbe" -> result.success(shareImoProbe())
                "openReportArtifact" -> result.success(openReportArtifact(call))
                "shareReportArtifact" -> result.success(shareReportArtifact(call))
                "shareWhatsAppText" -> result.success(shareWhatsAppText())
                "openSmsComposer" -> result.success(openSmsComposer())
                "openParentWhatsApp" ->
                    result.success(openParentWhatsApp(call))
                "openParentSms" ->
                    result.success(openParentSms(call))
                "getState" -> result.success(getState())
                "cleanupShareProbe" -> result.success(cleanupShareProbe())
                else -> result.notImplemented()
            }
        } catch (error: Throwable) {
            result.error(
                "P0_07_EXTERNAL_SHARING_ERROR",
                error.message ?: error.javaClass.simpleName,
                error.javaClass.name,
            )
        }
    }

    fun onHostPaused() {
        states.values.forEach { state ->
            if (state.pending) {
                state.pauseSeen = true
            }
        }

        if (pendingReportArtifactFile != null) {
            reportArtifactPauseSeen = true
        }
    }

    fun onHostResumed() {
        states.values.forEach { state ->
            if (state.pending && state.pauseSeen) {
                state.returned = true
                state.pending = false
            }
        }

        if (pendingReportArtifactFile != null && reportArtifactPauseSeen) {
            pendingReportArtifactFile?.delete()
            pendingReportArtifactFile = null
            reportArtifactPauseSeen = false
        }
    }

    private fun openReportArtifact(
        call: MethodCall,
    ): Map<String, Any?> {
        val bytes =
            call.argument<ByteArray>("bytes")
                ?: throw IllegalArgumentException("Missing report artifact bytes.")

        require(bytes.isNotEmpty()) {
            "Report artifact bytes must not be empty."
        }

        val expectedSha256 =
            call.argument<String>("sha256")
                ?.trim()
                ?.lowercase()
                ?: throw IllegalArgumentException(
                    "Missing report artifact SHA-256.",
                )

        require(Regex("^[0-9a-f]{64}$").matches(expectedSha256)) {
            "Report artifact SHA-256 must be 64 lowercase hexadecimal characters."
        }

        val mimeType =
            call.argument<String>("mimeType")
                ?.trim()
                ?: throw IllegalArgumentException(
                    "Missing report artifact MIME type.",
                )

        val extension =
            when (mimeType) {
                REPORT_XLSX_MIME_TYPE -> "xlsx"
                REPORT_PDF_MIME_TYPE -> "pdf"
                else -> throw IllegalArgumentException(
                    "Unsupported report artifact MIME type.",
                )
            }

        val shareDirectory =
            File(
                activity.cacheDir,
                SHARE_CACHE_DIRECTORY,
            )

        check(
            shareDirectory.exists() ||
                shareDirectory.mkdirs()
        ) {
            "Could not create dedicated report-open cache."
        }

        val canonicalShareDirectory =
            shareDirectory.canonicalFile
        val canonicalCacheRoot =
            activity.cacheDir.canonicalFile

        check(
            canonicalShareDirectory.path.startsWith(
                canonicalCacheRoot.path + File.separator,
            )
        ) {
            "Report-open cache escaped app cache."
        }

        canonicalShareDirectory
            .listFiles()
            ?.filter { file ->
                file.isFile &&
                    REPORT_ARTIFACT_EXTENSIONS.contains(
                        file.extension.lowercase(),
                    )
            }
            ?.forEach { file ->
                file.delete()
            }

        val file =
            File(
                canonicalShareDirectory,
                "$expectedSha256.$extension",
            )

        val actualSha256: String
        val uri: Uri

        try {
            file.writeBytes(bytes)

            check(file.length() == bytes.size.toLong()) {
                "Report-open cache file size mismatch."
            }

            actualSha256 = sha256(file).lowercase()

            check(actualSha256 == expectedSha256) {
                "Report-open cache SHA-256 mismatch."
            }

            uri =
                FileProvider.getUriForFile(
                    activity,
                    "${activity.packageName}.p007.fileprovider",
                    file,
                )

            check(uri.scheme == "content") {
                "FileProvider did not return a content URI for report artifact."
            }

            check(
                uri.authority ==
                    "${activity.packageName}.p007.fileprovider"
            ) {
                "Unexpected FileProvider authority for report artifact."
            }
        } catch (error: Throwable) {
            file.delete()
            throw error
        }

        val intent =
            Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                clipData =
                    ClipData.newRawUri(
                        "qurani_report_artifact",
                        uri,
                    )
            }

        pendingReportArtifactFile = file
        reportArtifactPauseSeen = false

        try {
            activity.startActivity(intent)
        } catch (error: Throwable) {
            pendingReportArtifactFile = null
            reportArtifactPauseSeen = false
            file.delete()
            throw error
        }

        return mapOf(
            "launched" to true,
            "action" to Intent.ACTION_VIEW,
            "mimeType" to mimeType,
            "uri" to uri.toString(),
            "authority" to uri.authority,
            "scheme" to uri.scheme,
            "fileName" to file.name,
            "bytes" to file.length(),
            "sha256" to actualSha256,
            "dedicatedShareCache" to canonicalShareDirectory.path,
            "cacheRoot" to canonicalCacheRoot.path,
        )
    }

    private fun shareReportArtifact(
        call: MethodCall,
    ): Map<String, Any?> {
        val bytes =
            call.argument<ByteArray>("bytes")
                ?: throw IllegalArgumentException("Missing report artifact bytes.")

        require(bytes.isNotEmpty()) {
            "Report artifact bytes must not be empty."
        }

        val expectedSha256 =
            call.argument<String>("sha256")
                ?.trim()
                ?.lowercase()
                ?: throw IllegalArgumentException(
                    "Missing report artifact SHA-256.",
                )

        require(Regex("^[0-9a-f]{64}$").matches(expectedSha256)) {
            "Report artifact SHA-256 must be 64 lowercase hexadecimal characters."
        }

        val suggestedName =
            call.argument<String>("suggestedName")
                ?.trim()
                ?.takeIf { it.isNotEmpty() }
                ?: throw IllegalArgumentException(
                    "Missing report artifact suggestedName.",
                )

        require(
            !suggestedName.contains('/') &&
                !suggestedName.contains('\\'),
        ) {
            "Report artifact suggestedName must be a simple file name."
        }

        val mimeType =
            call.argument<String>("mimeType")
                ?.trim()
                ?: throw IllegalArgumentException(
                    "Missing report artifact MIME type.",
                )

        val extension =
            when (mimeType) {
                REPORT_XLSX_MIME_TYPE -> "xlsx"
                REPORT_PDF_MIME_TYPE -> "pdf"
                else -> throw IllegalArgumentException(
                    "Unsupported report artifact MIME type.",
                )
            }

        require(suggestedName.endsWith(".$extension", ignoreCase = true)) {
            "Report artifact file extension does not match its MIME type."
        }

        val shareDirectory =
            File(
                activity.cacheDir,
                SHARE_CACHE_DIRECTORY,
            )

        check(
            shareDirectory.exists() ||
                shareDirectory.mkdirs()
        ) {
            "Could not create dedicated report-share cache."
        }

        val canonicalShareDirectory =
            shareDirectory.canonicalFile
        val canonicalCacheRoot =
            activity.cacheDir.canonicalFile

        check(
            canonicalShareDirectory.path.startsWith(
                canonicalCacheRoot.path + File.separator,
            )
        ) {
            "Report-share cache escaped app cache."
        }

        canonicalShareDirectory
            .listFiles()
            ?.filter { candidate ->
                candidate.isFile &&
                    REPORT_ARTIFACT_EXTENSIONS.contains(
                        candidate.extension.lowercase(),
                    )
            }
            ?.forEach { candidate ->
                candidate.delete()
            }

        val file =
            File(
                canonicalShareDirectory,
                suggestedName,
            ).canonicalFile

        check(file.parentFile == canonicalShareDirectory) {
            "Report-share file escaped dedicated cache."
        }

        val actualSha256: String
        val uri: Uri

        try {
            file.writeBytes(bytes)

            check(file.length() == bytes.size.toLong()) {
                "Report-share cache file size mismatch."
            }

            actualSha256 = sha256(file).lowercase()

            check(actualSha256 == expectedSha256) {
                "Report-share cache SHA-256 mismatch."
            }

            uri =
                FileProvider.getUriForFile(
                    activity,
                    "${activity.packageName}.p007.fileprovider",
                    file,
                )

            check(uri.scheme == "content") {
                "FileProvider did not return a content URI for report share."
            }

            check(
                uri.authority ==
                    "${activity.packageName}.p007.fileprovider"
            ) {
                "Unexpected FileProvider authority for report share."
            }
        } catch (error: Throwable) {
            file.delete()
            throw error
        }

        val shareIntent =
            Intent(Intent.ACTION_SEND).apply {
                type = mimeType
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                clipData =
                    ClipData.newRawUri(
                        "qurani_report_artifact_share",
                        uri,
                    )
            }

        val chooser =
            Intent.createChooser(
                shareIntent,
                                if (mimeType == REPORT_PDF_MIME_TYPE) {
                    "مشاركة ملف PDF المعتمد"
                } else {
                    "مشاركة ملف Excel المعتمد"
                },

            ).apply {
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

        pendingReportArtifactFile = file
        reportArtifactPauseSeen = false

        try {
            activity.startActivity(chooser)
        } catch (error: Throwable) {
            pendingReportArtifactFile = null
            reportArtifactPauseSeen = false
            file.delete()
            throw error
        }

        return mapOf(
            "launched" to true,
            "action" to Intent.ACTION_SEND,
            "mimeType" to mimeType,
            "uri" to uri.toString(),
            "authority" to uri.authority,
            "scheme" to uri.scheme,
            "fileName" to file.name,
            "bytes" to file.length(),
            "sha256" to actualSha256,
            "chooser" to true,
        )
    }

    private fun shareImoProbe(): Map<String, Any?> {
        val probe = createShareProbe()
        beginExternal(KIND_IMO)
        P007ChooserSelectionStore.clear(KIND_IMO)

        val shareIntent =
            Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_STREAM, probe.uri)
                putExtra(
                    Intent.EXTRA_TEXT,
                    "Qurani P0-07 FileProvider share probe",
                )
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                clipData =
                    ClipData.newRawUri(
                        "qurani_p0_07_probe",
                        probe.uri,
                    )
            }

        startChooser(
            kind = KIND_IMO,
            targetIntent = shareIntent,
            chooserTitle = "P0-07: اختر imo فقط",
            requestCode = REQUEST_IMO_CHOOSER,
        )

        return mapOf(
            "launched" to true,
            "kind" to KIND_IMO,
            "uri" to probe.uri.toString(),
            "authority" to probe.uri.authority,
            "scheme" to probe.uri.scheme,
            "fileName" to probe.file.name,
            "bytes" to probe.file.length(),
            "sha256" to sha256(probe.file),
            "dedicatedShareCache" to probe.shareDirectory.canonicalPath,
            "cacheRoot" to activity.cacheDir.canonicalPath,
        )
    }

    private fun openParentWhatsApp(
        call: MethodCall,
    ): Map<String, Any?> {
        val recipient =
            requireParentFollowUpRecipient(call, "recipient")
        val message =
            requireParentFollowUpText(call, "message")

        beginExternal(KIND_WHATSAPP)
        P007ChooserSelectionStore.clear(KIND_WHATSAPP)

        val digits = recipient.removePrefix("+")
        val uri =
            Uri.parse("https://wa.me/$digits")
                .buildUpon()
                .appendQueryParameter("text", message)
                .build()

        val intent =
            Intent(
                Intent.ACTION_VIEW,
                uri,
            )

        try {
            activity.startActivity(intent)
        } catch (error: ActivityNotFoundException) {
            resetFailedLaunch(KIND_WHATSAPP)
            throw error
        }

        return mapOf(
            "launched" to true,
            "kind" to KIND_WHATSAPP,
            "action" to Intent.ACTION_VIEW,
            "uriScheme" to (uri.scheme ?: ""),
            "recipient" to recipient,
        )
    }

    private fun openParentSms(
        call: MethodCall,
    ): Map<String, Any?> {
        val recipient =
            requireParentFollowUpRecipient(call, "recipient")
        val message =
            requireParentFollowUpText(call, "message")

        beginExternal(KIND_SMS)

        val uri =
            Uri.fromParts(
                "smsto",
                recipient,
                null,
            )

        val intent =
            Intent(
                Intent.ACTION_SENDTO,
                uri,
            ).apply {
                putExtra("sms_body", message)
            }

        try {
            activity.startActivity(intent)
        } catch (error: ActivityNotFoundException) {
            resetFailedLaunch(KIND_SMS)
            throw error
        }

        return mapOf(
            "launched" to true,
            "kind" to KIND_SMS,
            "action" to Intent.ACTION_SENDTO,
            "uriScheme" to "smsto",
            "recipient" to recipient,
            "directSendPermissionRequired" to false,
        )
    }

    private fun requireParentFollowUpText(
        call: MethodCall,
        key: String,
    ): String {
        val value =
            call.argument<String>(key)?.trim()
                ?: throw IllegalArgumentException(
                    "Missing $key.",
                )

        require(value.isNotEmpty()) {
            "$key must not be blank."
        }

        return value
    }

    private fun requireParentFollowUpRecipient(
        call: MethodCall,
        key: String,
    ): String {
        val recipient =
            requireParentFollowUpText(call, key)

        require(
            Regex("^\\+[0-9]{8,15}$")
                .matches(recipient),
        ) {
            "Recipient must be a normalized E.164 number."
        }

        return recipient
    }
    private fun shareWhatsAppText(): Map<String, Any?> {
        beginExternal(KIND_WHATSAPP)
        P007ChooserSelectionStore.clear(KIND_WHATSAPP)

        val shareIntent =
            Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(
                    Intent.EXTRA_TEXT,
                    "قرآني P0-07 WhatsApp Intent probe - رسالة اختبار فقط.",
                )
            }

        startChooser(
            kind = KIND_WHATSAPP,
            targetIntent = shareIntent,
            chooserTitle = "P0-07: اختر WhatsApp فقط",
            requestCode = REQUEST_WHATSAPP_CHOOSER,
        )

        return mapOf(
            "launched" to true,
            "kind" to KIND_WHATSAPP,
            "action" to Intent.ACTION_SEND,
            "mime" to "text/plain",
        )
    }

    private fun openSmsComposer(): Map<String, Any?> {
        beginExternal(KIND_SMS)

        val smsIntent =
            Intent(
                Intent.ACTION_SENDTO,
                Uri.parse("smsto:"),
            ).apply {
                putExtra(
                    "sms_body",
                    "قرآني P0-07 SMS Intent probe - لا ترسل هذه الرسالة.",
                )
            }

        try {
            activity.startActivity(smsIntent)
        } catch (error: ActivityNotFoundException) {
            resetFailedLaunch(KIND_SMS)
            throw error
        }

        return mapOf(
            "launched" to true,
            "kind" to KIND_SMS,
            "action" to Intent.ACTION_SENDTO,
            "uriScheme" to "smsto",
            "directSendPermissionRequired" to false,
        )
    }

    private fun startChooser(
        kind: String,
        targetIntent: Intent,
        chooserTitle: String,
        requestCode: Int,
    ) {
        val callbackIntent =
            Intent(
                activity,
                P007ChooserReceiver::class.java,
            ).apply {
                putExtra(
                    P007ChooserReceiver.EXTRA_KIND,
                    kind,
                )
            }

        val pendingIntentFlags =
            PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.FLAG_MUTABLE
                } else {
                    0
                }

        val pendingIntent =
            PendingIntent.getBroadcast(
                activity,
                requestCode,
                callbackIntent,
                pendingIntentFlags,
            )

        val chooser =
            Intent.createChooser(
                targetIntent,
                chooserTitle,
                pendingIntent.intentSender,
            )

        try {
            activity.startActivity(chooser)
        } catch (error: ActivityNotFoundException) {
            resetFailedLaunch(kind)
            throw error
        }
    }

    private fun beginExternal(kind: String) {
        val state =
            checkNotNull(states[kind]) {
                "Unknown P0-07 external action kind: $kind"
            }

        state.launchCount += 1
        state.pending = true
        state.pauseSeen = false
        state.returned = false
    }

    private fun resetFailedLaunch(kind: String) {
        val state = states[kind] ?: return
        state.pending = false
        state.pauseSeen = false
        state.returned = false
    }

    private fun getState(): Map<String, Any?> =
        mapOf(
            "imo" to stateMap(KIND_IMO),
            "whatsapp" to stateMap(KIND_WHATSAPP),
            "sms" to stateMap(KIND_SMS),
        )

    private fun stateMap(kind: String): Map<String, Any?> {
        val state =
            checkNotNull(states[kind]) {
                "Unknown P0-07 external action kind: $kind"
            }

        return mapOf(
            "launchCount" to state.launchCount,
            "pending" to state.pending,
            "pauseSeen" to state.pauseSeen,
            "returned" to state.returned,
            "chosenComponent" to
                P007ChooserSelectionStore.selectedComponent(kind),
        )
    }

    private fun cleanupShareProbe(): Map<String, Any?> {
        val shareDirectory =
            File(
                activity.cacheDir,
                SHARE_CACHE_DIRECTORY,
            )

        val existedBefore = shareDirectory.exists()
        val filesBefore =
            if (shareDirectory.exists()) {
                shareDirectory
                    .walkTopDown()
                    .filter { it.isFile }
                    .count()
            } else {
                0
            }

        val deleted =
            if (!shareDirectory.exists()) {
                true
            } else {
                shareDirectory.deleteRecursively()
            }

        return mapOf(
            "existedBefore" to existedBefore,
            "filesBefore" to filesBefore,
            "deleted" to deleted,
            "existsAfter" to shareDirectory.exists(),
        )
    }

    private data class ShareProbe(
        val shareDirectory: File,
        val file: File,
        val uri: Uri,
    )

    private fun createShareProbe(): ShareProbe {
        val shareDirectory =
            File(
                activity.cacheDir,
                SHARE_CACHE_DIRECTORY,
            )

        check(
            shareDirectory.exists() ||
                shareDirectory.mkdirs()
        ) {
            "Could not create dedicated P0-07 share cache."
        }

        val canonicalShareDirectory =
            shareDirectory.canonicalFile

        val canonicalCacheRoot =
            activity.cacheDir.canonicalFile

        check(
            canonicalShareDirectory.path.startsWith(
                canonicalCacheRoot.path + File.separator,
            )
        ) {
            "P0-07 share directory escaped app cache."
        }

        val file =
            File(
                canonicalShareDirectory,
                SHARE_PROBE_FILE_NAME,
            )

        file.writeText(
            SHARE_PROBE_CONTENT,
            Charsets.UTF_8,
        )

        val uri =
            FileProvider.getUriForFile(
                activity,
                "${activity.packageName}.p007.fileprovider",
                file,
            )

        check(uri.scheme == "content") {
            "FileProvider did not return a content URI."
        }

        check(
            uri.authority ==
                "${activity.packageName}.p007.fileprovider"
        ) {
            "Unexpected P0-07 FileProvider authority."
        }

        return ShareProbe(
            shareDirectory = canonicalShareDirectory,
            file = file,
            uri = uri,
        )
    }

    private fun sha256(file: File): String {
        val digest =
            MessageDigest.getInstance("SHA-256")

        file.inputStream().use { input ->
            val buffer = ByteArray(8 * 1024)

            while (true) {
                val read = input.read(buffer)
                if (read < 0) {
                    break
                }

                if (read > 0) {
                    digest.update(
                        buffer,
                        0,
                        read,
                    )
                }
            }
        }

        return digest
            .digest()
            .joinToString(separator = "") { byte ->
                "%02X".format(byte)
            }
    }

    companion object {
        const val CHANNEL =
            "qurani/p0_07_external_sharing"

        private const val KIND_IMO = "imo"
        private const val KIND_WHATSAPP = "whatsapp"
        private const val KIND_SMS = "sms"

        private const val SHARE_CACHE_DIRECTORY =
            "p0_07_share"

        private const val SHARE_PROBE_FILE_NAME =
            "p0_07_imo_probe.txt"

        private const val SHARE_PROBE_CONTENT =
            "QURANI-P0-07-PRIVATE-SHARE-PROBE\n" +
                "DEDICATED_CACHE_ONLY\n" +
                "NO_PRIVATE_SPACE_EXPOSURE\n"

        private const val REPORT_XLSX_MIME_TYPE =
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

        private const val REPORT_PDF_MIME_TYPE =
            "application/pdf"

        private val REPORT_ARTIFACT_EXTENSIONS =
            setOf("xlsx", "pdf")

        @Volatile
        private var reportArtifactStartupCleanupComplete = false

        private const val REQUEST_IMO_CHOOSER = 7001
        private const val REQUEST_WHATSAPP_CHOOSER = 7002
    }
}