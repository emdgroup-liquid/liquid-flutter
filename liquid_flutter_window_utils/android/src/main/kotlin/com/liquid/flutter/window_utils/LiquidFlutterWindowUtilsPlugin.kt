package com.liquid.flutter.window_utils

import android.app.Activity
import android.graphics.Rect as AndroidRect
import android.os.Build
import android.util.Log
import android.view.View
import android.view.WindowInsets
import androidx.core.view.ViewCompat
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
        return try {
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

            maxRadius
        } catch (e: Exception) {
            Log.e("LiquidFlutterWindowUtils", "Failed to get screen radius", e)
            0.0
        }
    }

    override fun setSystemGestureExclusionRects(rects: List<Rect>) {
        val currentActivity = activity
        if (currentActivity == null) {
            Log.w("LiquidFlutterWindowUtils", "Cannot set system gesture exclusion rects: activity is null")
            return
        }

        // Check if API level is sufficient (Android 10/API 29+)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            Log.w("LiquidFlutterWindowUtils", "setSystemGestureExclusionRects requires Android 10 (API 29+), current: ${Build.VERSION.SDK_INT}")
            return
        }

        setSystemGestureExclusionRectsApi29(currentActivity, rects)
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun setSystemGestureExclusionRectsApi29(activity: Activity, rects: List<Rect>) {
        try {
            val rootView = activity.window.decorView.rootView
            if (rootView == null) {
                Log.e("LiquidFlutterWindowUtils", "Cannot set system gesture exclusion rects: rootView is null")
                return
            }

            // Convert Pigeon Rect objects to Android Rect objects
            // Note: Coordinates from Flutter's localToGlobal are in physical pixels (device pixels),
            // which is what Android's setSystemGestureExclusionRects expects.
            // The coordinates should be relative to the view (rootView in this case).
            // Since we're using screen coordinates from localToGlobal, we need to convert them
            // to view-relative coordinates by subtracting the view's position.
            val viewLocation = IntArray(2)
            rootView.getLocationOnScreen(viewLocation)
            val viewX = viewLocation[0]
            val viewY = viewLocation[1]

            val androidRects = rects.map { rect ->
                AndroidRect(
                    (rect.left - viewX).toInt(),
                    (rect.top - viewY).toInt(),
                    (rect.right - viewX).toInt(),
                    (rect.bottom - viewY).toInt(),
                )
            }

            ViewCompat.setSystemGestureExclusionRects(rootView, androidRects)
            Log.d("LiquidFlutterWindowUtils", "Set ${androidRects.size} system gesture exclusion rects")
        } catch (e: IllegalStateException) {
            Log.e("LiquidFlutterWindowUtils", "Failed to set system gesture exclusion rects: view not attached", e)
        } catch (e: IllegalArgumentException) {
            Log.e("LiquidFlutterWindowUtils", "Failed to set system gesture exclusion rects: invalid rect coordinates", e)
        } catch (e: Exception) {
            Log.e("LiquidFlutterWindowUtils", "Failed to set system gesture exclusion rects", e)
        }
    }
}

