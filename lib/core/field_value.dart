enum InAppFieldValues {
  arrayFilter,
  arrayRemove,
  arrayUnify,
  arrayUnion,
  delete,
  increment,
  serverTimestamp,
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

  factory InAppFieldValue.arrayRemove(List<Object?> elements) {
    return InAppFieldValue(
      List.unmodifiable(elements),
      InAppFieldValues.arrayRemove,
    );
  }

  factory InAppFieldValue.arrayUnify() {
    return const InAppFieldValue(null, InAppFieldValues.arrayUnify);
  }

  factory InAppFieldValue.arrayUnion(List<Object?> elements) {
    return InAppFieldValue(
      List.unmodifiable(elements),
      InAppFieldValues.arrayUnion,
    );
  }

  factory InAppFieldValue.delete() {
    return const InAppFieldValue(null, InAppFieldValues.delete);
  }

  factory InAppFieldValue.increment(num value) {
    return InAppFieldValue(value, InAppFieldValues.increment);
  }

  factory InAppFieldValue.serverTimestamp([bool asNumberTimestamp = true]) {
    return InAppFieldValue(asNumberTimestamp, InAppFieldValues.serverTimestamp);
  }

  factory InAppFieldValue.serverTimestampAsString() {
    return const InAppFieldValue(false, InAppFieldValues.serverTimestamp);
  }

  factory InAppFieldValue.toggle([bool? initial]) {
    return InAppFieldValue(initial, InAppFieldValues.toggle);
  }

  @override
  String toString() => 'InAppFieldValue(type: $type, value: $value)';
}
