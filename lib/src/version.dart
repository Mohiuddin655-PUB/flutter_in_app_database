part of 'database.dart';

class InAppDatabaseVersion {
  final String code;

  const InAppDatabaseVersion.custom(this.code);

  static const InAppDatabaseVersion v1 = InAppDatabaseVersion.custom('v1');
  static const InAppDatabaseVersion v2 = InAppDatabaseVersion.custom('v2');

  static int _idCounter = 0;
  static int _lastTs = 0;

  String get _id {
    var ts = DateTime.now().microsecondsSinceEpoch;
    if (ts <= _lastTs) ts = _lastTs + 1;
    _lastTs = ts;
    _idCounter = (_idCounter + 1) & 0xFFFFFF;
    return '$ts-${_idCounter.toRadixString(16).padLeft(6, '0')}';
  }

  String get _idRef => code == v1.code ? '_id' : 'id';

  bool get _isV1 => code == v1.code;

  String _ref([String? path]) {
    if (path == null) return _isV1 ? '' : '$code/';
    return _isV1 ? path : '$code/$path';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppDatabaseVersion && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'InAppDatabaseVersion($code)';
}
