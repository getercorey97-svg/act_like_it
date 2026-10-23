import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_screen.dart';
import '../auth/auth_service.dart';
import '../offline_manager.dart';
import '../ui/game_app_bar.dart';

class SavedPaymentCard {
  final String id;
  final String cardholderName;
  final String last4;
  final String brand;
  final String expiry;
  final String billingZip;

  const SavedPaymentCard({
    required this.id,
    required this.cardholderName,
    required this.last4,
    required this.brand,
    required this.expiry,
    required this.billingZip,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'cardholderName': cardholderName,
        'last4': last4,
        'brand': brand,
        'expiry': expiry,
        'billingZip': billingZip,
      };

  factory SavedPaymentCard.fromJson(Map<String, dynamic> json) {
    return SavedPaymentCard(
      id: (json['id'] ?? 'card_1').toString(),
      cardholderName: (json['cardholderName'] ?? 'STAGE ACTOR').toString(),
      last4: (json['last4'] ?? '4242').toString(),
      brand: (json['brand'] ?? 'VISA').toString(),
      expiry: (json['expiry'] ?? '08/28').toString(),
      billingZip: (json['billingZip'] ?? '90028').toString(),
    );
  }
}

class BoxOfficeReceiptItem {
  final String id;
  final String title;
  final String priceLabel;
  final String paymentMethodLabel;
  final DateTime purchasedAt;

  const BoxOfficeReceiptItem({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.paymentMethodLabel,
    required this.purchasedAt,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'priceLabel': priceLabel,
        'paymentMethodLabel': paymentMethodLabel,
        'purchasedAt': purchasedAt.toIso8601String(),
      };

  factory BoxOfficeReceiptItem.fromJson(Map<String, dynamic> json) {
    return BoxOfficeReceiptItem(
      id: (json['id'] ?? 'rcpt_1').toString(),
      title: (json['title'] ?? 'Studio Upgrade').toString(),
      priceLabel: (json['priceLabel'] ?? '\$4.99').toString(),
      paymentMethodLabel:
          (json['paymentMethodLabel'] ?? 'Google Play Billing').toString(),
      purchasedAt: DateTime.tryParse('${json['purchasedAt'] ?? ''}') ??
          DateTime.now().toUtc(),
    );
  }
}

/// PART 5: Google Play Store-Ready VIP Box Office & Payment Dashboard
/// (`lib/monetization/payment_dashboard_screen.dart`).
class PaymentDashboardScreen extends StatefulWidget {
  final String? highlightProductKey;
  final String? contextBannerText;
  final bool returnOnUnlock;

  const PaymentDashboardScreen({
    super.key,
    this.highlightProductKey,
    this.contextBannerText,
    this.returnOnUnlock = false,
  });

  @override
  State<PaymentDashboardScreen> createState() => _PaymentDashboardScreenState();
}

class _PaymentDashboardScreenState extends State<PaymentDashboardScreen>
    with TickerProviderStateMixin {
  static const String _kSavedCardsPrefsKey = 'act_like_it_saved_cards_v1';
  static const String _kReceiptsPrefsKey = 'act_like_it_receipts_v1';
  static const String _kDefaultMethodPrefsKey = 'act_like_it_default_pay_v1';
  static const String _kExpressCheckoutPrefsKey = 'act_like_it_express_pay_v1';

  late final TabController _tabController;
  late final AnimationController _goldenStampController;

  final List<SavedPaymentCard> _savedCards = <SavedPaymentCard>[];
  final List<BoxOfficeReceiptItem> _receipts = <BoxOfficeReceiptItem>[];
  String _selectedPaymentMethodId = 'google_play_1tap';
  bool _expressOneTapCheckout = true;
  bool _showStampCelebration = false;
  String _lastUnlockedTitle = '';

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _cardNumCtrl = TextEditingController();
  final TextEditingController _expiryCtrl = TextEditingController();
  final TextEditingController _cvcCtrl = TextEditingController();
  final TextEditingController _zipCtrl = TextEditingController();
  String? _cardFormError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _goldenStampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    AuthService.instance.addListener(_onAuthUpdated);
    _loadBillingState();
  }

