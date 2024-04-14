part of 'database.dart';

class InAppDatabaseImpl extends InAppDatabase {
  const InAppDatabaseImpl(super.preferences);

  static SharedPreferences? _proxy;

  static Future<InAppDatabaseImpl> get instance async {
    return InAppDatabaseImpl(
      _proxy ??= await SharedPreferences.getInstance(),
    );
  }

  static Future<InAppDatabase> get I => instance;

  static Future<InAppDatabase> getInstance() => instance;

  @override
  Future<bool> input<T extends Entity>(
    String key,
    List<T>? data,
  ) async {
    try {
      final db = this;
      if (data != null && data.isNotEmpty) {
        return db.setItems(key, data._);
      } else {
        return db.setItems(key, null);
      }
    } catch (_) {
      return Future.error(_);
    }
  }

  @override
  Future<List<T>> output<T extends Entity>(
    String key,
    InAppDataBuilder<T> builder,
  ) async {
    try {
      final db = this;
      return db.getItems(key)._.map((E) => builder(E)).toList();
    } catch (_) {
      return Future.error(_);
    }
  }

  @override
  Future<InAppClearByFinder<T>> clearBy<T extends Entity>({
    required String path,
    required InAppDataBuilder<T> builder,
  }) {
    return I.clearBy(path: path, builder: builder);
  }

  @override
  Future<InAppDeleteByIdFinder<T>> deleteById<T extends Entity>({
    required String path,
    required String id,
    required InAppDataBuilder<T> builder,
  }) {
    return I.deleteById(path: path, id: id, builder: builder);
  }

  @override
  Future<InAppFindByFinder<T>> findBy<T extends Entity>({
    required String path,
    required InAppDataBuilder<T> builder,
  }) {
    return I.findBy(path: path, builder: builder);
  }

  @override
  Future<InAppFindByIdFinder<T>> findById<T extends Entity>({
    required String path,
    required String id,
    required InAppDataBuilder<T> builder,
  }) {
    return I.findById(path: path, id: id, builder: builder);
  }

  @override
  Future<InAppUpdateByDataFinder<T>> updateByData<T extends Entity>({
    required String path,
    required String id,
    required Map<String, dynamic> data,
    required InAppDataBuilder<T> builder,
  }) {
    return I.updateByData(path: path, id: id, data: data, builder: builder);
  }

  @override
  Future<InAppSetByDataFinder<T>> setByData<T extends Entity>({
    required String path,
    required T data,
    required InAppDataBuilder<T> builder,
  }) {
    return I.setByData(path: path, data: data, builder: builder);
  }

  @override
  Future<InAppSetByListFinder<T>> setByList<T extends Entity>({
    required String path,
    required List<T> data,
    required InAppDataBuilder<T> builder,
  }) {
    return I.setByList(path: path, data: data, builder: builder);
  }
}
