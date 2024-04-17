import 'package:in_app_database/src/base/faker.dart';

import 'firestore.dart';

class Sorting {
  final String field;
  final bool descending;

  const Sorting(
    this.field, {
    this.descending = false,
  });
}

void main() async {
  // Example Firestore-like data
  List<Map<String, dynamic>> firestoreData = UserFaker.users;

  // Initialize Firestore
  var firestore = Firestore(firestoreData);

  // Firestore-like query
  var querySnapshot = await firestore
      .collection('users')
      // .where('username', isNull: true)
      .where('username', isNull: false)
      .where('username', isEqualTo: "daniel_white")
      // .where('username', isNotEqualTo: "daniel_white")
      // .where('age', isGreaterThan: 60)
      // .where('age', isGreaterThanOrEqualTo: 60)
      // .where('age', isLessThan: 60)
      .where('age', isLessThanOrEqualTo: 50)
      // .where('posts', arrayContains: "a")
      // .where('posts', arrayContains: "x")
      // .where('posts', arrayContainsAny: ["a", "x"])
      // .where('posts', arrayContainsAny: ["x", "y"])
      // .where('posts', arrayNotContains: "x")
      // .where('posts', arrayNotContains: "a")
      // .where('posts', arrayNotContainsAny: ["a", "x"])
      // .where('posts', arrayNotContainsAny: ["a", "b"])
      .orderBy(const [
        Sorting("username", descending: false),
        Sorting("age", descending: true),
        Sorting("country", descending: false),
      ])
      .get();

  // Print query results
  print('Query Result:');
  querySnapshot.forEach((doc) {
    print(doc);
  });
}
