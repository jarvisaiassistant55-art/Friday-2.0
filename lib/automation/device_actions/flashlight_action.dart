import 'package:torch_light/torch_light.dart';

import '../../core/models/automation_result.dart';

class FlashlightAction {
  Future<AutomationResult> execute(bool enabled) async {
    try {
      if (enabled) {
        await TorchLight.enableTorch();
      } else {
        await TorchLight.disableTorch();
      }

      return AutomationResult(
        true,
        enabled ? 'Flashlight turned on.' : 'Flashlight turned off.',
      );
    } catch (e) {
      return AutomationResult(
        false,
        'Unable to control the flashlight: $e',
      );
    }
  }
}
