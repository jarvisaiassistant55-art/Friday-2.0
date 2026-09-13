import 'package:flutter/material.dart';

import 'chat/chat_screen.dart';
import 'core/app_theme.dart';
import 'core/runtime/runtime_scope.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/tools_screen.dart';

class FridayApp extends StatefulWidget {
  const FridayApp({super.key});

  @override
  State<FridayApp> createState() => _FridayAppState();
}

class _FridayAppState extends State<FridayApp> {
  int index = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = const [
      HomeScreen(),
      ChatScreen(),
      ToolsScreen(),
      ProfileScreen(),
      SettingsScreen(),
    ];

    jarvisRuntime.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Friday 4.0',
      theme: AppTheme.dark,
      home: Scaffold(
        body: IndexedStack(
          index: index,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (int value) {
            setState(() {
              index = value;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.apps_outlined),
              selectedIcon: Icon(Icons.apps),
              label: 'Tools',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}