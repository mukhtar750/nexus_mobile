import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Use LAN IP for physical device support
      return 'http://192.168.100.100:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static String get apiUrl => '$baseUrl/api';

  static String? getValidUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Handle full URLs
    if (url.startsWith('http')) {
      // If on Android, replace localhost/127.0.0.1 with 192.168.100.41
      if (Platform.isAndroid) {
        if (url.contains('localhost')) {
          return url.replaceFirst('localhost', '192.168.100.100');
        }
        if (url.contains('127.0.0.1')) {
          return url.replaceFirst('127.0.0.1', '192.168.100.100');
        }
      }
      return url;
    }

    // Handle relative URLs
    return '$baseUrl${url.startsWith('/') ? '' : '/'}$url';
  }
}
