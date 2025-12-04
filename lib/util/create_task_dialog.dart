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
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "New Task",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Title",
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _subtitleController,
              decoration: InputDecoration(
                labelText: "Notes (optional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? "No deadline"
                        : "Due ${_selectedDate!.toLocal()}".split(" ").first,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: pickDueDate,
                  child: Text("Pick date"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text("Cancel"),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final title = _nameController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Task name is required")),
                      );
                      return;
                    }

                    widget.onSave(
                      title,
                      _subtitleController.text.trim().isEmpty
                          ? null
                          : _subtitleController.text.trim(),
                      _selectedDate,
                    );
                  },
                  child: Text("Create"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
