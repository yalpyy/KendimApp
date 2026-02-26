import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/data/datasources/auth_datasource.dart';
import 'package:kendin/presentation/providers/providers.dart';

/// Admin panel — visible only to users with is_admin = true.
///
/// Shows:
/// - App statistics (total users, premium users, entries, reflections)
/// - User list with premium/admin badges
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  Map<String, int>? _stats;
  List<Map<String, dynamic>>? _users;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final datasource = ref.read(authDatasourceProvider);
      final results = await Future.wait([
        datasource.getAdminStats(),
        datasource.getAllUsers(),
      ]);

      setState(() {
        _stats = results[0] as Map<String, int>;
        _users = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
            // Header
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
                        onPressed: _loadData,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.adminTitle,
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.genericError,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextButton(
                                  onPressed: _loadData,
                                  child: Text(l10n.genericError),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            children: [
                              // ─── Statistics ──────────────────────
                              Text(
                                l10n.adminStatsTitle,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildStatsGrid(context),

                              const SizedBox(height: AppSpacing.xxl),

                              // ─── Users list ─────────────────────
                              Text(
                                l10n.adminUsersTitle,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildUsersList(context),

                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = _stats ?? {};

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: l10n.adminTotalUsers,
          value: '${stats['total_users'] ?? 0}',
        ),
        _StatCard(
          label: l10n.adminPremiumUsers,
          value: '${stats['premium_users'] ?? 0}',
        ),
        _StatCard(
          label: l10n.adminTotalEntries,
          value: '${stats['total_entries'] ?? 0}',
        ),
        _StatCard(
          label: l10n.adminTotalReflections,
          value: '${stats['total_reflections'] ?? 0}',
        ),
      ],
    );
  }

  Widget _buildUsersList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final users = _users ?? [];

    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            l10n.adminNoUsers,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserTile(user: user);
      },
    );
  }
}

// ─── Stat Card ──────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha:0.2)
                : AppColors.lightDivider.withValues(alpha:0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── User Tile ──────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final displayName = user['display_name'] as String? ?? '';
    final isPremium = user['is_premium'] as bool? ?? false;
    final isAdmin = user['is_admin'] as bool? ?? false;
    final id = user['id'] as String? ?? '';
    final createdAt = user['created_at'] as String? ?? '';

    // Format date
    String dateLabel = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        dateLabel = '${dt.day.toString().padLeft(2, '0')}.'
            '${dt.month.toString().padLeft(2, '0')}.'
            '${dt.year}';
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Name or truncated ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isNotEmpty
                      ? displayName
                      : id.length > 8
                          ? '${id.substring(0, 8)}...'
                          : id,
                  style: theme.textTheme.bodyMedium,
                ),
                if (dateLabel.isNotEmpty)
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Badges
          if (isAdmin)
            _Badge(
              label: l10n.adminAdminBadge,
              color: theme.colorScheme.primary,
            ),
          if (isPremium)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: _Badge(
                label: l10n.adminPremiumBadge,
                color: theme.colorScheme.tertiary,
              ),
            ),
          if (!isPremium && !isAdmin)
            _Badge(
              label: l10n.adminFreeBadge,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha:0.5)),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 11,
            ),
      ),
    );
  }
}
