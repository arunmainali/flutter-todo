import 'package:flutter/material.dart';

class CreateTaskDialog extends StatefulWidget {
  final Function(String, String?, DateTime?) onSave;
  final VoidCallback onCancel;

  const CreateTaskDialog({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _nameController = TextEditingController();
  final _subtitleController = TextEditingController();

  DateTime? _selectedDate;

  Future pickDueDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (selected != null) {
      setState(() => _selectedDate = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text("Create To-Do"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Task name *",
            ),
          ),
          TextField(
            controller: _subtitleController,
            decoration: InputDecoration(
              labelText: "Subtitle (optional)",
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? "No due date"
                      : "Due: ${_selectedDate!.toLocal()}".split(" ").first,
                ),
              ),
              TextButton(
                onPressed: pickDueDate,
                child: Text("Pick date"),
              )
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Task name is required.")),
              );
              return;
            }
            widget.onSave(
              _nameController.text.trim(),
              _subtitleController.text.trim().isEmpty
                  ? null
                  : _subtitleController.text.trim(),
              _selectedDate,
            );
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
