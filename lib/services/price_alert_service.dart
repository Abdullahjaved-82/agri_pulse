import 'package:shared_preferences/shared_preferences.dart';

import '../models/price_alert_model.dart';
import '../services/notification_service.dart';

class PriceAlertService {
  static const String _storageKey = 'price_alerts';
  static PriceAlertService? _instance;

  PriceAlertService._();
  static PriceAlertService get instance => _instance ??= PriceAlertService._();

  List<PriceAlertModel> _alerts = [];
  bool _loaded = false;

  List<PriceAlertModel> get alerts => List.unmodifiable(_alerts);
  int get activeCount => _alerts.where((a) => a.enabled).length;
  bool get hasActiveAlerts => _alerts.any((a) => a.enabled);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        _alerts = PriceAlertModel.listFromJson(jsonStr);
      } catch (_) {
        _alerts = [];
      }
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, PriceAlertModel.listToJson(_alerts));
  }

  Future<void> addAlert(PriceAlertModel alert) async {
    await load();
    _alerts.add(alert);
    await _save();
  }

  Future<void> removeAlert(String id) async {
    await load();
    _alerts.removeWhere((a) => a.id == id);
    await _save();
  }

  Future<void> toggleAlert(String id) async {
    await load();
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _alerts[idx] = _alerts[idx].copyWith(enabled: !_alerts[idx].enabled);
      await _save();
    }
  }

  /// Check all enabled alerts against current prices.
  /// [currentPrices] is a list of maps with at least 'name' and 'price' keys.
  Future<void> checkAlerts(List<Map<String, dynamic>> currentPrices) async {
    await load();

    for (final alert in _alerts) {
      if (!alert.enabled) continue;

      final match = currentPrices.where(
        (c) => (c['name'] as String).toLowerCase() == alert.commodityName.toLowerCase(),
      );
      if (match.isEmpty) continue;

      final double currentPrice = (match.first['price'] as num).toDouble();
      bool triggered = false;

      if (alert.condition == 'above' && currentPrice >= alert.targetPrice) {
        triggered = true;
      } else if (alert.condition == 'below' && currentPrice <= alert.targetPrice) {
        triggered = true;
      }

      if (triggered) {
        await NotificationService.instance.showTestNotification(
          title: '🔔 Price Alert: ${alert.commodityName}',
          body: '${alert.commodityName} is now PKR ${currentPrice.toStringAsFixed(0)} '
              '(target: ${alert.condition} PKR ${alert.targetPrice.toStringAsFixed(0)})',
        );
      }
    }
  }
}
