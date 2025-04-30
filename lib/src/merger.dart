part of 'database.dart';

class InAppMerger {
  final InAppDocument root;

  InAppMerger(InAppDocument? root) : root = Map.from(root ?? {});

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
    switch (type) {
      case InAppFieldValues.arrayFilter:
        return _applyArrayFilter(field, baseValue, modifier);
      case InAppFieldValues.arrayRemove:
        return _applyArrayRemove(field, baseValue, modifier);
      case InAppFieldValues.arrayUnify:
        return _applyArrayUnify(field, baseValue);
      case InAppFieldValues.arrayUnion:
        return _applyArrayUnion(field, baseValue, modifier);
      case InAppFieldValues.delete:
        return _applyDelete(field);
      case InAppFieldValues.increment:
        return _applyIncrement(field, baseValue, modifier);
      case InAppFieldValues.timestamp:
        return _applyTimestamp(field, modifier);
      case InAppFieldValues.toggle:
        return _applyToggle(field, baseValue, modifier);
      case InAppFieldValues.none:
        return;
    }
  }

  void _applyArrayFilter(String field, dynamic base, dynamic modifier) {
    if (base is List && modifier is bool Function(Object?)) {
      final mergedList = List.from(base.where(modifier));
      root[field] = mergedList.isEmpty ? null : mergedList;
    }
  }

  void _applyArrayRemove(String field, dynamic base, dynamic modifier) {
    if (base is List && modifier is List) {
      final filteredList = base.where((i) => !modifier.contains(i)).toList();
      root[field] = filteredList;
    }
  }

  void _applyArrayUnify(String field, dynamic base) {
    if (base is List) {
      final mergedList = base.toSet().toList();
      root[field] = mergedList;
    }
  }

  void _applyArrayUnion(String field, dynamic base, dynamic modifier) {
    if (base is List? && modifier is List) {
      final mergedList = List.from(base ?? [])..addAll(modifier);
      root[field] = mergedList;
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

  void _applyTimestamp(String field, dynamic modifier) {
    final now = DateTime.now();
    root[field] = (modifier is bool ? modifier : false)
        ? now.millisecondsSinceEpoch
        : now.toString();
  }

  void _applyToggle(String field, dynamic base, dynamic modifier) {
    if (base is bool?) {
      base ??= (modifier is bool ? modifier : false);
      final newValue = !base;
      root[field] = newValue;
    }
  }
}
