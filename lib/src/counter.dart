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
      return InAppCounterSnapshot(_p.id, value, value.docs.length);
    });
  }

  Stream<InAppCounterSnapshot> snapshots() {
    final n = _db._addNotifier(_p.path);
    Future.delayed(const Duration(seconds: 1)).whenComplete(_p._notify);
    return Stream.multi((c) {
      void update() {
        c.add(InAppCounterSnapshot(
          _p.id,
          n.value ?? InAppQuerySnapshot(_p.id),
          n.value?.docs.length ?? 0,
        ));
      }

      n.addListener(update);
      c.onCancel = () => n.removeListener(update);
    });
  }
}
