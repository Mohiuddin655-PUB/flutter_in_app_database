## InAppDatabase

## INITIALIZATIONS:
```dart
final _kLimitations = {
  "users": const InAppWriteLimitation(5),
  "posts": const InAppWriteLimitation(10),
  "users/user_id/posts": const InAppWriteLimitation(10),
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await SharedPreferences.getInstance();
  // Map<String, dynamic> db = {};
  InAppDatabase.init(
    limiter: (key) async {
      return _kLimitations[key]; // OPTIONAL
    },
    reader: (String key) async {
      return db.getString(key);
      // final x = db[key];
      // return x;
    },
    writer: (String key, String? value) async {
      if (value != null) {
        return db.setString(key, value);
        // db[key] = value;
        // return true;
      } else {
        return db.remove(key);
        // db.remove(key);
        // return true;
      }
    },
  );
  runApp(const MyApp());
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
    'balance': InAppFieldValue.increment(-10.2),
    'hobbies': InAppFieldValue.arrayUnion(['swimming']),
    'skills': InAppFieldValue.arrayRemove(['node.js', 'spring boot']),
    'timestamp': InAppFieldValue.serverTimestamp(),
    'photoUrl': InAppFieldValue.delete(),
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
### Get specific documents by simple query
```dart
Stream<InAppQuerySnapshot> getSpecificDocumentsByQuerySnapshots() {
  return InAppDatabase.i
      .collection("users")
      .where("username", isEqualTo: "emma_smith")
      .snapshots();
}
```

### Get specific documents by complex query
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