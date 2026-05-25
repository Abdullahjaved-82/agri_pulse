import 'package:shared_preferences/shared_preferences.dart';

/// Checks data staleness on app foreground and triggers refresh if needed.
class DataSyncService {
  static const String _lastSyncKey = 'last_data_sync';
  static const Duration _staleThreshold = Duration(hours: 6);

  /// Returns true if data is stale (older than 6 hours) and should be refreshed.
  static Future<bool> isDataStale() async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastSync = prefs.getInt(_lastSyncKey);
    if (lastSync == null) return true;

    final DateTime lastSyncTime =
        DateTime.fromMillisecondsSinceEpoch(lastSync);
    return DateTime.now().difference(lastSyncTime) > _staleThreshold;
  }

  /// Mark data as freshly synced.
  static Future<void> markSynced() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get the last sync time for display.
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastSync = prefs.getInt(_lastSyncKey);
    if (lastSync == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastSync);
  }
}
