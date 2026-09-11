import '../core/models/automation_result.dart'; import 'command_router.dart';
class AutomationManager { final CommandRouter router; AutomationManager([CommandRouter? r]):router=r??CommandRouter(); Future<AutomationResult> execute(String command)=>router.route(command); }
