import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';

/// Admin reflections debug screen with pagination.
class AdminReflectionsScreen extends ConsumerStatefulWidget {
  const AdminReflectionsScreen({super.key});

  @override
  ConsumerState<AdminReflectionsScreen> createState() =>
      _AdminReflectionsScreenState();
}

class _AdminReflectionsScreenState
    extends ConsumerState<AdminReflectionsScreen> {
  static const _pageSize = 10;
  List<Map<String, dynamic>> _reflections = [];
  int _currentPage = 0;
  bool _isLoading = true;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  Future<void> _loadReflections() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ref.read(authDatasourceProvider).getReflections(
            page: _currentPage,
            pageSize: _pageSize,
          );
      setState(() {
        _reflections = data;
        _hasMore = data.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    _currentPage++;
    _loadReflections();
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _loadReflections();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.screenVertical),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadReflections,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.adminTabReflections,
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                              style: theme.textTheme.bodySmall))
                      : _reflections.isEmpty
                          ? Center(
                              child: Text(
                                l10n.adminNoReflectionsDebug,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.screenHorizontal,
                              ),
                              itemCount: _reflections.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return _ReflectionTile(
                                  reflection: _reflections[index],
                                );
                              },
                            ),
            ),

            // Pagination
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0 ? _prevPage : null,
                  ),
                  Text(
                    '${_currentPage + 1}',
                    style: theme.textTheme.bodySmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _hasMore ? _nextPage : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReflectionTile extends StatelessWidget {
  const _ReflectionTile({required this.reflection});

  final Map<String, dynamic> reflection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final id = reflection['id'] as String? ?? '';
    final userId = reflection['user_id'] as String? ?? '';
    final weekStart = reflection['week_start_date'] as String? ?? '';
    final content = reflection['content'] as String? ?? '';
    final createdAt = reflection['created_at'] as String? ?? '';
    final isArchived = reflection['is_archived'] as bool? ?? false;

    final sentenceCount = content.isNotEmpty
        ? content
            .split(RegExp(r'[.!?]+'))
            .where((s) => s.trim().isNotEmpty)
            .length
        : 0;

    String formatDate(String raw) {
      if (raw.isEmpty) return '-';
      try {
        final dt = DateTime.parse(raw);
        return '${dt.day.toString().padLeft(2, '0')}.'
            '${dt.month.toString().padLeft(2, '0')}.'
            '${dt.year}';
      } catch (_) {
        return raw;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ID copied'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    'ID: ${id.length > 8 ? '${id.substring(0, 8)}...' : id}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              if (isArchived)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.tertiary.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Text(
                    'Archived',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'user: ${userId.length > 8 ? '${userId.substring(0, 8)}...' : userId}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'week: ${formatDate(weekStart)}  |  sentences: $sentenceCount  |  ${formatDate(createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
