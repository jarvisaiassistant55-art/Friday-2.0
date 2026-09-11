import 'dart:async';
import 'assistant_event.dart';

class AssistantEventBus {
  final StreamController<AssistantEvent> _controller =
      StreamController<AssistantEvent>.broadcast();

  Stream<AssistantEvent> get stream => _controller.stream;

  void emit(AssistantEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  Future<void> dispose() => _controller.close();
}
