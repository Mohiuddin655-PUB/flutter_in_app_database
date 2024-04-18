enum InAppFieldPaths {
  documentId,
  none;

  bool get isDocumentId => this == documentId;

  bool get isNone => this == none;
}

class InAppFieldPath {
  final Object? field;
  final InAppFieldPaths type;

  const InAppFieldPath(
    this.field, [
    this.type = InAppFieldPaths.none,
  ]);

  static InAppFieldPath get documentId {
    return const InAppFieldPath(null, InAppFieldPaths.documentId);
  }
}
