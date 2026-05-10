class InAppPointer {
  final List<String> components;

  InAppPointer(String path)
      : components = List.unmodifiable(
          path.split('/').where((e) => e.isNotEmpty),
        );

  String get path => components.join('/');

  String get id => components.isEmpty ? '' : components.last;

  bool isCollection() => components.length.isOdd;

  bool isDocument() => components.length.isEven && components.isNotEmpty;

  String collectionPath(String collectionPath) {
    if (!isDocument()) {
      throw StateError('Collections can only be created from a document path.');
    }
    if (collectionPath.isEmpty) {
      throw ArgumentError.value(
        collectionPath,
        'collectionPath',
        'must not be empty.',
      );
    }
    return '$path/$collectionPath';
  }

  String documentPath(String documentPath) {
    if (!isCollection()) {
      throw StateError('Documents can only be created from a collection path.');
    }
    if (documentPath.isEmpty) {
      throw ArgumentError.value(
        documentPath,
        'documentPath',
        'must not be empty.',
      );
    }
    return '$path/$documentPath';
  }

  String? parentPath() {
    if (components.length < 2) return null;
    return components.sublist(0, components.length - 1).join('/');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InAppPointer && other.path == path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'InAppPointer($path)';
}
