package com.example.plug_in_kotlin

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

class PlugInKotlinPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
    private lateinit var channel: MethodChannel

    private var context: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PLUG_IN)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            GET_PLATFORM_VERSION -> getPlatformVersion(result)
            INITIALIZE_LOCATOR_PLUGIN -> initializeLocatorPlugin(result)
            CHECK_PERMISSIONS -> checkPermissions(result)
            REQUEST_PERMISSIONS -> requestPermissions(result)
            else -> result.notImplemented()
        }
    }

    private fun getPlatformVersion(result: MethodChannel.Result) {
        result.success(ANDROID + Build.VERSION.RELEASE)
    }

    private fun initializeLocatorPlugin(result: MethodChannel.Result) {
        if (checkPermissionIsDenied()) {
            result.success(false)
        } else {
            result.success(true)
        }
    }

    private fun checkPermissionIsDenied(): Boolean {
        var permitted = false
        context?.run {
            permitted = ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
        }
        return permitted
    }

    private fun checkPermissions(result: MethodChannel.Result) {
        result.success(checkPermissionIsDenied())
    }

    private fun requestPermissions(result: MethodChannel.Result) {
        context?.run {
            activity?.let {
                ActivityCompat.requestPermissions(it, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION), REQUEST_ACCESS_FINE)
            }
        }
        result.success(null)
    }

    private fun stopLocatorPlugin(result: MethodChannel.Result) {
        if (checkPermissionIsDenied()) {
            result.success(false)
        } else {
            result.success(true)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return false
    }

    companion object {
        private const val REQUEST_ACCESS_FINE = 0
        private const val PLUG_IN = "plug_in"
        private const val GET_PLATFORM_VERSION = "getPlatformVersion"
        private const val INITIALIZE_LOCATOR_PLUGIN = "initializeLocatorPlugin"
        private const val CHECK_PERMISSIONS = "checkPermissions"
        private const val REQUEST_PERMISSIONS = "requestPermissions"
        private const val ANDROID = "Android "
    }
}
