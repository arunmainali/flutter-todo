import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  // The RAM (Memory) list
  List<Map<String, dynamic>> toDoList = [];

  // Reference the Hive box
  final _myBox = Hive.box('mybox');

  // Run this only if this is the 1st time ever opening the app
  void createInitialData() {
    toDoList = [];
  }

  // Load the data from database
  void loadData() {
    final rawData = _myBox.get("TODOLIST");

    if (rawData != null) {
      // Hive returns a List<dynamic>. We must safely cast each item
      // to Map<String, dynamic> so Flutter can use it.
      toDoList = rawData.map<Map<String, dynamic>>((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    } else {
      // If rawData is null, it means this is the first time running the app
      createInitialData();
    }
  }

  // Update the database
  void updateDataBase() {
    _myBox.put("TODOLIST", toDoList);
  }
}