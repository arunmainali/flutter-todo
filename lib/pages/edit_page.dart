import 'package:flutter/material.dart';
import '../data/database.dart';

class EditPage extends StatefulWidget {
  final int index;
  final ToDoDataBase dataBase;

  const EditPage({
    super.key,
    required this.index,
    required this.dataBase,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController nameController;
  late TextEditingController subtitleController;

  @override
  void initState() {
    final item = widget.dataBase.toDoList[widget.index];

    nameController = TextEditingController(text: item["name"]);
    subtitleController =
        TextEditingController(text: item["subtitle"] ?? "");

    super.initState();
  }

  void saveChanges() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Task name is required.")),
      );
      return;
    }

    widget.dataBase.toDoList[widget.index]["name"] =
        nameController.text.trim();

    widget.dataBase.toDoList[widget.index]["subtitle"] =
        subtitleController.text.trim().isEmpty
            ? null
            : subtitleController.text.trim();

    widget.dataBase.updateDataBase();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit To-Do"),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Task name *"),
            ),
            TextField(
              controller: subtitleController,
              decoration: InputDecoration(labelText: "Subtitle"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveChanges,
              child: Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
