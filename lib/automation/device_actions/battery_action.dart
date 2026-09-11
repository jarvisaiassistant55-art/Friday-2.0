import 'package:battery_plus/battery_plus.dart'; import '../../core/models/automation_result.dart';
class BatteryAction {final battery=Battery();Future<AutomationResult> execute() async {final p=await battery.batteryLevel;return AutomationResult(true,'Battery level is $p percent.');}}
