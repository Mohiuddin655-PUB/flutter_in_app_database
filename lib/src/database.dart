import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter_entity/flutter_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'extensions.dart';

part 'finder.dart';

part 'implement.dart';

part 'io_service.dart';

part 'keeper.dart';

part 'key_generator.dart';

part 'security.dart';

part 'typedefs.dart';

abstract class InAppDatabase extends DataKeeper {
  const InAppDatabase(super.preferences);

  Future<bool> input<T extends Entity>(
    String key,
    List<T>? data,
  );

  Future<List<T>> output<T extends Entity>(
    String key,
    InAppDataBuilder<T> builder,
  );

  Future<InAppClearByFinder<T>> clearBy<T extends Entity>({
    required String path,
    required InAppDataBuilder<T> builder,
  });

  Future<InAppDeleteByIdFinder<T>> deleteById<T extends Entity>({
    required String path,
    required String id,
    required InAppDataBuilder<T> builder,
  });

  Future<InAppFindByFinder<T>> findBy<T extends Entity>({
    required String path,
    required InAppDataBuilder<T> builder,
  });

  Future<InAppFindByIdFinder<T>> findById<T extends Entity>({
    required String path,
    required String id,
    required InAppDataBuilder<T> builder,
  });

  Future<InAppUpdateByDataFinder<T>> updateByData<T extends Entity>({
    required String path,
    required String id,
    required Map<String, dynamic> data,
    required InAppDataBuilder<T> builder,
  });

  Future<InAppSetByDataFinder<T>> setByData<T extends Entity>({
    required String path,
    required T data,
    required InAppDataBuilder<T> builder,
  });

  Future<InAppSetByListFinder<T>> setByList<T extends Entity>({
    required String path,
    required List<T> data,
    required InAppDataBuilder<T> builder,
  });
}
