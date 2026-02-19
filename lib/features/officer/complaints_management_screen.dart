/// CiviCore - Complaints Management Screen
/// 
/// Officer/Admin interface for managing all complaints
/// Supports filtering, status updates, and responses

import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../complaints/complaint_detail_screen.dart';

class ComplaintsManagementScreen extends StatefulWidget {
  const ComplaintsManagementScreen({super.key});

  @override
  State<ComplaintsManagementScreen> createState() => _ComplaintsManagementScreenState();
}

class _ComplaintsManagementScreenState extends State<ComplaintsManagementScreen> {
  final _apiClient = ApiClient();
  List<dynamic> _complaints = [];
  bool _isLoading = true;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    try {
      String url = ApiConstants.complaints;
      if (_selectedStatus != null) {
        url += '?status=$_selectedStatus';
      }
      final response = await _apiClient.get(url);
      if (response.data['success'] == true) {
        setState(() {
          _complaints = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading complaints: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints Management'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Statuses')),
                      ...['open', 'in_progress', 'resolved', 'closed'].map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedStatus = value);
                      _loadComplaints();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadComplaints,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // Statistics
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total',
                    value: _complaints.length.toString(),
                    color: Colors.blue,
                    icon: Icons.report_problem,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Open',
                    value: _complaints.where((c) => c['status'] == 'open').length.toString(),
                    color: Colors.orange,
                    icon: Icons.access_time,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Resolved',
                    value: _complaints.where((c) => c['status'] == 'resolved').length.toString(),
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),

          // Complaints List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _complaints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No complaints found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadComplaints,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _complaints.length,
                          itemBuilder: (context, index) {
                            final complaint = _complaints[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(complaint['status'] ?? 'open')
                                      .withOpacity(0.2),
                                  child: Icon(
                                    Icons.report_problem,
                                    color: _getStatusColor(complaint['status'] ?? 'open'),
                                  ),
                                ),
                                title: Text(
                                  complaint['subject'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      complaint['description'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(complaint['status'] ?? 'open')
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            complaint['status']?.toString().toUpperCase() ?? 'OPEN',
                                            style: TextStyle(
                                              color: _getStatusColor(complaint['status'] ?? 'open'),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatDate(complaint['created_at']),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (complaint['citizen_name'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'By: ${complaint['citizen_name']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ComplaintDetailScreen(
                                        complaintId: complaint['id'],
                                        isOfficerView: true,
                                      ),
                                    ),
                                  ).then((_) => _loadComplaints());
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

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr.toString();
    }
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
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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
