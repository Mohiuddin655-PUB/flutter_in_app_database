part of 'database.dart';

abstract class InAppReference {
  final String ref;
  final InAppDatabase _db;

  const InAppReference({required this.ref, required InAppDatabase db})
      : _db = db;

  InAppDatabase get database => _db;

  String get _id => _db._version._id;

  String get _idField => _db._version._idRef;

  String get _idFieldSecondary => _db._version._isV1 ? 'id' : '_id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppReference &&
          runtimeType == other.runtimeType &&
          other.ref == ref;

  @override
  int get hashCode => Object.hash(runtimeType, ref);

  @override
  String toString() => '$runtimeType($ref)';
}
