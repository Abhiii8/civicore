/// CiviCore - Enhanced Officer Dashboard
/// 
/// Modern officer dashboard with statistics and visualizations
/// Supports efficient application review

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/application_service.dart';
import '../../models/application_model.dart';
import '../../widgets/charts/statistics_chart.dart';
import 'application_review_screen.dart';
import 'complaints_management_screen.dart';

class OfficerDashboardEnhanced extends StatefulWidget {
  const OfficerDashboardEnhanced({super.key});

  @override
  State<OfficerDashboardEnhanced> createState() => _OfficerDashboardEnhancedState();
}

class _OfficerDashboardEnhancedState extends State<OfficerDashboardEnhanced> {
  final _applicationService = ApplicationService();
  final _authService = AuthService();
  
  List<ApplicationModel> _applications = [];
  bool _isLoading = true;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    final applications = await _applicationService.getAssignedApplications(
      status: _selectedStatus,
    );
    setState(() {
      _applications = applications;
      _isLoading = false;
    });
  }

  Map<String, int> get _applicationStats {
    final stats = <String, int>{
      'Pending': 0,
      'Under Review': 0,
      'Approved': 0,
      'Rejected': 0,
    };
    
    for (var app in _applications) {
      switch (app.status) {
        case 'pending':
          stats['Pending'] = (stats['Pending'] ?? 0) + 1;
          break;
        case 'under_review':
          stats['Under Review'] = (stats['Under Review'] ?? 0) + 1;
          break;
        case 'approved':
          stats['Approved'] = (stats['Approved'] ?? 0) + 1;
          break;
        case 'rejected':
          stats['Rejected'] = (stats['Rejected'] ?? 0) + 1;
          break;
      }
    }
    
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CiviCore - Officer Portal'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ComplaintsManagementScreen(),
                ),
              );
            },
            tooltip: 'Manage Complaints',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApplications,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total',
                    value: _applications.length.toString(),
                    color: Colors.blue,
                    icon: Icons.description,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Pending',
                    value: _applications.where((a) => a.status == 'pending').length.toString(),
                    color: Colors.orange,
                    icon: Icons.pending,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Review',
                    value: _applications.where((a) => a.status == 'under_review').length.toString(),
                    color: Colors.purple,
                    icon: Icons.hourglass_empty,
                  ),
                ),
              ],
            ),
          ),

          // Chart
          if (_applications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatisticsChart(
                title: 'Applications Overview',
                data: _applicationStats,
                type: ChartType.pie,
              ),
            ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _selectedStatus == null,
                    onSelected: () {
                      setState(() {
                        _selectedStatus = null;
                        _loadApplications();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    selected: _selectedStatus == 'pending',
                    onSelected: () {
                      setState(() {
                        _selectedStatus = 'pending';
                        _loadApplications();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Under Review',
                    selected: _selectedStatus == 'under_review',
                    onSelected: () {
                      setState(() {
                        _selectedStatus = 'under_review';
                        _loadApplications();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(),

          // Applications List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadApplications,
                    child: _applications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No applications assigned',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _applications.length,
                            itemBuilder: (context, index) {
                              final app = _applications[index];
                              return _ApplicationCard(
                                application: app,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ApplicationReviewScreen(applicationId: app.id),
                                    ),
                                  ).then((_) => _loadApplications());
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onTap;

  const _ApplicationCard({
    required this.application,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(application.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description,
                  color: _getStatusColor(application.status),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.serviceName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Application #${application.applicationNumber}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Citizen: ${application.citizenName}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(application.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  application.statusDisplay,
                  style: TextStyle(
                    color: _getStatusColor(application.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
