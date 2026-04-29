import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/dummy_data.dart';
import '../../main.dart';
import '../profile/profile_screen.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class ToolsScreen extends StatefulWidget {
  static const String routeName = '/tools';

  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  static final TextInputFormatter _twoDecimalFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final String text = newValue.text;
        if (text.isEmpty || RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(text)) {
          return newValue;
        }
        return oldValue;
      });

  static final TextInputFormatter _wholeNumberFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final String text = newValue.text;
        if (text.isEmpty || RegExp(r'^\d+$').hasMatch(text)) {
          return newValue;
        }
        return oldValue;
      });

  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();

  final TextEditingController _alertPriceController = TextEditingController();

  double? _totalRevenue;
  double? _totalCost;
  double? _netProfit;
  double? _profitMargin;

  late List<String> _cropOptions;
  String? _selectedCrop;
  String _selectedCondition = 'Above';

  final List<_AlertItem> _activeAlerts = [
    _AlertItem(id: 'wheat-3500', cropName: 'Wheat', condition: 'Above', targetPrice: 3500),
    _AlertItem(id: 'rice-4500', cropName: 'Rice', condition: 'Below', targetPrice: 4500),
  ];

  @override
  void initState() {
    super.initState();
    _cropOptions = DummyData.crops
        .map((crop) => crop['name'] as String)
        .toSet()
        .toList();
    _cropOptions.sort();
    if (_cropOptions.isNotEmpty) {
      _selectedCrop = _cropOptions.first;
    }
  }

  @override
  void dispose() {
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _totalCostController.dispose();
    _alertPriceController.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    final double? sellingPrice = _parseNumeric(_sellingPriceController.text);
    final double? quantity = _parseNumeric(_quantityController.text);
    final double? totalCost = _parseNumeric(_totalCostController.text);

    if (sellingPrice == null || quantity == null || totalCost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values.')),
      );
      return;
    }

    final double revenue = sellingPrice * quantity;
    final double profit = revenue - totalCost;
    final double margin = revenue == 0 ? 0 : (profit / revenue) * 100;

    setState(() {
      _totalRevenue = revenue;
      _totalCost = totalCost;
      _netProfit = profit;
      _profitMargin = margin;
    });
  }

  void _setAlert() {
    final String? crop = _selectedCrop;
    final double? targetPrice = _parseNumeric(_alertPriceController.text);

    if (crop == null || targetPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select crop and enter a valid alert price.')),
      );
      return;
    }

    setState(() {
      _activeAlerts.insert(
        0,
        _AlertItem(
          id: '$crop-${DateTime.now().millisecondsSinceEpoch}',
          cropName: crop,
          condition: _selectedCondition,
          targetPrice: targetPrice,
        ),
      );
      _alertPriceController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert saved!')),
    );
  }

  void _removeAlert(String id) {
    setState(() {
      _activeAlerts.removeWhere((alert) => alert.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showResult = _totalRevenue != null &&
        _totalCost != null &&
        _netProfit != null &&
        _profitMargin != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farming Tools'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Market Overview',
            onPressed: () {
              Navigator.of(context).pushNamed(MyApp.marketOverviewRoute);
            },
            icon: const Icon(Icons.assessment_outlined),
          ),
          IconButton(
            tooltip: 'Weather',
            onPressed: () {
              Navigator.of(context).pushNamed(MyApp.weatherRoute);
            },
            icon: const Icon(Icons.cloud_outlined),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          kDefaultPadding,
          14,
          kDefaultPadding,
          20,
        ),
        child: Column(
          children: [
            _buildProfitCalculatorCard(showResult),
            const SizedBox(height: 16),
            _buildPriceAlertsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitCalculatorCard(bool showResult) {
    return _SectionCard(
      headerColor: kPrimaryColor,
      headerTitle: 'Profit Calculator',
      headerEmoji: '💰',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _sellingPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_twoDecimalFormatter],
            decoration: const InputDecoration(
              labelText: 'Selling Price (PKR per 40kg)',
              prefixIcon: Icon(Icons.sell_outlined),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [_wholeNumberFormatter],
            decoration: const InputDecoration(
              labelText: 'Quantity (40kg bags)',
              prefixIcon: Icon(Icons.inventory_2_outlined),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _totalCostController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_twoDecimalFormatter],
            decoration: const InputDecoration(
              labelText: 'Total Cost (PKR)',
              prefixIcon: Icon(Icons.payments_outlined),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _calculateProfit,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'Calculate Profit',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (showResult) ...[
            const SizedBox(height: 14),
            _buildResultCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final double netProfit = _netProfit ?? 0;
    final Color netColor = netProfit >= 0 ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultRow(label: 'Total Revenue', value: 'PKR ${_formatNum(_totalRevenue)}'),
          const SizedBox(height: 8),
          _ResultRow(label: 'Total Cost', value: 'PKR ${_formatNum(_totalCost)}'),
          const SizedBox(height: 10),
          Text(
            'Net Profit: PKR ${_formatNum(_netProfit)}',
            style: TextStyle(
              color: netColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Profit Margin: ${(_profitMargin ?? 0).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: kTextDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAlertsCard() {
    return _SectionCard(
      headerColor: kHighlightColor,
      headerTitle: 'Price Alerts',
      headerEmoji: '🔔',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedCrop,
            items: _cropOptions
                .map(
                  (crop) => DropdownMenuItem<String>(
                    value: crop,
                    child: Text(crop),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCrop = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Select Crop',
              prefixIcon: Icon(Icons.grass_outlined),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Alert when price goes',
            style: TextStyle(
              color: kTextDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCondition,
                  items: const [
                    DropdownMenuItem(value: 'Above', child: Text('Above')),
                    DropdownMenuItem(value: 'Below', child: Text('Below')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedCondition = value;
                    });
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _alertPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_twoDecimalFormatter],
                  decoration: const InputDecoration(
                    hintText: 'Price (PKR)',
                    prefixIcon: Icon(Icons.currency_rupee),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _setAlert,
            style: ElevatedButton.styleFrom(
              backgroundColor: kHighlightColor,
              foregroundColor: Colors.black87,
              minimumSize: const Size.fromHeight(46),
            ),
            child: const Text(
              'Set Alert',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Active Alerts',
            style: TextStyle(
              color: kTextDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (_activeAlerts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No active alerts.',
                style: TextStyle(color: kTextLight),
              ),
            )
          else
            ..._activeAlerts.map((alert) {
              return Dismissible(
                key: ValueKey(alert.id),
                background: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  _removeAlert(alert.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kAccentColor.withValues(alpha: 0.4)),
                  ),
                  child: ListTile(
                    title: Text(
                      alert.cropName,
                      style: const TextStyle(
                        color: kTextDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${alert.cropName} ${alert.condition == 'Above' ? '>' : '<'} ${_formatNum(alert.targetPrice)} PKR',
                      style: const TextStyle(color: kTextLight),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeAlert(alert.id),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatNum(double? value) {
    final String normalized = ((value ?? 0).isFinite ? (value ?? 0) : 0)
        .toStringAsFixed(0);
    final bool isNegative = normalized.startsWith('-');
    final String digits = isNegative ? normalized.substring(1) : normalized;
    final String withCommas = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return isNegative ? '-$withCommas' : withCommas;
  }

  double? _parseNumeric(String input) {
    final String sanitized = input.replaceAll(',', '').trim();
    if (sanitized.isEmpty) {
      return null;
    }
    return double.tryParse(sanitized);
  }
}

class _SectionCard extends StatelessWidget {
  final Color headerColor;
  final String headerTitle;
  final String headerEmoji;
  final Widget child;

  const _SectionCard({
    required this.headerColor,
    required this.headerTitle,
    required this.headerEmoji,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(kDefaultBorderRadius),
                topRight: Radius.circular(kDefaultBorderRadius),
              ),
            ),
            child: Text(
              '$headerEmoji $headerTitle',
              style: TextStyle(
                color: headerColor == kHighlightColor ? Colors.black87 : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: kTextLight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: kTextDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AlertItem {
  final String id;
  final String cropName;
  final String condition;
  final double targetPrice;

  const _AlertItem({
    required this.id,
    required this.cropName,
    required this.condition,
    required this.targetPrice,
  });
}


