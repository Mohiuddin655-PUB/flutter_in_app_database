part of 'database.dart';

extension _LocalExtension on Future<InAppDatabase> {
  Future<bool> input<T extends Entity>(
    String key,
    List<T>? data,
  ) async {
    var db = await this;
    return db.input(key, data);
  }

  Future<List<T>> output<T extends Entity>(
    String key,
    InAppDataBuilder<T> builder,
  ) async {
    var db = await this;
    return db.output(key, builder);
  }
}

