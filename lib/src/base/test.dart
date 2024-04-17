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
  // _queryTest();
  _sortingTest();
  // _selectionTest();
}

void _queryTest() async {
  // Example Firestore-like data
  List<Map<String, dynamic>> firestoreData = UserFaker.generateUsers(100);

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
      .get();

  querySnapshot.output("query");
}

void _sortingTest() async {
  // Example Firestore-like data
  List<Map<String, dynamic>> firestoreData = [
    {'username': 'olivia_adams', 'email': 'olivia_adams@hotmail.com', 'age': 57, 'country': 'Japan'},
    {'username': 'olivia_adams', 'email': 'olivia_adams@test.com', 'age': 36, 'country': 'Brazil'},
    {'username': 'daniel_white', 'email': 'daniel_white@example.com', 'age': 43, 'country': 'India'},
    {'username': 'olivia_adams', 'email': 'olivia_adams@demo.com', 'age': 53, 'country': 'Japan'},
    {'username': 'peter_brown', 'email': 'peter_brown@gmail.com', 'age': 57, 'country': 'China'},
    {'username': 'olivia_adams', 'email': 'olivia_adams@yahoo.com', 'age': 30, 'country': 'Brazil'},
    {'username': 'emma_smith', 'email': 'emma_smith@example.com', 'age': 49, 'country': 'Germany'},
    {'username': 'peter_brown', 'email': 'peter_brown@hotmail.com', 'age': 65, 'country': 'Brazil'},
    {'username': 'sarah_carter', 'email': 'sarah_carter@gmail.com', 'age': 55, 'country': 'Japan'},
    {'username': 'olivia_adams', 'email': 'olivia_adams@yahoo.com', 'age': 53, 'country': 'Australia'},
  ];

  // Initialize Firestore
  var firestore = Firestore(firestoreData);

  // Firestore-like query with multiple orderBy statements
  var querySnapshot = await firestore
      .collection('users')
      .orderBy("username", descending: false)
      .orderBy("age", descending: true)
      .orderBy("country", descending: false)
      .get();

  querySnapshot.output("Sorted by username(asc), age(des) and country(asc)");
/*
  From Data:
  {username: olivia_adams, email: olivia_adams@hotmail.com, age: 57, country: Japan}
  {username: olivia_adams, email: olivia_adams@test.com, age: 36, country: Brazil}
  {username: daniel_white, email: daniel_white@example.com, age: 43, country: India}
  {username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Japan}
  {username: peter_brown, email: peter_brown@gmail.com, age: 57, country: China}
  {username: olivia_adams, email: olivia_adams@yahoo.com, age: 30, country: Brazil}
  {username: emma_smith, email: emma_smith@example.com, age: 49, country: Germany}
  {username: peter_brown, email: peter_brown@hotmail.com, age: 65, country: Brazil}
  {username: sarah_carter, email: sarah_carter@gmail.com, age: 55, country: Japan}
  {username: olivia_adams, email: olivia_adams@yahoo.com, age: 53, country: Australia}

  To Result:
  {username: daniel_white, email: daniel_white@example.com, age: 43, country: India}
  {username: emma_smith, email: emma_smith@example.com, age: 49, country: Germany}
  {username: olivia_adams, email: olivia_adams@hotmail.com, age: 57, country: Japan}
  {username: olivia_adams, email: olivia_adams@yahoo.com, age: 53, country: Australia}
  {username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Japan}
  {username: olivia_adams, email: olivia_adams@test.com, age: 36, country: Brazil}
  {username: olivia_adams, email: olivia_adams@yahoo.com, age: 30, country: Brazil}
  {username: peter_brown, email: peter_brown@hotmail.com, age: 65, country: Brazil}
  {username: peter_brown, email: peter_brown@gmail.com, age: 57, country: China}
  {username: sarah_carter, email: sarah_carter@gmail.com, age: 55, country: Japan}
  */
}

void _selectionTest() async {
  // Example Firestore-like data
  List<Map<String, dynamic>> firestoreData = [
    {'username': 'alice', 'age': 25, 'country': 'USA'},
    {'username': 'bob', 'age': 30, 'country': 'Canada'},
    {'username': 'charlie', 'age': 35, 'country': 'Australia'},
    {'username': 'daniel', 'age': 40, 'country': 'UK'},
    {'username': 'emma', 'age': 45, 'country': 'Germany'}
  ];

  // Initialize Firestore
  var firestore = Firestore(firestoreData);

  // Firestore-like query with selection mode collection
  var all = await firestore.collection('users').get();
  all.output("all");

  // Firestore-like query with selection mode startAt
  var startAt = await firestore.collection('users').startAt(['charlie']).get();
  startAt.output("startAt");

  // Firestore-like query with selection mode endAt
  var endAt = await firestore.collection('users').endAt(['charlie']).get();
  endAt.output("endAt");

  // Firestore-like query with selection mode startAfter
  var startAfter =
      await firestore.collection('users').startAfter(['charlie']).get();
  startAfter.output("startAfter");

  // Firestore-like query with selection mode endBefore
  var endBefore =
      await firestore.collection('users').endBefore(['charlie']).get();
  endBefore.output("endBefore");

  // Firestore-like query with selection mode startAfterDocument
  var startAfterDocument = await firestore
      .collection('users')
      .startAfterDocument(
          {'username': 'charlie', 'age': 35, 'country': 'Australia'}).get();
  startAfterDocument.output("startAfterDocument");

  // Firestore-like query with selection mode endBeforeDocument
  var endBeforeDocument = await firestore.collection('users').endBeforeDocument(
      {'username': 'charlie', 'age': 35, 'country': 'Australia'}).get();
  endBeforeDocument.output("endBeforeDocument");

  // Firestore-like query with selection mode startAtEndAt
  var startAtEndAt = await firestore
      .collection('users')
      .startAt(['bob']).endAt(["daniel"]).get();
  startAtEndAt.output("startAtEndAt");

  // Firestore-like query with selection mode startAfterEndBefore
  var startAfterEndBefore = await firestore
      .collection('users')
      .startAfter(['bob']).endBefore(["daniel"]).get();
  startAfterEndBefore.output("startAfterEndBefore");

  // Firestore-like query with selection mode startAfterDocumentEndBeforeDocument
  var startAfterDocumentEndBeforeDocument =
      await firestore.collection('users').startAfterDocument(
    {'username': 'bob', 'age': 30, 'country': 'Canada'},
  ).endBeforeDocument(
    {'username': 'daniel', 'age': 40, 'country': 'UK'},
  ).get();
  startAfterDocumentEndBeforeDocument
      .output("startAfterDocumentEndBeforeDocument");
  /*
  OUTPUTS:

  Query Result: all
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}

  Query Result: startAt
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}

  Query Result: startAfter
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}

  Query Result: startAfterDocument
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}

  Query Result: endAt
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}

  Query Result: endBefore
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}

  Query Result: endBeforeDocument
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}

  Query Result: startAtEndAt
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}

  Query Result: startAfterEndBefore
  {username: charlie, age: 35, country: Australia}

  Query Result: startAfterDocumentEndBeforeDocument
  {username: charlie, age: 35, country: Australia}
  */
}

extension on List {
  void output(String name) {
    print('\n$name');
    forEach(print);
  }
}
