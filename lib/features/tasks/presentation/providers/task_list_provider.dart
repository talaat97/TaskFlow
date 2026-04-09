import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/sources/task_remote_source.dart';
import '../../domain/entities/task_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

final taskRemoteSourceProvider = Provider<TaskRemoteSource>(
  (ref) => TaskRemoteSource(dio: ref.watch(dioProvider)),
);

final taskRepositoryProvider = Provider<TaskRepositoryImpl>(
  (ref) =>
      TaskRepositoryImpl(remote: ref.watch(taskRemoteSourceProvider)),
);

// ─── Task List State ──────────────────────────────────────────────────────────

class TaskListNotifier extends AsyncNotifier<List<TaskEntity>> {
  @override
  Future<List<TaskEntity>> build() => _fetch();

  Future<List<TaskEntity>> _fetch() =>
      ref.read(taskRepositoryProvider).getTasks();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> createTask(TaskEntity task) async {
    await ref.read(taskRepositoryProvider).createTask(task);
    await refresh();
  }

  Future<void> updateTask(TaskEntity task) async {
    await ref.read(taskRepositoryProvider).updateTask(task);
    await refresh();
  }

  Future<void> deleteTask(int id) async {
    await ref.read(taskRepositoryProvider).deleteTask(id);
    await refresh();
  }
}

final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<TaskEntity>>(
  TaskListNotifier.new,
);
