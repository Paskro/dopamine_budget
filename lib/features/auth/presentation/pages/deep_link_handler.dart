import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Инициализировать один раз в main() перед runApp.
/// Supabase сам обрабатывает сессию из URI — нам нужно только прокинуть ссылку.
final class DeepLinkHandler {
  static StreamSubscription<Uri>? _sub;

  static Future<void> init() async {
    final appLinks = AppLinks();

    // Cold start — приложение убито
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      await _handleUri(initialUri);
    }

    // Foreground / background → foreground
    _sub = appLinks.uriLinkStream.listen(_handleUri);
  }

  static Future<void> _handleUri(Uri uri) async {
    if (uri.scheme == 'dopaminebudget' && uri.host == 'auth') {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    }
  }

  static void dispose() => _sub?.cancel();
}