import 'package:flutter/material.dart';

class CreateTaskDialog extends StatefulWidget {
  final void Function(String title, String? subtitle, DateTime? date) onSave;
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
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _subtitleCtrl = TextEditingController();

  DateTime? _selectedDate;

  bool _titleError = false;

  void _handleCreate() {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _titleError = true);
      return;
    }

    widget.onSave(
      _titleCtrl.text.trim(),
      _subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim(),
      _selectedDate,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: now,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create new task",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Title field — mandatory
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: "Title *",
                labelStyle: TextStyle(
                  color: _titleError ? Colors.red : Colors.grey[700],
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _titleError ? Colors.red : Colors.black,
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _titleError ? Colors.red : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) {
                if (_titleError) setState(() => _titleError = false);
              },
            ),

            if (_titleError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  "Title is compulsory",
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12.5),
                ),
              ),

            const SizedBox(height: 14),

            // Subtitle optional
            TextField(
              controller: _subtitleCtrl,
              decoration: InputDecoration(
                labelText: "Subtitle (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Date selector optional
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? "No due date"
                        : "Due: ${_selectedDate!.toLocal()}".split(' ')[0],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text("Pick date"),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("Create"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
