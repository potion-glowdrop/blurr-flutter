import 'package:blurr/core/widgets/camera_handler.dart'; // AVPermissionGate
import 'package:flutter/material.dart';
import 'features/onboarding/onboarding_page.dart';
// import 'features/home/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AVPermissionGate(
        child: const OnboardingPage(),
      ),
    );
  }
}
