import 'package:volume_controller/volume_controller.dart';

import '../../core/models/automation_result.dart';

class VolumeAction {
  final VolumeController controller = VolumeController();

  Future<AutomationResult> execute(int delta) async {
    final currentVolume = await controller.getVolume();

    final newVolume = (currentVolume + (delta * 0.1)).clamp(0.0, 1.0);

    controller.setVolume(newVolume);

    return const AutomationResult(
      true,
      'Volume adjusted.',
    );
  }
}
