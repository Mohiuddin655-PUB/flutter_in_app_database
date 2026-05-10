import 'package:pluralize/pluralize.dart' show Pluralize;

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathDetails &&
          other.path == path &&
          other.format == format &&
          other.lastSegment == lastSegment;

  @override
  int get hashCode => Object.hash(path, format, lastSegment);

  @override
  String toString() {
    return 'PathDetails(path: $path, format: $format, lastSegment: $lastSegment, values: $values)';
  }
}

class PathModifier {
  const PathModifier._();

  static final Pluralize _pluralize = Pluralize();

  static PathDetails format(String path) {
    final segments =
        path.split('/').where((e) => e.isNotEmpty).toList(growable: false);
    final buffer = StringBuffer();
    final values = <String, String>{};
    for (int i = 0; i < segments.length; i++) {
      if (i.isEven) {
        buffer.write(segments[i]);
      } else {
        final key = '${_pluralize.singular(segments[i - 1])}_id';
        values[key] = segments[i];
        buffer
          ..write('{')
          ..write(key)
          ..write('}');
      }
      if (i < segments.length - 1) buffer.write('/');
    }
    return PathDetails._(
      path: path,
      format: buffer.toString(),
      lastSegment: segments.isEmpty ? '' : segments.last,
      values: Map.unmodifiable(values),
    );
  }

  static PathDetails path(String format, Map<String, String> values) {
    final segments =
        format.split('/').where((e) => e.isNotEmpty).toList(growable: false);
    final buffer = StringBuffer();
    for (int i = 0; i < segments.length; i++) {
      if (i.isEven) {
        buffer.write(segments[i]);
      } else {
        final key = '${_pluralize.singular(segments[i - 1])}_id';
        buffer.write(values[key] ?? '');
      }
      if (i < segments.length - 1) buffer.write('/');
    }
    return PathDetails._(
      path: buffer.toString(),
      format: format,
      lastSegment: segments.isEmpty ? '' : segments.last,
      values: Map.unmodifiable(values),
    );
  }
}
