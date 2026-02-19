/// CiviCore - Application Detail Screen
/// 
/// Shows detailed information about an application
/// Includes status timeline, documents, and actions

import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../services/certificate_service.dart';
import '../../models/application_model.dart';
import '../../core/constants/app_constants.dart';
import 'document_upload_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final int applicationId;

  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final _applicationService = ApplicationService();
  final _certificateService = CertificateService();
  ApplicationModel? _application;
  bool _isLoading = true;
  bool _isGeneratingCertificate = false;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    setState(() => _isLoading = true);
    final application = await _applicationService.getApplication(widget.applicationId);
    setState(() {
      _application = application;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusApproved:
        return Colors.green;
      case AppConstants.statusRejected:
        return Colors.red;
      case AppConstants.statusUnderReview:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _application == null
              ? const Center(child: Text('Application not found'))
              : RefreshIndicator(
                  onRefresh: _loadApplication,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Application Info Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _application!.serviceName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(_application!.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _application!.statusDisplay,
                                        style: TextStyle(
                                          color: _getStatusColor(_application!.status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _InfoRow(
                                  icon: Icons.confirmation_number,
                                  label: 'Application Number',
                                  value: _application!.applicationNumber,
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.business,
                                  label: 'Department',
                                  value: _application!.departmentName,
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.calendar_today,
                                  label: 'Applied Date',
                                  value: _formatDate(_application!.appliedDate),
                                ),
                                if (_application!.reviewedDate != null) ...[
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.visibility,
                                    label: 'Reviewed Date',
                                    value: _formatDate(_application!.reviewedDate!),
                                  ),
                                ],
                                if (_application!.approvedDate != null) ...[
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.check_circle,
                                    label: 'Approved Date',
                                    value: _formatDate(_application!.approvedDate!),
                                  ),
                                ],
                                if (_application!.remarks != null) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Remarks',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_application!.remarks!),
                                ],
                                if (_application!.rejectionReason != null) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rejection Reason',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: Colors.red,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _application!.rejectionReason!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Status Timeline
                        if (_application!.logs != null && _application!.logs!.isNotEmpty) ...[
                          Text(
                            'Status Timeline',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  ..._application!.logs!.asMap().entries.map((entry) {
                                    final isLast = entry.key == _application!.logs!.length - 1;
                                    return _TimelineItem(
                                      log: entry.value,
                                      isLast: isLast,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Documents Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Documents',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (_application!.status == 'pending' || _application!.status == 'under_review')
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DocumentUploadScreen(applicationId: _application!.id),
                                    ),
                                  ).then((_) => _loadApplication());
                                },
                                icon: const Icon(Icons.upload),
                                label: const Text('Upload'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_application!.documents != null && _application!.documents!.isNotEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: _application!.documents!.map((doc) {
                                  return ListTile(
                                    leading: const Icon(Icons.description, color: Colors.blue),
                                    title: Text(doc['document_name'] ?? 'Document'),
                                    subtitle: Text('${_formatFileSize(doc['file_size'] ?? 0)}'),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      // Handle document view/download
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        else
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Icon(Icons.description, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No documents uploaded',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  if (_application!.status == 'pending' || _application!.status == 'under_review')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DocumentUploadScreen(applicationId: _application!.id),
                                            ),
                                          ).then((_) => _loadApplication());
                                        },
                                        icon: const Icon(Icons.upload),
                                        label: const Text('Upload Document'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // Certificate Download (if approved)
                        if (_application!.status == AppConstants.statusApproved) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isGeneratingCertificate ? null : () async {
                                setState(() => _isGeneratingCertificate = true);
                                try {
                                  await _certificateService.viewCertificate(_application!);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Certificate opened successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error generating certificate: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isGeneratingCertificate = false);
                                  }
                                }
                              },
                              icon: _isGeneratingCertificate
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.download),
                              label: Text(_isGeneratingCertificate ? 'Generating...' : 'Download Certificate'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> log;
  final bool isLast;

  const _TimelineItem({
    required this.log,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['action'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (log['remarks'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    log['remarks'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatDate(log['created_at'] ?? ''),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
