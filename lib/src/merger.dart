part of 'database.dart';

class InAppMerger {
  final InAppDocument root;

  InAppMerger(InAppDocument? root)
      : root = Map<String, InAppValue>.of(root ?? const {});

  InAppDocument merge(InAppDocument updates, {Set<String>? onlyFields}) {
    final extra = <String, InAppValue>{};
    for (final entry in updates.entries) {
      final field = entry.key;
      if (onlyFields != null && !_matchesAnyField(field, onlyFields)) continue;
      final fieldValue = entry.value;
      if (fieldValue is InAppFieldValue) {
        _apply(field, fieldValue, root[field]);
      } else if (fieldValue is Map<String, InAppValue>) {
        final base = root[field];
        final nestedOnly = _nestedOnly(field, onlyFields);
        if (base is Map) {
          final nested = InAppMerger(Map<String, InAppValue>.from(base));
          root[field] = nested.merge(fieldValue, onlyFields: nestedOnly);
        } else if (nestedOnly == null) {
          extra[field] = fieldValue;
        } else {
          final filtered = <String, InAppValue>{};
          fieldValue.forEach((k, v) {
            if (nestedOnly.contains(k) ||
                nestedOnly.any((p) => p.startsWith('$k.'))) {
              filtered[k] = v;
            }
          });
          if (filtered.isNotEmpty) extra[field] = filtered;
        }
      } else {
        extra[field] = fieldValue;
      }
    }
    if (extra.isNotEmpty) root.addAll(extra);
    return root;
  }

  static Set<String>? _nestedOnly(String field, Set<String>? only) {
    if (only == null) return null;
    if (only.contains(field)) return null;
    final result = <String>{};
    final prefix = '$field.';
    for (final f in only) {
      if (f.startsWith(prefix)) result.add(f.substring(prefix.length));
    }
    return result.isEmpty ? <String>{} : result;
  }

  static bool _matchesAnyField(String field, Set<String> only) {
    if (only.contains(field)) return true;
    for (final f in only) {
      if (f.startsWith('$field.')) return true;
    }
    return false;
  }

  void _apply(String field, InAppFieldValue fieldValue, Object? baseValue) {
    final modifier = fieldValue.value;
    switch (fieldValue.type) {
      case InAppFieldValues.arrayFilter:
        _applyArrayFilter(field, baseValue, modifier);
        break;
      case InAppFieldValues.arrayRemove:
        _applyArrayRemove(field, baseValue, modifier);
        break;
      case InAppFieldValues.arrayUnify:
        _applyArrayUnify(field, baseValue);
        break;
      case InAppFieldValues.arrayUnion:
        _applyArrayUnion(field, baseValue, modifier);
        break;
      case InAppFieldValues.delete:
        _applyDelete(field);
        break;
      case InAppFieldValues.increment:
        _applyIncrement(field, baseValue, modifier);
        break;
      case InAppFieldValues.serverTimestamp:
        _applyTimestamp(field, modifier);
        break;
      case InAppFieldValues.toggle:
        _applyToggle(field, baseValue, modifier);
        break;
      case InAppFieldValues.none:
        break;
    }
  }

  void _applyArrayFilter(String field, Object? base, Object? modifier) {
    if (base is List && modifier is bool Function(Object?)) {
      final merged = base.where(modifier).toList(growable: false);
      root[field] = merged;
    }
  }

  void _applyArrayRemove(String field, Object? base, Object? modifier) {
    if (base is List && modifier is List) {
      final removeSet = modifier.toSet();
      root[field] =
          base.where((e) => !removeSet.contains(e)).toList(growable: false);
    }
  }

  void _applyArrayUnify(String field, Object? base) {
    if (base is List) {
      final seen = <Object?>{};
      final merged = <Object?>[];
      for (final e in base) {
        if (seen.add(e)) merged.add(e);
      }
      root[field] = merged;
    }
  }

  void _applyArrayUnion(String field, Object? base, Object? modifier) {
    if ((base is List || base == null) && modifier is List) {
      final src = base is List ? base : const <Object?>[];
      final seen = <Object?>{...src};
      final merged = <Object?>[...src];
      for (final e in modifier) {
        if (seen.add(e)) merged.add(e);
      }
      root[field] = merged;
    }
  }

  void _applyIncrement(String field, Object? base, Object? modifier) {
    if ((base is num || base == null) && modifier is num) {
      final current = base is num ? base : 0;
      root[field] = current + modifier;
    }
  }

  void _applyDelete(String field) {
    root.remove(field);
  }

  void _applyTimestamp(String field, Object? modifier) {
    final now = DateTime.now().toUtc();
    final asNumber = modifier is bool ? modifier : false;
    root[field] = asNumber ? now.millisecondsSinceEpoch : now.toIso8601String();
  }

  void _applyToggle(String field, Object? base, Object? modifier) {
    if (base is bool) {
      root[field] = !base;
    } else if (modifier is bool) {
      root[field] = modifier;
    } else {
      root[field] = true;
    }
  }
}
