part of 'database.dart';

class _InAppNotifier<T> extends ValueNotifier<T> {
  _InAppNotifier(super.data);

  void notify() => notifyListeners();
}

class _InAppQueryNotifier extends _InAppNotifier<InAppQuerySnapshot?> {
  final Map<String, _InAppDocumentNotifier> children = {};

  _InAppQueryNotifier(super.data);

  _InAppDocumentNotifier set(
    String id, [
    InAppDocumentSnapshot? value,
  ]) {
    final i = children[id];
    if (i == null) children[id] = _InAppDocumentNotifier(value);
    final x = i ?? children[id];
    return x is _InAppDocumentNotifier ? x : _InAppDocumentNotifier(null);
  }

  @override
  set value(InAppQuerySnapshot? value) {
    if (value != null) {
      final id = value.id;
      final data = value.docs.where((i) {
        final item = i.data;
        return item != null && item.isNotEmpty;
      }).toList();
      if (id.isNotEmpty && data.isNotEmpty) {
        super.value = InAppQuerySnapshot(id, data);
      } else {
        super.value = null;
      }
    } else {
      super.value = null;
    }
  }
}

class _InAppDocumentNotifier extends _InAppNotifier<InAppDocumentSnapshot?> {
  _InAppDocumentNotifier(super.data);

  @override
  set value(InAppDocumentSnapshot? value) {
    if (value != null) {
      final id = value.id;
      final data = value.data;
      if (id.isNotEmpty && data != null && data.isNotEmpty) {
        super.value = InAppDocumentSnapshot(id, data);
      } else {
        super.value = null;
      }
    } else {
      super.value = null;
    }
  }
}
