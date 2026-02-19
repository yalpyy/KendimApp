import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:kendin/core/constants/app_constants.dart';
import 'package:kendin/core/errors/app_exception.dart';
import 'package:kendin/data/datasources/supabase_client_setup.dart';

/// Manages premium subscription state and in-app purchases.
///
/// Uses the `in_app_purchase` package for both iOS and Android.
/// No Adapty.
class PremiumService {
  PremiumService();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _premiumController = StreamController<bool>.broadcast();

  /// Stream that emits premium status changes.
  Stream<bool> get premiumStream => _premiumController.stream;

  /// Product details after loading.
  List<ProductDetails> products = [];

  /// Initialize the purchase listener.
  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        // Log but don't crash.
      },
    );

    await _loadProducts();
  }

  /// Load available subscription products.
  Future<void> _loadProducts() async {
    const ids = {
      AppConstants.monthlyProductId,
      AppConstants.yearlyProductId,
    };

    final response = await _iap.queryProductDetails(ids);
    products = response.productDetails;
  }

  /// Initiates a purchase for the given product.
  Future<void> purchase(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restores previous purchases.
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Handles purchase updates from the store.
  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndActivate(purchase);
          break;
        case PurchaseStatus.error:
          _premiumController.addError(
            PurchaseException(
              purchase.error?.message ?? 'Purchase failed',
            ),
          );
          break;
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Verifies the purchase and activates premium in Supabase.
  Future<void> _verifyAndActivate(PurchaseDetails purchase) async {
    try {
      // Send receipt to Supabase for server-side verification.
      // In production, use an edge function for receipt validation.
      final client = SupabaseClientSetup.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw const PurchaseException('Not authenticated');
      }

      // Server-side verification via edge function.
      final response = await client.functions.invoke(
        'verify-purchase',
        body: {
          'user_id': userId,
          'receipt': purchase.verificationData.serverVerificationData,
          'source': Platform.isIOS ? 'apple' : 'google',
          'product_id': purchase.productID,
        },
      );

      if (response.status == 200) {
        // Update local premium state.
        await client
            .from('users')
            .update({'is_premium': true})
            .eq('id', userId);
        _premiumController.add(true);
      } else {
        throw const PurchaseException('Verification failed');
      }
    } catch (e) {
      if (e is PurchaseException) rethrow;
      throw PurchaseException('Failed to verify purchase: $e');
    }
  }

  /// Cleanup.
  void dispose() {
    _subscription?.cancel();
    _premiumController.close();
  }
}
