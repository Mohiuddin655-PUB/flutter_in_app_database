part of '../src/database.dart';

mixin _LoggerMixin {
  bool get showLogs;

  void _log(Object? msg, {String field = '', String action = ''}) {
    if (!showLogs || kReleaseMode) return;
    var text = msg.toString();
    if (field.isNotEmpty) {
      text = '${action.isEmpty ? field : '$action($field)'}: $text';
    } else if (action.isNotEmpty) {
      text = '$action: $text';
    }
    log(text, name: 'IN_APP_DATABASE');
  }
}
