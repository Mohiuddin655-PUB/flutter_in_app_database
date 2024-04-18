class InAppPagingOptions {
  final bool fetchFromLast;
  final int? fetchingSize;
  final int? initialSize;

  const InAppPagingOptions({
    int? initialFetchSize,
    this.fetchFromLast = false,
    this.fetchingSize,
  }) : initialSize = initialFetchSize ?? fetchingSize;

  InAppPagingOptions copy({
    bool? fetchFromLast,
    int? fetchingSize,
    int? initialSize,
  }) {
    return InAppPagingOptions(
      initialFetchSize: initialSize ?? this.initialSize,
      fetchingSize: fetchingSize ?? this.fetchingSize,
      fetchFromLast: fetchFromLast ?? this.fetchFromLast,
    );
  }
}
