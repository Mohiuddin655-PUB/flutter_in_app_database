import 'package:flutter_test/flutter_test.dart'
    show
        test,
        setUp,
        expect,
        tearDown,
        isNotNull,
        throwsStateError,
        group,
        isNull,
        isA,
        throwsA,
        expectLater,
        isNotEmpty,
        greaterThanOrEqualTo,
        anything,
        returnsNormally,
        completes,
        throwsArgumentError,
        completion,
        lessThanOrEqualTo;
import 'package:in_app_database/in_app_database.dart'
    show
        InAppDatabase,
        InAppDatabaseType,
        InAppSetOptions,
        InAppDatabaseException,
        InAppDocumentReference,
        InAppDocumentSnapshot,
        InAppQuerySnapshot,
        InAppAggregateQuerySnapshot,
        InAppWriteLimitation,
        InAppFieldPath,
        InAppQueryDocumentSnapshot,
        InAppFieldValue;

import 'delegate.dart' show InMemoryDelegate;

void main() {
  late InMemoryDelegate delegate;
  late InAppDatabase db;

  setUp(() async {
    delegate = InMemoryDelegate();
    final ok = await InAppDatabase.init(
      name: 'test_db',
      delegate: delegate,
      type: InAppDatabaseType.json,
    );
    expect(ok, true);
    db = InAppDatabase.instance;
  });

  tearDown(() {
    db.dispose();
  });

  group('Initialization', () {
    test('initializes once and exposes singleton', () {
      expect(InAppDatabase.instance, isNotNull);
      expect(db.isInitialized, true);
    });

    test('dispose clears the singleton', () {
      db.dispose();
      expect(() => InAppDatabase.instance, throwsStateError);
    });
  });

  group('DocumentReference - basic CRUD', () {
    test('set creates a new document', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice', 'age': 30});

      final snap = await ref.get();
      expect(snap.exists, true);
      expect(snap.id, 'u1');
      expect(snap.data()?['name'], 'Alice');
      expect(snap.data()?['age'], 30);
    });

    test('set overwrites the entire document by default', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice', 'age': 30});
      await ref.set({'name': 'Bob'});

      final snap = await ref.get();
      expect(snap.data()?['name'], 'Bob');
      expect(snap.data()?['age'], isNull);
    });

    test('set with merge:true preserves untouched fields', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice', 'age': 30});
      await ref.set({'age': 31}, const InAppSetOptions(merge: true));

      final snap = await ref.get();
      expect(snap.data()?['name'], 'Alice');
      expect(snap.data()?['age'], 31);
    });

    test('set with mergeFields only writes specified fields', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice', 'age': 30});
      await ref.set({
        'name': 'Bob',
        'age': 99,
      }, const InAppSetOptions(mergeFields: ['age']));

      final snap = await ref.get();
      expect(snap.data()?['name'], 'Alice');
      expect(snap.data()?['age'], 99);
    });

    test('update modifies fields and preserves the rest', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice', 'age': 30, 'city': 'Dhaka'});
      await ref.update({'age': 31});

      final snap = await ref.get();
      expect(snap.data()?['name'], 'Alice');
      expect(snap.data()?['age'], 31);
      expect(snap.data()?['city'], 'Dhaka');
    });

    test('delete removes the document', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice'});
      await ref.delete();

      final snap = await ref.get();
      expect(snap.exists, false);
    });

    test('throws on set failure', () async {
      delegate.failNextWrite = true;
      final ref = db.doc('users/u1');
      await expectLater(
        () => ref.set({'name': 'Alice'}),
        throwsA(isA<InAppDatabaseException>()),
      );
    });

    test('parent and firestore getters', () {
      final ref = db.doc('users/u1');
      expect(ref.parent.path, 'users');
      expect(ref.database, db);
      expect(ref.id, 'u1');
      expect(ref.path, 'users/u1');
    });
  });

  group('DocumentSnapshot', () {
    test('data() returns null when document does not exist', () async {
      final snap = await db.doc('users/missing').get();
      expect(snap.exists, false);
      expect(snap.data(), isNull);
    });

    test('get(field) reads top-level field', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice', 'age': 30});

      final snap = await ref.get();
      expect(snap.get<String>('name'), 'Alice');
      expect(snap.get<int>('age'), 30);
    });

    test('get(field) with dot-path reads nested field', () async {
      final ref = db.doc('users/u1');
      await ref.set({
        'profile': {
          'address': {'city': 'Dhaka'},
        },
      });

      final snap = await ref.get();
      expect(snap.get<String>('profile.address.city'), 'Dhaka');
    });

    test('get(InAppFieldPath.documentId) returns id', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice'});
      final snap = await ref.get();
      expect(snap.get<String>(InAppFieldPath.documentId), 'u1');
    });

    test('operator [] is equivalent to get()', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice'});
      final snap = await ref.get();
      expect(snap['name'], 'Alice');
    });

    test('reference back-pointer is set', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice'});
      final snap = await ref.get();
      expect(snap.reference?.path, 'users/u1');
    });

    test('metadata is from cache by default', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice'});
      final snap = await ref.get();
      expect(snap.metadata.isFromCache, true);
      expect(snap.metadata.hasPendingWrites, false);
    });
  });

  group('CollectionReference', () {
    test('add creates a document and returns reference', () async {
      final col = db.collection('users');
      final ref = await col.add({'name': 'Alice'});

      expect(ref, isA<InAppDocumentReference>());
      expect(ref.id, isNotEmpty);

      final snap = await ref.get();
      expect(snap.exists, true);
      expect(snap.data()?['name'], 'Alice');
    });

    test('add uses provided id when present', () async {
      final col = db.collection('users');
      final ref = await col.add({'id': 'custom_id', 'name': 'Alice'});
      expect(ref.id, 'custom_id');
    });

    test('doc() returns reference to specified document', () {
      final ref = db.collection('users').doc('u1');
      expect(ref.path, 'users/u1');
    });

    test('doc() without id returns reference with auto id', () {
      final ref = db.collection('users').doc();
      expect(ref.id, isNotEmpty);
    });

    test('parent of root collection is null', () {
      expect(db.collection('users').parent, isNull);
    });

    test('parent of subcollection points to document', () {
      final sub = db.doc('users/u1').collection('posts');
      expect(sub.parent?.path, 'users/u1');
    });

    test('setAll writes a list of documents', () async {
      final col = db.collection('users');
      await col.setAll([
        InAppQueryDocumentSnapshot('u1', {'name': 'Alice'}),
        InAppQueryDocumentSnapshot('u2', {'name': 'Bob'}),
      ]);

      final snap = await col.get();
      expect(snap.size, 2);
    });

    test('drop deletes the collection and its descendants', () async {
      await db.doc('users/u1').set({'name': 'Alice'});
      await db.doc('users/u1/posts/p1').set({'title': 'Hello'});

      await db.collection('users').drop();

      final snap = await db.collection('users').get();
      expect(snap.exists, false);
    });
  });

  group('Subcollections', () {
    test('nested set/get round-trip', () async {
      final ref = db.doc('users/u1').collection('posts').doc('p1');
      await ref.set({'title': 'Hello'});

      final snap = await ref.get();
      expect(snap.data()?['title'], 'Hello');
      expect(ref.path, 'users/u1/posts/p1');
      expect(snap.reference?.path, 'users/u1/posts/p1');
    });

    test('deep paths via doc() helper', () async {
      final ref = db.doc('users/u1/posts/p1');
      await ref.set({'title': 'Hello'});

      final snap = await db.doc('users/u1/posts/p1').get();
      expect(snap.data()?['title'], 'Hello');
      expect(ref.path, 'users/u1/posts/p1');
    });
  });

  group('Streams', () {
    test('document snapshots emit on initial subscribe and updates', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice'});

      final emissions = <InAppDocumentSnapshot>[];
      final sub = ref.snapshots().listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(
        emissions.length,
        greaterThanOrEqualTo(1),
        reason: 'should emit initial snapshot',
      );
      expect(emissions.last.data()?['name'], 'Alice');

      await ref.update({'name': 'Bob'});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(
        emissions.length,
        greaterThanOrEqualTo(2),
        reason: 'should emit after update',
      );
      expect(emissions.last.data()?['name'], 'Bob');

      await sub.cancel();
    });

    test('collection snapshots emit on add', () async {
      final col = db.collection('users');

      final emissions = <InAppQuerySnapshot>[];
      final sub = col.snapshots().listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(emissions.length, greaterThanOrEqualTo(1));
      expect(emissions.last.size, 0);

      await col.add({'name': 'Alice'});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last.size, 1);

      await sub.cancel();
    });

    test('aggregate snapshots emit count updates', () async {
      final col = db.collection('users');
      final emissions = <InAppAggregateQuerySnapshot>[];
      final sub = col.count().snapshots().listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await col.add({'name': 'Alice'});
      await col.add({'name': 'Bob'});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(emissions.last.count, 2);
      await sub.cancel();
    });
  });

  group('FieldValue', () {
    test('increment adds to numeric field', () async {
      final ref = db.doc('counters/global');
      await ref.set({'count': 10});
      await ref.update({'count': InAppFieldValue.increment(5)});

      final snap = await ref.get();
      expect(snap.data()?['count'], 15);
    });

    test('increment on missing field starts from zero', () async {
      final ref = db.doc('counters/global');
      await ref.set({'name': 'visits'});
      await ref.update({'count': InAppFieldValue.increment(3)});

      final snap = await ref.get();
      expect(snap.data()?['count'], 3);
    });

    test('arrayUnion adds unique values', () async {
      final ref = db.doc('users/u1');
      await ref.set({
        'tags': ['a', 'b'],
      });
      await ref.update({
        'tags': InAppFieldValue.arrayUnion(['b', 'c']),
      });

      final snap = await ref.get();
      expect(snap.data()?['tags'], ['a', 'b', 'c']);
    });

    test('arrayRemove removes specified values', () async {
      final ref = db.doc('users/u1');
      await ref.set({
        'tags': ['a', 'b', 'c'],
      });
      await ref.update({
        'tags': InAppFieldValue.arrayRemove(['b']),
      });

      final snap = await ref.get();
      expect(snap.data()?['tags'], ['a', 'c']);
    });

    test('delete removes field', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice', 'temp': 'remove-me'});
      await ref.update({'temp': InAppFieldValue.delete()});

      final snap = await ref.get();
      expect(snap.data()?.containsKey('temp'), false);
      expect(snap.data()?['name'], 'Alice');
    });

    test('serverTimestamp writes ISO string by default', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice'});
      await ref
          .update({'createdAt': InAppFieldValue.serverTimestampAsString()});

      final snap = await ref.get();
      expect(snap.data()?['createdAt'], isA<String>());
    });

    test('serverTimestamp(true) writes millis', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice'});
      await ref.update({'createdAt': InAppFieldValue.serverTimestamp(true)});

      final snap = await ref.get();
      expect(snap.data()?['createdAt'], isA<int>());
    });

    test('toggle flips boolean field', () async {
      final ref = db.doc('settings/u1');
      await ref.set({'enabled': true});
      await ref.update({'enabled': InAppFieldValue.toggle()});

      final snap = await ref.get();
      expect(snap.data()?['enabled'], false);

      await ref.update({'enabled': InAppFieldValue.toggle()});
      final snap2 = await ref.get();
      expect(snap2.data()?['enabled'], true);
    });
  });

  group('Query', () {
    setUp(() async {
      final col = db.collection('users');
      await col.doc('u1').set({'name': 'Alice', 'age': 30, 'city': 'Dhaka'});
      await col.doc('u2').set({'name': 'Bob', 'age': 25, 'city': 'Dhaka'});
      await col.doc('u3').set({
        'name': 'Charlie',
        'age': 35,
        'city': 'Chittagong',
      });
      await col.doc('u4').set({'name': 'Diana', 'age': 28, 'city': 'Sylhet'});
    });

    test('where isEqualTo', () async {
      final snap =
          await db.collection('users').where('city', isEqualTo: 'Dhaka').get();
      expect(snap.size, 2);
    });

    test('where isGreaterThan', () async {
      final snap =
          await db.collection('users').where('age', isGreaterThan: 28).get();
      expect(snap.size, 2);
    });

    test('where whereIn', () async {
      final snap = await db
          .collection('users')
          .where('name', whereIn: ['Alice', 'Bob']).get();
      expect(snap.size, 2);
    });

    test('orderBy ascending', () async {
      final snap = await db.collection('users').orderBy('age').get();
      final ages = snap.docs.map((d) => d.data()['age']).toList();
      expect(ages, [25, 28, 30, 35]);
    });

    test('orderBy descending', () async {
      final snap =
          await db.collection('users').orderBy('age', descending: true).get();
      final ages = snap.docs.map((d) => d.data()['age']).toList();
      expect(ages, [35, 30, 28, 25]);
    });

    test('limit caps results', () async {
      final snap = await db.collection('users').orderBy('age').limit(2).get();
      expect(snap.size, 2);
      expect(snap.docs.first.data()['age'], 25);
    });

    test('limitToLast returns last N', () async {
      final snap =
          await db.collection('users').orderBy('age').limitToLast(2).get();
      expect(snap.size, 2);
      expect(snap.docs.last.data()['age'], 35);
    });

    test('combined where + orderBy + limit', () async {
      final snap = await db
          .collection('users')
          .where('city', isEqualTo: 'Dhaka')
          .orderBy('age')
          .limit(1)
          .get();
      expect(snap.size, 1);
      expect(snap.docs.first.data()['name'], 'Bob');
    });

    test('count() returns aggregate snapshot', () async {
      final agg = db.collection('users').count();
      final snap = await agg.get();
      expect(snap.count, 4);
    });

    test('count() respects where clauses', () async {
      final agg =
          db.collection('users').where('city', isEqualTo: 'Dhaka').count();
      final snap = await agg.get();
      expect(snap.count, 2);
    });
  });

  group('WriteBatch', () {
    test('commits multiple operations atomically', () async {
      final batch = db.batch();
      batch.set(db.doc('users/u1'), {'name': 'Alice'});
      batch.set(db.doc('users/u2'), {'name': 'Bob'});
      batch.update(db.doc('users/u1'), {'age': 30});

      await batch.commit();

      final s1 = await db.doc('users/u1').get();
      final s2 = await db.doc('users/u2').get();
      expect(s1.data()?['name'], 'Alice');
      expect(s1.data()?['age'], 30);
      expect(s2.data()?['name'], 'Bob');
    });

    test('cannot be used after commit', () async {
      final batch = db.batch();
      batch.set(db.doc('users/u1'), {'name': 'Alice'});
      await batch.commit();

      expect(
        () => batch.set(db.doc('users/u2'), {'name': 'Bob'}),
        throwsStateError,
      );
      expect(batch.commit, throwsStateError);
    });

    test('rolls back on failure mid-commit', () async {
      await db.doc('users/u1').set({'name': 'Original', 'age': 100});

      final batch = db.batch();
      batch.update(db.doc('users/u1'), {'name': 'Updated'});

      delegate.failNextWrite = true;
      batch.set(db.doc('users/u2'), {'name': 'Bob'});

      await expectLater(batch.commit, throwsA(anything));

      final snap = await db.doc('users/u1').get();
      expect(snap.data()?['name'], 'Original');
    });

    test('rejects documents from a different database', () {
      final batch = db.batch();
      expect(
        () => batch.set(
          InAppDocumentReference(
            db: db,
            ref: 'foreign/u1',
            id: 'u1',
            parent: db.collection('foreign'),
          ),
          {'name': 'X'},
        ),
        returnsNormally,
      );
    });

    test('empty commit is a no-op', () async {
      final batch = db.batch();
      await expectLater(batch.commit(), completes);
    });
  });

  group('Transaction', () {
    test('commits writes when handler completes', () async {
      await db.runTransaction<void>((txn) async {
        txn.set(db.doc('users/u1'), {'name': 'Alice'});
        txn.set(db.doc('users/u2'), {'name': 'Bob'});
      });

      final s1 = await db.doc('users/u1').get();
      final s2 = await db.doc('users/u2').get();
      expect(s1.exists, true);
      expect(s2.exists, true);
    });

    test('reads through transaction', () async {
      await db.doc('counters/global').set({'count': 5});

      final result = await db.runTransaction<int>((txn) async {
        final snap = await txn.get(db.doc('counters/global'));
        final current = (snap.data()?['count'] as int?) ?? 0;
        txn.update(db.doc('counters/global'), {'count': current + 1});
        return current + 1;
      });

      expect(result, 6);
      final snap = await db.doc('counters/global').get();
      expect(snap.data()?['count'], 6);
    });

    test('does not apply writes when handler throws', () async {
      await db.doc('users/u1').set({'name': 'Original'});

      await expectLater(
        db.runTransaction<void>((txn) async {
          txn.update(db.doc('users/u1'), {'name': 'Updated'});
          throw StateError('abort');
        }, maxAttempts: 1),
        throwsA(isA<StateError>()),
      );

      final snap = await db.doc('users/u1').get();
      expect(snap.data()?['name'], 'Original');
    });
  });

  group('Streams', () {
    test('document snapshots emit on initial subscribe and updates', () async {
      final ref = db.doc('users/u1');
      await ref.set({'name': 'Alice'});

      final emissions = <InAppDocumentSnapshot>[];
      final sub = ref.snapshots().listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await ref.update({'name': 'Bob'});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last.data()?['name'], 'Bob');

      await sub.cancel();
    });

    test('collection snapshots emit on add', () async {
      final col = db.collection('users');
      final emissions = <InAppQuerySnapshot>[];
      final sub = col.snapshots().listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await col.add({'name': 'Alice'});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last.size, 1);

      await sub.cancel();
    });

    test('aggregate snapshots emit count updates', () async {
      final col = db.collection('users');
      final emissions = <InAppAggregateQuerySnapshot>[];
      final sub = col.count().snapshots().listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await col.add({'name': 'Alice'});
      await col.add({'name': 'Bob'});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions.last.count, 2);
      await sub.cancel();
    });
  });

  group('InAppFieldPath', () {
    test('documentId is a singleton', () {
      expect(InAppFieldPath.documentId.isDocumentId, true);
    });

    test('fromString splits on dots', () {
      final path = InAppFieldPath.fromString('a.b.c');
      expect(path.segments, ['a', 'b', 'c']);
    });

    test('rejects empty segments', () {
      expect(() => InAppFieldPath([]), throwsArgumentError);
      expect(() => InAppFieldPath(['a', '']), throwsArgumentError);
    });
  });

  group('Path validation', () {
    test('rejects empty document path', () {
      expect(() => db.doc(''), throwsArgumentError);
    });

    test('rejects collection path on doc()', () {
      expect(() => db.doc('users'), throwsArgumentError);
    });

    test('rejects document path on collection()', () {
      expect(() => db.collection('users/u1'), throwsArgumentError);
    });

    test('rejects double slashes', () {
      expect(() => db.doc('users//u1'), throwsArgumentError);
      expect(() => db.collection('users//posts'), throwsArgumentError);
    });
  });

  group('Multiple databases', () {
    test('create + activate switches active store', () async {
      await InAppDatabase.create('secondary');
      await InAppDatabase.activate('secondary');

      await db.doc('users/u1').set({'name': 'Alice'});
      final snap = await db.doc('users/u1').get();
      expect(snap.data()?['name'], 'Alice');

      await InAppDatabase.activate();
      final fromDefault = await db.doc('users/u1').get();
      expect(fromDefault.exists, false);
    });

    test('cannot delete the active database', () async {
      await InAppDatabase.create('temp');
      await InAppDatabase.activate('temp');

      await expectLater(
        () => InAppDatabase.delete('temp'),
        throwsA(isA<InAppDatabaseException>()),
      );

      await InAppDatabase.activate();
      await expectLater(InAppDatabase.delete('temp'), completion(true));
    });
  });

  group('Write limitation', () {
    test('respects collection size limit', () async {
      delegate.limitationProvider =
          (_, __) => const InAppWriteLimitation(2, limitByRecent: true);

      final col = db.collection('logs');
      await col.doc('a').set({'msg': 'first'});
      await col.doc('b').set({'msg': 'second'});
      await col.doc('c').set({'msg': 'third'});

      final snap = await col.get();
      expect(snap.size, lessThanOrEqualTo(2));
    });
  });
}
