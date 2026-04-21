import '../models/task_entity.dart';
import '../models/task_model.dart';
import '../sources/task_remote_source.dart';

TaskModel _toModel(TaskEntity e) => TaskModel(
      id: e.id,
      title: e.title,
      description: e.description,
      status: e.status,
      priority: e.priority,
      dueDate: e.dueDate,
      assignedUser: e.assignedUser,
    );

TaskEntity _toEntity(TaskModel m) => TaskEntity(
      id: m.id,
      title: m.title,
      description: m.description,
      status: m.status,
      priority: m.priority,
      dueDate: m.dueDate,
      assignedUser: m.assignedUser,
    );

class TaskRepository {
  final TaskRemoteSource _remote;

  TaskRepository({required TaskRemoteSource remote}) : _remote = remote;

  Future<List<TaskEntity>> getTasks() async {
    final models = await _remote.getTasks();
    return models.map(_toEntity).toList();
  }

  Future<TaskEntity> getTask(int id) async {
    final model = await _remote.getTask(id);
    return _toEntity(model);
  }

  Future<TaskEntity> createTask(TaskEntity task) async {
    final model = await _remote.createTask(_toModel(task));
    return _toEntity(model);
  }

  Future<TaskEntity> updateTask(TaskEntity task) async {
    final model = await _remote.updateTask(_toModel(task));
    return _toEntity(model);
  }

  Future<void> deleteTask(int id) => _remote.deleteTask(id);
}
