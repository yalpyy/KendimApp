import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';

/// Admin users screen with search, pagination, and premium management.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  static const _pageSize = 10;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  int _currentPage = 0;
  bool _isLoading = true;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final search = _searchController.text.trim();
      final data = await ref.read(authDatasourceProvider).getUsers(
            page: _currentPage,
            pageSize: _pageSize,
            search: search.isNotEmpty ? search : null,
          );
      setState(() {
        _users = data;
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

  void _onSearch() {
    _currentPage = 0;
    _loadUsers();
  }

  void _nextPage() {
    _currentPage++;
    _loadUsers();
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _loadUsers();
    }
  }

  Future<void> _grantPremium(Map<String, dynamic> user) async {
    final l10n = AppLocalizations.of(context);

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: l10n.adminSetPremiumDate,
    );
    if (picked == null) return;

    try {
      await ref
          .read(authDatasourceProvider)
          .grantPremium(user['id'] as String, picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminPremiumGranted),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _revokePremium(Map<String, dynamic> user) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminRevokePremium),
        content: Text(l10n.adminNotificationConfirm(
          (user['display_name'] as String?) ??
              (user['id'] as String).substring(0, 8),
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.adminConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(authDatasourceProvider)
          .revokePremium(user['id'] as String);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminPremiumRevoked),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
                        onPressed: _loadUsers,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.adminTabUsers,
                    style: theme.textTheme.displayLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Search
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.adminSearchUsers,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      ),
                    ),
                    onSubmitted: (_) => _onSearch(),
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
                      : _users.isEmpty
                          ? Center(
                              child: Text(
                                l10n.adminNoUsers,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.screenHorizontal,
                              ),
                              itemCount: _users.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                return _AdminUserTile(
                                  user: user,
                                  onGrantPremium: () => _grantPremium(user),
                                  onRevokePremium: () => _revokePremium(user),
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

class _AdminUserTile extends StatelessWidget {
  const _AdminUserTile({
    required this.user,
    required this.onGrantPremium,
    required this.onRevokePremium,
  });

  final Map<String, dynamic> user;
  final VoidCallback onGrantPremium;
  final VoidCallback onRevokePremium;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final displayName = user['display_name'] as String? ?? '';
    final isPremium = user['is_premium'] as bool? ?? false;
    final isAdmin = user['is_admin'] as bool? ?? false;
    final id = user['id'] as String? ?? '';
    final createdAt = user['created_at'] as String? ?? '';
    final expiresAt = user['premium_expires_at'] as String?;

    String dateLabel = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        dateLabel = '${dt.day.toString().padLeft(2, '0')}.'
            '${dt.month.toString().padLeft(2, '0')}.'
            '${dt.year}';
      } catch (_) {}
    }

    String? expiryLabel;
    if (expiresAt != null) {
      try {
        final dt = DateTime.parse(expiresAt);
        expiryLabel = '${dt.day.toString().padLeft(2, '0')}.'
            '${dt.month.toString().padLeft(2, '0')}.'
            '${dt.year}';
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
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
                        displayName.isNotEmpty
                            ? displayName
                            : id.length > 8
                                ? '${id.substring(0, 8)}...'
                                : id,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    if (dateLabel.isNotEmpty)
                      Text(
                        dateLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (isPremium && expiryLabel != null)
                      Text(
                        '${l10n.adminPremiumUntil}: $expiryLabel',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 11,
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
          const SizedBox(height: AppSpacing.xs),
          // Premium actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isPremium)
                TextButton(
                  onPressed: onGrantPremium,
                  child: Text(
                    l10n.adminGrantPremium,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              if (isPremium)
                TextButton(
                  onPressed: onRevokePremium,
                  child: Text(
                    l10n.adminRevokePremium,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
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
        border: Border.all(color: color.withOpacity(0.5)),
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
