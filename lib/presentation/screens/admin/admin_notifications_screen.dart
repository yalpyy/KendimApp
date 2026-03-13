import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/data/datasources/supabase_client_setup.dart';

/// Notification types admin can send.
enum _NotificationType { email, push }

/// Audience segments.
enum _Audience { all, premium, free }

/// Admin notification screen — email and push notifications.
class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends ConsumerState<AdminNotificationsScreen> {
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final _pushTitleController = TextEditingController();
  _Audience _audience = _Audience.all;
  _NotificationType _notificationType = _NotificationType.email;
  bool _isSending = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    _pushTitleController.dispose();
    super.dispose();
  }

  String _audienceLabel(AppLocalizations l10n) {
    switch (_audience) {
      case _Audience.all:
        return l10n.adminNotificationAudienceAll;
      case _Audience.premium:
        return l10n.adminNotificationAudiencePremium;
      case _Audience.free:
        return l10n.adminNotificationAudienceFree;
    }
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);

    if (_notificationType == _NotificationType.push) {
      await _sendPush();
      return;
    }

    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();
    if (subject.isEmpty || body.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminNotificationsTitle),
        content: Text(l10n.adminNotificationConfirm(_audienceLabel(l10n))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.adminNotificationSend),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSending = true);

    try {
      final response = await SupabaseClientSetup.client.functions.invoke(
        'send-email',
        body: {
          'broadcast': true,
          'audience': _audience.name,
          'subject': subject,
          'body': body,
        },
      );

      if (!mounted) return;

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>?;
        final sent = data?['sent'] as int? ?? 0;
        final failed = data?['failed'] as int? ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminNotificationSuccess(sent, failed)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _subjectController.clear();
        _bodyController.clear();
      } else {
        final data = response.data as Map<String, dynamic>?;
        final error = data?['error']?.toString() ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminNotificationError(error)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('[AdminNotifications] Broadcast error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminNotificationError(e.toString())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendPush() async {
    final l10n = AppLocalizations.of(context);
    final title = _pushTitleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminNotificationsTitle),
        content: Text(l10n.adminNotificationConfirm(_audienceLabel(l10n))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.adminNotificationSend),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSending = true);

    try {
      final response = await SupabaseClientSetup.client.functions.invoke(
        'send-push',
        body: {
          'broadcast': true,
          'audience': _audience.name,
          'title': title,
          'body': body,
        },
      );

      if (!mounted) return;

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>?;
        final sent = data?['sent'] as int? ?? 0;
        final failed = data?['failed'] as int? ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminNotificationSuccess(sent, failed)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _pushTitleController.clear();
        _bodyController.clear();
      } else {
        final data = response.data as Map<String, dynamic>?;
        final error = data?['error']?.toString() ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminNotificationError(error)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('[AdminNotifications] Push error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminNotificationError(e.toString())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.screenVertical),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.adminTabNotifications,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Notification type selector
              Text(
                l10n.adminNotificationType,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<_NotificationType>(
                segments: [
                  ButtonSegment(
                    value: _NotificationType.email,
                    label: Text(l10n.adminNotificationTypeEmail,
                        style: const TextStyle(fontSize: 12)),
                    icon: const Icon(Icons.email, size: 16),
                  ),
                  ButtonSegment(
                    value: _NotificationType.push,
                    label: Text(l10n.adminNotificationTypePush,
                        style: const TextStyle(fontSize: 12)),
                    icon: const Icon(Icons.notifications, size: 16),
                  ),
                ],
                selected: {_notificationType},
                onSelectionChanged: (v) =>
                    setState(() => _notificationType = v.first),
                showSelectedIcon: false,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Audience selector
              Text(
                l10n.adminNotificationAudience,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<_Audience>(
                segments: [
                  ButtonSegment(
                    value: _Audience.all,
                    label: Text(l10n.adminNotificationAudienceAll,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: _Audience.premium,
                    label: Text(l10n.adminNotificationAudiencePremium,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: _Audience.free,
                    label: Text(l10n.adminNotificationAudienceFree,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
                selected: {_audience},
                onSelectionChanged: (v) =>
                    setState(() => _audience = v.first),
                showSelectedIcon: false,
              ),

              const SizedBox(height: AppSpacing.lg),

              if (_notificationType == _NotificationType.email) ...[
                // Subject
                TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: l10n.adminNotificationSubject,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Body
                TextField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: l10n.adminNotificationBody,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
              ] else ...[
                // Push notification fields
                TextField(
                  controller: _pushTitleController,
                  decoration: InputDecoration(
                    labelText: l10n.adminPushTitle,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: l10n.adminNotificationBody,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Send button
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: FilledButton(
                  onPressed: _isSending ? null : _send,
                  child: Text(
                    _isSending
                        ? l10n.adminNotificationSending
                        : l10n.adminNotificationSend,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
