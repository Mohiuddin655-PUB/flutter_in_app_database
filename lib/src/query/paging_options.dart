part of 'query.dart';

class PagingOptions {
  final bool fetchFromLast;
  final int? fetchSize;
  final int? initialSize;

  const PagingOptions({
    int? initialFetchSize,
    this.fetchFromLast = false,
    this.fetchSize,
  }) : initialSize = initialFetchSize ?? fetchSize;

  PagingOptions copy({
    bool? fetchFromLast,
    int? fetchSize,
    int? initialSize,
  }) {
    return PagingOptions(
      initialFetchSize: initialSize ?? this.initialSize,
      fetchSize: fetchSize ?? this.fetchSize,
      fetchFromLast: fetchFromLast ?? this.fetchFromLast,
    );
  }
}
