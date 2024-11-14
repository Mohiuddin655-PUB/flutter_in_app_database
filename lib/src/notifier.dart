part of 'database.dart';

class _InAppNotifier<T> extends ValueNotifier<T> {
  _InAppNotifier(super.data);

  void notify() => notifyListeners();
}

class InAppQueryNotifier extends _InAppNotifier<InAppQuerySnapshot?> {
  final Map<String, InAppDocumentNotifier> children = {};

  InAppQueryNotifier(super.data);

  InAppDocumentNotifier set(
    String id, [
    InAppDocumentSnapshot? value,
  ]) {
    final i = children[id];
    if (i == null) children[id] = InAppDocumentNotifier(value, id);
    final x = i ?? children[id];
    return x is InAppDocumentNotifier ? x : InAppDocumentNotifier(null, id);
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

  @override
  String toString() => "$InAppQueryNotifier(${value?.id})";
}

class InAppDocumentNotifier extends _InAppNotifier<InAppDocumentSnapshot?> {
  final String id;

  InAppDocumentNotifier(super.data, this.id);

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

  @override
  String toString() => "$InAppDocumentNotifier($id)";
}
