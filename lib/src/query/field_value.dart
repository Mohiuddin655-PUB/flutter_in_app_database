part of 'query.dart';

enum DataFieldValueType {
  arrayUnion,
  arrayRemove,
  delete,
  serverTimestamp,
  increment,
  none,
}

class DataFieldValue {
  final Object? value;
  final DataFieldValueType type;

  const DataFieldValue(this.value, [this.type = DataFieldValueType.none]);

  factory DataFieldValue.arrayUnion(List<dynamic> elements) {
    return DataFieldValue(elements, DataFieldValueType.arrayUnion);
  }

  factory DataFieldValue.arrayRemove(List<dynamic> elements) {
    return DataFieldValue(elements, DataFieldValueType.arrayRemove);
  }

  factory DataFieldValue.delete() {
    return const DataFieldValue(null, DataFieldValueType.delete);
  }

  factory DataFieldValue.serverTimestamp() {
    return const DataFieldValue(null, DataFieldValueType.serverTimestamp);
  }

  factory DataFieldValue.increment(num value) {
    return DataFieldValue(value, DataFieldValueType.increment);
  }
}
