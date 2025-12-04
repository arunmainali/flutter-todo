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

Widget buildFilterButton(String text, int index) {
  final bool selected = _filterIndex == index;

  return Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.black.withOpacity(0.85) : Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
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
        backgroundColor: const Color(0xFFF8F7F4),
        elevation: 0,
        scrolledUnderElevation: 3,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: colors.primary,
        child: const Icon(Icons.add, size: 28),
      ),

      body: Column(
  children: [
    const SizedBox(height: 18),

    // FILTER BUTTON BAR
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildFilterButton("All", 0),
          buildFilterButton("Active", 1),
          buildFilterButton("Completed", 2),
        ],
      ),
    ),

    const SizedBox(height: 12),

    // LIST OR EMPTY VIEW
    Expanded(
      child: filteredTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "No items here yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Create tasks to organise your work better.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: createNewTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12
                      ),
                      backgroundColor: Colors.black, // main CTA
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Create new item"),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final item = filteredTasks[index];
                final name = item["name"] ?? "";
                final subtitle = item["subtitle"];
                final dueDateIso = item["dueDate"];
                final dueDate = dueDateIso == null
                    ? null
                    : DateTime.tryParse(dueDateIso);
                final completed = item["completed"] ?? false;

                // Get index inside main list for edit/delete
                final originalIndex = db.toDoList.indexOf(item);

                return ToDoTile(
                  name: name,
                  subtitle: subtitle,
                  dueDate: dueDate,
                  completed: completed,
                  onChanged: (val) => checkBoxChanged(val, originalIndex),
                  deleteTask: (context) => confirmAndDelete(originalIndex),
                  onTapEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPage(
                          index: originalIndex,
                          dataBase: db,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                );
              },
            ),
    ),
  ],
),

    );
  }
}
