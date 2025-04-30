enum InAppFieldValues {
  arrayFilter,
  arrayRemove,
  arrayUnify,
  arrayUnion,
  delete,
  increment,
  timestamp,
  toggle,
  none,
}

class InAppFieldValue {
  final Object? value;
  final InAppFieldValues type;

  const InAppFieldValue(this.value, [this.type = InAppFieldValues.none]);

  factory InAppFieldValue.arrayFilter(bool Function(Object?) where) {
    return InAppFieldValue(where, InAppFieldValues.arrayFilter);
  }

  factory InAppFieldValue.arrayRemove(List<dynamic> elements) {
    return InAppFieldValue(elements, InAppFieldValues.arrayRemove);
  }

  factory InAppFieldValue.arrayUnify() {
    return InAppFieldValue(null, InAppFieldValues.arrayUnify);
  }

  factory InAppFieldValue.arrayUnion(List<dynamic> elements) {
    return InAppFieldValue(elements, InAppFieldValues.arrayUnion);
  }

  factory InAppFieldValue.delete() {
    return const InAppFieldValue(null, InAppFieldValues.delete);
  }

  factory InAppFieldValue.increment(num value) {
    return InAppFieldValue(value, InAppFieldValues.increment);
  }

  factory InAppFieldValue.timestamp([bool asNumberTimestamp = false]) {
    return InAppFieldValue(asNumberTimestamp, InAppFieldValues.timestamp);
  }

  factory InAppFieldValue.toggle([bool? initial]) {
    return InAppFieldValue(initial, InAppFieldValues.toggle);
  }
}
