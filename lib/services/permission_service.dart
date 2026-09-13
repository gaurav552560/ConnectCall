import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request microphone permission
  static Future<bool> requestMicrophone() async {
    final PermissionStatus status =
    await Permission.microphone.request();

    return status.isGranted;
  }

  // Request camera and microphone permission
  static Future<bool> requestCameraAndMicrophone() async {
    final Map<Permission, PermissionStatus> statuses =
    await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses[Permission.camera]?.isGranted == true &&
        statuses[Permission.microphone]?.isGranted == true;
  }

  // Open app settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}