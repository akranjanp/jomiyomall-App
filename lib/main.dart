import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'shared/providers/app_providers.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 4));
    } catch (_) {}

    // Fallback if prefs creation has any issue
    prefs ??= await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const JomiyoMallApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught app error: $error\n$stack');
  });
}
