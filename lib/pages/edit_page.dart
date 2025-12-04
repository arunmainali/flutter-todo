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

  DateTime? _dueDate;
  String _priority = 'medium';
  bool _nameError = false;

  @override
  void initState() {
    super.initState();

    final item = widget.dataBase.toDoList[widget.index];

    nameController = TextEditingController(text: item["name"] ?? "");
    subtitleController = TextEditingController(text: item["subtitle"] ?? "");

    // parse possible stored due date formats (String ISO or DateTime)
    final dueRaw = item["dueDate"];
    _dueDate = _parseDate(dueRaw);

    _priority = (item["priority"] is String && (item["priority"] != ""))
        ? item["priority"] as String
        : 'medium';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      initialDate: initial,
    );

    if (picked != null) setState(() => _dueDate = picked);
  }

  void _clearDate() {
    setState(() => _dueDate = null);
  }

  void saveChanges() {
    if (nameController.text.trim().isEmpty) {
      setState(() => _nameError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task name is required.")),
      );
      return;
    }

    final trimmedName = nameController.text.trim();
    final trimmedSubtitle =
        subtitleController.text.trim().isEmpty ? null : subtitleController.text.trim();

    // update the DB entry
    widget.dataBase.toDoList[widget.index]["name"] = trimmedName;
    widget.dataBase.toDoList[widget.index]["subtitle"] = trimmedSubtitle;
    widget.dataBase.toDoList[widget.index]["dueDate"] =
        _dueDate == null ? null : _dueDate!.toIso8601String();
    widget.dataBase.toDoList[widget.index]["priority"] = _priority;

    widget.dataBase.updateDataBase();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit To-Do"),
        leading: BackButton(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Task name *",
                errorText: _nameError ? "Task name is required" : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_nameError) setState(() => _nameError = false);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(
                labelText: "Subtitle",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Due date row
            const Text(
              "Due date",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? "No due date"
                        : "Due: ${_dueDate!.toLocal()}".split(' ')[0],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text("Pick date"),
                ),
                if (_dueDate != null)
                  TextButton(
                    onPressed: _clearDate,
                    child: const Text("Clear"),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Priority selector
            const Text(
              "Priority",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: ["urgent", "medium", "low"].map((p) {
                final isSelected = _priority == p;
                Color priorityColor;
                switch (p) {
                  case "urgent":
                    priorityColor = Colors.red;
                    break;
                  case "medium":
                    priorityColor = Colors.orange;
                    break;
                  case "low":
                  default:
                    priorityColor = Colors.green;
                    break;
                }
                return ChoiceChip(
                  label: Text(p.toUpperCase()),
                  selected: isSelected,
                  onSelected: (sel) {
                    if (sel) setState(() => _priority = p);
                  },
                  backgroundColor: priorityColor.withOpacity(0.15),
                  selectedColor: priorityColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  child: const Text("Save"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}