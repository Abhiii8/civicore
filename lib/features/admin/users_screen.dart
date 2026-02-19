/// CiviCore - Users Management Screen
/// 
/// Admin interface for managing users

import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _apiClient = ApiClient();
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(
        ApiConstants.adminUsers,
        queryParameters: _selectedRole != null ? {'role': _selectedRole} : null,
      );
      if (response.data['success'] == true) {
        setState(() {
          _users = response.data['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Failed to load users'),
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

  Future<void> _showCreateUserDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    String? selectedRole = 'officer'; // Default to officer
    int? selectedDepartmentId;
    List<dynamic> departments = [];

    // Load departments
    try {
      final deptResponse = await _apiClient.get(ApiConstants.adminDepartments);
      if (deptResponse.data['success'] == true) {
        departments = deptResponse.data['data'] ?? [];
      }
    } catch (e) {
      // Handle error
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create User Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Role Selection (default to officer)
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'officer', child: Text('Officer')),
                    DropdownMenuItem(value: 'citizen', child: Text('Citizen')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value;
                      if (value == 'citizen') {
                        selectedDepartmentId = null; // Citizens don't have departments
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Department Selection (only for officers)
                if ((selectedRole == 'officer' || selectedRole == 'admin') && departments.isNotEmpty) ...[
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
                  const SizedBox(height: 16),
                ],
                
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
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
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty &&
                    (selectedRole == 'citizen' || selectedDepartmentId != null)) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true &&
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      try {
        // Get role_id based on role name
        // Role IDs: 1=citizen, 2=officer, 3=admin
        int roleId;
        if (selectedRole == 'officer') {
          roleId = 2; // Officer role_id
        } else if (selectedRole == 'admin') {
          roleId = 3; // Admin role_id
        } else {
          roleId = 1; // Citizen role_id
        }

        final createResult = await _apiClient.post(
          ApiConstants.adminUsers,
          data: {
            'full_name': nameController.text,
            'email': emailController.text,
            'password': passwordController.text,
            'role_id': roleId,
            if ((selectedRole == 'officer' || selectedRole == 'admin') && selectedDepartmentId != null)
              'department_id': selectedDepartmentId,
            if (phoneController.text.isNotEmpty) 'phone': phoneController.text,
          },
        );

        if (!mounted) return;

        if (createResult.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(createResult.data['message'] ?? 'Failed to create user'),
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
        title: const Text('Users'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        child: const Icon(Icons.person_add),
        tooltip: 'Create User',
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
                    selected: _selectedRole == null,
                    onSelected: () {
                      setState(() {
                        _selectedRole = null;
                        _loadUsers();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Citizens',
                    selected: _selectedRole == 'citizen',
                    onSelected: () {
                      setState(() {
                        _selectedRole = 'citizen';
                        _loadUsers();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Officers',
                    selected: _selectedRole == 'officer',
                    onSelected: () {
                      setState(() {
                        _selectedRole = 'officer';
                        _loadUsers();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Admins',
                    selected: _selectedRole == 'admin',
                    onSelected: () {
                      setState(() {
                        _selectedRole = 'admin';
                        _loadUsers();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          
          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: _users.isEmpty
                        ? const Center(child: Text('No users found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      user['full_name']?[0] ?? 'U',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(
                                    user['full_name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['email'] ?? ''),
                                      if (user['role_name'] != null)
                                        Text(
                                          'Role: ${user['role_name']}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      if (user['department_name'] != null)
                                        Text(
                                          'Department: ${user['department_name']}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                    ],
                                  ),
                                  trailing: user['is_active'] == true
                                      ? const Icon(Icons.check_circle, color: Colors.green)
                                      : const Icon(Icons.cancel, color: Colors.red),
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
