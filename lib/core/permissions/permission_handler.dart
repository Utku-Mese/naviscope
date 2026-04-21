import 'package:permission_handler/permission_handler.dart' as ph;

enum NaviPermissionStatus { granted, denied, permanentlyDenied, restricted }

class NaviPermissionHandler {
  Future<NaviPermissionStatus> requestLocationPermission() async {
    // On Android request precise (fine) location; on iOS this triggers the
    // WhenInUse → AlwaysAllowed dialog chain via CoreLocation.
    final status = await ph.Permission.locationWhenInUse.request();
    return _map(status);
  }

  Future<NaviPermissionStatus> checkLocationPermission() async {
    final status = await ph.Permission.locationWhenInUse.status;
    return _map(status);
  }

  Future<void> openSettings() => ph.openAppSettings();

  NaviPermissionStatus _map(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
      case ph.PermissionStatus.limited:
        return NaviPermissionStatus.granted;
      case ph.PermissionStatus.permanentlyDenied:
        return NaviPermissionStatus.permanentlyDenied;
      case ph.PermissionStatus.restricted:
        return NaviPermissionStatus.restricted;
      default:
        return NaviPermissionStatus.denied;
    }
  }
}
