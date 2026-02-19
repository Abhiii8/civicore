/// CiviCore - Admin Dashboard
/// 
/// Administrative dashboard with analytics and system management

import 'package:flutter/material.dart';
import 'admin_dashboard_enhanced.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Use enhanced dashboard with charts
    return const AdminDashboardEnhanced();
  }
}
