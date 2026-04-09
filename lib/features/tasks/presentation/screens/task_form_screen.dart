import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_list_provider.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../app/theme.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  /// Null means create mode; non-null means edit mode.
  final String? taskId;

  const TaskFormScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _assigneeCtrl = TextEditingController();

  String _status = 'todo';
  String _priority = 'medium';
  DateTime? _dueDate;
  bool _saving = false;
  bool _initialized = false;

  bool get _isEdit => widget.taskId != null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _assigneeCtrl.dispose();
    super.dispose();
  }

  void _maybeInit(List<TaskEntity> tasks) {
    if (_initialized || !_isEdit) {
      _initialized = true;
      return;
    }
    final id = int.tryParse(widget.taskId!);
    final task = id != null
        ? tasks.where((t) => t.id == id).firstOrNull
        : null;

    if (task != null) {
      _titleCtrl.text = task.title;
      _descCtrl.text = task.description;
      _assigneeCtrl.text = task.assignedUser;
      _status = task.status;
      _priority = task.priority;
      _dueDate = DateTime.tryParse(task.dueDate);
    }
    _initialized = true;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.card,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit(List<TaskEntity> tasks) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final task = TaskEntity(
      id: _isEdit ? int.tryParse(widget.taskId!) : null,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _dueDate != null
          ? DateFormat('yyyy-MM-dd').format(_dueDate!)
          : '',
      assignedUser: _assigneeCtrl.text.trim(),
    );

    try {
      if (_isEdit) {
        await ref.read(taskListProvider.notifier).updateTask(task);
        if (mounted) showSuccessSnackBar(context, 'Task updated!');
      } else {
        await ref.read(taskListProvider.notifier).createTask(task);
        if (mounted) showSuccessSnackBar(context, 'Task created!');
      }
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to save task. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEdit ? 'Edit Task' : 'New Task'),
        actions: [
          tasksAsync.whenOrNull(
            data: (tasks) => TextButton(
              onPressed: _saving ? null : () => _submit(tasks),
              child: Text(
                _saving ? 'Saving…' : 'Save',
                style: GoogleFonts.inter(
                  color: _saving ? AppColors.textSecondary : AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ) ?? const SizedBox.shrink(),
          const SizedBox(width: 8),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(child: Text('$e')),
        data: (tasks) {
          _maybeInit(tasks);
          return _buildForm(tasks);
        },
      ),
    );
  }

  Widget _buildForm(List<TaskEntity> tasks) {
    final dueFmt = _dueDate != null
        ? DateFormat('MMM d, yyyy').format(_dueDate!)
        : 'Pick a date';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('Title *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(hintText: 'What needs to be done?'),
              maxLines: 1,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 20),
            _label('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Add more details…',
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _buildStatusPicker()),
              const SizedBox(width: 12),
              Expanded(child: _buildPriorityPicker()),
            ]),
            const SizedBox(height: 20),
            _label('Due Date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: _dueDate != null
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dueFmt,
                      style: GoogleFonts.inter(
                        color: _dueDate != null
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(Icons.clear_rounded,
                            size: 16, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _label('Assigned To'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _assigneeCtrl,
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Team member name',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    size: 20, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : () => _submit(tasks),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white70)),
                      )
                    : Text(
                        _isEdit ? 'Update Task' : 'Create Task',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Status'),
        const SizedBox(height: 8),
        _Dropdown<String>(
          value: _status,
          items: const {
            'todo': 'To Do',
            'in_progress': 'In Progress',
            'done': 'Done',
          },
          onChanged: (v) => setState(() => _status = v!),
        ),
      ],
    );
  }

  Widget _buildPriorityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Priority'),
        const SizedBox(height: 8),
        _Dropdown<String>(
          value: _priority,
          items: const {
            'low': '🟢 Low',
            'medium': '🟡 Medium',
            'high': '🔴 High',
          },
          onChanged: (v) => setState(() => _priority = v!),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      );
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.card,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        icon: const Icon(Icons.expand_more_rounded,
            color: AppColors.textSecondary, size: 20),
        items: items.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
