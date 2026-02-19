/// CiviCore - Officer Dashboard
/// 
/// Dashboard for government officers to review applications

import 'package:flutter/material.dart';
import 'officer_dashboard_enhanced.dart';

class OfficerDashboard extends StatelessWidget {
  const OfficerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Use enhanced dashboard with charts
    return const OfficerDashboardEnhanced();
  }
}
