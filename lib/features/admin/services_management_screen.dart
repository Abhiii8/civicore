/// CiviCore - Services Management Screen
/// 
/// Admin interface for managing services

import 'package:flutter/material.dart';
import '../../services/service_service.dart';
import '../../models/service_model.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';

class ServicesManagementScreen extends StatefulWidget {
  const ServicesManagementScreen({super.key});

  @override
  State<ServicesManagementScreen> createState() => _ServicesManagementScreenState();
}

class _ServicesManagementScreenState extends State<ServicesManagementScreen> {
  final _serviceService = ServiceService();
  final _apiClient = ApiClient();
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await _serviceService.getAllServices();
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading services: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddServiceDialog() async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descController = TextEditingController();
    final docsController = TextEditingController();
    final daysController = TextEditingController(text: '7');
    final feeController = TextEditingController(text: '0');
    int? selectedDepartmentId;

    // Load departments
    List<dynamic> departments = [];
    try {
      final response = await _apiClient.get(ApiConstants.adminDepartments);
      if (response.data['success'] == true) {
        departments = response.data['data'] ?? [];
      }
    } catch (e) {
      // Handle error
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (departments.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    value: selectedDepartmentId,
                    decoration: const InputDecoration(
                      labelText: 'Department *',
                      border: OutlineInputBorder(),
                    ),
                    items: departments.map((dept) {
                      return DropdownMenuItem<int>(
                        value: dept['id'] is int ? dept['id'] : int.tryParse(dept['id'].toString()),
                        child: Text(dept['name']?.toString() ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedDepartmentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Service Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: docsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Required Documents',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: daysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Processing Days',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: feeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fee',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedDepartmentId != null) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty && selectedDepartmentId != null) {
      try {
        final createResult = await _serviceService.createService(
          name: nameController.text,
          departmentId: selectedDepartmentId!,
          code: codeController.text.isEmpty ? null : codeController.text,
          description: descController.text.isEmpty ? null : descController.text,
          requiredDocuments: docsController.text.isEmpty ? null : docsController.text,
          processingDays: int.tryParse(daysController.text) ?? 7,
          fee: double.tryParse(feeController.text) ?? 0.0,
        );

        if (!mounted) return;

        if (createResult['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadServices();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(createResult['message'] ?? 'Failed to create service'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Management'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add New Service',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: _services.isEmpty
                  ? const Center(child: Text('No services found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              service.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (service.description != null)
                                  Text(service.description!),
                                const SizedBox(height: 4),
                                Text(
                                  'Department: ${service.departmentName} | Processing: ${service.processingDays} days',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Show service details/edit
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
