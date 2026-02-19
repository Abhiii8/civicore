/// CiviCore - My Applications Screen
/// 
/// Lists all applications submitted by the citizen
/// Shows application status and timeline

import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../models/application_model.dart';
import 'application_detail_screen.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final _applicationService = ApplicationService();
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
    final applications = await _applicationService.getMyApplications();
    setState(() {
      _applications = applications;
      _isLoading = false;
    });
  }

  List<ApplicationModel> get _filteredApplications {
    if (_selectedStatus == null) return _applications;
    return _applications.where((app) => app.status == _selectedStatus).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: Column(
        children: [
          // Filter chips
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
                      setState(() => _selectedStatus = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    selected: _selectedStatus == 'pending',
                    onSelected: () {
                      setState(() => _selectedStatus = 'pending');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Under Review',
                    selected: _selectedStatus == 'under_review',
                    onSelected: () {
                      setState(() => _selectedStatus = 'under_review');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Approved',
                    selected: _selectedStatus == 'approved',
                    onSelected: () {
                      setState(() => _selectedStatus = 'approved');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Rejected',
                    selected: _selectedStatus == 'rejected',
                    onSelected: () {
                      setState(() => _selectedStatus = 'rejected');
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          
          // Applications list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadApplications,
                    child: _filteredApplications.isEmpty
                        ? const Center(child: Text('No applications found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredApplications.length,
                            itemBuilder: (context, index) {
                              final app = _filteredApplications[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ApplicationDetailScreen(applicationId: app.id),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _getStatusIcon(app.status),
                                              color: _getStatusColor(app.status),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    app.serviceName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Application #${app.applicationNumber}',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(app.status).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                app.statusDisplay,
                                                style: TextStyle(
                                                  color: _getStatusColor(app.status),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.business, size: 16, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              app.departmentName,
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                            const Spacer(),
                                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDate(app.appliedDate),
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
