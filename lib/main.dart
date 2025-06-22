// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pontebarbon/providers/registration_provider.dart';
import 'package:pontebarbon/screens/home_page.dart';
import 'package:pontebarbon/screens/login_screen.dart';
import 'package:pontebarbon/screens/welcome_page.dart';
import 'package:pontebarbon/screens/registration/step1_profile.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
      ],
      child: MaterialApp(
        title: 'PonteBarbon',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomePage(),
          '/register': (context) => const CreateProfileScreen(),
        },
      ),
    );
  }
}
