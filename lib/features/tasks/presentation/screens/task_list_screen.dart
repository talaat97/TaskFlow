import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_list_provider.dart';
import '../providers/task_filter_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../app/theme.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final _searchCtrl = TextEditingController();
  bool _searchExpanded = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _LogoutDialog(),
    );
    if (confirm == true && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final filteredAsync = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);

    ref.listen(taskListProvider, (_, next) {
      if (next is AsyncError) {
        showErrorSnackBar(context, 'Failed to load tasks. Check your connection.');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(user?.name ?? 'User'),
            _buildSearchBar(),
            _buildFilterChips(filter),
            const SizedBox(height: 4),
            Expanded(child: _buildBody(filteredAsync)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/create'),
        icon: const Icon(Icons.add_rounded),
        label: Text('New Task', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAppBar(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_greeting()}, 👋',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _searchExpanded = !_searchExpanded),
            icon: Icon(
              _searchExpanded ? Icons.search_off_rounded : Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(taskListProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: _searchExpanded
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) =>
                    ref.read(taskFilterProvider.notifier).setQuery(v),
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search tasks…',
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: AppColors.textSecondary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref
                                .read(taskFilterProvider.notifier)
                                .setQuery('');
                          },
                        )
                      : null,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterChips(TaskFilterState filter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          // Status filters
          _FilterChip(
            label: 'To Do',
            color: AppColors.statusTodo,
            selected: filter.statusFilter == 'todo',
            onTap: () => ref.read(taskFilterProvider.notifier).setStatus(
                  filter.statusFilter == 'todo' ? null : 'todo',
                ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'In Progress',
            color: AppColors.statusInProgress,
            selected: filter.statusFilter == 'in_progress',
            onTap: () => ref.read(taskFilterProvider.notifier).setStatus(
                  filter.statusFilter == 'in_progress' ? null : 'in_progress',
                ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Done',
            color: AppColors.statusDone,
            selected: filter.statusFilter == 'done',
            onTap: () => ref.read(taskFilterProvider.notifier).setStatus(
                  filter.statusFilter == 'done' ? null : 'done',
                ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: AppColors.border),
          const SizedBox(width: 12),
          // Priority filters
          _FilterChip(
            label: '🔴 High',
            color: AppColors.priorityHigh,
            selected: filter.priorityFilter == 'high',
            onTap: () => ref.read(taskFilterProvider.notifier).setPriority(
                  filter.priorityFilter == 'high' ? null : 'high',
                ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '🟡 Medium',
            color: AppColors.priorityMedium,
            selected: filter.priorityFilter == 'medium',
            onTap: () => ref.read(taskFilterProvider.notifier).setPriority(
                  filter.priorityFilter == 'medium' ? null : 'medium',
                ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '🟢 Low',
            color: AppColors.priorityLow,
            selected: filter.priorityFilter == 'low',
            onTap: () => ref.read(taskFilterProvider.notifier).setPriority(
                  filter.priorityFilter == 'low' ? null : 'low',
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AsyncValue<List<TaskEntity>> async) {
    return async.when(
      loading: () => const ShimmerLoader(itemCount: 6),
      error: (e, _) => _ErrorState(onRetry: () =>
          ref.read(taskListProvider.notifier).refresh()),
      data: (tasks) {
        if (tasks.isEmpty) return const _EmptyState();
        return RefreshIndicator(
          onRefresh: () => ref.read(taskListProvider.notifier).refresh(),
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: tasks.length,
            itemBuilder: (ctx, i) => _TaskCard(task: tasks[i]),
          ),
        );
      },
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

// ─── Task Card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskEntity task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final due = DateTime.tryParse(task.dueDate);
    final dueFmt =
        due != null ? DateFormat('MMM d, yyyy').format(due) : task.dueDate;

    return Hero(
      tag: 'task-${task.id}',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => context.push('/tasks/${task.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge.priority(task.priority),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatusBadge.status(task.status),
                    const SizedBox(width: 8),
                    if (task.isOverdue) ...[
                      const OverdueBadge(),
                      const SizedBox(width: 8),
                    ],
                    const Spacer(),
                    if (due != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: task.isOverdue
                                ? AppColors.overdue
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dueFmt,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: task.isOverdue
                                  ? AppColors.overdue
                                  : AppColors.textSecondary,
                              fontWeight: task.isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (task.assignedUser.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Avatar(name: task.assignedUser),
                      const SizedBox(width: 8),
                      Text(
                        task.assignedUser,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.accentDim,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.accentLight,
          ),
        ),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.6) : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Empty / Error States ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 38, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text('No tasks found',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Try clearing filters or create\nyour first task.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('Failed to load tasks',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Check the mock API is running.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logout Dialog ────────────────────────────────────────────────────────────

class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Sign out?',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      content: Text('You\'ll need to sign in again to access your tasks.',
          style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textSecondary)),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Sign out',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
