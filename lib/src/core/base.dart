import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../query/query.dart';

part 'collection.dart';
part 'database.dart';
part 'document.dart';
part 'notifier.dart';
part 'params.dart';
part 'query.dart';
part 'reference.dart';

typedef InAppValue = Object?;
typedef InAppDocument = Map<String, InAppValue>;

class InAppSetOptions {
  final bool merge;

  const InAppSetOptions({
    this.merge = false,
  });
}
