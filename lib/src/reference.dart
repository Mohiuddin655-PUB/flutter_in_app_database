part of 'database.dart';

abstract class InAppReference {
  final String reference;
  final InAppDatabase _db;

  const InAppReference({
    required this.reference,
    required InAppDatabase db,
  }) : _db = db;

  String get _id => _db._version._id;

  String get _idField => _db._version._idRef;

  String get _idFieldSecondary => "_id";
}
