import 'dart:async';

import 'package:in_app_database/in_app_database.dart';

class InAppCounterSnapshot {
  final String id;
  final int docs;
  final int docChanges;

  bool get exists => docs > 0;

  const InAppCounterSnapshot(
    this.id, [
    this.docs = 0,
    this.docChanges = 0,
  ]);

  @override
  String toString() {
    return "InAppCounterSnapshot(id: $id, docs: $docs, docChanges: $docChanges)";
  }
}

class InAppCounterReference extends InAppReference {
  final InAppCollectionReference parent;
  final String collectionPath;
  final String collectionId;

  const InAppCounterReference({
    required super.db,
    required super.reference,
    required this.collectionPath,
    required this.collectionId,
    required this.parent,
  });

  InAppCounterNotifier? get notifier => db.notifier("$collectionPath-count");

  T _n<T>(T value, [InAppCounterSnapshot? snapshot]) {
    if (notifier != null) {
      if (snapshot == null) {
        get().then((value) => notifier!.value = value);
      } else {
        notifier!.value = snapshot;
      }
    }
    return value;
  }

  void notify([InAppCounterSnapshot? snapshot]) => _n(null, snapshot);

  Future<InAppCounterSnapshot> get() {
    return parent.get().then((value) {
      return InAppCounterSnapshot(collectionId, value.docs.length);
    });
  }

  Stream<InAppCounterSnapshot> snapshots() {
    final controller = StreamController<InAppCounterSnapshot>();
    db.setNotifier("$collectionPath-count");
    notifier?.addListener(() {
      controller.add(notifier?.value ?? InAppCounterSnapshot(collectionId));
    });
    _n(null);
    return controller.stream;
  }
}
