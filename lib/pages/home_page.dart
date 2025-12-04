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
  // Filter: 'all', 'active', 'completed', or a priority like 'urgent', 'medium', 'low'
  String _filterType = 'all'; // 'all', 'active', 'completed', 'urgent', 'medium', 'low'
  
  // Order: 'none', 'priority', 'timeRemaining'
  String _orderBy = 'none';

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

  // Helper to parse a stored date value (supports String or DateTime)
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  List<Map<String, dynamic>> get filteredAndSortedTasks {
    // Work on a copy so we don't mutate the underlying DB list
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(db.toDoList);

    // First, filter
    if (_filterType == 'active') {
      result = result.where((task) => task['completed'] == false).toList();
    } else if (_filterType == 'completed') {
      result = result.where((task) => task['completed'] == true).toList();
    } else if (['urgent', 'medium', 'low'].contains(_filterType)) {
      result = result.where((task) => (task['priority'] ?? 'low') == _filterType).toList();
    }

    // Then, sort
    if (_orderBy == 'priority') {
      final priorityOrder = {'urgent': 0, 'medium': 1, 'low': 2};
      result.sort((a, b) {
        final aPriority = priorityOrder[(a['priority'] ?? 'low')] ?? 2;
        final bPriority = priorityOrder[(b['priority'] ?? 'low')] ?? 2;
        return aPriority.compareTo(bPriority);
      });
    } else if (_orderBy == 'timeRemaining') {
      // Sort by due date ascending (earliest / most urgent first).
      // Items with no due date should come last.
      result.sort((a, b) {
        final aDue = _parseDate(a['dueDate']);
        final bDue = _parseDate(b['dueDate']);

        if (aDue == null && bDue == null) return 0;
        if (aDue == null) return 1; // a after b
        if (bDue == null) return -1; // a before b

        return aDue.compareTo(bDue);
      });
    }

    return result;
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
        onSave: (name, subtitle, dueDate, priority) {
          setState(() {
            db.toDoList.add({
              "name": name,
              "subtitle": subtitle,
              "dueDate": dueDate?.toIso8601String(),
              "priority": priority,
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

  void _showFilterMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'all',
          child: Text("All Tasks"),
        ),
        const PopupMenuItem<String>(
          value: 'active',
          child: Text("Active"),
        ),
        const PopupMenuItem<String>(
          value: 'completed',
          child: Text("Completed"),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'urgent',
          child: Text("Urgent"),
        ),
        const PopupMenuItem<String>(
          value: 'medium',
          child: Text("Medium"),
        ),
        const PopupMenuItem<String>(
          value: 'low',
          child: Text("Low"),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() => _filterType = value);
      }
    });
  }

  void _showOrderMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'none',
          child: Text("No Sorting"),
        ),
        const PopupMenuItem<String>(
          value: 'priority',
          child: Text("By Priority"),
        ),
        const PopupMenuItem<String>(
          value: 'timeRemaining',
          child: Text("By Time Remaining"),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() => _orderBy = value);
      }
    });
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

          // FILTER & ORDER BUTTON BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) => ElevatedButton.icon(
                      onPressed: () => _showFilterMenu(context),
                      icon: const Icon(Icons.filter_list),
                      label: const Text("Filter"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.85),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (context) => ElevatedButton.icon(
                      onPressed: () => _showOrderMenu(context),
                      icon: const Icon(Icons.sort),
                      label: const Text("Order"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.85),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // LIST OR EMPTY VIEW
          Expanded(
            child: filteredAndSortedTasks.isEmpty
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
                          child: const Text("Create Task"),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: filteredAndSortedTasks.length,
                    itemBuilder: (context, index) {
                      final item = filteredAndSortedTasks[index];
                      final name = item["name"] ?? "";
                      final subtitle = item["subtitle"];
                      final dueDateIso = item["dueDate"];
                      final dueDate = dueDateIso == null
                          ? null
                          : _parseDate(dueDateIso);
                      final priority = item["priority"] ?? "low";
                      final completed = item["completed"] ?? false;

                      final originalIndex = db.toDoList.indexOf(item);

                      return ToDoTile(
                        name: name,
                        subtitle: subtitle,
                        dueDate: dueDate,
                        priority: priority,
                        completed: completed,
                        onChanged: (val) => checkBoxChanged(val, originalIndex),
                        deleteTask: (context) => confirmAndDelete(originalIndex),
                        onTapEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPage(
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
