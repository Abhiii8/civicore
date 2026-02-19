/// CiviCore - Departments Management Screen
/// 
/// Admin interface for managing departments

import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  final _apiClient = ApiClient();
  List<dynamic> _departments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.adminDepartments);
      if (response.data['success'] == true) {
        setState(() {
          _departments = response.data['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Failed to load departments'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
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

  Future<void> _createDepartment() async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Department'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Department Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        await _apiClient.post(
          ApiConstants.adminDepartments,
          data: {
            'name': nameController.text,
            'code': codeController.text.isEmpty ? null : codeController.text,
            'description': descController.text.isEmpty ? null : descController.text,
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Department created successfully')),
          );
          _loadDepartments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create department: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDepartments,
              child: _departments.isEmpty
                  ? const Center(child: Text('No departments found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _departments.length,
                      itemBuilder: (context, index) {
                        final dept = _departments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              dept['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dept['code'] != null)
                                  Text('Code: ${dept['code']}'),
                                if (dept['description'] != null)
                                  Text(dept['description']),
                                const SizedBox(height: 4),
                                Text(
                                  'Officers: ${dept['officer_count'] ?? 0} | Services: ${dept['service_count'] ?? 0}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: dept['is_active'] == true
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.cancel, color: Colors.red),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createDepartment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
