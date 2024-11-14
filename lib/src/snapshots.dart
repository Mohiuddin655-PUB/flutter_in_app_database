part of 'database.dart';

abstract class InAppSnapshot {
  const InAppSnapshot();
}

class InAppQuerySnapshot extends InAppSnapshot {
  final String id;
  final List<InAppDocumentSnapshot> docs;
  final List<InAppDocumentChangeSnapshot> docChanges;

  bool get exists => docs.isNotEmpty;

  InAppDocument get rootDocs {
    final x = docs.map((e) => MapEntry(e.id, e.data));
    return Map.fromEntries(x);
  }

  InAppDocument get rootDocChanges {
    final x = docChanges.map((e) => MapEntry(e.doc.id, e.doc.data));
    return Map.fromEntries(x);
  }

  const InAppQuerySnapshot(
    this.id, [
    this.docs = const [],
    this.docChanges = const [],
  ]);

  @override
  int get hashCode => id.hashCode ^ docs.hashCode ^ docChanges.hashCode;

  @override
  bool operator ==(Object other) {
    return other is InAppQuerySnapshot &&
        other.id == id &&
        other.docs == docs &&
        other.docChanges == docChanges;
  }

  @override
  String toString() {
    return "$InAppQuerySnapshot(id: $id, docs: $docs, docChanges: $docChanges)";
  }
}

class InAppCounterSnapshot extends InAppSnapshot {
  final String id;
  final int count;
  final InAppQuerySnapshot query;

  bool get exists => query.exists;

  const InAppCounterSnapshot(
    this.id,
    this.query, [
    this.count = 0,
  ]);

  @override
  int get hashCode => id.hashCode ^ count.hashCode ^ query.hashCode;

  @override
  bool operator ==(Object other) {
    return other is InAppCounterSnapshot &&
        other.id == id &&
        other.count == count &&
        other.query == query;
  }

  @override
  String toString() {
    return "$InAppCounterSnapshot(id: $id, count: $count, query: $query)";
  }
}

class InAppDocumentChangeSnapshot extends InAppSnapshot {
  final InAppDocumentSnapshot doc;

  const InAppDocumentChangeSnapshot({
    required this.doc,
  });

  @override
  int get hashCode => doc.hashCode;

  @override
  bool operator ==(Object other) {
    return other is InAppDocumentChangeSnapshot && other.doc == doc;
  }

  @override
  String toString() => "$InAppDocumentChangeSnapshot(doc: $doc)";
}

class InAppDocumentSnapshot extends InAppSnapshot {
  final String id;
  final InAppDocument? _doc;

  InAppDocument? get data => _doc;

  bool get exists => _doc != null && _doc!.isNotEmpty;

  const InAppDocumentSnapshot(
    this.id, [
    this._doc,
  ]);

  InAppDocumentSnapshot copy({
    String? id,
    InAppDocument? doc,
  }) {
    return InAppDocumentSnapshot(id ?? this.id, doc ?? _doc);
  }

  @override
  int get hashCode => id.hashCode ^ _doc.hashCode;

  @override
  bool operator ==(Object other) {
    return other is InAppDocumentSnapshot &&
        other.id == id &&
        other._doc == _doc;
  }

  @override
  String toString() => "$InAppDocumentSnapshot(id: $id, doc: $_doc)";
}

class InAppFailureSnapshot extends InAppSnapshot {
  final String message;

  const InAppFailureSnapshot(this.message);

  @override
  int get hashCode => message.hashCode;

  @override
  bool operator ==(Object other) {
    return other is InAppFailureSnapshot && other.message == message;
  }

  @override
  String toString() => "$InAppFailureSnapshot(message: $message)";
}

class InAppErrorSnapshot extends InAppFailureSnapshot {
  const InAppErrorSnapshot(super.message);

  @override
  String toString() => "$InAppErrorSnapshot(message: $message)";
}
