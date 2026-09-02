package com.amjadjihad.qurani

import android.content.Context
import android.content.Intent
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.Build
import android.os.Process
import android.os.StatFs
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.ByteBuffer

class P004AudioBridge(
    private val context: Context,
) {
    fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "getRootPath" -> result.success(getRootPath())
                "startForegroundService" -> {
                    startForegroundService()
                    result.success(true)
                }
                "stopForegroundService" -> {
                    stopForegroundService()
                    result.success(true)
                }
                "freeBytes" -> {
                    val path = requireString(call, "path")
                    result.success(freeBytes(path))
                }
                "remuxAdtsToM4a" -> {
                    val parts = requireStringList(call, "parts")
                    val output = requireString(call, "output")
                    result.success(remuxAdtsToM4a(parts, output))
                }
                "validateM4a" -> {
                    val path = requireString(call, "path")
                    result.success(validateM4a(path))
                }
                "killProcessForCrashTest" -> {
                    result.success(true)
                    android.os.Handler(context.mainLooper).postDelayed(
                        { Process.killProcess(Process.myPid()) },
                        150,
                    )
                }
                else -> result.notImplemented()
            }
        } catch (error: Throwable) {
            result.error(
                "P0_04_AUDIO_ERROR",
                error.message ?: error.javaClass.simpleName,
                error.javaClass.name,
            )
        }
    }

    private fun getRootPath(): String {
        val root = File(
            context.noBackupFilesDir,
            "qurani_p0_spikes/p0_04_audio",
        )
        check(root.exists() || root.mkdirs()) {
            "Could not create P0-04 no-backup directory."
        }
        return root.absolutePath
    }

    private fun startForegroundService() {
        val intent = Intent(context, P004AudioForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    private fun stopForegroundService() {
        context.stopService(
            Intent(context, P004AudioForegroundService::class.java),
        )
    }

    private fun freeBytes(path: String): Long {
        val file = File(path)
        val stat = StatFs(file.absolutePath)
        return stat.availableBytes
    }

    private fun remuxAdtsToM4a(
        parts: List<String>,
        output: String,
    ): Map<String, Any?> {
        require(parts.isNotEmpty()) { "No AAC parts supplied." }

        val outputFile = File(output)
        outputFile.parentFile?.mkdirs()
        if (outputFile.exists()) {
            check(outputFile.delete()) { "Could not replace output M4A." }
        }

        val combined = File(
            outputFile.parentFile,
            "${outputFile.nameWithoutExtension}.combined.aac",
        )

        if (combined.exists()) {
            check(combined.delete()) { "Could not replace combined AAC staging file." }
        }

        try {
            FileOutputStream(combined).use { destination ->
                parts.forEach { partPath ->
                    val part = File(partPath)
                    require(part.isFile && part.length() > 0L) {
                        "Invalid AAC part: $partPath"
                    }

                    FileInputStream(part).use { input ->
                        input.copyTo(destination)
                    }
                }
                destination.fd.sync()
            }

            val extractor = MediaExtractor()
            var muxer: MediaMuxer? = null

            try {
                extractor.setDataSource(combined.absolutePath)

                var sourceTrack = -1
                for (index in 0 until extractor.trackCount) {
                    val format = extractor.getTrackFormat(index)
                    val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
                    if (mime.startsWith("audio/")) {
                        sourceTrack = index
                        break
                    }
                }

                check(sourceTrack >= 0) { "No audio track found in ADTS input." }

                extractor.selectTrack(sourceTrack)
                val sourceFormat = extractor.getTrackFormat(sourceTrack)

                muxer = MediaMuxer(
                    outputFile.absolutePath,
                    MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4,
                )

                val targetTrack = muxer.addTrack(sourceFormat)
                muxer.start()

                val maxInput = if (sourceFormat.containsKey(MediaFormat.KEY_MAX_INPUT_SIZE)) {
                    sourceFormat.getInteger(MediaFormat.KEY_MAX_INPUT_SIZE)
                } else {
                    1024 * 1024
                }.coerceAtLeast(64 * 1024)

                val buffer = ByteBuffer.allocate(maxInput)
                val info = MediaCodec.BufferInfo()
                var sampleCount = 0

                while (true) {
                    buffer.clear()
                    val size = extractor.readSampleData(buffer, 0)
                    if (size < 0) {
                        break
                    }

                    info.offset = 0
                    info.size = size
                    info.presentationTimeUs = extractor.sampleTime.coerceAtLeast(0L)
                    info.flags = extractor.sampleFlags

                    muxer.writeSampleData(targetTrack, buffer, info)
                    sampleCount += 1
                    extractor.advance()
                }

                check(sampleCount > 0) { "No AAC samples were muxed." }
            } finally {
                try {
                    muxer?.stop()
                } catch (_: Throwable) {
                }
                try {
                    muxer?.release()
                } catch (_: Throwable) {
                }
                extractor.release()
            }

            check(outputFile.isFile && outputFile.length() > 0L) {
                "M4A output was not created."
            }

            return validateM4a(outputFile.absolutePath)
        } finally {
            if (combined.exists()) {
                combined.delete()
            }
        }
    }

    private fun validateM4a(path: String): Map<String, Any?> {
        val file = File(path)
        require(file.isFile && file.length() > 0L) {
            "M4A file missing or empty: $path"
        }

        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(file.absolutePath)

            var audioFormat: MediaFormat? = null

            for (index in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(index)
                val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
                if (mime.startsWith("audio/")) {
                    audioFormat = format
                    break
                }
            }

            val format = checkNotNull(audioFormat) {
                "No audio track found in M4A."
            }

            val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
            val sampleRate = if (format.containsKey(MediaFormat.KEY_SAMPLE_RATE)) {
                format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            } else {
                -1
            }
            val channelCount = if (format.containsKey(MediaFormat.KEY_CHANNEL_COUNT)) {
                format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            } else {
                -1
            }
            val durationUs = if (format.containsKey(MediaFormat.KEY_DURATION)) {
                format.getLong(MediaFormat.KEY_DURATION)
            } else {
                -1L
            }

            require(mime == "audio/mp4a-latm") {
                "Unexpected M4A audio MIME: $mime"
            }
            require(sampleRate == 44100) {
                "Unexpected sample rate: $sampleRate"
            }
            require(channelCount == 1) {
                "Unexpected channel count: $channelCount"
            }

            return mapOf(
                "path" to file.absolutePath,
                "bytes" to file.length(),
                "mime" to mime,
                "sampleRate" to sampleRate,
                "channelCount" to channelCount,
                "durationUs" to durationUs,
            )
        } finally {
            extractor.release()
        }
    }

    private fun requireString(
        call: MethodCall,
        name: String,
    ): String {
        return call.argument<String>(name)
            ?.takeIf { it.isNotBlank() }
            ?: error("Missing argument: $name")
    }

    private fun requireStringList(
        call: MethodCall,
        name: String,
    ): List<String> {
        val values = call.argument<List<*>>(name)
            ?: error("Missing argument: $name")

        return values.map {
            (it as? String)?.takeIf(String::isNotBlank)
                ?: error("Invalid $name entry.")
        }
    }

    companion object {
        const val CHANNEL = "qurani/p0_04_audio"
    }
}