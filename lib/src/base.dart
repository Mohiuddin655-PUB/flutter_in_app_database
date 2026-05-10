part of 'database.dart';

typedef InAppValue = Object?;
typedef InAppDocument = Map<String, InAppValue>;

class InAppSetOptions {
  final bool merge;
  final List<Object>? mergeFields;

  const InAppSetOptions({this.merge = false, this.mergeFields});

  static const InAppSetOptions defaults = InAppSetOptions();
  static const InAppSetOptions mergeAll = InAppSetOptions(merge: true);

  bool get hasMergeFields => mergeFields != null && mergeFields!.isNotEmpty;

  bool get isMerge => merge || hasMergeFields;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppSetOptions &&
          other.merge == merge &&
          _listEquals(other.mergeFields, mergeFields);

  @override
  int get hashCode =>
      Object.hash(merge, mergeFields == null ? 0 : mergeFields!.length);

  static bool _listEquals(List? a, List? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class InAppSnapshotMetadata {
  final bool hasPendingWrites;
  final bool isFromCache;

  const InAppSnapshotMetadata({
    this.hasPendingWrites = false,
    this.isFromCache = true,
  });

  static const InAppSnapshotMetadata defaults = InAppSnapshotMetadata();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppSnapshotMetadata &&
          other.hasPendingWrites == hasPendingWrites &&
          other.isFromCache == isFromCache;

  @override
  int get hashCode => Object.hash(hasPendingWrites, isFromCache);

  @override
  String toString() =>
      'InAppSnapshotMetadata(hasPendingWrites: $hasPendingWrites, isFromCache: $isFromCache)';
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

  const InAppWriteLimitation(this.limit, {this.limitByRecent = true});

  bool get isUnlimited => limit <= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppWriteLimitation &&
          other.limit == limit &&
          other.limitByRecent == limitByRecent;

  @override
  int get hashCode => Object.hash(limit, limitByRecent);
}

class InAppDatabaseException implements Exception {
  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;

  const InAppDatabaseException(
    this.message, {
    this.code,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final base = code == null
        ? 'InAppDatabaseException: $message'
        : 'InAppDatabaseException[$code]: $message';
    return cause == null ? base : '$base (cause: $cause)';
  }
}
