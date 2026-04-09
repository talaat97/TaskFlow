import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_entity.dart';
import 'task_list_provider.dart';

// ─── Filter State ─────────────────────────────────────────────────────────────

class TaskFilterState {
  final String query;
  final String? statusFilter;   // null = all
  final String? priorityFilter; // null = all

  const TaskFilterState({
    this.query = '',
    this.statusFilter,
    this.priorityFilter,
  });

  TaskFilterState copyWith({
    String? query,
    Object? statusFilter = _sentinel,
    Object? priorityFilter = _sentinel,
  }) =>
      TaskFilterState(
        query: query ?? this.query,
        statusFilter:
            statusFilter == _sentinel ? this.statusFilter : statusFilter as String?,
        priorityFilter:
            priorityFilter == _sentinel ? this.priorityFilter : priorityFilter as String?,
      );
}

const _sentinel = Object();

class TaskFilterNotifier extends StateNotifier<TaskFilterState> {
  TaskFilterNotifier() : super(const TaskFilterState());

  void setQuery(String q) => state = state.copyWith(query: q);

  void setStatus(String? s) => state = state.copyWith(statusFilter: s);

  void setPriority(String? p) => state = state.copyWith(priorityFilter: p);

  void reset() => state = const TaskFilterState();
}

final taskFilterProvider =
    StateNotifierProvider<TaskFilterNotifier, TaskFilterState>(
  (ref) => TaskFilterNotifier(),
);

// ─── Derived: filtered list ───────────────────────────────────────────────────

final filteredTasksProvider = Provider<AsyncValue<List<TaskEntity>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final filter = ref.watch(taskFilterProvider);

  return tasksAsync.whenData((tasks) {
    var filtered = tasks;

    if (filter.query.isNotEmpty) {
      final q = filter.query.toLowerCase();
      filtered = filtered.where((t) => t.title.toLowerCase().contains(q)).toList();
    }

    if (filter.statusFilter != null) {
      filtered = filtered.where((t) => t.status == filter.statusFilter).toList();
    }

    if (filter.priorityFilter != null) {
      filtered =
          filtered.where((t) => t.priority == filter.priorityFilter).toList();
    }

    return filtered;
  });
});
