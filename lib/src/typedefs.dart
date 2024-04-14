part of 'database.dart';

typedef InAppDataBuilder<T extends Entity> = T Function(dynamic);

typedef InAppClearByFinder<T extends Entity> = (
  bool isValid,
  List<T>? backups,
  String? message,
  Status? status,
);
typedef InAppDeleteByIdFinder<T extends Entity> = (
  bool isValid,
  T? find,
  List<T>? result,
  String? message,
  Status? status,
);
typedef InAppFindByFinder<T extends Entity> = (
  bool isValid,
  List<T>? result,
  String? message,
  Status? status,
);
typedef InAppFindByIdFinder<T extends Entity> = (
  bool isValid,
  T? find,
  List<T>? result,
  String? message,
  Status? status,
);
typedef InAppUpdateByDataFinder<T extends Entity> = (
  bool isValid,
  T? data,
  List<T>? result,
  String? message,
  Status? status,
);
typedef InAppSetByDataFinder<T extends Entity> = (
  bool isValid,
  T? ignore,
  List<T>? result,
  String? message,
  Status? status,
);
typedef InAppSetByListFinder<T extends Entity> = (
  bool isValid,
  List<T>? current,
  List<T>? ignores,
  List<T>? result,
  String? message,
  Status? status,
);