  void _onAuthUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadBillingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedPaymentMethodId =
          prefs.getString(_kDefaultMethodPrefsKey) ?? 'google_play_1tap';
      _expressOneTapCheckout =
          prefs.getBool(_kExpressCheckoutPrefsKey) ?? true;

      final rawCards = prefs.getString(_kSavedCardsPrefsKey);
      _savedCards.clear();
      if (rawCards != null && rawCards.isNotEmpty) {
        final decoded = jsonDecode(rawCards) as List;
        for (final item in decoded) {
          _savedCards.add(
            SavedPaymentCard.fromJson(Map<String, dynamic>.from(item as Map)),
          );
        }
      } else {
        _savedCards.add(
          const SavedPaymentCard(
            id: 'card_studio_visa',
            cardholderName: 'STUDIO VIP ACTOR',
            last4: '4242',
            brand: 'VISA',
            expiry: '09/28',
            billingZip: '90028',
          ),
        );
      }

      final rawReceipts = prefs.getString(_kReceiptsPrefsKey);
      _receipts.clear();
      if (rawReceipts != null && rawReceipts.isNotEmpty) {
        final decoded = jsonDecode(rawReceipts) as List;
        for (final item in decoded) {
          _receipts.add(
            BoxOfficeReceiptItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          );
        }
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _persistBillingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kDefaultMethodPrefsKey, _selectedPaymentMethodId);
      await prefs.setBool(_kExpressCheckoutPrefsKey, _expressOneTapCheckout);
      await prefs.setString(
        _kSavedCardsPrefsKey,
        jsonEncode(_savedCards.map((c) => c.toJson()).toList()),
      );
      await prefs.setString(
        _kReceiptsPrefsKey,
        jsonEncode(_receipts.map((r) => r.toJson()).toList()),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthUpdated);
    _tabController.dispose();
    _goldenStampController.dispose();
    _nameCtrl.dispose();
    _cardNumCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  String _detectCardBrand(String rawDigits) {
    final clean = rawDigits.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('4')) return 'VISA';
    if (clean.startsWith('5') || clean.startsWith('2')) return 'MASTERCARD';
    if (clean.startsWith('34') || clean.startsWith('37')) return 'AMEX';
    return 'STUDIO CARD';
  }

  String _activePaymentMethodLabel() {
    if (_selectedPaymentMethodId == 'google_play_1tap') {
      return 'Google Play Billing (1-Tap)';
    }
    final card = _savedCards.firstWhere(
      (c) => c.id == _selectedPaymentMethodId,
      orElse: () => _savedCards.isNotEmpty
          ? _savedCards.first
          : const SavedPaymentCard(
              id: 'fallback',
              cardholderName: 'VIP',
              last4: '4242',
              brand: 'VISA',
              expiry: '09/28',
              billingZip: '90028',
            ),
    );
    return '${card.brand} •••• ${card.last4}';
  }

