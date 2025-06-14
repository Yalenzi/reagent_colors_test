import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/get_it_config.dart';
import 'core/navigation/main_navigation_page.dart';
import 'firebase_options.dart';

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
    return MaterialApp(
      title: 'Reagent Testing App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MainNavigationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
