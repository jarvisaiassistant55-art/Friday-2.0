import '../../../automation/automation_manager.dart';
import '../tool_registry.dart';

ToolRegistry buildDefaultToolRegistry({AutomationManager? automation}) {
  final manager = automation ?? AutomationManager();
  final registry = ToolRegistry();
  registry.register(AiTool(
    name: 'device_command',
    description: 'Safely execute a supported device command such as flashlight, torch, volume, or battery status.',
    parameters: {'type': 'object', 'properties': {'command': {'type': 'string', 'description': 'The device command to execute'}}, 'required': ['command']},
    handler: (args) async => (await manager.execute(args['command']?.toString() ?? '')).message,
  ));
  return registry;
}
