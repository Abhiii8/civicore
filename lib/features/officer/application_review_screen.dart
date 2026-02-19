/// CiviCore - Application Review Screen
/// 
/// Allows officers to review, approve, or reject applications

import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../models/application_model.dart';
import '../../core/constants/app_constants.dart';

class ApplicationReviewScreen extends StatefulWidget {
  final int applicationId;

  const ApplicationReviewScreen({super.key, required this.applicationId});

  @override
  State<ApplicationReviewScreen> createState() => _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  final _applicationService = ApplicationService();
  final _remarksController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  
  ApplicationModel? _application;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadApplication() async {
    setState(() => _isLoading = true);
    final application = await _applicationService.getApplication(widget.applicationId);
    setState(() {
      _application = application;
      _isLoading = false;
    });
  }

  Future<void> _approveApplication() async {
    if (_application == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: const Text('Are you sure you want to approve this application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    final result = await _applicationService.approveApplication(
      widget.applicationId,
      remarks: _remarksController.text.trim().isEmpty 
          ? null 
          : _remarksController.text.trim(),
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to approve application'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectApplication() async {
    if (_application == null) return;

    if (_rejectionReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rejection reason'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: const Text('Are you sure you want to reject this application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    final result = await _applicationService.rejectApplication(
      widget.applicationId,
      _rejectionReasonController.text.trim(),
      remarks: _remarksController.text.trim().isEmpty 
          ? null 
          : _remarksController.text.trim(),
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to reject application'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Application'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _application == null
              ? const Center(child: Text('Application not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Application Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _application!.serviceName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Application #${_application!.applicationNumber}'),
                              const SizedBox(height: 8),
                              Text('Citizen: ${_application!.citizenName}'),
                              const SizedBox(height: 8),
                              Text('Department: ${_application!.departmentName}'),
                              const SizedBox(height: 8),
                              Text('Status: ${_application!.statusDisplay}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Documents
                      if (_application!.documents != null && _application!.documents!.isNotEmpty) ...[
                        Text(
                          'Documents',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: _application!.documents!.map((doc) {
                                return ListTile(
                                  leading: const Icon(Icons.description),
                                  title: Text(doc['document_name'] ?? 'Document'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    // Handle document view
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Remarks
                      Text(
                        'Remarks',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _remarksController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Enter remarks (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Rejection Reason (if rejecting)
                      if (_application!.status != AppConstants.statusRejected) ...[
                        Text(
                          'Rejection Reason (if rejecting)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _rejectionReasonController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Enter rejection reason (required for rejection)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Action Buttons
                      if (_application!.status != AppConstants.statusApproved &&
                          _application!.status != AppConstants.statusRejected) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isProcessing ? null : _approveApplication,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isProcessing
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Approve'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isProcessing ? null : _rejectApplication,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
