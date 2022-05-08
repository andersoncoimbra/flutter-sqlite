import 'package:flutter/material.dart';
import 'package:flutter_sqlite/helpers/DatabaseHelper.dart';
import 'package:flutter_sqlite/models/Grocery.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SqliteApp());
}

class SqliteApp extends StatefulWidget {
  const SqliteApp({Key? key}) : super(key: key);

  @override
  State<SqliteApp> createState() => _SqliteAppState();
}

class _SqliteAppState extends State<SqliteApp> {
  int? selectedId;
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: TextField(
          controller: textController,
        )),
        body: Center(
          child: FutureBuilder<List<Grocery>>(
            future: DatabaseHelper.instance.getGroceries(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Grocery>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Text("Loading"));
              }
              return ListView(
                children: snapshot.data!.map((grocery) {
                  return Center(
                    child: Card(
                      color: selectedId == grocery.id
                          ? Colors.white70
                          : Colors.white,
                      child: ListTile(
                        title: Text(grocery.name),
                        onTap: () {
                          setState(() {
                            if (selectedId == null) {
                              selectedId = grocery.id;
                              textController.text = grocery.name;
                            } else {
                              selectedId = null;
                              textController.text = "";
                            }
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            DatabaseHelper.instance.remove(grocery.id!);
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () async {
            selectedId != null
                ? await DatabaseHelper.instance.update(
                    Grocery(id: selectedId, name: textController.text),
                  )
                : await DatabaseHelper.instance
                    .add(Grocery(name: textController.text));
            setState(() {
              textController.clear();
            });
          },
        ),
      ),
    );
  }
}
