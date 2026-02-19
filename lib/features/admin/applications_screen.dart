/// CiviCore - Applications Management Screen
/// 
/// Admin interface for viewing and managing all applications
/// Admin can view, approve, and reject any application

import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../models/application_model.dart';
import '../officer/application_review_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
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
    try {
      final response = await _applicationService.getAllApplications(status: _selectedStatus);
      setState(() {
        _applications = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading applications: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        title: const Text('All Applications'),
        elevation: 0,
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
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Approved',
                    selected: _selectedStatus == 'approved',
                    onSelected: () {
                      setState(() {
                        _selectedStatus = 'approved';
                        _loadApplications();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Rejected',
                    selected: _selectedStatus == 'rejected',
                    onSelected: () {
                      setState(() {
                        _selectedStatus = 'rejected';
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
                    child: _filteredApplications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No applications found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredApplications.length,
                            itemBuilder: (context, index) {
                              final app = _filteredApplications[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColor(app.status).withOpacity(0.2),
                                    child: Icon(
                                      _getStatusIcon(app.status),
                                      color: _getStatusColor(app.status),
                                    ),
                                  ),
                                  title: Text(
                                    app.serviceName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${app.citizenName} • ${app.applicationNumber}'),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(app.status).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              app.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(app.status),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Applied: ${_formatDate(app.appliedDate)}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ApplicationReviewScreen(applicationId: app.id),
                                      ),
                                    ).then((_) => _loadApplications());
                                  },
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
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
