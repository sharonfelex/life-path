import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/emergency_provider.dart';
import 'widgets/emergency_button.dart';

void main() {
  runApp(const LifePathApp());
}

class LifePathApp extends StatelessWidget {
  const LifePathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmergencyProvider(),
      child: MaterialApp(
        title: 'LifePath',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.redAccent,
            brightness: Brightness.dark,
          ),
        ),
        home: const EmergencyHomeScreen(),
      ),
    );
  }
}

class EmergencyHomeScreen extends StatelessWidget {
  const EmergencyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: Center(
        child: Consumer<EmergencyProvider>(
          builder: (context, provider, _) {
            return EmergencyButton(
              isActive: provider.isEmergencyActive,
              onPressed: provider.toggleEmergency,
            );
          },
        ),
      ),
    );
  }
}
