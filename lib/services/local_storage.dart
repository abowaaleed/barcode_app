import 'dart:convert';
import 'dart:html' as html;

class LocalStorage {
  static const _key = 'qr_history';

  static List<Map<String, dynamic>> loadHistory() {
    try {
      final raw = html.window.localStorage[_key];
      if (raw == null || raw.isEmpty) return [];
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static void saveHistory(List<Map<String, dynamic>> items) {
    try {
      html.window.localStorage[_key] = jsonEncode(items);
    } catch (_) {}
  }

  static void clearHistory() {
    try {
      html.window.localStorage.remove(_key);
    } catch (_) {}
  }
}
