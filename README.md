## InAppDatabase

## CREATE DELEGATE

```dart
Map<String, Map<String, dynamic>> databases = {};

class DatabaseDelegate extends InAppDatabaseDelegate {
  @override
  Future<void> init(String dbName) async {
    databases[dbName] = {};
  }

  @override
  Future<Iterable<String>> paths(String dbName) async {
    final x = databases[dbName]!.keys.toList();
    return x;
  }

  @override
  Future<bool> delete(String dbName, String key) async {
    databases[dbName]!.remove(key);
    return true;
  }

  @override
  Future<bool> drop(String dbName) async {
    databases.remove(dbName);
    return true;
  }

  @override
  Future<Object?> read(String dbName, String key) async {
    return databases[dbName]![key];
  }

  @override
  Future<bool> write(String dbName, String key, String? value) async {
    if (value != null) {
      databases[dbName]![key] = value;
      return true;
    } else {
      databases[dbName]!.remove(key);
      return true;
    }
  }

  @override
  Future<InAppWriteLimitation?> limitation(
      String dbName,
      PathDetails details,
      ) async {
    return {
      "users": const InAppWriteLimitation(50),
      "posts": const InAppWriteLimitation(10),
      "users/{user_id}/posts": const InAppWriteLimitation(10),
    }[details.format]; // OPTIONAL
  }
}
```

## INITIALIZATIONS:

```dart
Future<void> main() async {
  InAppDatabase.init(
    delegate: DatabaseDelegate(), // required
    showLogs: true, // optional
    version: InAppDatabaseVersion.v2, // optional
  );
  // ...
}
```

## USE CASES:

### Add collection document

```dart
Future<InAppDocumentSnapshot?> addCollectionDocument() {
  return InAppDatabase.i.collection("users").add({
    "username": UserFaker.username,
    "email": UserFaker.email,
    "age": UserFaker.age,
    "country": UserFaker.country,
    "photoUrl": UserFaker.photoUrl,
  });
}
```

### Set new document

```dart
Future<InAppDocumentSnapshot?> setDocument() {
  return InAppDatabase.i.collection("users").doc("1").set({
    "username": "This is a username",
    "email": "This is a user email",
    "age": 24,
    "country": "Bangladesh",
    "photoUrl": "null",
    "hobbies": ['coding', 'gaming', 'sleeping'],
    "skills": ['flutter', 'android', 'node.js', 'spring boot', 'etc'],
  });
}
```

### Update specific document

```dart
Future<InAppDocumentSnapshot?> updateSpecificDocument() {
  return InAppDatabase.i.collection("users").doc("1").update({
    'username': "This is a updated username",
    'email': "This is a updated user email",
    'age': InAppFieldValue.increment(2),
    // to increment existing value
    'balance': InAppFieldValue.increment(-10.2),
    // to decrement existing value
    'hobbies': InAppFieldValue.arrayFilter((e) => e.isNotEmpty),
    // to filter existing array elements
    'hobbies': InAppFieldValue.arrayUnion(['swimming', 'swimming']),
    // to add new array elements
    'hobbies': InAppFieldValue.arrayUnify(),
    // to remove duplicate
    'skills': InAppFieldValue.arrayRemove(['node.js', 'spring boot']),
    // to remove existing array elements
    'timestamp': InAppFieldValue.timestamp(),
    // to add system timestamp internally
    'photoUrl': InAppFieldValue.delete(),
    // to delete field and value
    'is_verified': InAppFieldValue.toggle(),
    // to change bool status internally by toggle system true/false
  });
}
```

### Delete specific document

```dart
Future<bool> deleteSpecificDocument() {
  return InAppDatabase.i.collection("users").doc("1").delete();
}
```

### Get specific document

```dart
Future<InAppDocumentSnapshot?> getSpecificDocument() {
  return InAppDatabase.i.collection("users").doc("1").get();
}
```

### Get all documents from collection

```dart
Future<InAppQuerySnapshot> getAllDocuments() {
  return InAppDatabase.i.collection("users").get();
}
```

### Get specific documents by simple query

```dart
Future<InAppQuerySnapshot> getSpecificDocumentsByQuery() {
  return InAppDatabase.i
      .collection("users")
      .where("username", isEqualTo: "emma_smith")
      .get();
}
```

### Get specific documents by complex query

```dart
Future<InAppQuerySnapshot> getSpecificDocumentsByQuery() {
  return InAppDatabase.i
      .collection("users")
      .where(InAppFilter.or([
    InAppFilter("username", isEqualTo: "emma_smith"),
    InAppFilter("age", isGreaterThanOrEqualTo: 50),
  ]))
      .where("age", isLessThanOrEqualTo: 60)
      .orderBy("age", descending: false)
      .orderBy("email", descending: false)
      .limit(10)
      .get();
}
```

### Get all documents

```dart
Stream<InAppQuerySnapshot> getCollectionSnapshots() {
  return InAppDatabase.i.collection("users").snapshots();
}
```

### Listen specific documents by simple query

```dart
Stream<InAppQuerySnapshot> getSpecificDocumentsByQuerySnapshots() {
  return InAppDatabase.i
      .collection("users")
      .where("username", isEqualTo: "emma_smith")
      .snapshots();
}
```

### Listen specific documents by complex query

```dart
Stream<InAppQuerySnapshot> getComplexQuerySnapshots() {
  return InAppDatabase.i
      .collection("users")
      .where(InAppFilter.or([
    InAppFilter("username", isEqualTo: "emma_smith"),
    InAppFilter("age", isGreaterThanOrEqualTo: 50),
  ]))
      .where("age", isLessThanOrEqualTo: 60)
      .orderBy("age", descending: false)
      .orderBy("email", descending: false)
      .limit(10)
      .snapshots();
}
```