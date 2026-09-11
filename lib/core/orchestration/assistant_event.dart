import 'package:flutter/foundation.dart';

enum AssistantEventType {
  userInput,
  thinking,
  response,
  memoryUpdated,
  toolStarted,
  toolFinished,
  error,
  statusChanged,
}

@immutable
class AssistantEvent {
  final AssistantEventType type;
  final String message;
  final DateTime timestamp;
  final Map<String, Object?> data;

  AssistantEvent({
    required this.type,
    required this.message,
    DateTime? timestamp,
    this.data = const {},
  }) : timestamp = timestamp ?? DateTime.now();
}
