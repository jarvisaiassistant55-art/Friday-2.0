import 'package:android_intent_plus/android_intent.dart';
class AppLauncher { Future<void> openSettings()=>AndroidIntent(action:'android.settings.SETTINGS').launch(); }
