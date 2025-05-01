import 'package:pluralize/pluralize.dart';

final class PathDetails {
  final String path;
  final String format;
  final String lastSegment;
  final Map<String, String> values;

  const PathDetails._({
    required this.path,
    required this.format,
    required this.lastSegment,
    required this.values,
  });

  @override
  String toString() {
    return "$PathDetails(\n\tpath: $path, \n\tformat: $format, \n\tlastSegment: $lastSegment, \n\tvalues: $values\n)";
  }
}

class PathModifier {
  const PathModifier._();

  static PathDetails format(String path) {
    final segments = path.split('/');
    final buffer = StringBuffer();
    final values = <String, String>{};
    for (int i = 0; i < segments.length; i++) {
      if (i % 2 == 0) {
        buffer.write(segments[i]);
      } else {
        final key = '${Pluralize().singular(segments[i - 1])}_id';
        values[key] = segments[i];
        buffer.write("{$key}");
      }
      if (i < segments.length - 1) buffer.write('/');
    }
    return PathDetails._(
      path: path,
      format: buffer.toString(),
      lastSegment: segments.lastOrNull ?? '',
      values: values,
    );
  }

  static PathDetails path(String format, Map<String, String> values) {
    final segments = format.split('/');
    final buffer = StringBuffer();
    for (int i = 0; i < segments.length; i++) {
      if (i % 2 == 0) {
        buffer.write(segments[i]);
      } else {
        final key = '${Pluralize().singular(segments[i - 1])}_id';
        buffer.write(values[key]);
      }
      if (i < segments.length - 1) buffer.write('/');
    }
    return PathDetails._(
      path: buffer.toString(),
      format: format,
      lastSegment: segments.lastOrNull ?? '',
      values: values,
    );
  }
}
