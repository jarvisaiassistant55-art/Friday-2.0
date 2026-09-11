import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/tools_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'chat/chat_screen.dart';
import 'core/runtime/runtime_scope.dart';

class FridayApp extends StatefulWidget {
  const FridayApp({super.key});
  @override State<FridayApp> createState() => _FridayAppState();
}
class _FridayAppState extends State<FridayApp> {
  int index = 0;
  final pages = const [HomeScreen(), ChatScreen(), ToolsScreen(), ProfileScreen(), SettingsScreen()];
  @override void initState(){super.initState(); jarvisRuntime.initialize();}
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Friday 4.0',
    theme: AppTheme.dark,
    home: Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: FridayBottomNav(index: index, onChanged: (i) => setState(() => index = i)),
    ),
  );
}
