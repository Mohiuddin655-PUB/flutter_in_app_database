part of 'database.dart';

abstract class InAppSnapshot {
  const InAppSnapshot();
}

class InAppDocumentSnapshot extends InAppSnapshot {
  final String id;
  final InAppDocument? _data;
  final InAppDocumentReference? reference;
  final InAppSnapshotMetadata metadata;

  const InAppDocumentSnapshot(
    this.id, [
    this._data,
    this.reference,
    this.metadata = InAppSnapshotMetadata.defaults,
  ]);

  InAppDocument? data() => _data;

  bool get exists => _data != null && _data!.isNotEmpty;

  Object? operator [](Object field) => get(field);

  T? get<T extends Object?>(Object field) {
    if (field is InAppFieldPath && field.isDocumentId) {
      return id is T ? id as T : null;
    }
    if (_data == null) return null;
    final List<String>? key = field is InAppFieldPath
        ? (field.isDocumentId ? null : field.segments)
        : field is String
            ? field.split('.')
            : null;
    if (key == null) return null;
    Object? current = _data;
    for (final seg in key) {
      if (current is Map) {
        current = current[seg];
      } else {
        return null;
      }
    }
    return current is T ? current : null;
  }

  InAppDocumentSnapshot copy({
    String? id,
    InAppDocument? data,
    InAppDocumentReference? reference,
    InAppSnapshotMetadata? metadata,
  }) {
    return InAppDocumentSnapshot(
      id ?? this.id,
      data ?? _data,
      reference ?? this.reference,
      metadata ?? this.metadata,
    );
  }

  @override
  int get hashCode => Object.hash(id, _data == null ? 0 : _data!.length);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InAppDocumentSnapshot) return false;
    if (other.id != id) return false;
    final a = _data;
    final b = other._data;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key)) return false;
      if (!_deepEq(b[entry.key], entry.value)) return false;
    }
    return true;
  }

  static bool _deepEq(Object? a, Object? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final k in a.keys) {
        if (!b.containsKey(k)) return false;
        if (!_deepEq(a[k], b[k])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEq(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }

  @override
  String toString() => 'InAppDocumentSnapshot(id: $id, exists: $exists)';
}

class InAppQueryDocumentSnapshot extends InAppDocumentSnapshot {
  const InAppQueryDocumentSnapshot(
    super.id,
    InAppDocument super.data, [
    super.reference,
    super.metadata,
  ]);

  @override
  InAppDocument data() => _data!;

  @override
  bool get exists => true;
}

class InAppDocumentChange extends InAppSnapshot {
  final InAppDocumentChangeType type;
  final int oldIndex;
  final int newIndex;
  final InAppQueryDocumentSnapshot doc;

  const InAppDocumentChange({
    required this.type,
    required this.oldIndex,
    required this.newIndex,
    required this.doc,
  });

  @override
  int get hashCode => Object.hash(type, oldIndex, newIndex, doc);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppDocumentChange &&
          other.type == type &&
          other.oldIndex == oldIndex &&
          other.newIndex == newIndex &&
          other.doc == doc;

  @override
  String toString() =>
      'InAppDocumentChange(type: $type, oldIndex: $oldIndex, newIndex: $newIndex, doc: ${doc.id})';
}

class InAppDocumentChangeSnapshot extends InAppDocumentChange {
  const InAppDocumentChangeSnapshot({required super.doc})
      : super(
            type: InAppDocumentChangeType.modified, oldIndex: -1, newIndex: -1);
}

class InAppQuerySnapshot extends InAppSnapshot {
  final String id;
  final List<InAppQueryDocumentSnapshot> docs;
  final List<InAppDocumentChange> docChanges;
  final InAppSnapshotMetadata metadata;

  const InAppQuerySnapshot(
    this.id, [
    this.docs = const [],
    this.docChanges = const [],
    this.metadata = InAppSnapshotMetadata.defaults,
  ]);

  bool get exists => docs.isNotEmpty;

  int get size => docs.length;

  bool get isEmpty => docs.isEmpty;

  bool get isNotEmpty => docs.isNotEmpty;

  InAppDocument get rootDocs {
    final result = <String, InAppValue>{};
    for (final d in docs) {
      result[d.id] = d.data();
    }
    return result;
  }

  InAppDocument get rootDocChanges {
    final result = <String, InAppValue>{};
    for (final c in docChanges) {
      result[c.doc.id] = c.doc.data();
    }
    return result;
  }

  InAppQueryDocumentSnapshot? doc(String id) {
    for (final d in docs) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  int get hashCode =>
      Object.hash(id, Object.hashAll(docs), Object.hashAll(docChanges));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InAppQuerySnapshot) return false;
    if (other.id != id) return false;
    if (other.docs.length != docs.length) return false;
    if (other.docChanges.length != docChanges.length) return false;
    for (var i = 0; i < docs.length; i++) {
      if (other.docs[i] != docs[i]) return false;
    }
    for (var i = 0; i < docChanges.length; i++) {
      if (other.docChanges[i] != docChanges[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'InAppQuerySnapshot(id: $id, size: $size, changes: ${docChanges.length})';
}

class InAppAggregateQuerySnapshot extends InAppSnapshot {
  final int count;
  final InAppQuerySnapshot query;

  const InAppAggregateQuerySnapshot({required this.count, required this.query});

  bool get exists => query.exists;

  @override
  int get hashCode => Object.hash(count, query);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppAggregateQuerySnapshot &&
          other.count == count &&
          other.query == query;

  @override
  String toString() => 'InAppAggregateQuerySnapshot(count: $count)';
}

class InAppFailureSnapshot extends InAppSnapshot {
  final String message;

  const InAppFailureSnapshot(this.message);

  @override
  int get hashCode => message.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppFailureSnapshot && other.message == message;

  @override
  String toString() => 'InAppFailureSnapshot(message: $message)';
}

class InAppErrorSnapshot extends InAppFailureSnapshot {
  const InAppErrorSnapshot(super.message);

  @override
  String toString() => 'InAppErrorSnapshot(message: $message)';
}
