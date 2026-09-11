import 'package:permission_handler/permission_handler.dart';
class PermissionManager {Future<bool> microphone()async=>(await Permission.microphone.request()).isGranted;Future<bool> camera()async=>(await Permission.camera.request()).isGranted;Future<bool> location()async=>(await Permission.locationWhenInUse.request()).isGranted;}
