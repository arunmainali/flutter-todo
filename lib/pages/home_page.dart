import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/data/database.dart';
import 'package:todo_list/util/todo_tile.dart';
import 'package:todo_list/util/create_task_dialog.dart';
import 'edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    super.initState();
    if (_myBox.get("TODOLIST") == null) {
      // first run: create empty list
      db.createInitialData();
      db.updateDataBase();
    } else {
      db.loadData();
    }
  }

  /// Toggle completed state for item at [index]
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      final item = db.toDoList[index] as Map<String, dynamic>;
      // ensure key exists; flip the bool (default false if missing)
      final current = item['completed'] is bool ? item['completed'] as bool : false;
      item['completed'] = !current;
    });
    db.updateDataBase();
  }

  /// Show dialog to create a new task (CreateTaskDialog handles validation)
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        onSave: (name, subtitle, dueDate) {
          setState(() {
            db.toDoList.add({
              "name": name,
              "subtitle": subtitle,
              // store as ISO string (null if not provided)
              "dueDate": dueDate?.toIso8601String(),
              "completed": false,
            });
          });
          Navigator.pop(context);
          db.updateDataBase();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  /// Ask for confirmation before deleting
  void confirmAndDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete this item?"),
        content: const Text("Are you sure you want to delete it?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                db.toDoList.removeAt(index);
              });
              Navigator.pop(context);
              db.updateDataBase();
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure db.toDoList is a list to avoid build-time errors
    final listLength = db.toDoList.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Todo'), elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: listLength,
        itemBuilder: (context, index) {
          // read item as a Map
          final item = db.toDoList[index] as Map<String, dynamic>;

          // parse values safely
          final name = item['name']?.toString() ?? '';
          final subtitle = item['subtitle']?.toString();
          final dueDateIso = item['dueDate'] as String?;
          final dueDate = dueDateIso == null ? null : DateTime.tryParse(dueDateIso);
          final completed = item['completed'] is bool ? item['completed'] as bool : false;

          return ToDoTile(
            name: name,
            subtitle: subtitle,
            dueDate: dueDate,
            completed: completed,
            onChanged: (value) => checkBoxChanged(value, index),
            // ToDoTile's Slidable calls the provided function with (BuildContext) parameter,
            // so provide a closure which ignores the passed BuildContext and calls our confirmAndDelete.
            deleteTask: (context) => confirmAndDelete(index),
            onTapEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPage(index: index, dataBase: db),
                ),
              ).then((_) {
                // refresh state after possible edit
                setState(() {});
              });
            },
          );
        },
      ),
    );
  }
}
