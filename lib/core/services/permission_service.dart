import 'package:permission_handler/permission_handler.dart'; class PermissionService{Future<bool> request(Permission p)async=>(await p.request()).isGranted;}
