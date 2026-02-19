/// CiviCore - Citizen Dashboard
/// 
/// Main dashboard for citizens
/// Shows available services and application status

import 'package:flutter/material.dart';
import 'citizen_dashboard_enhanced.dart';

class CitizenDashboard extends StatelessWidget {
  const CitizenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Use enhanced dashboard with charts
    return const CitizenDashboardEnhanced();
  }
}
