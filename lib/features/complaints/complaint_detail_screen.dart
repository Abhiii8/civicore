/// CiviCore - Complaint Detail Screen
/// 
/// View complaint details with photo and responses
/// Supports officer/admin response functionality

import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final int complaintId;
  final bool isOfficerView;

  const ComplaintDetailScreen({
    super.key,
    required this.complaintId,
    this.isOfficerView = false,
  });

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final _apiClient = ApiClient();
  final _responseController = TextEditingController();
  
  Map<String, dynamic>? _complaint;
  List<dynamic> _responses = [];
  bool _isLoading = true;
  bool _isSubmittingResponse = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadComplaint();
    _loadResponses();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaint() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('${ApiConstants.complaintById}/${widget.complaintId}');
      if (response.data['success'] == true) {
        setState(() {
          _complaint = response.data['data'];
          _selectedStatus = _complaint!['status'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading complaint: $e')),
        );
      }
    }
  }

  Future<void> _loadResponses() async {
    try {
      final response = await _apiClient.get('${ApiConstants.complaintById}/${widget.complaintId}/responses');
      if (response.data['success'] == true) {
        setState(() {
          _responses = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      // Responses might not exist yet
    }
  }

  Future<void> _submitResponse() async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a response')),
      );
      return;
    }

    setState(() => _isSubmittingResponse = true);
    try {
      final response = await _apiClient.post(
        '${ApiConstants.complaintById}/${widget.complaintId}/response',
        data: {
          'response': _responseController.text.trim(),
          if (_selectedStatus != _complaint!['status'])
            'update_status': _selectedStatus,
        },
      );

      if (response.data['success'] == true) {
        _responseController.clear();
        _loadComplaint();
        _loadResponses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Response added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting response: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmittingResponse = false);
    }
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == _complaint!['status']) return;

    try {
      final response = await _apiClient.put(
        '${ApiConstants.updateComplaintStatus}/${widget.complaintId}/status',
        data: {'status': _selectedStatus},
      );

      if (response.data['success'] == true) {
        _loadComplaint();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body: const Center(child: Text('Complaint not found')),
      );
    }

    final photoPath = _complaint!['photo_path']?.toString();
    final hasPhoto = photoPath != null && photoPath.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint #${_complaint!['complaint_number']}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _getStatusColor(_complaint!['status']).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _getStatusColor(_complaint!['status']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _complaint!['status']?.toString().toUpperCase() ?? 'OPEN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(_complaint!['status']),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isOfficerView)
                      DropdownButton<String>(
                        value: _selectedStatus,
                        items: ['open', 'in_progress', 'resolved', 'closed']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                          _updateStatus();
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Complaint Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _complaint!['subject'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _complaint!['description'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    _buildInfoRow('Citizen', _complaint!['citizen_name'] ?? 'Unknown'),
                    _buildInfoRow('Email', _complaint!['citizen_email'] ?? 'N/A'),
                    if (_complaint!['assigned_officer_name'] != null)
                      _buildInfoRow('Assigned Officer', _complaint!['assigned_officer_name']),
                    _buildInfoRow('Submitted', _formatDate(_complaint!['created_at'])),
                    if (_complaint!['resolved_at'] != null)
                      _buildInfoRow('Resolved', _formatDate(_complaint!['resolved_at'])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Photo Section
            if (hasPhoto)
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.photo, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Attached Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        '${ApiConstants.baseUrl}/$photoPath',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 48),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Responses Section
            Text(
              'Responses (${_responses.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (_responses.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.comment_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No responses yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._responses.map((response) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: response['role_name'] == 'admin' || response['role_name'] == 'officer'
                                    ? Colors.blue
                                    : Colors.grey,
                                child: Text(
                                  response['user_name']?[0].toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      response['user_name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      response['role_name']?.toString().toUpperCase() ?? '',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatDate(response['created_at']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(response['response'] ?? ''),
                        ],
                      ),
                    ),
                  )),

            // Response Input (Officer/Admin only)
            if (widget.isOfficerView) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Response',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _responseController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Type your response...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _isSubmittingResponse ? null : _submitResponse,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: _isSubmittingResponse
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Send Response'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
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
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr.toString();
    }
  }
}
