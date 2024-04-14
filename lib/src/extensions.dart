part of 'database.dart';

extension _LocalListExtension<T extends Entity> on List<T>? {
  List<T> get use => this ?? [];

  List<Map<String, dynamic>> get _ => use.map((_) => _.source).toList();
}

extension _LocalRawItemsExtension on List? {
  List get _ => this ?? [];
}
