class TaskModel {
  final int? id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String dueDate;
  final String assignedUser;

  const TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.assignedUser,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: (json['id'] as num?)?.toInt(),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        status: (json['status'] as String? ?? 'todo').toLowerCase(),
        priority: (json['priority'] as String? ?? 'low').toLowerCase(),
        dueDate: json['dueDate'] as String? ?? '',
        assignedUser: json['assignedUser'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'dueDate': dueDate,
        'assignedUser': assignedUser,
      };

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? dueDate,
    String? assignedUser,
  }) =>
      TaskModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        dueDate: dueDate ?? this.dueDate,
        assignedUser: assignedUser ?? this.assignedUser,
      );

  bool get isOverdue {
    if (dueDate.isEmpty || status == 'done') return false;
    final due = DateTime.tryParse(dueDate);
    return due != null && due.isBefore(DateTime.now());
  }
}
