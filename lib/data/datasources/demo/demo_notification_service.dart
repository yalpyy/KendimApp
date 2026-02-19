/// No-op notification service for demo/web mode.
///
/// flutter_local_notifications does not support web,
/// so this stub provides the same API with no-op methods.
class DemoNotificationService {
  Future<void> initialize() async {}
  Future<bool> requestPermission() async => true;
  Future<void> scheduleReflectionReady() async {}
  Future<void> cancelReflectionNotification() async {}
}
