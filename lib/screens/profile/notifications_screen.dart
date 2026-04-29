import 'package:flutter/material.dart';

import '../../services/notification_service.dart';
import '../../utils/colors.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _marketAlerts = true;
  bool _newsAlerts = true;
  bool _weatherAlerts = false;

  Future<void> _sendTestNotification() async {
    await NotificationService.instance.showTestNotification(
      title: 'AgriPulse Alert',
      body: 'Wheat crossed your target price in Lahore mandi.',
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test notification sent.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _switchTile(
            title: 'Market Price Alerts',
            subtitle: 'Receive real-time mandi price movements',
            value: _marketAlerts,
            onChanged: (value) {
              setState(() {
                _marketAlerts = value;
              });
            },
          ),
          _switchTile(
            title: 'Agriculture News',
            subtitle: 'Daily policy, weather and crop updates',
            value: _newsAlerts,
            onChanged: (value) {
              setState(() {
                _newsAlerts = value;
              });
            },
          ),
          _switchTile(
            title: 'Weather Advisories',
            subtitle: 'Localized guidance for upcoming conditions',
            value: _weatherAlerts,
            onChanged: (value) {
              setState(() {
                _weatherAlerts = value;
              });
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _sendTestNotification,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
            ),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Send Test Notification'),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        activeThumbColor: kPrimaryColor,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: kTextLight)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

