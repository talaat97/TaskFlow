import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum BadgeType { status, priority }

class StatusBadge extends StatelessWidget {
  final String value;
  final BadgeType type;

  const StatusBadge.status(this.value, {super.key}) : type = BadgeType.status;
  const StatusBadge.priority(this.value, {super.key}) : type = BadgeType.priority;

  @override
  Widget build(BuildContext context) {
    final (label, color) =
        type == BadgeType.status ? _statusStyle(value) : _priorityStyle(value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static (String, Color) _statusStyle(String status) {
    return switch (status.toLowerCase()) {
      'done' => ('Done', AppColors.statusDone),
      'in_progress' => ('In Progress', AppColors.statusInProgress),
      _ => ('To Do', AppColors.statusTodo),
    };
  }

  static (String, Color) _priorityStyle(String priority) {
    return switch (priority.toLowerCase()) {
      'high' => ('High', AppColors.priorityHigh),
      'medium' => ('Medium', AppColors.priorityMedium),
      _ => ('Low', AppColors.priorityLow),
    };
  }
}

class OverdueBadge extends StatelessWidget {
  const OverdueBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.overdue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.overdue.withValues(alpha: 0.4), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 11, color: AppColors.overdue),
          SizedBox(width: 3),
          Text(
            'Overdue',
            style: TextStyle(
              color: AppColors.overdue,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
