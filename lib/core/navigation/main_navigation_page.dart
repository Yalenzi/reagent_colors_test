import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../admin/admin_panel_page.dart';

import '../../features/profile/presentation/views/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ReagentTestingPage(),
    const ResultsPage(),
    const SettingsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Footer credits (visible across the app)
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: const Column(
              children: [
                Text(
                  'Developed by: Mohammed Naffaa Alruwaili · Yousif Mesear Alenezi',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
                SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    'تم تطويره من قبل: محمد نفاع الرويلي · يوسف مسير العنزي',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Testing'),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Results',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }
}

// Placeholder Pages - Will be implemented in their respective features
class ReagentTestingPage extends StatelessWidget {
  const ReagentTestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧪 Reagent Testing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Reagent Testing Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Select reagents and test samples'),
          ],
        ),
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 Test Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Results History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('View your test results and history'),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    const adminEmails = {'testscolors@gmail.com'};
    final bool isAdmin = adminEmails.contains(userEmail);

    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Center(child: Icon(Icons.settings, size: 64, color: Colors.orange)),
            const SizedBox(height: 12),
            const Center(
              child: Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),

            if (isAdmin)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/admin');
                        },
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Open Admin Panel'),
                      ),
                      const SizedBox(height: 8),
                      Text('Signed in as: ${userEmail.isEmpty ? 'Guest' : userEmail}',
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Developed by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Mohammed Naffaa Alruwaili'),
                    Text('Yousif Mesear Alenezi'),
                    SizedBox(height: 12),
                    Text('تم تطويره من قبل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('محمد نفاع الرويلي'),
                    Text('يوسف مسير العنزي'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
