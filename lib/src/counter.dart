part of 'database.dart';

class InAppCounterReference extends InAppReference {
  final InAppCollectionReference _p;

  const InAppCounterReference({
    required super.db,
    required super.reference,
    required InAppCollectionReference parent,
  }) : _p = parent;

  Future<InAppCounterSnapshot> get() {
    return _p.get().then((value) {
      return InAppCounterSnapshot(_p.id, value.docs.length);
    });
  }

  Stream<InAppCounterSnapshot> snapshots() {
    final c = StreamController<InAppCounterSnapshot>();
    final n = _db._addNotifier(_p.path);
    n.addListener(() {
      c.add(InAppCounterSnapshot(
        _p.id,
        n.value?.docs.length ?? 0,
        n.value?.docChanges.length ?? 0,
      ));
    });
    Future.delayed(const Duration(seconds: 1)).whenComplete(_p._notify);
    return c.stream;
  }
}
