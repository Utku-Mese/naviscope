package com.naviscope.naviscope

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.GnssStatus
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

/**
 * GnssTelemetryPlugin
 *
 * Bridges Android LocationManager + GnssStatus.Callback to Flutter via:
 *   - MethodChannel: naviscope/gnss  (control + capability detection)
 *   - EventChannel:  naviscope/telemetry_stream  (live TelemetryFrame stream)
 *
 * Each emitted event is a Map<String, Any?> matching the structure expected by
 * TelemetryFrame.fromMap() on the Dart side.
 */
class GnssTelemetryPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    private lateinit var context: Context
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var locationManager: LocationManager? = null
    private var gnssCallback: GnssStatus.Callback? = null
    private var locationListener: LocationListener? = null

    // Latest data — merged on each update
    private var latestLocation: Location? = null
    private var latestGnssStatus: GnssStatus? = null

    /** Last location map we sent so GNSS-only callbacks can still emit frames. */
    private var lastEmittedLocationMap: Map<String, Any?>? = null

    /** Avoid duplicate LocationManager registrations when both MethodChannel
     *  and EventChannel trigger [startListening]. */
    private var isListening = false

    // ── FlutterPlugin ─────────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        locationManager =
            context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

        methodChannel = MethodChannel(binding.binaryMessenger, "naviscope/gnss")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "naviscope/telemetry_stream")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopListening()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    // ── MethodChannel.MethodCallHandler ──────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getCapabilities" -> result.success(buildCapabilities())
            "startListening" -> {
                startListening()
                result.success(null)
            }
            "stopListening" -> {
                stopListening()
                result.success(null)
            }
            "requestPermission" -> {
                // Runtime permission UX is driven from Dart (permission_handler).
                // Keep this for diagnostics / callers that only need current status.
                val granted = hasLocationPermission()
                result.success(if (granted) "granted" else "denied")
            }
            else -> result.notImplemented()
        }
    }

    // ── EventChannel.StreamHandler ────────────────────────────────────────────

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        eventSink = sink
        startListening()
    }

    override fun onCancel(arguments: Any?) {
        stopListening()
        eventSink = null
    }

    // ── Location + GNSS setup ─────────────────────────────────────────────────

    private fun startListening() {
        val lm = locationManager ?: return
        if (!hasLocationPermission()) return

        // Location updates are registered only once. GNSS is registered separately
        // so turning on precise location later (or a failed first registration)
        // can attach GnssStatus without this early-exiting whole method.
        if (!isListening) {
            isListening = true

            // Location updates — 1 Hz, 0 m distance filter
            locationListener = object : LocationListener {
                override fun onLocationChanged(location: Location) {
                    latestLocation = location
                    emitFrame()
                }
            }

            try {
                val listener = locationListener!!
                val looper = Looper.getMainLooper()
                if (lm.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                    lm.requestLocationUpdates(
                        LocationManager.GPS_PROVIDER,
                        1000L,
                        0f,
                        listener,
                        looper
                    )
                }
                if (lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                    lm.requestLocationUpdates(
                        LocationManager.NETWORK_PROVIDER,
                        1000L,
                        0f,
                        listener,
                        looper
                    )
                }
                // Delivers fixes when other apps or the fused stack obtain location
                // (helps emulators / indoor where GPS provider stays idle).
                try {
                    lm.requestLocationUpdates(
                        LocationManager.PASSIVE_PROVIDER,
                        1000L,
                        0f,
                        listener,
                        looper
                    )
                } catch (_: IllegalArgumentException) {
                }
            } catch (e: SecurityException) {
                isListening = false
                locationListener = null
                mainHandler.post { eventSink?.error("PERMISSION", e.message, null) }
                return
            }

            // Prime UI with last known fix while GPS warms up (emulator / cold start).
            mainHandler.post {
                ensureLastKnownLocation()
                emitFrame()
            }
        }

        registerGnssStatusIfNeeded()
    }

    /**
     * Idempotent: attaches [GnssStatus.Callback] when API + fine permission allow it.
     * Safe to call again after the user enables precise location in system settings.
     */
    private fun registerGnssStatusIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return
        if (!hasFineLocationPermission()) return
        if (gnssCallback != null) return
        val lm = locationManager ?: return

        gnssCallback = object : GnssStatus.Callback() {
            override fun onSatelliteStatusChanged(status: GnssStatus) {
                latestGnssStatus = status
                emitFrame()
            }
        }
        try {
            lm.registerGnssStatusCallback(gnssCallback!!, mainHandler)
        } catch (_: SecurityException) {
            gnssCallback = null
        } catch (_: Exception) {
            gnssCallback = null
        }
    }

    private fun stopListening() {
        if (!isListening) return
        isListening = false
        val lm = locationManager ?: return
        locationListener?.let {
            try { lm.removeUpdates(it) } catch (_: Exception) {}
        }
        locationListener = null

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            gnssCallback?.let {
                try { lm.unregisterGnssStatusCallback(it) } catch (_: Exception) {}
            }
            gnssCallback = null
        }
        latestLocation = null
        latestGnssStatus = null
        lastEmittedLocationMap = null
    }

    // ── Frame emission ────────────────────────────────────────────────────────

    private fun ensureLastKnownLocation() {
        if (latestLocation != null) return
        val lm = locationManager ?: return
        if (!hasLocationPermission()) return
        try {
            for (provider in listOf(
                LocationManager.GPS_PROVIDER,
                LocationManager.NETWORK_PROVIDER
            )) {
                if (latestLocation != null) break
                if (!lm.isProviderEnabled(provider)) continue
                latestLocation = lm.getLastKnownLocation(provider)
            }
        } catch (_: SecurityException) {
        }
    }

    private fun emitFrame() {
        ensureLastKnownLocation()
        val sink = eventSink ?: return
        val gnssMap = latestGnssStatus?.let { buildGnssMap(it) }

        val freshMap = latestLocation?.let { loc ->
            buildLocationMap(loc).also { lastEmittedLocationMap = it }
        }
        val locationMap = freshMap ?: lastEmittedLocationMap

        // Without any location anchor we cannot build a valid frame for Flutter.
        if (locationMap == null) return

        val frame = mutableMapOf<String, Any?>(
            "location" to locationMap,
            "gnss" to gnssMap
        )

        mainHandler.post { sink.success(frame) }
    }

    private fun buildLocationMap(loc: Location): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>(
            "latitude" to loc.latitude,
            "longitude" to loc.longitude,
            "timestamp" to loc.time,
            "source" to when (loc.provider) {
                LocationManager.GPS_PROVIDER -> "gps"
                LocationManager.NETWORK_PROVIDER -> "network"
                else -> "fused"
            }
        )
        if (loc.hasAltitude()) map["altitude"] = loc.altitude
        if (loc.hasSpeed()) map["speed"] = loc.speed.toDouble()
        if (loc.hasBearing()) map["heading"] = loc.bearing.toDouble()
        if (loc.hasAccuracy()) map["horizontalAccuracy"] = loc.accuracy.toDouble()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && loc.hasVerticalAccuracy()) {
            map["verticalAccuracy"] = loc.verticalAccuracyMeters.toDouble()
        }
        return map
    }

    /**
     * Many devices (often with fused / network-assisted location) report
     * [GnssStatus.usedInFix] always false even while CN0 and sky plot look healthy.
     * When the OS fix quality suggests a real GNSS lock, infer likely PVT sats from
     * signal strength so the UI matches pilot expectations.
     */
    @androidx.annotation.RequiresApi(Build.VERSION_CODES.N)
    private fun estimateUsedIndices(status: GnssStatus): Set<Int>? {
        val loc = latestLocation ?: return null
        if (!loc.hasAccuracy() || loc.accuracy > 38f) return null
        val n = status.satelliteCount
        if (n < 4) return null

        val byCn0 = (0 until n).sortedByDescending { status.getCn0DbHz(it) }
        val bestCn0 = status.getCn0DbHz(byCn0[0])
        if (bestCn0 < 18f) return null

        val strongSky = byCn0.filter {
            status.getCn0DbHz(it) >= 15f && status.getElevationDegrees(it) >= 8f
        }
        val pick = when {
            strongSky.size >= 4 -> strongSky.take(6)
            else -> byCn0.take(minOf(6, maxOf(4, n)))
        }
        return pick.toSet()
    }

    @androidx.annotation.RequiresApi(Build.VERSION_CODES.N)
    private fun buildGnssMap(status: GnssStatus): Map<String, Any?> {
        val n = status.satelliteCount
        val apiUsed = BooleanArray(n) { idx -> status.usedInFix(idx) }
        var usedCount = apiUsed.count { it }

        val inferred = if (usedCount == 0) estimateUsedIndices(status) else null
        val effectiveUsed = BooleanArray(n) { idx ->
            apiUsed[idx] || (inferred?.contains(idx) == true)
        }
        usedCount = effectiveUsed.count { it }

        val satellites = mutableListOf<Map<String, Any?>>()
        for (i in 0 until n) {
            val usedInFix = effectiveUsed[i]

            val sat = mutableMapOf<String, Any?>(
                "svid" to status.getSvid(i),
                "constellationType" to status.getConstellationType(i),
                "cn0DbHz" to status.getCn0DbHz(i).toDouble(),
                "azimuthDegrees" to status.getAzimuthDegrees(i).toDouble(),
                "elevationDegrees" to status.getElevationDegrees(i).toDouble(),
                "usedInFix" to usedInFix,
                "hasAlmanac" to status.hasAlmanacData(i),
                "hasEphemeris" to status.hasEphemerisData(i),
                "hasCn0" to (status.getCn0DbHz(i) > 0)
            )

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                status.hasCarrierFrequencyHz(i)
            ) {
                sat["carrierFrequencyHz"] = status.getCarrierFrequencyHz(i).toDouble()
            }

            satellites.add(sat)
        }

        // Infer fix type from used satellite count and location accuracy.
        val fixType = when {
            usedCount >= 4 && latestLocation?.hasAltitude() == true -> "fix3D"
            usedCount >= 3 -> "fix2D"
            usedCount > 0 -> "searching"
            status.satelliteCount > 0 -> "searching"
            else -> "none"
        }

        return mapOf(
            "satellites" to satellites,
            "satellitesVisible" to status.satelliteCount,
            "satellitesUsedInFix" to usedCount,
            "fixType" to fixType,
            "timestamp" to System.currentTimeMillis()
        )
    }

    // ── Capability detection ──────────────────────────────────────────────────

    private fun buildCapabilities(): Map<String, Any?> {
        val api = Build.VERSION.SDK_INT
        val hasGps = context.packageManager
            .hasSystemFeature(PackageManager.FEATURE_LOCATION_GPS)
        val hasGnssStatus = api >= Build.VERSION_CODES.N  // API 24
        val hasGnssMeasurements = api >= Build.VERSION_CODES.N
        val hasCarrierFrequency = api >= Build.VERSION_CODES.O  // API 26
        val hasVerticalAccuracy = api >= Build.VERSION_CODES.O

        val level = when {
            !hasGps -> "unavailable"
            hasGnssStatus -> "full"
            else -> "partialAndroid"
        }

        return mapOf(
            "isAndroid" to true,
            "isIOS" to false,
            "platformVersion" to "Android ${Build.VERSION.RELEASE} (API $api)",
            "gnssLevel" to level,
            "hasGnssStatus" to hasGnssStatus,
            "hasGnssMeasurements" to hasGnssMeasurements,
            "hasCarrierFrequency" to hasCarrierFrequency,
            "hasVerticalAccuracy" to hasVerticalAccuracy,
            "hasSpeed" to true,
            "hasHeading" to true,
            "deviceModel" to "${Build.MANUFACTURER} ${Build.MODEL}",
            "hasFineLocationPermission" to hasFineLocationPermission()
        )
    }

    /** Returns true only when ACCESS_FINE_LOCATION is granted.
     *  GnssStatus.Callback requires fine permission; coarse-only grants will
     *  produce location updates but never satellite-level data. */
    private fun hasFineLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun hasLocationPermission(): Boolean {
        val coarse = ContextCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        // Approximate-only grants still allow network / passive fixes.
        return hasFineLocationPermission() || coarse
    }
}
