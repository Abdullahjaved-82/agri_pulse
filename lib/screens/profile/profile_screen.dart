import 'package:flutter/material.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUrdu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            title: const Text('Profile'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryColor, kSecondaryColor],
                  ),
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 28,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Farmer Name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '+92 300 1234567',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          children: [
                            Expanded(
                              child: _HeaderStatCard(
                                value: '12',
                                label: 'Alerts Set',
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _HeaderStatCard(
                                value: '3',
                                label: 'Crops Tracked',
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _HeaderStatCard(
                                value: '2024',
                                label: 'Member Since',
                              ),
                            ),
                          ],
                        ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              kDefaultPadding,
              14,
              kDefaultPadding,
              20,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SettingsTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  onTap: () {
                    _showSoonSnack('Edit Profile');
                  },
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.of(context).pushNamed(MyApp.notificationsRoute);
                  },
                ),
                _LanguageTile(
                  isUrdu: _isUrdu,
                  onChanged: (value) {
                    setState(() {
                      _isUrdu = value;
                    });
                  },
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About App',
                  onTap: () {
                    Navigator.of(context).pushNamed(MyApp.aboutRoute);
                  },
                ),
                _SettingsTile(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  title: 'Logout',
                  onTap: _showLogoutDialog,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showSoonSnack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label will be available soon.')),
    );
  }

  Future<void> _showLogoutDialog() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout from AgriPulse?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
    }
  }
}

class _HeaderStatCard extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? kPrimaryColor;
    final Color effectiveTextColor = textColor ?? kTextDark;

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
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: effectiveIconColor),
        title: Text(
          title,
          style: TextStyle(
            color: effectiveTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: effectiveTextColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final bool isUrdu;
  final ValueChanged<bool> onChanged;

  const _LanguageTile({required this.isUrdu, required this.onChanged});

  @override
  Widget build(BuildContext context) {
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
      child: ListTile(
        leading: const Icon(Icons.language, color: kPrimaryColor),
        title: const Text(
          'Language',
          style: TextStyle(
            color: kTextDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          isUrdu ? 'اردو' : 'English',
          style: const TextStyle(
            color: kTextLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Switch(
          value: isUrdu,
          activeThumbColor: kPrimaryColor,
          onChanged: onChanged,
        ),
      ),
    );
  }
}


