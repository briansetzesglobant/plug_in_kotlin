package com.example.plug_in_kotlin

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

class PlugInKotlinPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
    private lateinit var channel: MethodChannel

    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationRequest: LocationRequest
    private lateinit var locationCallback: LocationCallback

    private lateinit var locationEventSource: EventChannel.EventSink
    private lateinit var locationEventChannel: EventChannel

    private var locationListener: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            if (events != null) {
                locationEventSource = events
            }
        }

        override fun onCancel(arguments: Any?) {
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PLUG_IN)
        channel.setMethodCallHandler(this)
        locationEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, LOCATION_EVENT_CHANNEL)
        locationEventChannel.setStreamHandler(locationListener)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            GET_PLATFORM_VERSION -> getPlatformVersion(result)
            INITIALIZE_LOCATOR_PLUGIN -> initializeLocatorPlugin(result)
            CHECK_PERMISSIONS -> checkPermissions(result)
            REQUEST_PERMISSIONS -> requestPermissions(result)
            RETURN_LAST_COORDINATES -> returnLastCoordinates(result)
            STOP_LOCATOR_PLUGIN -> stopLocatorPlugin(result)
            else -> result.notImplemented()
        }
    }

    private fun getPlatformVersion(result: MethodChannel.Result) {
        result.success(ANDROID + Build.VERSION.RELEASE)
    }

    private fun initializeLocatorPlugin(result: MethodChannel.Result) {
        fusedLocationClient = activity.let {
            LocationServices.getFusedLocationProviderClient(it)
        }
        if (checkPermissionIsDenied()) {
            result.success(false)
        } else {
            locationRequest = LocationRequest.create()
            locationRequest.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
            locationRequest.interval = INTERVAL
            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    val position: MutableMap<String, Any> = mutableMapOf()
                    if (locationResult != null) {
                        position[LATITUDE] = locationResult.lastLocation.latitude
                        position[LONGITUDE] = locationResult.lastLocation.longitude
                    } else {
                        position[STATUS] = NULL_LOCATION
                    }
                    locationEventSource.success(position)
                }
            }
            result.success(true)
        }
    }

    private fun checkPermissionIsDenied(): Boolean {
        var permitted = false
        context.run {
            permitted = ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
        }
        return permitted
    }

    private fun checkPermissions(result: MethodChannel.Result) {
        result.success(checkPermissionIsDenied())
    }

    private fun requestPermissions(result: MethodChannel.Result) {
        context.run {
            activity.let {
                ActivityCompat.requestPermissions(it, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION), REQUEST_ACCESS_FINE)
            }
        }
        result.success(null)
    }

    private fun returnLastCoordinates(result: MethodChannel.Result) {
        val position: MutableMap<String, Any> = mutableMapOf()
        activity.let {
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null)
            fusedLocationClient.lastLocation?.addOnSuccessListener(it) { location: Location? ->
                if (location != null) {
                    position[LATITUDE] = location.latitude
                    position[LONGITUDE] = location.longitude
                } else {
                    position[STATUS] = NULL_LOCATION
                }
                result.success(position)
            }
            fusedLocationClient.lastLocation?.addOnFailureListener {
                position[STATUS] = NULL_LOCATION
                result.success(position)
            }
        }
    }

    private fun stopLocatorPlugin(result: MethodChannel.Result) {
        context.run {
            fusedLocationClient.removeLocationUpdates(locationCallback)
        }
        result.success(true)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return false
    }

    companion object {
        private const val PLUG_IN = "plug_in"
        private const val LOCATION_EVENT_CHANNEL = "location_event_channel"
        private const val ANDROID = "Android "
        private const val GET_PLATFORM_VERSION = "getPlatformVersion"
        private const val INITIALIZE_LOCATOR_PLUGIN = "initializeLocatorPlugin"
        private const val CHECK_PERMISSIONS = "checkPermissions"
        private const val REQUEST_PERMISSIONS = "requestPermissions"
        private const val RETURN_LAST_COORDINATES = "returnLastCoordinates"
        private const val STOP_LOCATOR_PLUGIN = "stopLocatorPlugin"
        private const val INTERVAL = 2000L
        private const val LATITUDE = "latitude"
        private const val LONGITUDE = "longitude"
        private const val STATUS = "status"
        private const val NULL_LOCATION = "null location"
        private const val REQUEST_ACCESS_FINE = 0
    }
}
