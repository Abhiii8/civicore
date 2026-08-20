/// CiviCore - Application Review Screen
/// 
/// Allows officers to review, approve, or reject applications

import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../models/application_model.dart';
import '../../core/constants/app_constants.dart';
import '../../utils/certificate_type_helper.dart';

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
  String? _selectedCertificateType;
  List<String> _certificateTypes = [];
  final _certificateValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _rejectionReasonController.dispose();
    _certificateValueController.dispose();
    super.dispose();
  }

  Future<void> _loadApplication() async {
    setState(() => _isLoading = true);
    final application = await _applicationService.getApplication(widget.applicationId);
    setState(() {
      _application = application;
      // Load certificate types if service requires it
      if (application != null) {
        _certificateTypes = CertificateTypeHelper.getCertificateTypes(
          application.serviceCode,
          application.serviceName,
        );
        // Pre-select if already approved with a type
        if (application.certificateType != null) {
          _selectedCertificateType = application.certificateType;
        }
        // Pre-fill value if already approved with a value
        if (application.certificateValue != null) {
          _certificateValueController.text = application.certificateValue!;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _approveApplication() async {
    if (_application == null) return;

    // Check if certificate type is required but not selected
    if (CertificateTypeHelper.requiresTypeSelection(
          _application!.serviceCode,
          _application!.serviceName,
        ) &&
        (_selectedCertificateType == null || _selectedCertificateType!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a certificate type before approving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Check if value input is required
    if (CertificateTypeHelper.requiresValueInput(
          _application!.serviceCode,
          _application!.serviceName,
        )) {
      final value = _certificateValueController.text.trim();
      if (value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter ${CertificateTypeHelper.getValueLabel(_application!.serviceCode, _application!.serviceName).toLowerCase()}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Validate value
      final validationError = CertificateTypeHelper.validateValue(
        _application!.serviceCode,
        _application!.serviceName,
        value,
      );
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: Text(
          _selectedCertificateType != null
              ? 'Approve application with type: $_selectedCertificateType?'
              : 'Are you sure you want to approve this application?',
        ),
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
      certificateType: _selectedCertificateType,
      certificateValue: _certificateValueController.text.trim().isEmpty
          ? null
          : _certificateValueController.text.trim(),
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
                                  title: Text(doc['document_name'] ?? 'Document'),
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
                      
                      // Certificate Type Selection (if service requires it)
                      if (_certificateTypes.isNotEmpty && 
                          CertificateTypeHelper.requiresTypeSelection(
                            _application!.serviceCode,
                            _application!.serviceName,
                          )) ...[
                        Text(
                          'Certificate Type',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<String>(
                              value: _selectedCertificateType,
                              hint: const Text('Select certificate type'),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: _certificateTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCertificateType = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Certificate Value Input (if service requires it)
                      if (CertificateTypeHelper.requiresValueInput(
                            _application!.serviceCode,
                            _application!.serviceName,
                          )) ...[
                        Text(
                          CertificateTypeHelper.getValueLabel(
                            _application!.serviceCode,
                            _application!.serviceName,
                          ),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _certificateValueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: CertificateTypeHelper.getValuePlaceholder(
                              _application!.serviceCode,
                              _application!.serviceName,
                            ),
                            border: const OutlineInputBorder(),
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
