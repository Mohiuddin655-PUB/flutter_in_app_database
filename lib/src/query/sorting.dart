part of 'query.dart';

class Sorting {
  final String field;
  final bool descending;

  const Sorting(
    this.field, [
    this.descending = false,
  ]);
}
