import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gb_crop_assignment_task_app/features/tasks/domain/entities/task_entity.dart';
import 'package:gb_crop_assignment_task_app/features/tasks/presentation/providers/task_list_provider.dart';

class TaskFilterState {
  final String query;
  final String? status;
  final String? priority;

  const TaskFilterState({
    this.query = '',
    this.status,
    this.priority,
  });

  TaskFilterState copyWith({
    String? query,
    String? status,
    String? priority,
  }) {
    return TaskFilterState(
      query: query ?? this.query,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}

//🧠 Notifier (simple)
class TaskFilterNotifier extends StateNotifier<TaskFilterState> {
  TaskFilterNotifier() : super(const TaskFilterState());

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void setStatus(String? value) {
    state = state.copyWith(status: value);
  }

  void setPriority(String? value) {
    state = state.copyWith(priority: value);
  }

  void reset() {
    state = const TaskFilterState();
  }
}

//🧩 Provider
final taskFilterProvider =
    StateNotifierProvider<TaskFilterNotifier, TaskFilterState>(
  (ref) => TaskFilterNotifier(),
);

//🧮 Filtered Tasks
final filteredTasksProvider = Provider<AsyncValue<List<TaskEntity>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final filter = ref.watch(taskFilterProvider);

  return tasksAsync.when(
    data: (tasks) {
      var result = tasks;

      if (filter.query.isNotEmpty) {
        result = result
            .where((t) =>
                t.title.toLowerCase().contains(filter.query.toLowerCase()))
            .toList();
      }

      if (filter.status != null) {
        result = result.where((t) => t.status == filter.status).toList();
      }

      if (filter.priority != null) {
        result = result.where((t) => t.priority == filter.priority).toList();
      }

      return AsyncValue.data(result);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
