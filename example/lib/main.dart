import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:in_app_database/in_app_database.dart';

Map<String, Map> databases = {};

class NoteKey {
  static const id = 'id';
  static const title = 'title';
  static const body = 'body';
  static const tags = 'tags';
  static const pinned = 'pinned';
  static const color = 'color';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
  static const views = 'views';
}

class Note {
  final String id;
  final String title;
  final String body;
  final List<String> tags;
  final bool pinned;
  final String color;
  final int views;
  final int? createdAt;
  final int? updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    this.tags = const [],
    this.pinned = false,
    this.color = 'white',
    this.views = 0,
    this.createdAt,
    this.updatedAt,
  });

  static String _asString(Object? v, [String fallback = '']) {
    if (v == null) return fallback;
    if (v is String) return v;
    return v.toString();
  }

  static bool _asBool(Object? v, [bool fallback = false]) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return fallback;
  }

  static int _asInt(Object? v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final n = int.tryParse(v);
      if (n != null) return n;
      final d = double.tryParse(v);
      if (d != null) return d.toInt();
      final t = DateTime.tryParse(v);
      if (t != null) return t.toUtc().millisecondsSinceEpoch;
    }
    if (v is DateTime) return v.toUtc().millisecondsSinceEpoch;
    return fallback;
  }

  static int? _asIntOrNull(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final n = int.tryParse(v);
      if (n != null) return n;
      final d = double.tryParse(v);
      if (d != null) return d.toInt();
      final t = DateTime.tryParse(v);
      if (t != null) return t.toUtc().millisecondsSinceEpoch;
    }
    if (v is DateTime) return v.toUtc().millisecondsSinceEpoch;
    return null;
  }

  static List<String> _asStringList(Object? v) {
    if (v is List) {
      return v
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    if (v is String && v.isNotEmpty) {
      return v
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  factory Note.fromMap(InAppDocument map) {
    return Note(
      id: _asString(map[NoteKey.id]),
      title: _asString(map[NoteKey.title]),
      body: _asString(map[NoteKey.body]),
      tags: _asStringList(map[NoteKey.tags]),
      pinned: _asBool(map[NoteKey.pinned]),
      color: _asString(map[NoteKey.color], 'null'),
      views: _asInt(map[NoteKey.views]),
      createdAt: _asIntOrNull(map[NoteKey.createdAt]),
      updatedAt: _asIntOrNull(map[NoteKey.updatedAt]),
    );
  }

  factory Note.fromSnapshot(InAppDocumentSnapshot snap) {
    final data = snap.data();
    if (data == null) return Note.empty(snap.id);
    return Note.fromMap({...data, NoteKey.id: snap.id});
  }

  factory Note.empty(String id) =>
      Note(id: id, title: '', body: '', color: 'white');

  InAppDocument toMap() => {
    NoteKey.id: id,
    NoteKey.title: title,
    NoteKey.body: body,
    NoteKey.tags: tags,
    NoteKey.pinned: pinned,
    NoteKey.color: color,
    NoteKey.views: views,
    if (createdAt != null) NoteKey.createdAt: createdAt,
    if (updatedAt != null) NoteKey.updatedAt: updatedAt,
  };

  Note copyWith({
    String? title,
    String? body,
    List<String>? tags,
    bool? pinned,
    String? color,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      pinned: pinned ?? this.pinned,
      color: color ?? this.color,
      views: views,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class DatabaseDelegate extends InAppDatabaseDelegate {
  @override
  Future<bool> init(String dbName) async {
    databases[dbName] = databases[dbName] ??= {};
    return true;
  }

  @override
  Future<Iterable<String>> paths(String dbName) async {
    final x = databases[dbName]!.keys.whereType<String>().toList();
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
  Future<bool> write(String dbName, String key, Object? value) async {
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    InAppDatabase.init(
      showLogs: true, // optional
      type: InAppDatabaseType.json, // optional
      version: InAppDatabaseVersion.v1, // optional
      delegate: DatabaseDelegate(), // required
    );
    InAppDatabase.i.collection("users").get().then((value) {
      log("USERS: $value");
    });
    InAppDatabase.i.collection("users").snapshots().listen((value) {
      log("USER_SNAPSHOTS: $value");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'In App Database',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LocalDataTestPage(),
    );
  }
}

class LocalDataTestPage extends StatefulWidget {
  const LocalDataTestPage({super.key});

  @override
  State<LocalDataTestPage> createState() => _LocalDataTestPageState();
}

class _LocalDataTestPageState extends State<LocalDataTestPage> {
  final _db = InAppDatabase.instance;
  String _log = '';

  static const _id = '1778319785575';

  InAppQueryReference get _notes =>
      _db.collection('notes_v2').doc('v1').collection('notes');

  InAppDocumentReference _noteDoc(String id) => _notes.doc(id);

  void _log_(String msg) {
    if (!mounted) return;
    setState(() => _log = msg);
  }

  Future<void> _safe(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      _log_('$label error: $e');
      rethrow;
    }
  }

  Future<void> _create() => _safe('create', () async {
    final tagPool = ['work', 'personal', 'idea', 'todo', 'urgent'];
    final colors = ['yellow', 'blue', 'green', 'pink', 'white'];

    final rnd = DateTime.now().millisecondsSinceEpoch;
    final tags = (tagPool..shuffle()).take(2).toList();
    final color = colors[rnd % colors.length];

    final n = Note(
      id: _id,
      title: 'Note ${rnd % 1000}',
      body: 'This is a sample note body created at $rnd',
      tags: tags,
      pinned: rnd % 2 == 0,
      color: color,
    );

    await _noteDoc(_id).set({
      ...n.toMap(),
      NoteKey.createdAt: InAppFieldValue.serverTimestamp(true),
    });

    _log_('Created: ${n.title} | ${n.color} | pinned: ${n.pinned}');
  });

  Future<void> _createRandom() => _safe('createRandom', () async {
    final titles = ['Meeting', 'Idea', 'Shopping', 'Reminder', 'Quote', 'Task'];
    final colors = ['yellow', 'blue', 'green', 'pink', 'white'];
    final tagPool = ['work', 'personal', 'idea', 'todo', 'urgent'];

    final rnd = DateTime.now().millisecondsSinceEpoch;
    final n = Note(
      id: rnd.toString(),
      title: '${titles[rnd % titles.length]} ${rnd % 1000}',
      body: 'Body content at $rnd',
      tags: (tagPool..shuffle()).take(2).toList(),
      pinned: rnd % 2 == 0,
      color: colors[rnd % colors.length],
    );

    final ref = await _notes.add({
      ...n.toMap(),
      NoteKey.createdAt: InAppFieldValue.serverTimestamp(true),
    });

    _log_('Created: ${ref.id} | ${n.title} | ${n.color}');
  });

  Future<void> _update() => _safe('update', () async {
    await _noteDoc(_id).update({
      NoteKey.pinned: true,
      NoteKey.views: InAppFieldValue.increment(1),
      NoteKey.tags: InAppFieldValue.arrayUnion(['updated']),
      NoteKey.updatedAt: InAppFieldValue.serverTimestamp(true),
    });
    _log_('Updated: $_id (incremented views, added tag)');
  });

  Future<void> _setMerge() => _safe('setMerge', () async {
    await _noteDoc(_id).set({
      NoteKey.color: 'pink',
      NoteKey.title: 'Merged title',
    }, const InAppSetOptions(merge: true));
    _log_('Merged update on: $_id');
  });

  Future<void> _toggle() => _safe('toggle', () async {
    await _noteDoc(_id).update({NoteKey.pinned: InAppFieldValue.toggle()});
    _log_('Toggled pinned on: $_id');
  });

  Future<void> _removeTag() => _safe('removeTag', () async {
    await _noteDoc(_id).update({
      NoteKey.tags: InAppFieldValue.arrayRemove(['updated']),
    });
    _log_('Removed tag "updated"');
  });

  Future<void> _deleteField() => _safe('deleteField', () async {
    await _noteDoc(_id).update({NoteKey.color: InAppFieldValue.delete()});
    _log_('Deleted color field');
  });

  Future<void> _delete(String id) => _safe('delete', () async {
    await _noteDoc(id).delete();
    _log_('Deleted: $id');
  });

  Future<void> _checkById() => _safe('checkById', () async {
    final snap = await _noteDoc(_id).get();
    _log_(snap.exists ? 'Exists: $_id' : 'Not found: $_id');
  });

  Future<void> _deleteAll() => _safe('deleteAll', () async {
    await _notes.drop();
    _log_('Cleared all notes');
  });

  Future<void> _get() => _safe('get', () async {
    final snap = await _notes.get();
    _log_('Got ${snap.size} items');
  });

  Future<void> _getById() => _safe('getById', () async {
    final snap = await _noteDoc(_id).get();
    if (!snap.exists) return _log_('Not found');
    final n = Note.fromSnapshot(snap);
    _log_('Got: ${n.title}');
  });

  Future<void> _query() => _safe('query', () async {
    final snap =
        await _notes
            .where(NoteKey.color, isEqualTo: 'yellow')
            .orderBy(NoteKey.createdAt, descending: true)
            .limit(10)
            .get();
    _log_('Query: ${snap.size} yellow notes');
  });

  Future<void> _queryWhereIn() => _safe('queryWhereIn', () async {
    final snap =
        await _notes
            .where(NoteKey.color, whereIn: ['yellow', 'blue', 'green'])
            .get();
    _log_('whereIn: ${snap.size} items');
  });

  Future<void> _queryArrayContains() => _safe('queryArrayContains', () async {
    final snap = await _notes.where(NoteKey.tags, arrayContains: 'work').get();
    _log_('arrayContains "work": ${snap.size} items');
  });

  Future<void> _queryRange() => _safe('queryRange', () async {
    final snap =
        await _notes
            .where(NoteKey.views, isGreaterThanOrEqualTo: 1)
            .orderBy(NoteKey.views, descending: true)
            .get();
    _log_('views >= 1: ${snap.size} items');
  });

  Future<void> _search() => _safe('search', () async {
    final value = "Note";
    final snap =
        await _notes.orderBy(NoteKey.title).startAt([value]).endAt([
          '$value\uf8ff',
        ]).get();
    _log_(
      'Search "Note": ${snap.docs.length} items: '
      '${snap.docs.map((d) => d.data()[NoteKey.title]).join(", ")}',
    );
  });

  Future<void> _count() => _safe('count', () async {
    final snap = await _notes.count().get();
    _log_('Count: ${snap.count}');
  });

  Future<void> _batch() => _safe('batch', () async {
    final batch = _db.batch();
    batch.set(_noteDoc('batch_1'), {
      NoteKey.id: 'batch_1',
      NoteKey.title: 'Batch one',
      NoteKey.body: 'created via batch',
      NoteKey.color: 'green',
    });
    batch.set(_noteDoc('batch_2'), {
      NoteKey.id: 'batch_2',
      NoteKey.title: 'Batch two',
      NoteKey.body: 'created via batch',
      NoteKey.color: 'blue',
    });
    batch.update(_noteDoc('batch_1'), {NoteKey.pinned: true});
    await batch.commit();
    _log_('Batch committed: 3 ops');
  });

  Future<void> _transaction() => _safe('transaction', () async {
    final result = await _db.runTransaction<int>((txn) async {
      final ref = _noteDoc('counter_doc');
      final snap = await txn.get(ref);
      final current = (snap.data()?[NoteKey.views] as int?) ?? 0;
      final next = current + 1;
      txn.set(ref, {
        NoteKey.id: 'counter_doc',
        NoteKey.title: 'Counter',
        NoteKey.body: 'Atomic counter',
        NoteKey.views: next,
      });
      return next;
    });
    _log_('Txn committed: counter = $result');
  });

  Future<void> _subcollection() => _safe('subcollection', () async {
    final ref = _noteDoc(_id).collection('comments').doc('c1');
    await ref.set({
      'id': 'c1',
      'text': 'A nested comment',
      'createdAt': InAppFieldValue.serverTimestamp(true),
    });
    final snap = await ref.get();
    _log_('Subcollection: ${snap.exists ? snap.data() : "missing"}');
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(title: const Text('InAppDatabase Test')),
        floatingActionButton: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _btn('Create', _create),
                _btn('CreateRandom (add)', _createRandom),
                _btn('Update', _update),
                _btn('Set Merge', _setMerge),
                _btn('Toggle Pin', _toggle),
                _btn('Remove Tag', _removeTag),
                _btn('Delete Field', _deleteField),
                _btn('Batch (3 ops)', _batch),
                _btn('Transaction', _transaction),
                _btn('Subcollection', _subcollection),
                _btn('Check By Id', _checkById),
                _btn('Get All', _get),
                _btn('Get By Id', _getById),
                _btn('Query (color)', _query),
                _btn('whereIn', _queryWhereIn),
                _btn('arrayContains', _queryArrayContains),
                _btn('Range', _queryRange),
                _btn('Search', _search),
                _btn('Count', _count),
                _btn('Delete By Id', () => _delete(_id)),
                _btn('Clear All', _deleteAll),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_log.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.black26,
                    child: Text(
                      _log,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                const _Section('Listen Count (count().snapshots())'),
                StreamBuilder<InAppAggregateQuerySnapshot>(
                  stream: _notes.count().snapshots(),
                  builder: (context, s) {
                    return Text('Total notes: ${s.data?.count ?? 0}');
                  },
                ),
                const Divider(),
                const _Section('Listen By Id (doc().snapshots())'),
                StreamBuilder<InAppDocumentSnapshot>(
                  stream: _noteDoc(_id).snapshots(),
                  builder: (context, s) {
                    if (!s.hasData) return const Text('Loading...');
                    final snap = s.data!;
                    if (!snap.exists) return const Text('No data');
                    final n = Note.fromSnapshot(snap);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(n.title),
                      subtitle: Text('${n.body} | pinned: ${n.pinned}'),
                      trailing: Text(n.color),
                    );
                  },
                ),
                const Divider(),
                const _Section('Listen All (collection.snapshots())'),
                StreamBuilder<InAppQuerySnapshot>(
                  stream: _notes.snapshots(),
                  builder: (context, s) {
                    final docs = s.data?.docs ?? const [];
                    if (docs.isEmpty) return const Text('No data');
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.take(5).length,
                      itemBuilder: (_, i) {
                        final n = Note.fromSnapshot(docs[i]);
                        return ListTile(
                          onLongPress: () => _delete(n.id),
                          contentPadding: EdgeInsets.zero,
                          title: Text(n.title),
                          subtitle: Text('${n.color} | ${n.tags.join(", ")}'),
                          trailing: Text('Pinned: ${n.pinned}'),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                const _Section('Listen By Query (where + orderBy)'),
                StreamBuilder<InAppQuerySnapshot>(
                  stream:
                      _notes
                          .where(NoteKey.pinned, isEqualTo: true)
                          .orderBy(NoteKey.createdAt, descending: true)
                          .limit(10)
                          .snapshots(),
                  builder: (context, s) {
                    final docs = s.data?.docs ?? const [];
                    if (docs.isEmpty) return const Text('No pinned notes');
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.take(5).length,
                      itemBuilder: (_, i) {
                        final n = Note.fromSnapshot(docs[i]);
                        return ListTile(
                          onLongPress: () => _delete(n.id),
                          contentPadding: EdgeInsets.zero,
                          title: Text(n.title),
                          subtitle: Text('${n.color} | ${n.tags.join(", ")}'),
                          trailing: Text('Views: ${n.views}'),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                const _Section('Listen Subcollection'),
                StreamBuilder<InAppQuerySnapshot>(
                  stream: _noteDoc(_id).collection('comments').snapshots(),
                  builder: (context, s) {
                    final docs = s.data?.docs ?? const [];
                    if (docs.isEmpty) return const Text('No comments');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          docs
                              .take(5)
                              .map(
                                (d) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    d.data()['text']?.toString() ?? '',
                                  ),
                                  subtitle: Text('id: ${d.id}'),
                                ),
                              )
                              .toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(label),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
