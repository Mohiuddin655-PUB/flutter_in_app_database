part of 'database.dart';

extension InAppDataFinder on Future<InAppDatabase> {
  Future<InAppClearByFinder<T>> clearBy<T extends Entity>({
    required String path,
    required InAppDataBuilder<T> builder,
  }) async {
    try {
      return output<T>(path, builder).then((value) {
        if (value.isNotEmpty) {
          return input(path, null).then((successful) {
            if (successful) {
              return (true, value, null, Status.ok);
            } else {
              return (false, null, "Database error!", Status.error);
            }
          }).onError((e, s) {
            return (false, null, "$e", Status.failure);
          });
        } else {
          return (false, null, null, Status.notFound);
        }
      });
    } catch (_) {
      return (false, null, "$_", Status.failure);
    }
  }

  Future<InAppDeleteByIdFinder<T>> deleteById<T extends Entity>({
    required String path,
    required String id,
    required InAppDataBuilder<T> builder,
  }) async {
    if (id.isNotEmpty) {
      try {
        return output<T>(path, builder).then((value) {
          final result = value.where((E) => E.id == id).toList();
          if (result.isNotEmpty) {
            value.removeWhere((E) => E.id == id);
            return input(path, value).then((successful) {
              if (successful) {
                return (true, result.first, value, null, Status.ok);
              } else {
                return (false, null, null, "Database error!", Status.error);
              }
            }).onError((e, s) {
              return (false, null, null, "$e", Status.failure);
            });
          } else {
            return (false, null, null, null, Status.notFound);
          }
        });
      } catch (_) {
        return (false, null, null, "$_", Status.failure);
      }
    } else {
      return (false, null, null, null, Status.invalidId);
    }
  }

  Future<InAppFindByFinder<T>> findBy<T extends Entity>({
    required String path,
    required InAppDataBuilder<T> builder,
  }) async {
    try {
      return output<T>(path, builder).then((value) {
        if (value.isNotEmpty) {
          return (true, value, null, Status.alreadyFound);
        } else {
          return (false, null, null, Status.notFound);
        }
      });
    } catch (_) {
      return (false, null, "$_", Status.failure);
    }
  }

  Future<InAppFindByIdFinder<T>> findById<T extends Entity>({
    required String path,
    required String id,
    required InAppDataBuilder<T> builder,
  }) async {
    if (id.isNotEmpty) {
      try {
        return output<T>(path, builder).then((value) {
          final result = value.where((E) => E.id == id).toList();
          if (result.isNotEmpty) {
            return (true, result.first, value, null, Status.alreadyFound);
          } else {
            return (false, null, null, null, Status.notFound);
          }
        });
      } catch (_) {
        return (false, null, null, "$_", Status.failure);
      }
    } else {
      return (false, null, null, null, Status.invalidId);
    }
  }

  Future<InAppUpdateByDataFinder<T>> updateByData<T extends Entity>({
    required String path,
    required String id,
    required Map<String, dynamic> data,
    required InAppDataBuilder<T> builder,
  }) async {
    if (id.isNotEmpty) {
      try {
        return output<T>(path, builder).then((value) {
          T? B;
          var i = value.indexWhere((E) {
            if (id == E.id) {
              B = E;
              return true;
            } else {
              return false;
            }
          });
          if (i > -1) {
            value.removeAt(i);
            value.insert(i, builder(data));
            return input(path, value).then((task) {
              if (task) {
                return (true, B, value, null, Status.ok);
              } else {
                return (false, null, null, "Database error!", Status.error);
              }
            }).onError((e, s) {
              return (false, null, null, "$e", Status.failure);
            });
          } else {
            return (false, null, null, null, Status.notFound);
          }
        });
      } catch (_) {
        return (false, null, null, "$_", Status.failure);
      }
    } else {
      return (false, null, null, null, Status.invalidId);
    }
  }

  Future<InAppSetByDataFinder<T>> setByData<T extends Entity>({
    required String path,
    required T data,
    required InAppDataBuilder<T> builder,
  }) async {
    if (data.id.isNotEmpty) {
      try {
        return output<T>(path, builder).then((value) {
          final insertable = value.where((E) => E.id == data.id).isEmpty;
          if (insertable) {
            value.add(data);
            return input(path, value).then((task) {
              if (task) {
                return (true, null, value, null, Status.ok);
              } else {
                return (false, null, null, "Database error!", Status.error);
              }
            }).onError((e, s) {
              return (false, null, null, "$e", Status.error);
            });
          } else {
            return (false, data, null, null, Status.alreadyFound);
          }
        });
      } catch (_) {
        return (false, null, null, "$_", Status.failure);
      }
    } else {
      return (false, null, null, null, Status.invalidId);
    }
  }

  Future<InAppSetByListFinder<T>> setByList<T extends Entity>({
    required String path,
    required List<T> data,
    required InAppDataBuilder<T> builder,
  }) async {
    if (data.isNotEmpty) {
      try {
        return output<T>(path, builder).then((value) {
          List<T> current = [];
          List<T> ignores = [];
          for (var i in data) {
            final insertable = value.where((E) => E.id == i.id).isEmpty;
            if (insertable) {
              current.add(i);
              value.add(i);
            } else {
              ignores.add(i);
            }
          }
          if (data.length != ignores.length) {
            return input(path, value).then((task) {
              if (task) {
                return (true, current, ignores, value, null, Status.ok);
              } else {
                return (
                  false,
                  null,
                  null,
                  null,
                  "Database error!",
                  Status.error,
                );
              }
            }).onError((e, s) {
              return (false, null, null, null, "$e", Status.failure);
            });
          } else {
            return (false, null, ignores, null, null, Status.alreadyFound);
          }
        });
      } catch (_) {
        return (false, null, null, null, "$_", Status.failure);
      }
    } else {
      return (false, null, null, null, null, Status.invalidId);
    }
  }
}
