import CoreLocation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private var eventSink: FlutterEventSink?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone

        guard let controller = window?.rootViewController as? FlutterViewController
        else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let messenger = controller.binaryMessenger

        // ── Method channel ──────────────────────────────────────────────────
        let methodChannel = FlutterMethodChannel(
            name: "naviscope/gnss",
            binaryMessenger: messenger
        )
        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self else { return }
            switch call.method {
            case "getCapabilities":
                result(self.buildCapabilities())
            case "startListening":
                self.startLocation()
                result(nil)
            case "stopListening":
                self.stopLocation()
                result(nil)
            case "requestPermission":
                let status = CLLocationManager.authorizationStatus()
                if status == .notDetermined {
                    self.locationManager.requestWhenInUseAuthorization()
                }
                let granted = status == .authorizedWhenInUse || status == .authorizedAlways
                result(granted ? "granted" : "denied")
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // ── Event channel ───────────────────────────────────────────────────
        let eventChannel = FlutterEventChannel(
            name: "naviscope/telemetry_stream",
            binaryMessenger: messenger
        )
        eventChannel.setStreamHandler(self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ── Location management ──────────────────────────────────────────────────

    private func startLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }

    private func stopLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    // ── CLLocationManagerDelegate ────────────────────────────────────────────

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        emitFrame(location: loc)
    }

    private func emitFrame(location: CLLocation) {
        guard let sink = eventSink else { return }

        var locMap: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Int(location.timestamp.timeIntervalSince1970 * 1000),
            "source": "gps",
        ]

        if location.altitude != 0 {
            locMap["altitude"] = location.altitude
        }
        if location.speed >= 0 {
            locMap["speed"] = location.speed
        }
        if location.horizontalAccuracy > 0 {
            locMap["horizontalAccuracy"] = location.horizontalAccuracy
        }
        if location.verticalAccuracy > 0 {
            locMap["verticalAccuracy"] = location.verticalAccuracy
        }
        if let heading = locationManager.heading, heading.trueHeading >= 0 {
            locMap["heading"] = heading.trueHeading
        } else if location.course >= 0 {
            locMap["heading"] = location.course
        }

        let frame: [String: Any?] = [
            "location": locMap,
            "gnss": nil
        ]

        DispatchQueue.main.async { sink(frame) }
    }

    // ── Capability map ────────────────────────────────────────────────────────

    private func buildCapabilities() -> [String: Any] {
        return [
            "isAndroid": false,
            "isIOS": true,
            "platformVersion": "iOS \(UIDevice.current.systemVersion)",
            "gnssLevel": "iosLocationOnly",
            "hasGnssStatus": false,
            "hasGnssMeasurements": false,
            "hasCarrierFrequency": false,
            "hasVerticalAccuracy": true,
            "hasSpeed": true,
            "hasHeading": CLLocationManager.headingAvailable(),
            "deviceModel": UIDevice.current.model,
        ]
    }
}

// MARK: - FlutterStreamHandler
extension AppDelegate: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        startLocation()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopLocation()
        eventSink = nil
        return nil
    }
}
