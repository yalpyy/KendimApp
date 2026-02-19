/// Provider wiring — uses conditional import to select web-safe demo
/// providers on web builds and production providers on native.
///
/// Both files export the same provider names, so the rest of the app
/// is unchanged.
export 'providers_production.dart'
    if (dart.library.html) 'providers_demo.dart';
