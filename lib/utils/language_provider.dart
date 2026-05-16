import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LanguageProvider  –  simple InheritedNotifier-based locale switcher
//   • No external packages needed
//   • Works with MaterialApp.locale
//   • Toggle between English (en) and Urdu (ur)
// ─────────────────────────────────────────────────────────────────────────────

class LanguageNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isUrdu => _locale.languageCode == 'ur';

  void setUrdu(bool urdu) {
    final next = urdu ? const Locale('ur') : const Locale('en');
    if (_locale == next) return;
    _locale = next;
    notifyListeners();
  }

  void toggle() => setUrdu(!isUrdu);
}

/// Put this above MaterialApp in main.dart:
///   LanguageScope(child: MaterialApp(...))
class LanguageScope extends StatefulWidget {
  final Widget child;
  const LanguageScope({super.key, required this.child});

  @override
  State<LanguageScope> createState() => _LanguageScopeState();

  static LanguageNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_LanguageInherited>()!
        .notifier!;
  }
}

class _LanguageScopeState extends State<LanguageScope> {
  final LanguageNotifier _notifier = LanguageNotifier();

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, child) => _LanguageInherited(
        notifier: _notifier,
        child: widget.child,
      ),
    );
  }
}

class _LanguageInherited extends InheritedNotifier<LanguageNotifier> {
  const _LanguageInherited({
    required super.notifier,
    required super.child,
  });
}
