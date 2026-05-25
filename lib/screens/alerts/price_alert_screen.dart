import '../../utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/dummy_data.dart';
import '../../models/price_alert_model.dart';
import '../../services/price_alert_service.dart';
import '../../utils/colors.dart';

class PriceAlertScreen extends StatefulWidget {
  static const String routeName = '/price-alerts';
  const PriceAlertScreen({super.key});

  @override
  State<PriceAlertScreen> createState() => _PriceAlertScreenState();
}

class _PriceAlertScreenState extends State<PriceAlertScreen> {
  final PriceAlertService _alertService = PriceAlertService.instance;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _alertService.load();
    if (mounted) setState(() => _loaded = true);
  }

  void _showCreateDialog({String? prefilledCrop}) {
    String selectedCrop = prefilledCrop ??
        (DummyData.crops.isNotEmpty ? DummyData.crops.first['name'] as String : 'Wheat');
    String condition = 'above';
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            20, 20, 20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create Price Alert',
                style: AppFonts.dmSans(context, 
                  fontSize: 20, fontWeight: FontWeight.w700, color: kTextDark,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCrop,
                items: DummyData.crops
                    .map((c) => c['name'] as String)
                    .toSet()
                    .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
                onChanged: (v) => setSheetState(() => selectedCrop = v ?? selectedCrop),
                decoration: const InputDecoration(
                  labelText: 'Commodity',
                  prefixIcon: Icon(Icons.grass_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Price (PKR)',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Alert when price goes: ',
                      style: TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Above'),
                    selected: condition == 'above',
                    selectedColor: kSecondaryColor,
                    labelStyle: TextStyle(
                      color: condition == 'above' ? Colors.white : kTextDark,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setSheetState(() => condition = 'above'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Below'),
                    selected: condition == 'below',
                    selectedColor: Colors.red.shade400,
                    labelStyle: TextStyle(
                      color: condition == 'below' ? Colors.white : kTextDark,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setSheetState(() => condition = 'below'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final price = double.tryParse(priceController.text.trim());
                    if (price == null || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid price')),
                      );
                      return;
                    }
                    final alert = PriceAlertModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      commodityName: selectedCrop,
                      targetPrice: price,
                      condition: condition,
                      mandiId: 'default',
                      enabled: true,
                      createdAt: DateTime.now(),
                    );
                    await _alertService.addAlert(alert);
                    if (mounted) {
                      Navigator.of(ctx).pop();
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Create Alert',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Price Alerts'),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final alerts = _alertService.alerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('New Alert', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: kTextLight.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No price alerts set',
                    style: AppFonts.dmSans(context, 
                      color: kTextLight, fontSize: 16, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first alert',
                    style: AppFonts.dmSans(context, color: kTextLight, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final crop = DummyData.crops.firstWhere(
                  (c) => c['name'] == alert.commodityName,
                  orElse: () => {'imageEmoji': '🌾', 'price': 0.0},
                );
                final currentPrice = (crop['price'] as num?)?.toDouble() ?? 0;
                final isTriggered = alert.condition == 'above'
                    ? currentPrice >= alert.targetPrice
                    : currentPrice <= alert.targetPrice;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isTriggered && alert.enabled
                        ? Border.all(color: Colors.orange.shade400, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(crop['imageEmoji'] as String? ?? '🌾',
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.commodityName,
                              style: AppFonts.dmSans(context, 
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: kTextDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: alert.condition == 'above'
                                        ? Colors.green.withValues(alpha: 0.12)
                                        : Colors.red.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${alert.condition == 'above' ? '↑' : '↓'} ${alert.condition.toUpperCase()} PKR ${alert.targetPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: alert.condition == 'above'
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (isTriggered && alert.enabled) ...[
                                  const SizedBox(width: 6),
                                  const Text('⚡', style: TextStyle(fontSize: 12)),
                                  Text(
                                    'TRIGGERED',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Current: PKR ${currentPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: kTextLight, fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: alert.enabled,
                        activeColor: kPrimaryColor,
                        onChanged: (_) async {
                          await _alertService.toggleAlert(alert.id);
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red.shade400, size: 22),
                        onPressed: () async {
                          await _alertService.removeAlert(alert.id);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
