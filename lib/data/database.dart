import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List<Map<String, dynamic>> toDoList = [];

  final _myBox = Hive.box('mybox');

  void createInitialData() {
    toDoList = [];
  }

  void loadData() {
    final raw = _myBox.get("TODOLIST");
    if (raw != null && raw is List) {
      toDoList = raw.map<Map<String, dynamic>>((item) {
        // already a map -> copy safely
        if (item is Map) return Map<String, dynamic>.from(item);

        // legacy/alternate format: a List like [name, subtitle, dueDate, completed]
        if (item is List) {
          final name = item.isNotEmpty ? (item[0]?.toString() ?? '') : '';
          final subtitle = item.length > 1 ? (item[1]?.toString()) : null;
          final dueDateVal = item.length > 2 ? item[2] : null;
          final dueDate = dueDateVal is DateTime ? dueDateVal.toIso8601String() : dueDateVal?.toString();
          final completed = item.length > 3
              ? (item[3] is bool ? item[3] : item[3].toString().toLowerCase() == 'true')
              : false;
          return {
            "name": name,
            "subtitle": subtitle,
            "dueDate": dueDate,
            "completed": completed,
          };
        }

        // fallback: try to coerce to a map, otherwise create a minimal item
        try {
          return Map<String, dynamic>.from(item);
        } catch (_) {
          return {
            "name": item?.toString() ?? '',
            "subtitle": null,
            "dueDate": null,
            "completed": false,
          };
        }
      }).toList();
    } else {
      toDoList = [];
    }
  }

  void updateDataBase() {
    _myBox.put("TODOLIST", toDoList);
  }
}
