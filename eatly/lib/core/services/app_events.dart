import 'dart:async';

enum AppEventType { photoAdded, photoAnalyzed }

class AppEvent {
  final AppEventType type;
  final String? id;
  AppEvent(this.type, {this.id});
}

class AppEvents {
  AppEvents._();
  static final AppEvents instance = AppEvents._();

  final StreamController<AppEvent> _controller = StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get stream => _controller.stream;

  void emitPhotoAdded(String id) {
    _controller.add(AppEvent(AppEventType.photoAdded, id: id));
  }

  void emitPhotoAnalyzed(String id) {
    _controller.add(AppEvent(AppEventType.photoAnalyzed, id: id));
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}


