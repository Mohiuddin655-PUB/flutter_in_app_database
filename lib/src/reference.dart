import 'database.dart';

abstract class InAppReference {
  final String reference;
  final InAppDatabase db;

  const InAppReference({
    required this.reference,
    required this.db,
  });

  String get id => DateTime.now().millisecondsSinceEpoch.toString();
}
