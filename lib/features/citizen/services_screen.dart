/// CiviCore - Services Screen
/// 
/// Displays all available government services
/// Allows citizens to apply for services

import 'package:flutter/material.dart';
import 'services_screen_enhanced.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use enhanced services screen
    return const ServicesScreenEnhanced();
  }
}
