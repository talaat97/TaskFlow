import 'package:dio/dio.dart';
import '../models/task_model.dart';

class TaskRemoteSource {
  final Dio _dio;

  const TaskRemoteSource({required Dio dio}) : _dio = dio;

  Future<List<TaskModel>> getTasks() async {
    final res = await _dio.get('/tasks');
    return (res.data as List)
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> getTask(int id) async {
    final res = await _dio.get('/tasks/$id');
    return TaskModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final res = await _dio.post('/tasks', data: task.toJson());
    return TaskModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final res = await _dio.put('/tasks/${task.id}', data: task.toJson());
    return TaskModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) => _dio.delete('/tasks/$id');
}
