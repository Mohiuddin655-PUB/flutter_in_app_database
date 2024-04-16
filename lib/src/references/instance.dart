part of 'base.dart';

typedef InAppCollections = Map<String, Object?>;
typedef InAppDatabaseReader = Future<InAppDocument> Function(
  InAppKeeper keeper,
);
typedef InAppDatabaseWriter = Future<InAppDocument> Function(
  InAppKeeper keeper,
);

class InAppKeeper {
  final String path;
  final String id;
  final InAppDocument doc;

  const InAppKeeper({
    required this.path,
    required this.id,
    required this.doc,
  });
}

class InAppDatabaseInstance {
  final String name;
  final DataKeeper keeper;
  InAppCollections collections = {};

  InAppDatabaseInstance._({
    required this.name,
    InAppCollections? collections,
    required this.keeper,
  }) : collections = collections ?? {};

  static InAppDatabaseInstance? _i;

  static InAppDatabaseInstance get i => _i!;

  static Future<InAppDatabaseInstance> init({
    InAppCollections? collections,
    SharedPreferences? preferences,
  }) async {
    preferences ??= await SharedPreferences.getInstance();
    return _i ??= InAppDatabaseInstance._(
      name: "__in_app_database__",
      collections: collections,
      keeper: DataKeeper(preferences),
    );
  }

  InAppCollectionReference ref(String field) {
    collections = root;
    return InAppCollectionReference(field, this);
  }

  InAppCollections get root => keeper.getItem(name) ?? {};

  Future<InAppCollections> build() {
    return keeper.setItem(name, collections).then((value) {
      return value ? collections : {};
    });
  }
}
