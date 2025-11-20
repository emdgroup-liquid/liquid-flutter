package com.liquid.flutter.window_utils

import android.app.Activity
import android.os.Build
import android.view.WindowInsets
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** LiquidFlutterWindowUtilsPlugin */
class LiquidFlutterWindowUtilsPlugin :
    FlutterPlugin,
    ActivityAware,
    WindowUtilsApi {
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        WindowUtilsApi.setUp(
            flutterPluginBinding.binaryMessenger,
            this,
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        WindowUtilsApi.setUp(binding.binaryMessenger, null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun setWindowSize(width: Long, height: Long): Boolean {
        // Not implemented for Android
        return false
    }

    override fun setWindowTitle(title: String) {
        // Not implemented for Android
    }

    override fun setWindowPosition(x: Long, y: Long): Boolean {
        // Not implemented for Android
        return false
    }

    override fun startDragging() {
        // Not implemented for Android
    }

    override fun configureWindow() {
        // Not implemented for Android
    }

    override fun closeWindow() {
        // Not implemented for Android
    }

    override fun minimizeWindow() {
        // Not implemented for Android
    }

    override fun maximizeWindow() {
        // Not implemented for Android
    }

    override fun isWindowMaximized(): Boolean {
        // Not implemented for Android
        return false
    }

    override fun getWindowState(): WindowState {
        // Not implemented for Android
        return WindowState(
            x = 0,
            y = 0,
            width = 0,
            height = 0,
            isMaximized = false,
            isMinimized = false,
        )
    }

    override fun getScreenRadius(): Double {
        val currentActivity = activity ?: return 0.0

        // Check if API level is sufficient (Android S/API 31+)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return 0.0
        }

        return getScreenRadiusApi31(currentActivity)
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun getScreenRadiusApi31(activity: Activity): Double {
        try {
            val rootView = activity.window.decorView.rootView
            val insets = rootView.rootWindowInsets ?: return 0.0

            var maxRadius = 0.0

            // Check all four corners using position constants (0-3)
            // POSITION_TOP_LEFT = 0, POSITION_TOP_RIGHT = 1,
            // POSITION_BOTTOM_RIGHT = 2, POSITION_BOTTOM_LEFT = 3
            val cornerPositions = listOf(0, 1, 2, 3)

            for (position in cornerPositions) {
                val roundedCorner = insets.getRoundedCorner(position)
                roundedCorner?.let {
                    val radius = it.radius.toDouble()
                    if (radius > maxRadius) {
                        maxRadius = radius
                    }
                }
            }

            return maxRadius
        } catch (e: Exception) {
            // Return 0.0 if there's any error accessing the API
            return 0.0
        }
    }
}

