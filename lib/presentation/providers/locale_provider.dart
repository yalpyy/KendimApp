import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User-selected locale override.
///
/// null = follow system locale (default).
/// Set to Locale('tr') or Locale('en') from LanguageScreen.
final localeProvider = StateProvider<Locale?>((ref) => null);
