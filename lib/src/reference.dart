part of 'database.dart';

abstract class InAppReference {
  final String reference;
  final InAppDatabase _db;

  const InAppReference({
    required this.reference,
    required InAppDatabase db,
  }) : _db = db;

  String get _id => DateTime.now().millisecondsSinceEpoch.toString();

  String get _idField => "_id";
}