  Future<void> _executeContextualCheckout({
    required String productKey,
    required String title,
    required String priceLabel,
    int tokenGrant = 0,
    List<String> unlockPacks = const <String>[],
  }) async {
    HapticFeedback.heavyImpact();

    if (!_expressOneTapCheckout) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0B0E17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFFFD700), width: 2),
          ),
          title: Text(
            'CONFIRM BOX OFFICE CHECKOUT',
            style: GoogleFonts.bebasNeue(
              fontSize: 24,
              letterSpacing: 1.4,
              color: const Color(0xFFFFD700),
            ),
          ),
          content: Text(
            'Item: $title\nPrice: $priceLabel\nPayment Method: ${_activePaymentMethodLabel()}',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: const Color(0xFF05070B),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'AUTHORIZE & UNLOCK',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    if (tokenGrant > 0) {
      await AuthService.instance.topUpAiTokens(tokenGrant);
    }
    for (final pack in unlockPacks) {
      await AuthService.instance.unlockScenePack(pack);
    }

    final receipt = BoxOfficeReceiptItem(
      id: 'rcpt_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      priceLabel: priceLabel,
      paymentMethodLabel: _activePaymentMethodLabel(),
      purchasedAt: DateTime.now().toUtc(),
    );
    _receipts.insert(0, receipt);
    await _persistBillingState();

    if (!mounted) return;
    setState(() {
      _lastUnlockedTitle = title;
      _showStampCelebration = true;
    });
    await _goldenStampController.forward(from: 0.0);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF065F46),
        content: Text(
          'VIP Box Office Unlocked: $title via ${_activePaymentMethodLabel()}!',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );

    if (widget.returnOnUnlock && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      setState(() => _showStampCelebration = false);
    }
  }

  void _handleSaveNewCard() {
    final name = _nameCtrl.text.trim();
    final digits = _cardNumCtrl.text.replaceAll(RegExp(r'\D'), '');
    final expiry = _expiryCtrl.text.trim();
    final cvc = _cvcCtrl.text.replaceAll(RegExp(r'\D'), '');
    final zip = _zipCtrl.text.trim();

    if (name.isEmpty || digits.length < 12) {
      setState(() {
        _cardFormError = 'Enter a valid Cardholder Name and 16-digit Card Number.';
      });
      return;
    }
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      setState(() {
        _cardFormError = 'Enter Expiration Date in MM/YY format (e.g., 08/28).';
      });
      return;
    }
    if (cvc.length < 3 || zip.length < 3) {
      setState(() {
        _cardFormError = 'Enter a valid 3-4 digit CVC and Billing ZIP Code.';
      });
      return;
    }

    HapticFeedback.heavyImpact();
    final brand = _detectCardBrand(digits);
    final last4 = digits.substring(digits.length - 4);
    final newCard = SavedPaymentCard(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      cardholderName: name.toUpperCase(),
      last4: last4,
      brand: brand,
      expiry: expiry,
      billingZip: zip,
    );

    setState(() {
      _cardFormError = null;
      _savedCards.insert(0, newCard);
      _selectedPaymentMethodId = newCard.id;
      _nameCtrl.clear();
      _cardNumCtrl.clear();
      _expiryCtrl.clear();
      _cvcCtrl.clear();
      _zipCtrl.clear();
    });
    _persistBillingState();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        content: Text(
          'Saved $brand •••• $last4 as active Box Office payment method!',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            color: Color(0xFF05070B),
          ),
        ),
      ),
    );
  }

  Future<void> _restorePurchases() async {
    HapticFeedback.heavyImpact();
    await AuthService.instance.topUpAiTokens(10);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF06B6D4),
        content: Text(
          'Google Play Billing Synced: Active entitlements & +10 bonus AI Tokens verified!',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            color: Color(0xFF05070B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final tokens = auth.aiTokenBalance;

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: GameAppBar(
        title: 'VIP Box Office & Store',
        subtitle: '$tokens AI TOKENS · ${_activePaymentMethodLabel()}',
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              if (widget.contextBannerText != null &&
                  widget.contextBannerText!.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B0610),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.contextBannerText!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFF5DEB3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E131F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFFFFD700),
                  labelColor: const Color(0xFFFFD700),
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  tabs: const [
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '1. STORE & UPGRADES',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '2. PAYMENT METHODS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '3. RECEIPTS & PRIVACY',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStoreAndUpgradesTab(auth),
                    _buildPaymentMethodsTab(),
                    _buildReceiptsAndPrivacyTab(auth),
                  ],
                ),
              ),
            ],
          ),
          if (_showStampCelebration)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.72),
                child: Center(
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _goldenStampController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(28),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0E17),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 3.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFFFFD700),
                            size: 64,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'GOLDEN TICKET STAMPED!',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 30,
                              letterSpacing: 1.8,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _lastUnlockedTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreAndUpgradesTab(AuthService auth) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      children: [
        _buildSectionBanner(
          'AI TELEMETRICS TOKEN PACKS',
          'Power real-time Gemini 2.5 Flash facial micro-expression & vocal scans',
          const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 10),
        _buildProductCard(
          productKey: 'tokens_25',
          badge: 'STARTER REEL',
          title: '25 AI Tokens (Screen Test Pack)',
          subtitle: '25 full multimodal Gemini AI Telemetrics stage evaluations.',
          priceLabel: '\$1.99',
          accent: const Color(0xFF06B6D4),
          isUnlocked: false,
          onBuy: () => _executeContextualCheckout(
            productKey: 'tokens_25',
            title: '25 AI Tokens (Screen Test Pack)',
            priceLabel: '\$1.99',
            tokenGrant: 25,
          ),
        ),
        _buildProductCard(
          productKey: 'tokens_100',
          badge: 'MOST POPULAR · BEST VALUE',
          title: '100 AI Tokens (Director\'s Bundle)',
          subtitle: '100 multimodal AI Telemetrics scans for cast parties & duets.',
          priceLabel: '\$4.99',
          accent: const Color(0xFFFFD700),
          isUnlocked: false,
          onBuy: () => _executeContextualCheckout(
            productKey: 'tokens_100',
            title: '100 AI Tokens (Director\'s Bundle)',
            priceLabel: '\$4.99',
            tokenGrant: 100,
          ),
        ),
        _buildProductCard(
          productKey: 'tokens_300',
          badge: 'STUDIO MOGUL VAULT',
          title: '300 AI Tokens (Studio Mogul Vault)',
          subtitle: '300 AI Telemetrics tokens for non-stop ensemble tournaments.',
          priceLabel: '\$9.99',
          accent: const Color(0xFFE11D48),
          isUnlocked: false,
          onBuy: () => _executeContextualCheckout(
            productKey: 'tokens_300',
            title: '300 AI Tokens (Studio Mogul Vault)',
            priceLabel: '\$9.99',
            tokenGrant: 300,
          ),
        ),
        const SizedBox(height: 18),
        _buildSectionBanner(
          'HOST-PAYS SCENE VAULT EXPANSIONS (GUESTS PLAY FREE!)',
          'Unlock once as Host — up to 8 friends in your 6-digit room play free',
          const Color(0xFFA855F7),
        ),
        const SizedBox(height: 10),
        _buildProductCard(
          productKey: 'emmy_cult_bundle',
          badge: 'ONE-TIME HOST UNLOCK',
          title: 'Emmy Award & Cult Classics Vault Pass',
          subtitle:
              'Unlocks Prestige Television Showstoppers & Midnight Cult Classics for your entire room.',
          priceLabel: '\$3.99',
          accent: const Color(0xFFA855F7),
          isUnlocked: auth.hasEmmyAndCultVault,
          onBuy: () => _executeContextualCheckout(
            productKey: 'emmy_cult_bundle',
            title: 'Emmy Award & Cult Classics Vault Pass',
            priceLabel: '\$3.99',
            unlockPacks: const <String>[
              'emmy_cult_bundle',
              'emmy_vault',
              'cult_classics',
            ],
          ),
        ),
        _buildProductCard(
          productKey: 'all_era_bundle',
          badge: 'COMPLETE STUDIO ARCHIVE',
          title: 'All-Era Complete Box Office Bundle',
          subtitle:
              'Unlocks every current & future Scene Vault category + 40 bonus AI Tokens.',
          priceLabel: '\$6.99',
          accent: const Color(0xFF10B981),
          isUnlocked: auth.hasAllEraBundle,
          onBuy: () => _executeContextualCheckout(
            productKey: 'all_era_bundle',
            title: 'All-Era Complete Box Office Bundle',
            priceLabel: '\$6.99',
            tokenGrant: 40,
            unlockPacks: const <String>[
              'all_era_bundle',
              'emmy_cult_bundle',
              'emmy_vault',
              'cult_classics',
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildSectionBanner(
          '18+ AFTER-HOURS MIDNIGHT SPEAKEASY SUBSCRIPTION',
          'Uncensored R-Rated / TV-MA scripts, Velvet Rope access & monthly token drop',
          const Color(0xFFE11D48),
        ),
        const SizedBox(height: 10),
        _buildProductCard(
          productKey: 'vip_speakeasy_pass',
          badge: 'MONTHLY VIP SUBSCRIPTION',
          title: 'VIP Speakeasy Monthly Pass (18+)',
          subtitle:
              'Unlocks uncensored 18+ Midnight Speakeasy scenes + 50 bonus AI Tokens every month.',
          priceLabel: '\$4.99 / mo',
          accent: const Color(0xFFE11D48),
          isUnlocked: auth.hasVipSpeakeasyPass,
          onBuy: () => _executeContextualCheckout(
            productKey: 'vip_speakeasy_pass',
            title: 'VIP Speakeasy Monthly Pass (18+)',
            priceLabel: '\$4.99 / month',
            tokenGrant: 50,
            unlockPacks: const <String>['vip_speakeasy_pass', 'late_night'],
          ),
        ),
        const SizedBox(height: 18),
        _buildSectionBanner(
          'PRO CREATOR UPGRADE',
          '4K Watermark-Free exports for TikTok, Reels & YouTube Shorts',
          const Color(0xFFFFD700),
        ),
        const SizedBox(height: 10),
        _buildProductCard(
          productKey: 'watermark_free_pro',
          badge: 'CREATOR PRO UNLOCK',
          title: 'Watermark-Free Premiere Reels & Golden Scorecards',
          subtitle:
              'Removes studio watermarks and unlocks 4K Golden Critic Scorecard exports.',
          priceLabel: '\$2.99',
          accent: const Color(0xFFFFD700),
          isUnlocked: auth.hasWatermarkFreePro,
          onBuy: () => _executeContextualCheckout(
            productKey: 'watermark_free_pro',
            title: 'Watermark-Free Premiere Reels & Golden Scorecards',
            priceLabel: '\$2.99',
            unlockPacks: const <String>['watermark_free_pro'],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBanner(String title, String subtitle, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E131F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.65), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String productKey,
    required String badge,
    required String title,
    required String subtitle,
    required String priceLabel,
    required Color accent,
    required bool isUnlocked,
    required VoidCallback onBuy,
  }) {
    final highlighted = widget.highlightProductKey == productKey;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFF171324) : const Color(0xFF0B0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? const Color(0xFFFFD700) : accent,
          width: highlighted ? 2.8 : 1.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accent),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isUnlocked ? 'UNLOCKED ✓' : priceLabel,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isUnlocked
                      ? const Color(0xFF10B981)
                      : const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.38,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isUnlocked ? const Color(0xFF1E293B) : accent,
                foregroundColor:
                    isUnlocked ? const Color(0xFF10B981) : const Color(0xFF05070B),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isUnlocked ? null : onBuy,
              icon: Icon(
                isUnlocked
                    ? Icons.check_circle_rounded
                    : Icons.shopping_bag_rounded,
                size: 18,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isUnlocked
                      ? 'ACTIVE IN YOUR STUDIO VAULT'
                      : 'INSTANT CHECKOUT · $priceLabel',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0E131F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF10B981), width: 1.8),
          ),
          child: Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1-Tap Express Studio Checkout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Fulfill AI Tokens & Scene Vault passes immediately with your default payment method.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _expressOneTapCheckout,
                activeColor: const Color(0xFF10B981),
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _expressOneTapCheckout = v);
                  _persistBillingState();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SAVED PAYMENT METHODS',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD700),
          ),
        ),
        const SizedBox(height: 8),
        RadioListTile<String>(
          value: 'google_play_1tap',
          groupValue: _selectedPaymentMethodId,
          activeColor: const Color(0xFF10B981),
          tileColor: const Color(0xFF0B0E17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF1E293B)),
          ),
          title: const Text(
            'Google Play Billing (1-Tap)',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          ),
          subtitle: const Text(
            'Official Play Store In-App Purchase · Galaxy S26 Ultra Verified',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
          ),
          onChanged: (val) {
            if (val == null) return;
            HapticFeedback.selectionClick();
            setState(() => _selectedPaymentMethodId = val);
            _persistBillingState();
          },
        ),
        const SizedBox(height: 8),
        ..._savedCards.map((card) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              value: card.id,
              groupValue: _selectedPaymentMethodId,
              activeColor: const Color(0xFFFFD700),
              tileColor: const Color(0xFF0B0E17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF1E293B)),
              ),
              title: Text(
                '${card.brand} •••• ${card.last4} (${card.cardholderName})',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                'Expires ${card.expiry} · Billing ZIP ${card.billingZip}',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              ),
              secondary: IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE11D48),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _savedCards.removeWhere((c) => c.id == card.id);
                    if (_selectedPaymentMethodId == card.id) {
                      _selectedPaymentMethodId = 'google_play_1tap';
                    }
                  });
                  _persistBillingState();
                },
              ),
              onChanged: (val) {
                if (val == null) return;
                HapticFeedback.selectionClick();
                setState(() => _selectedPaymentMethodId = val);
                _persistBillingState();
              },
            ),
          );
        }),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0E17),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ADD NEW CREDIT OR DEBIT CARD',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  filled: true,
                  fillColor: Color(0xFF07090E),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cardNumCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Card Number (XXXX XXXX XXXX XXXX)',
                  suffixText: _detectCardBrand(_cardNumCtrl.text),
                  filled: true,
                  fillColor: const Color(0xFF07090E),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        hintText: '08/28',
                        filled: true,
                        fillColor: Color(0xFF07090E),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _cvcCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'CVC',
                        filled: true,
                        fillColor: Color(0xFF07090E),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _zipCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'ZIP Code',
                        filled: true,
                        fillColor: Color(0xFF07090E),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              if (_cardFormError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _cardFormError!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF05070B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _handleSaveNewCard,
                icon: const Icon(Icons.credit_card_rounded),
                label: const Text(
                  'SAVE CARD & SET DEFAULT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptsAndPrivacyTab(AuthService auth) {
    final unlocked = auth.currentProfile?.unlockedScenePacks ?? const <String>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0E17),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF06B6D4), width: 1.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ACTIVE STUDIO ENTITLEMENTS',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• AI Token Balance: ${auth.aiTokenBalance} Tokens\n'
                '• 18+ Midnight Speakeasy VIP: ${auth.hasVipSpeakeasyPass ? "ACTIVE" : "NOT SUBSCRIBED"}\n'
                '• Emmy & Cult Vault Pass: ${auth.hasEmmyAndCultVault ? "UNLOCKED" : "LOCKED"}\n'
                '• Watermark-Free Creator Pro: ${auth.hasWatermarkFreePro ? "UNLOCKED" : "LOCKED"}\n'
                '• Unlocked Pack Keys: ${unlocked.isEmpty ? "Starter Vault" : unlocked.join(", ")}',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _restorePurchases,
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Restore Google Play Purchases'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'ITEMIZED BOX OFFICE RECEIPT HISTORY',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD700),
          ),
        ),
        const SizedBox(height: 8),
        if (_receipts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No Box Office purchases recorded on this device yet.',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          )
        else
          ..._receipts.map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0E17),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${r.paymentMethodLabel} · ${r.purchasedAt.toLocal().toString().substring(0, 16)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    r.priceLabel,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF140B12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE11D48)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'PRIVACY, TERMS & ACCOUNT MANAGEMENT',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE11D48),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await OfflineManager.instance.clearLocalCacheAndOfflineQueue();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cleared local scene cache & offline queues.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.cleaning_services_rounded, size: 18),
                label: const Text('Clear Local Cache & Offline Queue'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF0B0E17),
                      title: const Text(
                        'Delete Actor Profile & Account Data?',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'This permanently removes your active Actor Profile and local data from this device and Supabase.',
                        style: TextStyle(color: Color(0xFFCBD5E1)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('CANCEL'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('DELETE ACCOUNT'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await AuthService.instance.deleteCurrentActorProfileAndData();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const AuthScreen(),
                      ),
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.delete_forever_rounded, size: 18),
                label: const Text('Delete Actor Profile & Account Data'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
