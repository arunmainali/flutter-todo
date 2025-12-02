import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final DateTime? dueDate;
  final bool completed;

  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteTask;
  final VoidCallback? onTapEdit;

  const ToDoTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.dueDate,
    required this.completed,
    required this.onChanged,
    required this.deleteTask,
    required this.onTapEdit,
  });

  String getTimeRemaining() {
    if (dueDate == null) return "No deadline";

    final now = DateTime.now();
    final diff = dueDate!.difference(now);

    if (diff.inSeconds <= 0) {
      return "Overdue";
    }

    if (diff.inDays > 0) return "${diff.inDays} days left";
    if (diff.inHours > 0) return "${diff.inHours} hours left";
    return "${diff.inMinutes} minutes left";
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteTask,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: InkWell(
          onTap: onTapEdit,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: completed,
                  onChanged: onChanged,
                  activeColor: colors.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          decoration:
                              completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurface.withOpacity(0.7),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        getTimeRemaining(),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
