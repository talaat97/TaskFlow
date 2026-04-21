import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/task_entity.dart';
import '../providers/task_list_provider.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../app/theme.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);

    return tasksAsync.when(
      loading: () => const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Task')),
        body: Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.textSecondary))),
      ),
      data: (tasks) {
        final id = int.tryParse(taskId);
        final task = id != null
            ? tasks.where((t) => t.id == id).firstOrNull
            : null;

        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task')),
            body: const Center(
                child: Text('Task not found',
                    style: TextStyle(color: AppColors.textSecondary))),
          );
        }

        return _TaskDetailView(task: task);
      },
    );
  }
}

class _TaskDetailView extends ConsumerWidget {
  final TaskEntity task;
  const _TaskDetailView({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = DateTime.tryParse(task.dueDate);
    final dueFmt =
        due != null ? DateFormat('MMMM d, yyyy').format(due) : task.dueDate;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, ref),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'task-${task.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      StatusBadge.status(task.status),
                      StatusBadge.priority(task.priority),
                      if (task.isOverdue) const OverdueBadge(),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _Divider(),
                  const SizedBox(height: 24),
                  if (task.description.isNotEmpty) ...[
                    _sectionLabel('Description'),
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                  _DetailGrid(task: task, dueFmt: dueFmt),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
          onPressed: () => context.push('/tasks/${task.id}/edit'),
        ),
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline_rounded,
              color: AppColors.error),
          onPressed: () => _confirmDelete(context, ref),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete task?',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text(
          'This action cannot be undone.',
          style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true && task.id != null) {
      try {
        await ref.read(taskListProvider.notifier).deleteTask(task.id!);
        if (context.mounted) {
          showSuccessSnackBar(context, 'Task deleted.');
          context.pop();
        }
      } catch (_) {
        if (context.mounted) {
          showErrorSnackBar(context, 'Failed to delete task.');
        }
      }
    }
  }

  Widget _sectionLabel(String label) => Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 1,
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.divider, height: 1);
}

class _DetailGrid extends StatelessWidget {
  final TaskEntity task;
  final String dueFmt;
  const _DetailGrid({required this.task, required this.dueFmt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Row(
          icon: Icons.person_outline_rounded,
          label: 'Assigned to',
          value: task.assignedUser.isNotEmpty ? task.assignedUser : '—',
        ),
        const SizedBox(height: 18),
        _Row(
          icon: Icons.calendar_today_rounded,
          label: 'Due date',
          value: dueFmt.isNotEmpty ? dueFmt : '—',
          valueColor:
              task.isOverdue ? AppColors.overdue : null,
        ),
        const SizedBox(height: 18),
        _Row(
          icon: Icons.tag_rounded,
          label: 'Task ID',
          value: '#${task.id}',
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textHint,
                    letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
