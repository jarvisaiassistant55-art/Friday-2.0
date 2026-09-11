class AiTool {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final Future<String> Function(Map<String, dynamic>) handler;

  const AiTool({required this.name, required this.description, required this.parameters, required this.handler});

  Map<String, dynamic> toProviderJson() => {
    'type': 'function',
    'function': {'name': name, 'description': description, 'parameters': parameters},
  };
}

class ToolRegistry {
  final Map<String, AiTool> _tools = {};
  void register(AiTool tool) => _tools[tool.name] = tool;
  AiTool? get(String name) => _tools[name];
  List<AiTool> get all => _tools.values.toList(growable: false);
  List<Map<String, dynamic>> get schemas => all.map((t) => t.toProviderJson()).toList(growable: false);
}
