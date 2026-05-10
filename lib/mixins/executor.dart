part of '../src/database.dart';

mixin _ExecutorMixin {
  static const Duration _retryDelay = Duration(milliseconds: 250);
  static const int _maxRetries = 3;

  bool get isDisposed;

  bool get isInitialized;

  String get name;

  Future<T> _execute<T>(
    Future<T> Function() callback, [
    int attempt = 0,
  ]) async {
    if (isDisposed) {
      throw const InAppDatabaseException('Database has been disposed.');
    }
    if (!isInitialized) {
      throw InAppDatabaseException('$InAppDatabase($name) not initialized.');
    }
    try {
      return await callback();
    } on ArgumentError {
      rethrow;
    } on StateError {
      rethrow;
    } on InAppDatabaseException {
      rethrow;
    } catch (e) {
      if (attempt >= _maxRetries) rethrow;
      await Future<void>.delayed(_retryDelay * (attempt + 1));
      return _execute(callback, attempt + 1);
    }
  }
}
