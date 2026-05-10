part of '../src/database.dart';

mixin _ReaderMixin on _LoggerMixin, _ErrorMixin, _ExecutorMixin {
  InAppDatabaseDelegate get _delegate;

  String get _name;

  InAppDatabaseVersion get _version;

  Future<InAppSnapshot> _r({
    required InAppReadType type,
    required String reference,
    required String collectionPath,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      return await _execute(() async {
        final ref = _version._ref(collectionPath);
        Object? raw;
        try {
          raw = await _delegate.read(_name, ref);
        } catch (_) {
          raw = null;
        }
        Object? value = raw;
        if (raw is String) {
          try {
            value = jsonDecode(raw);
          } catch (_) {
            value = null;
          }
        }
        if (value is! Map) {
          if (type.isCollection) return InAppQuerySnapshot(collectionId);
          if (type.isDocument) return InAppDocumentSnapshot(documentId);
          return const InAppFailureSnapshot('Data not found.');
        }
        if (type.isCollection) {
          final docs = <InAppQueryDocumentSnapshot>[];
          value.forEach((k, v) {
            if (k is! String) return;
            Object? parsed = v;
            if (v is String) {
              try {
                parsed = jsonDecode(v);
              } catch (_) {
                return;
              }
            }
            if (parsed is! Map) return;
            final doc = Map<String, InAppValue>.from(parsed);
            if (doc.isEmpty) return;
            docs.add(InAppQueryDocumentSnapshot(k, doc));
          });
          return InAppQuerySnapshot(collectionId, docs);
        } else if (type.isDocument) {
          final entry = value[documentId];
          if (entry == null) return InAppDocumentSnapshot(documentId);
          Object? parsed = entry;
          if (entry is String) {
            try {
              parsed = jsonDecode(entry);
            } catch (_) {
              return InAppDocumentSnapshot(documentId);
            }
          }
          final doc =
              parsed is Map ? Map<String, InAppValue>.from(parsed) : null;
          return InAppDocumentSnapshot(documentId, doc);
        }
        return const InAppErrorSnapshot('Unsupported read type.');
      });
    } catch (e, st) {
      _setError(e, st);
      _log(e, action: 'read', field: collectionPath);
      return InAppFailureSnapshot(e.toString());
    }
  }

  Future<Iterable<String>> _k(String path) async {
    try {
      return await _execute(() async {
        final paths = await _delegate.paths(_name);
        final r = _version._ref(path);
        return paths
            .where((p) => p == r || p.startsWith('$r/'))
            .toList(growable: false);
      });
    } catch (e) {
      _log(e, action: 'keys', field: path);
      return const <String>[];
    }
  }
}
