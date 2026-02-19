/// CiviCore - Enhanced Services Screen
/// 
/// Modern service listing with search and filters
/// Beautiful UI for browsing government services

import 'package:flutter/material.dart';
import '../../services/service_service.dart';
import '../../services/application_service.dart';
import '../../models/service_model.dart';
import '../../core/theme/app_theme.dart';
import 'application_detail_screen.dart';

class ServicesScreenEnhanced extends StatefulWidget {
  const ServicesScreenEnhanced({super.key});

  @override
  State<ServicesScreenEnhanced> createState() => _ServicesScreenEnhancedState();
}

class _ServicesScreenEnhancedState extends State<ServicesScreenEnhanced> {
  final _serviceService = ServiceService();
  final _applicationService = ApplicationService();
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    final services = await _serviceService.getAllServices();
    setState(() {
      _services = services;
      _filteredServices = services;
      _isLoading = false;
    });
  }

  void _filterServices(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredServices = _services;
      } else {
      _filteredServices = _services.where((service) {
        return service.name.toLowerCase().contains(query.toLowerCase()) ||
            (service.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            service.departmentName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      }
    });
  }

  Future<void> _applyForService(ServiceModel service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Apply for Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${service.name}'),
            const SizedBox(height: 8),
            Text('Department: ${service.departmentName}'),
            const SizedBox(height: 8),
            Text('Processing Time: ${service.processingDays} days'),
            const SizedBox(height: 16),
            const Text('Do you want to proceed?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    final result = await _applicationService.createApplication(service.id);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Navigate to application detail screen
      if (result['data'] != null && result['data']['id'] != null) {
        final appId = result['data']['id'] is int 
            ? result['data']['id'] 
            : int.tryParse(result['data']['id'].toString());
        
        if (appId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ApplicationDetailScreen(applicationId: appId),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit application'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Services'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TextField(
              onChanged: _filterServices,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _filterServices(''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
          ),

          // Services List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadServices,
                    child: _filteredServices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No services available'
                                      : 'No services found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = _filteredServices[index];
                              return _ServiceCard(
                                service: service,
                                onApply: () => _applyForService(service),
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

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onApply;

  const _ServiceCard({
    required this.service,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onApply,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.verified,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.departmentName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (service.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  service.description!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.schedule,
                    label: '${service.processingDays} days',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.currency_rupee,
                    label: service.fee == 0 ? 'Free' : '₹${service.fee}',
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.add),
                  label: const Text('Apply Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
