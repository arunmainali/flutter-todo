import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final DateTime? dueDate;
  final bool completed;
  final String priority;

  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteTask;
  final VoidCallback? onTapEdit;

  const ToDoTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.dueDate,
    required this.completed,
    required this.priority,
    required this.onChanged,
    required this.deleteTask,
    required this.onTapEdit,
  });

  String getTimeRemaining() {
    if (dueDate == null) return "No deadline";

    final now = DateTime.now();
    final diff = dueDate!.difference(now);

    if (diff.inSeconds <= 0) return "Overdue";
    if (diff.inDays > 0) return "${diff.inDays} days left";
    if (diff.inHours > 0) return "${diff.inHours} hours left";
    return "${diff.inMinutes} minutes left";
  }

  Color _getPriorityColor() {
    switch (priority) {
      case "urgent":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon() {
    switch (priority) {
      case "urgent":
        return Icons.priority_high;
      case "medium":
        return Icons.remove;
      case "low":
        return Icons.arrow_downward;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(10),
              onPressed: deleteTask,
              icon: Icons.delete_outline,
              backgroundColor: Colors.redAccent.withOpacity(.85),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: completed
                  ? Colors.grey.withOpacity(.25)
                  : Colors.black12.withOpacity(.15),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: completed,
                activeColor: colors.primary,
                onChanged: onChanged,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: completed ? TextDecoration.lineThrough : null,
                              color: completed ? Colors.black54 : Colors.black87,
                            ),
                          ),
                        ),
                        Icon(
                          _getPriorityIcon(),
                          size: 18,
                          color: _getPriorityColor(),
                        ),
                      ],
                    ),

                    if (subtitle != null && subtitle!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        getTimeRemaining(),
                        style: TextStyle(
                          fontSize: 12,
                          color: completed
                              ? Colors.grey
                              : colors.primary.withOpacity(.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: onTapEdit,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}