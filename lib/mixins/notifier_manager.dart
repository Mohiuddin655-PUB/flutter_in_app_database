part of '../src/database.dart';

mixin _NotifierManagerMixin {
  final Map<String, _InAppNotifier> _notifiers = {};

  InAppQueryNotifier _addNotifier(
    String reference, [
    InAppQuerySnapshot? value,
  ]) {
    final existing = _notifiers[reference];
    if (existing is InAppQueryNotifier && !existing.isDisposed) {
      if (value != null) existing.value = value;
      return existing;
    }
    if (existing != null && existing.isDisposed) {
      _notifiers.remove(reference);
    }
    final created = InAppQueryNotifier(value);
    _notifiers[reference] = created;
    return created;
  }

  InAppDocumentNotifier _addChildNotifier(
    String reference,
    String id, [
    InAppDocumentSnapshot? value,
  ]) {
    return _addNotifier(reference).set(id, value);
  }

  void _maybeCleanupNotifier(String path) {
    final n = _notifiers[path];
    if (n == null) return;
    if (n is InAppQueryNotifier) {
      final hasActiveChild = n.children.values.any((c) => c.hasActiveListeners);
      if (!n.hasActiveListeners && !hasActiveChild) {
        _notifiers.remove(path);
        n.dispose();
      }
    } else {
      if (!n.hasActiveListeners) {
        _notifiers.remove(path);
        n.dispose();
      }
    }
  }

  void _maybeCleanupChild(String parentPath, String id) {
    final parent = _notifiers[parentPath];
    if (parent is! InAppQueryNotifier) return;
    final child = parent.children[id];
    if (child != null && !child.hasActiveListeners) {
      parent.children.remove(id);
      child.dispose();
    }
    _maybeCleanupNotifier(parentPath);
  }

  void _disposeAllNotifiers() {
    for (final n in _notifiers.values) {
      n.dispose();
    }
    _notifiers.clear();
  }
}
