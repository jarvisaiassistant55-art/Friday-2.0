import 'package:volume_controller/volume_controller.dart'; import '../../core/models/automation_result.dart';
class VolumeAction {Future<AutomationResult> execute(int delta) async {final v=await VolumeController.instance.getVolume(); final n=(v+delta*.1).clamp(0.0,1.0);await VolumeController.instance.setVolume(n);return const AutomationResult(true,'Volume adjusted.');}}
