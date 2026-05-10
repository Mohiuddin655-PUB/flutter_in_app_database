part of '../src/database.dart';

mixin _WriterMixin on _LoggerMixin, _ErrorMixin, _SerialMixin, _ExecutorMixin {
  InAppDatabaseDelegate get _delegate;

  String get _name;

  InAppDatabaseVersion get _version;

  InAppDatabaseType get _type;

  Object? _sanitize(Object? v) {
    if (v == null || v is num || v is bool || v is String) return v;
    if (v is DateTime) return v.toUtc().toIso8601String();
    if (v is Duration) return v.inMicroseconds;
    if (v is Uri) return v.toString();
    if (v is BigInt) return v.toString();
    if (v is Map) {
      final r = <String, Object?>{};
      v.forEach((k, val) => r['$k'] = _sanitize(val));
      return r;
    }
    if (v is Iterable) {
      return v.map(_sanitize).toList(growable: false);
    }
    try {
      return v.toString();
    } catch (_) {
      return null;
    }
  }

  String _safeEncode(Object? data) {
    return jsonEncode(
      data,
      toEncodable: (Object? v) {
        final s = _sanitize(v);
        if (s == null || s is num || s is bool || s is String) return s;
        if (s is List || s is Map) return s;
        return s.toString();
      },
    );
  }

  Future<Object?> _wb(
    String path,
    Map<String, Object?> base,
    bool isJson,
  ) async {
    if (base.isEmpty) return null;
    final l = await _delegate.limitation(_name, PathModifier.format(path));
    if (l == null || l.isUnlimited) {
      return isJson ? _safeEncode(base) : base;
    }
    final entries = base.entries;
    if (entries.length <= l.limit) return isJson ? _safeEncode(base) : base;
    final list = entries.toList(growable: false);
    final selected =
        l.limitByRecent ? list.reversed.take(l.limit) : list.take(l.limit);
    final reduced = Map<String, Object?>.fromEntries(selected);
    return isJson ? _safeEncode(reduced) : reduced;
  }

  Future<bool> _w({
    required InAppWriteType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
    InAppDocument? value,
  }) {
    return _serial(
      collectionPath,
      () => _wInner(
        type: type,
        reference: reference,
        collectionPath: collectionPath,
        collectionId: collectionId,
        documentId: documentId,
        value: value,
      ),
    );
  }

  Future<bool> _wInner({
    required InAppWriteType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
    InAppDocument? value,
  }) async {
    final isJson = _type == InAppDatabaseType.json;
    try {
      return await _execute(() async {
        final ref = _version._ref(collectionPath);
        Object? root;
        try {
          root = await _delegate.read(_name, ref);
        } catch (_) {
          root = null;
        }
        Object? raw = root;
        if (root is String) {
          try {
            raw = jsonDecode(root);
          } catch (_) {
            raw = null;
          }
        }
        final base =
            raw is Map ? Map<String, Object?>.from(raw) : <String, Object?>{};

        if (type.isDocument) {
          if (value != null && value.isNotEmpty) {
            final cleaned = <String, Object?>{};
            value.forEach((k, v) {
              if (v != null) cleaned[k] = _sanitize(v);
            });
            base[documentId] = isJson ? _safeEncode(cleaned) : cleaned;
          } else {
            base.remove(documentId);
          }
        } else if (type.isCollection) {
          if (value != null) {
            value.forEach((k, v) {
              if (v == null) {
                base.remove(k);
              } else {
                final s = _sanitize(v);
                base[k] = isJson ? _safeEncode(s) : s;
              }
            });
          } else {
            base.clear();
          }
        }

        final payload = await _wb(collectionPath, base, isJson);
        final ok = await _delegate.write(_name, ref, payload);
        if (!ok) {
          throw const InAppDatabaseException(
            'Delegate write returned false.',
            code: 'delegate-write-failed',
          );
        }
        return ok;
      });
    } catch (e, st) {
      _setError(e, st);
      _log(e, action: 'write', field: collectionPath);
      return false;
    }
  }
}
