import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/config/get_it_config.dart';
import 'core/navigation/main_navigation_page.dart';
import 'admin/admin_panel_page.dart';
import 'firebase_options.dart';

bool get _isAdminEmail {
  const adminEmails = {'testscolors@gmail.com'};
  final email = FirebaseAuth.instance.currentUser?.email ?? '';
  return adminEmails.contains(email);
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationPage(),
    ),
    GoRoute(
      path: '/admin',
      redirect: (context, state) => _isAdminEmail ? null : '/',
      builder: (context, state) => const AdminPanelPage(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure dependencies
  await configureDependencies();

  runApp(const ProviderScope(child: ReagentTestingApp()));
}

class ReagentTestingApp extends StatelessWidget {
  const ReagentTestingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reagent Testing App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
