part of '../src/database.dart';

mixin _DeleterMixin on _LoggerMixin, _ErrorMixin, _SerialMixin, _ExecutorMixin {
  InAppDatabaseDelegate get _delegate;

  String get _name;

  InAppDatabaseVersion get _version;

  Future<bool> _delete(
    String collectionPath, {
    bool related = true,
    Iterable<String> Function(String path, Iterable<String>)? filter,
  }) {
    final ref = _version._ref(collectionPath);
    return _serial(collectionPath, () async {
      try {
        return await _execute(() async {
          if (!related) return _delegate.delete(_name, ref);
          final paths = await _delegate.paths(_name);
          final keys = filter != null
              ? filter(ref, paths)
              : paths.where((p) => p == ref || p.startsWith('$ref/'));
          var any = false;
          for (final k in keys) {
            if (await _delegate.delete(_name, k)) any = true;
          }
          return any || filter != null;
        });
      } catch (e, st) {
        _setError(e, st);
        _log(e, action: 'delete', field: collectionPath);
        return false;
      }
    });
  }
}
