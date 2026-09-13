import '../core/models/automation_result.dart';
import 'device_actions/flashlight_action.dart';
import 'device_actions/battery_action.dart';

class CommandRouter {
  final flashlight = FlashlightAction();
  final battery = BatteryAction();

  Future<AutomationResult> route(String c) async {
    final x = c.toLowerCase();

    if (x.contains('flashlight') || x.contains('torch')) {
      return flashlight.execute(x.contains('on'));
    }

    if (x.contains('battery')) {
      return battery.execute();
    }

    return const AutomationResult(
      false,
      'I do not have a safe action mapped for that command yet.',
    );
  }
}
