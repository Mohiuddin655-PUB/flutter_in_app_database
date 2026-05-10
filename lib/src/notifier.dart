part of 'database.dart';

class _InAppNotifier<T> extends ValueNotifier<T> {
  _InAppNotifier(super.data);

  bool _disposed = false;
  int _listenerCount = 0;

  bool get isDisposed => _disposed;

  bool get hasActiveListeners => _listenerCount > 0;

  @override
  void addListener(VoidCallback listener) {
    if (_disposed) return;
    super.addListener(listener);
    _listenerCount++;
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (_listenerCount > 0) _listenerCount--;
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _listenerCount = 0;
    super.dispose();
  }
}

class InAppQueryNotifier extends _InAppNotifier<InAppQuerySnapshot?> {
  final Map<String, InAppDocumentNotifier> children = {};

  InAppQueryNotifier(super.data);

  InAppDocumentNotifier set(String id, [InAppDocumentSnapshot? value]) {
    final existing = children[id];
    if (existing != null && !existing.isDisposed) {
      if (value != null) existing.value = value;
      return existing;
    }
    if (existing != null && existing.isDisposed) children.remove(id);
    final created = InAppDocumentNotifier(value, id);
    children[id] = created;
    return created;
  }

  @override
  set value(InAppQuerySnapshot? value) {
    if (_disposed) return;
    if (value == null) {
      super.value = null;
      return;
    }
    final id = value.id;
    if (id.isEmpty) {
      super.value = null;
      return;
    }
    final filtered = <InAppQueryDocumentSnapshot>[];
    for (final d in value.docs) {
      final data = d.data();
      if (data.isNotEmpty) filtered.add(d);
    }
    super.value = InAppQuerySnapshot(
      id,
      filtered,
      value.docChanges,
      value.metadata,
    );
  }

  @override
  void dispose() {
    for (final child in children.values) {
      child.dispose();
    }
    children.clear();
    super.dispose();
  }

  @override
  String toString() => 'InAppQueryNotifier(${value?.id})';
}

class InAppDocumentNotifier extends _InAppNotifier<InAppDocumentSnapshot?> {
  final String id;

  InAppDocumentNotifier(super.data, this.id);

  @override
  set value(InAppDocumentSnapshot? value) {
    if (_disposed) return;
    if (value == null) {
      super.value = null;
      return;
    }
    final vId = value.id;
    final data = value.data();
    if (vId.isNotEmpty && data != null && data.isNotEmpty) {
      super.value = value;
    } else {
      super.value = null;
    }
  }

  @override
  String toString() => 'InAppDocumentNotifier($id)';
}
