part of 'database.dart';

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

  Future<InAppCounterSnapshot> get() {
    return parent.get().then((value) {
      return InAppCounterSnapshot(collectionId, value.docs.length);
    });
  }

  Stream<InAppCounterSnapshot> snapshots() {
    final c = StreamController<InAppCounterSnapshot>();
    final n = db.addListener(collectionPath);
    n.addListener(() {
      c.add(InAppCounterSnapshot(
        collectionId,
        n.value?.docs.length ?? 0,
        n.value?.docChanges.length ?? 0,
      ));
    });
    Future.delayed(const Duration(seconds: 1)).whenComplete(parent.notify);
    return c.stream;
  }
}
