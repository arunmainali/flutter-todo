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
  // 0 = All, 1 = Active, 2 = Completed
  int _filterIndex = 0;
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    super.initState();
    Hive.box('mybox').clear();
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
      db.updateDataBase();
    } else {
      db.loadData();
    }
  }

  List<Map<String, dynamic>> get filteredTasks {
    if (_filterIndex == 1) {
      // Active only
      return db.toDoList.where((task) => task['completed'] == false).toList();
    } else if (_filterIndex == 2) {
      // Completed only
      return db.toDoList.where((task) => task['completed'] == true).toList();
    }
    return db.toDoList; // All
  }


  void checkBoxChanged(bool? value, int index) {
    setState(() {
      final item = db.toDoList[index] as Map<String, dynamic>;
      final current = item['completed'] is bool ? item['completed'] as bool : false;
      item['completed'] = !current;
    });
    db.updateDataBase();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        onSave: (name, subtitle, dueDate) {
          setState(() {
            db.toDoList.add({
              "name": name,
              "subtitle": subtitle,
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

  void confirmAndDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete this item?"),
        content: const Text("You sure you want to remove it?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => db.toDoList.removeAt(index));
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      appBar: AppBar(
        title: const Text("Things To Do"),
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 3,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: colors.primary,
        child: const Icon(Icons.add, size: 28),
      ),

      body: db.toDoList.isEmpty
          ? const Center(
              child: Text(
                "Nothing here yet.\nTap + to create one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 15, bottom: 80),
              itemCount: db.toDoList.length,
              itemBuilder: (context, index) {
                final item = db.toDoList[index] as Map<String, dynamic>;

                final name = item['name']?.toString() ?? '';
                final subtitle = item['subtitle']?.toString();
                final dueIso = item['dueDate'] as String?;
                final dueDate = dueIso == null ? null : DateTime.tryParse(dueIso);
                final completed =
                    item['completed'] is bool ? item['completed'] as bool : false;

                return ToDoTile(
                  name: name,
                  subtitle: subtitle,
                  dueDate: dueDate,
                  completed: completed,
                  onChanged: (v) => checkBoxChanged(v, index),
                  deleteTask: (context) => confirmAndDelete(index),
                  onTapEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPage(index: index, dataBase: db),
                      ),
                    ).then((_) => setState(() {}));
                  },
                );
              },
            ),
    );
  }
}
