part of 'database.dart';

class _InAppMerger {
  final InAppDocument root;

  _InAppMerger(InAppDocument? root) : root = Map.from(root ?? {});

  InAppDocument merge(InAppDocument updates) {
    Map<String, dynamic> extra = {};
    for (var entry in updates.entries) {
      final field = entry.key;
      final fieldValue = entry.value;
      final baseValue = root[field];
      if (fieldValue is InAppFieldValue) {
        _apply(field, fieldValue, baseValue);
      } else {
        extra[field] = fieldValue;
      }
    }
    if (extra.isNotEmpty) root.addAll(extra);
    return root;
  }

  void _apply(String field, InAppFieldValue fieldValue, dynamic baseValue) {
    final modifier = fieldValue.value;
    final type = fieldValue.type;
    if (type.isArrayUnion) {
      _applyArrayUnion(field, baseValue, modifier);
    } else if (type.isArrayRemove) {
      _applyArrayRemove(field, baseValue, modifier);
    } else if (type.isIncrement) {
      _applyIncrement(field, baseValue, modifier);
    } else if (type.isDelete) {
      _applyDelete(field);
    } else if (type.isServerTimestamp) {
      _applyServerTimestamp(field);
    }
  }

  void _applyArrayUnion(String field, dynamic base, dynamic modifier) {
    if (base is List? && modifier is List) {
      final mergedList = List.from(base ?? [])..addAll(modifier);
      root[field] = mergedList;
    }
  }

  void _applyArrayRemove(String field, dynamic base, dynamic modifier) {
    if (base is List && modifier is List) {
      final filteredList = base.where((i) => !modifier.contains(i)).toList();
      root[field] = filteredList;
    }
  }

  void _applyIncrement(String field, dynamic base, dynamic modifier) {
    if (base is num? && modifier is num) {
      final newValue = (base ?? 0) + modifier;
      root[field] = newValue;
    }
  }

  void _applyDelete(String field) {
    root.remove(field);
  }

  void _applyServerTimestamp(String field) {
    root[field] = DateTime.now().toString();
  }
}
