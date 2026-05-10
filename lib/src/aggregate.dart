part of 'database.dart';

class InAppAggregateQuery extends InAppReference {
  final InAppCollectionReference _p;

  const InAppAggregateQuery({
    required super.db,
    required super.ref,
    required InAppCollectionReference parent,
  }) : _p = parent;

  InAppCollectionReference get parent => _p;

  Future<InAppAggregateQuerySnapshot> get([
    InAppSource source = InAppSource.cache,
  ]) async {
    final query = await _p.get(source);
    return InAppAggregateQuerySnapshot(count: query.docs.length, query: query);
  }

  Stream<InAppAggregateQuerySnapshot> snapshots() {
    final n = _db._addNotifier(_p.path);
    return Stream<InAppAggregateQuerySnapshot>.multi((controller) {
      InAppAggregateQuerySnapshot? last;
      void emit(InAppAggregateQuerySnapshot snap) {
        if (controller.isClosed) return;
        if (last == snap) return;
        last = snap;
        controller.add(snap);
      }

      void listener() {
        final snap = n.value ?? InAppQuerySnapshot(_p.id);
        emit(InAppAggregateQuerySnapshot(count: snap.docs.length, query: snap));
      }

      n.addListener(listener);
      controller.onCancel = () {
        n.removeListener(listener);
        _db._maybeCleanupNotifier(_p.path);
      };

      Future<void>(() async {
        try {
          final s = await get();
          if (!controller.isClosed) emit(s);
        } catch (_) {}
      });
    });
  }
}
