import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/teacher_signin_screen.dart';
import 'screens/main_layout_screen.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state to see if the user has a token
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Student Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // If a token exists, the user is logged in! Route them to the Dashboard.
      // Otherwise, route them to the Sign In screen.
      home: authState.token != null 
          ? const MainLayoutScreen() 
          : const TeacherSignInScreen(),
    );
  }
}