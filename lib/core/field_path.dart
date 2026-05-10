enum InAppFieldPaths { documentId, none }

class InAppFieldPath {
  final Object? field;
  final InAppFieldPaths type;
  final List<String> segments;

  const InAppFieldPath._(this.field, this.type, this.segments);

  factory InAppFieldPath(List<String> segments) {
    if (segments.isEmpty) {
      throw ArgumentError.value(segments, 'segments', 'must not be empty.');
    }
    for (final s in segments) {
      if (s.isEmpty) {
        throw ArgumentError.value(
          segments,
          'segments',
          'segments cannot be empty strings.',
        );
      }
    }
    return InAppFieldPath._(
      segments.join('.'),
      InAppFieldPaths.none,
      List.unmodifiable(segments),
    );
  }

  factory InAppFieldPath.fromString(String path) {
    if (path.isEmpty) {
      throw ArgumentError.value(path, 'path', 'must not be empty.');
    }
    return InAppFieldPath(path.split('.'));
  }

  static const InAppFieldPath documentId = InAppFieldPath._(
    null,
    InAppFieldPaths.documentId,
    <String>[],
  );

  bool get isDocumentId => type == InAppFieldPaths.documentId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppFieldPath && other.field == field && other.type == type;

  @override
  int get hashCode => Object.hash(field, type);

  @override
  String toString() => isDocumentId ? '__name__' : segments.join('.');
}
