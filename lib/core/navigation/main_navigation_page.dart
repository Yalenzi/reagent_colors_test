import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/auth_guard.dart';
import '../../features/profile/presentation/views/profile_page.dart';
import '../../features/reagent_testing/presentation/views/reagent_testing_page.dart';
import '../../features/reagent_testing/presentation/views/test_result_history_page.dart';
import '../../features/settings/presentation/views/settings_page.dart';
import '../../l10n/app_localizations.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    AuthGuard(
      redirectMessage:
          'Sign in to start testing reagents and view your results.',
      child: const ReagentTestingPage(),
    ),
    AuthGuard(
      redirectMessage:
          'Sign in to view your test history and track your results.',
      child: const TestResultHistoryPage(),
    ),
    AuthGuard(
      redirectMessage: 'Sign in to access app settings and preferences.',
      child: const SettingsPage(),
    ),
    const ProfilePage(), // Profile page handles its own auth state
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.science),
            label: l10n.reagentTesting,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: l10n.testHistory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Placeholder Pages - Will be implemented in their respective features
