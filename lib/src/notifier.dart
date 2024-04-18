import 'package:flutter/foundation.dart';

import 'collection.dart';
import 'counter.dart';
import 'document.dart';

class InAppNotifier<T> extends ValueNotifier<T> {
  InAppNotifier(super.data);

  void notify() => notifyListeners();
}

class InAppQueryNotifier extends InAppNotifier<InAppQuerySnapshot?> {
  final Map<String, InAppDocumentNotifier> children = {};

  InAppQueryNotifier(super.data);

  InAppQueryNotifier set(String id) {
    children.putIfAbsent(id, () => InAppDocumentNotifier(null));
    return this;
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

class InAppCounterNotifier extends InAppNotifier<InAppCounterSnapshot?> {
  InAppCounterNotifier(super.data);

  @override
  set value(InAppCounterSnapshot? value) {
    if (value != null) {
      final id = value.id;
      final x = value.docs;
      final y = value.docChanges;
      if (id.isNotEmpty && (x > 0 || y > 0)) {
        super.value = InAppCounterSnapshot(id, x, y);
      } else {
        super.value = null;
      }
    } else {
      super.value = null;
    }
  }
}

class InAppDocumentNotifier extends InAppNotifier<InAppDocumentSnapshot?> {
  InAppDocumentNotifier(super.data);

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
