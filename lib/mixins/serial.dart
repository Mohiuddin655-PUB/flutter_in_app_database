part of '../src/database.dart';

mixin _SerialMixin {
  final Map<String, Future<void>> _serialQueue = {};

  Future<T> _serial<T>(String key, Future<T> Function() task) {
    final prev = _serialQueue[key] ?? Future<void>.value();
    final completer = Completer<T>();
    late final Future<void> next;
    next = (() async {
      try {
        await prev;
      } catch (_) {}
      try {
        final r = await task();
        if (!completer.isCompleted) completer.complete(r);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      } finally {
        if (identical(_serialQueue[key], next)) {
          _serialQueue.remove(key);
        }
      }
    })();
    _serialQueue[key] = next;
    return completer.future;
  }

  Future<void> _drainSerial() async {
    final pending = List<Future<void>>.of(_serialQueue.values);
    for (final f in pending) {
      try {
        await f;
      } catch (_) {}
    }
  }
}
