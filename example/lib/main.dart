import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_database/in_app_database.dart';
import 'package:in_app_faker/in_app_faker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // return db[key];
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'In App Database',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("In App Database"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Counter Snapshot",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                StreamBuilder(
                  stream:
                      InAppDatabase.i.collection("users").count().snapshots(),
                  builder: (context, s) {
                    final count = s.data?.docs ?? 0;
                    return Text("Total users: $count");
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "Document Snapshot",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                StreamBuilder(
                  stream:
                      InAppDatabase.i.collection("users").doc("1").snapshots(),
                  builder: (context, s) {
                    final item = s.data?.data ?? {};
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text("${item["age"]}"),
                      ),
                      title: Text("${item["username"]}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${item["email"]}"),
                          Text(
                            "Updated At: ${item["updateAt"] ?? "Not update yet"}",
                            maxLines: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "Collection Snapshots",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                StreamBuilder(
                  stream: InAppDatabase.i.collection("users").snapshots(),
                  builder: (context, s) {
                    final data = s.data?.docs ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data.elementAt(index).data;
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text("${item?["age"]}"),
                          ),
                          title: Text("${item?["username"]}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${item?["email"]}"),
                              Text(
                                "Updated At: ${item?["updateAt"] ?? "Not update yet"}",
                                maxLines: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Button(
            text: "Add",
            onClick: () => InAppDatabase.i.collection("users").add({
              "username": UserFaker.username,
              "email": UserFaker.email,
              "age": UserFaker.age,
              "country": UserFaker.country,
              "photoUrl": UserFaker.photoUrl,
            }),
          ),
          Button(
            text: "Set",
            onClick: () {
              InAppDatabase.i.collection("users").doc("1").set({
                "username": UserFaker.username,
                "email": UserFaker.email,
                "age": UserFaker.age,
                "country": UserFaker.country,
                "photoUrl": UserFaker.photoUrl,
              });
            },
          ),
          Button(
            text: "Update",
            onClick: () {
              InAppDatabase.i.collection("users").doc("1").update({
                "updateAt": DateTime.now().millisecondsSinceEpoch.toString(),
              });
            },
          ),
          Button(
            text: "Delete",
            onClick: () {
              InAppDatabase.i.collection("users").doc("1").delete();
            },
          ),
          Button(
            text: "Get",
            onClick: () {
              InAppDatabase.i.collection("users").doc("1").get().then((value) {
                DataBottomSheet.show(
                  context,
                  title: "Get",
                  contents: [value],
                );
              });
            },
          ),
          Button(
            text: "Gets",
            onClick: () {
              InAppDatabase.i.collection("users").get().then((value) {
                if (value.exists) {
                  DataBottomSheet.show(
                    context,
                    title: "Gets",
                    contents: value.docs,
                  );
                }
              });
            },
          ),
          Button(
            text: "Query",
            onClick: () {
              InAppDatabase.i
                  .collection("users")
                  .where("username", isEqualTo: "emma_smith")
                  .get()
                  .then((value) {
                if (value.exists) {
                  DataBottomSheet.show(
                    context,
                    title: "Query",
                    contents: value.docs,
                  );
                }
              });
            },
          ),
          Button(
            text: "Filter",
            onClick: () {
              InAppDatabase.i
                  .collection("users")
                  .where(InAppFilter.or([
                    InAppFilter("username", isEqualTo: "emma_smith"),
                    InAppFilter("age", isGreaterThanOrEqualTo: 50),
                  ]))
                  .where("age", isLessThanOrEqualTo: 60)
                  .orderBy("age", descending: false)
                  .orderBy("email", descending: false)
                  .limit(10)
                  .get()
                  .then((value) {
                if (value.exists) {
                  DataBottomSheet.show(
                    context,
                    title: "Filter",
                    contents: value.docs,
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onClick;

  const Button({
    super.key,
    required this.text,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: primary),
      onPressed: onClick,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

class DataBottomSheet extends StatefulWidget {
  final String title;
  final List<InAppDocumentSnapshot> contents;

  const DataBottomSheet({
    super.key,
    required this.title,
    required this.contents,
  });

  @override
  State<DataBottomSheet> createState() => _DataBottomSheetState();

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<InAppDocumentSnapshot> contents,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return DataBottomSheet(title: title, contents: contents);
      },
    );
  }
}

class _DataBottomSheetState extends State<DataBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 600,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 8,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(50),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.contents.length,
              itemBuilder: (context, index) {
                final item = widget.contents.elementAtOrNull(index)?.data;
                return ListTile(
                  leading: CircleAvatar(
                    child: Text("${item?["age"]}"),
                  ),
                  title: Text("${item?["username"]}"),
                  subtitle: Text("${item?["email"]}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
