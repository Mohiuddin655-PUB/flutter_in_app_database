enum InAppFieldValues {
  arrayUnion,
  arrayRemove,
  delete,
  serverTimestamp,
  increment,
  none;

  bool get isArrayUnion => this == arrayUnion;

  bool get isArrayRemove => this == arrayRemove;

  bool get isDelete => this == delete;

  bool get isServerTimestamp => this == serverTimestamp;

  bool get isIncrement => this == increment;

  bool get isNone => this == none;
}

class InAppFieldValue {
  final Object? value;
  final InAppFieldValues type;

  const InAppFieldValue(this.value, [this.type = InAppFieldValues.none]);

  factory InAppFieldValue.arrayUnion(List<dynamic> elements) {
    return InAppFieldValue(elements, InAppFieldValues.arrayUnion);
  }

  factory InAppFieldValue.arrayRemove(List<dynamic> elements) {
    return InAppFieldValue(elements, InAppFieldValues.arrayRemove);
  }

  factory InAppFieldValue.delete() {
    return const InAppFieldValue(null, InAppFieldValues.delete);
  }

  factory InAppFieldValue.serverTimestamp() {
    return const InAppFieldValue(null, InAppFieldValues.serverTimestamp);
  }

  factory InAppFieldValue.increment(num value) {
    return InAppFieldValue(value, InAppFieldValues.increment);
  }
}
