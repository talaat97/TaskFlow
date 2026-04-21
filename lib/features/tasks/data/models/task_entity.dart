class TaskEntity {
  final int? id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String dueDate;
  final String assignedUser;

  const TaskEntity({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.assignedUser,
  });

  bool get isOverdue {
    if (dueDate.isEmpty || status == 'done') return false;
    final due = DateTime.tryParse(dueDate);
    return due != null && due.isBefore(DateTime.now());
  }
}
