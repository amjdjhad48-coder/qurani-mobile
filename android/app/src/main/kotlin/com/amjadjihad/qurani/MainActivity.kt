package com.amjadjihad.qurani

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val p003KeystoreBridge = P003KeystoreBridge()
    private val quraniKeystoreBridge = QuraniKeystoreBridge()
    private lateinit var p006SafBridge: P006SafBridge
    private lateinit var p007ExternalSharingBridge: P007ExternalSharingBridge

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            P003KeystoreBridge.CHANNEL,
        ).setMethodCallHandler { call, result ->
            p003KeystoreBridge.handle(call, result)
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            QuraniKeystoreBridge.CHANNEL,
        ).setMethodCallHandler { call, result ->
            quraniKeystoreBridge.handle(call, result)
        }

        val p004AudioBridge = P004AudioBridge(applicationContext)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            P004AudioBridge.CHANNEL,
        ).setMethodCallHandler { call, result ->
            p004AudioBridge.handle(call, result)
        }

        p006SafBridge = P006SafBridge(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            P006SafBridge.CHANNEL,
        ).setMethodCallHandler { call, result ->
            p006SafBridge.handle(call, result)
        }

        p007ExternalSharingBridge = P007ExternalSharingBridge(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            P007ExternalSharingBridge.CHANNEL,
        ).setMethodCallHandler { call, result ->
            p007ExternalSharingBridge.handle(call, result)
        }
    }

    override fun onPause() {
        if (::p007ExternalSharingBridge.isInitialized) {
            p007ExternalSharingBridge.onHostPaused()
        }

        super.onPause()
    }

    override fun onResume() {
        super.onResume()

        if (::p007ExternalSharingBridge.isInitialized) {
            p007ExternalSharingBridge.onHostResumed()
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ) {
        if (
            ::p006SafBridge.isInitialized &&
            p006SafBridge.onActivityResult(
                requestCode,
                resultCode,
                data,
            )
        ) {
            return
        }

        super.onActivityResult(
            requestCode,
            resultCode,
            data,
        )
    }
}