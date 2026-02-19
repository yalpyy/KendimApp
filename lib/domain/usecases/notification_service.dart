import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:kendin/core/constants/app_constants.dart';

/// Manages local notifications for the Kendin app.
///
/// Primary use: schedule a notification 10 minutes after
/// the user triggers their weekly reflection.
class NotificationService {
  NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _reflectionChannelId = 'kendin_reflection';
  static const _reflectionNotificationId = 1;

  /// Initialize notification plugin and timezone data.
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  /// Request notification permissions (iOS).
  Future<bool> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );
      return granted ?? false;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  /// Schedule the "reflection ready" notification 10 minutes from now.
  Future<void> scheduleReflectionReady() async {
    await requestPermission();

    final scheduledTime = tz.TZDateTime.now(tz.local).add(
      AppConstants.reflectionDelay,
    );

    const androidDetails = AndroidNotificationDetails(
      _reflectionChannelId,
      'Haftalık Yansıma',
      channelDescription: 'Haftalık yansımanız hazır olduğunda bildirim alın.',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _reflectionNotificationId,
      AppConstants.reflectionNotificationTitle,
      AppConstants.reflectionNotificationBody,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancel pending reflection notification.
  Future<void> cancelReflectionNotification() async {
    await _plugin.cancel(_reflectionNotificationId);
  }
}
