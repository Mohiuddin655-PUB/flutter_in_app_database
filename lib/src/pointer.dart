class InAppPointer {
  /// Create instance of [InAppPointer]
  InAppPointer(String path)
      : components =
            path.split('/').where((element) => element.isNotEmpty).toList();

  /// The InAppDatabase normalized path of the [InAppPointer].
  String get path => components.join('/');

  /// Pointer components of the path.
  ///
  /// This is used to determine whether a path is a collection or document.
  final List<String> components;

  /// Returns the ID for this pointer.
  ///
  /// The ID is the last component of a given path. For example, the ID of the
  /// document "user/123" is "123".
  String get id => components.last;

  /// Returns whether the given path is a pointer to a InAppDatabase collection.
  ///
  /// Collections are paths whose components are not dividable by 2, for example
  /// "collection/document/sub-collection".
  bool isCollection() => components.length.isOdd;

  /// Returns whether the given path is a pointer to a InAppDatabase document.
  ///
  /// Documents are paths whose components are dividable by 2, for example
  /// "collection/document".
  bool isDocument() => components.length.isEven;

  /// Returns a new collection path from the current document pointer.
  String collectionPath(String collectionPath) {
    assert(isDocument());
    return '$path/$collectionPath';
  }

  /// Returns a new document path from the current collection pointer.
  String documentPath(String documentPath) {
    assert(isCollection());
    return '$path/$documentPath';
  }

  /// Returns a path pointing to the parent of the current path.
  String? parentPath() {
    if (components.length < 2) {
      return null;
    }

    List<String> parentComponents = List<String>.from(components)..removeLast();
    return parentComponents.join('/');
  }

  @override
  bool operator ==(Object other) => other is InAppPointer && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
