import 'dart:async';

/// No-op premium service for demo/web mode.
///
/// in_app_purchase does not support web.
/// In demo mode, the user is always treated as premium.
class DemoPremiumService {
  final _premiumController = StreamController<bool>.broadcast();

  Stream<bool> get premiumStream => _premiumController.stream;

  Future<void> initialize() async {}
  Future<void> restorePurchases() async {}

  void dispose() {
    _premiumController.close();
  }
}
