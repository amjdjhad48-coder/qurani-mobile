package com.amjadjihad.qurani

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent

internal object P007ChooserSelectionStore {
    private val selectedComponents = mutableMapOf<String, String>()

    @Synchronized
    fun clear(kind: String) {
        selectedComponents.remove(kind)
    }

    @Synchronized
    fun record(kind: String, component: ComponentName?) {
        if (component == null) {
            selectedComponents.remove(kind)
            return
        }

        selectedComponents[kind] = component.flattenToString()
    }

    @Synchronized
    fun selectedComponent(kind: String): String? = selectedComponents[kind]
}

class P007ChooserReceiver : BroadcastReceiver() {
    @Suppress("DEPRECATION")
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        val kind = intent.getStringExtra(EXTRA_KIND) ?: return
        val component =
            intent.getParcelableExtra(Intent.EXTRA_CHOSEN_COMPONENT) as? ComponentName

        P007ChooserSelectionStore.record(
            kind = kind,
            component = component,
        )
    }

    companion object {
        const val EXTRA_KIND =
            "com.amjadjihad.qurani.p0_07.EXTRA_KIND"
    }
}