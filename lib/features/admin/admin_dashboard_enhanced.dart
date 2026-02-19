/// CiviCore - Enhanced Admin Dashboard
/// 
/// Modern admin dashboard with charts, graphs, and analytics
/// Supports efficient governance and accountability

import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/charts/statistics_chart.dart';
import 'departments_screen.dart';
import 'users_screen.dart';
import 'services_management_screen.dart';
import 'applications_screen.dart';
import '../officer/complaints_management_screen.dart';

class AdminDashboardEnhanced extends StatefulWidget {
  const AdminDashboardEnhanced({super.key});

  @override
  State<AdminDashboardEnhanced> createState() => _AdminDashboardEnhancedState();
}

class _AdminDashboardEnhancedState extends State<AdminDashboardEnhanced> {
  final _apiClient = ApiClient();
  final _authService = AuthService();
  
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.adminDashboard);
      if (response.data is Map && response.data['success'] == true) {
        setState(() {
          _dashboardData = response.data['data'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          final errorMsg = response.data is Map 
              ? (response.data['message'] ?? 'Failed to load dashboard')
              : 'Failed to load dashboard';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CiviCore - Admin Portal'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _authService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    _WelcomeCard(),
                    const SizedBox(height: 24),

                    // Quick Stats Cards
                    _QuickStatsGrid(data: _dashboardData),
                    const SizedBox(height: 24),

                    // Application Statistics Chart
                    if (_dashboardData['applications'] != null)
                      StatisticsChart(
                        title: 'Applications by Status',
                        data: Map<String, int>.from(
                          _dashboardData['applications'] as Map,
                        ),
                        type: ChartType.pie,
                      ),
                    const SizedBox(height: 24),

                    // User Statistics Chart
                    if (_dashboardData['users'] != null)
                      StatisticsChart(
                        title: 'Users by Role',
                        data: Map<String, int>.from(
                          _dashboardData['users'] as Map,
                        ),
                        type: ChartType.bar,
                      ),
                    const SizedBox(height: 24),

                    // Complaint Statistics Chart
                    if (_dashboardData['complaints'] != null)
                      StatisticsChart(
                        title: 'Complaints by Status',
                        data: Map<String, int>.from(
                          _dashboardData['complaints'] as Map,
                        ),
                        type: ChartType.bar,
                      ),
                    const SizedBox(height: 24),

                    // Management Section
                    Text(
                      'System Management',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _ManagementGrid(),
                    const SizedBox(height: 24),

                    // Recent Applications
                    if (_dashboardData['recent_applications'] != null &&
                        (_dashboardData['recent_applications'] as List).isNotEmpty)
                      _RecentApplicationsCard(
                        applications: _dashboardData['recent_applications'] as List,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Administrator',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage departments, services, and monitor system activity',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _QuickStatsGrid extends StatelessWidget {
  final Map<String, dynamic> data;

  const _QuickStatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final applications = data['applications'] as Map<String, dynamic>? ?? {};
    final users = data['users'] as Map<String, dynamic>? ?? {};
    final complaints = data['complaints'] as Map<String, dynamic>? ?? {};

    final totalApplications = applications.values.fold<int>(
      0,
      (sum, value) => sum + (value is int ? value : 0),
    );
    final totalUsers = users.values.fold<int>(
      0,
      (sum, value) => sum + (value is int ? value : 0),
    );
    final totalComplaints = complaints.values.fold<int>(
      0,
      (sum, value) => sum + (value is int ? value : 0),
    );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          title: 'Total Applications',
          value: totalApplications.toString(),
          icon: Icons.description,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Total Users',
          value: totalUsers.toString(),
          icon: Icons.people,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Total Complaints',
          value: totalComplaints.toString(),
          icon: Icons.report_problem,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Pending Reviews',
          value: (applications['pending'] ?? 0).toString(),
          icon: Icons.pending_actions,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _ManagementCard(
          icon: Icons.business,
          title: 'Departments',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DepartmentsScreen()),
            );
          },
        ),
        _ManagementCard(
          icon: Icons.people,
          title: 'Users',
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UsersScreen()),
            );
          },
        ),
        _ManagementCard(
          icon: Icons.list_alt,
          title: 'Services',
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServicesManagementScreen()),
            );
          },
        ),
        _ManagementCard(
          icon: Icons.description,
          title: 'Applications',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApplicationsScreen()),
            );
          },
        ),
        _ManagementCard(
          icon: Icons.report_problem,
          title: 'Complaints',
          color: Colors.red,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ComplaintsManagementScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentApplicationsCard extends StatelessWidget {
  final List applications;

  const _RecentApplicationsCard({required this.applications});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Applications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...applications.take(5).map((app) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(app['status'] ?? 'pending')
                      .withOpacity(0.2),
                  child: Icon(
                    _getStatusIcon(app['status'] ?? 'pending'),
                    color: _getStatusColor(app['status'] ?? 'pending'),
                  ),
                ),
                title: Text(
                  app['service_name'] ?? 'Unknown Service',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${app['citizen_name'] ?? 'Unknown'} • ${app['application_number'] ?? ''}',
                ),
                trailing: Chip(
                  label: Text(
                    app['status'] ?? 'pending',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor(app['status'] ?? 'pending')
                      .withOpacity(0.1),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'under_review':
        return Icons.hourglass_empty;
      default:
        return Icons.pending;
    }
  }
}
