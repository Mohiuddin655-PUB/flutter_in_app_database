part of '../src/database.dart';

mixin _ErrorMixin {
  Object? _lastError;
  StackTrace? _lastErrorStack;

  Object? consumeLastError() {
    final e = _lastError;
    _lastError = null;
    _lastErrorStack = null;
    return e;
  }

  StackTrace? get lastErrorStack => _lastErrorStack;

  void _setError(Object error, [StackTrace? stack]) {
    _lastError = error;
    _lastErrorStack = stack;
  }
}
