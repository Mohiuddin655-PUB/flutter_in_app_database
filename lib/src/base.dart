part of 'database.dart';

typedef InAppValue = Object?;
typedef InAppDocument = Map<String, InAppValue>;

class InAppSetOptions {
  final bool merge;

  const InAppSetOptions({
    this.merge = false,
  });
}

enum InAppReadType {
  collection,
  document;

  bool get isCollection => this == collection;

  bool get isDocument => this == document;
}

enum InAppWriteType {
  collection,
  document;

  bool get isCollection => this == collection;

  bool get isDocument => this == document;
}

class InAppWriteLimitation {
  final int limit;
  final bool limitByRecent;

  const InAppWriteLimitation(
    this.limit, {
    this.limitByRecent = true,
  });
}
