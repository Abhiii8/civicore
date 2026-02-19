/// CiviCore - Certificate Templates Management
/// 
/// Admin interface for managing certificate templates
/// Upload and configure templates for different services

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../services/service_service.dart';
import '../../models/service_model.dart';
import 'template_visual_editor.dart';

class CertificateTemplatesScreen extends StatefulWidget {
  const CertificateTemplatesScreen({super.key});

  @override
  State<CertificateTemplatesScreen> createState() => _CertificateTemplatesScreenState();
}

class _CertificateTemplatesScreenState extends State<CertificateTemplatesScreen> {
  final _apiClient = ApiClient();
  final _serviceService = ServiceService();
  List<dynamic> _templates = [];
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.certificateTemplates);
      if (response.data['success'] == true) {
        setState(() {
          _templates = response.data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading templates: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadTemplateFile(
    File file, 
    String name, 
    int? serviceId,
    Map<String, Map<String, dynamic>>? fieldConfig,
  ) async {
    try {
      setState(() => _isLoading = true);
      
      final formData = FormData.fromMap({
        'name': name,
        if (serviceId != null) 'service_id': serviceId,
      });
      
      // Add field config as JSON string if provided
      if (fieldConfig != null) {
        final fieldConfigJson = jsonEncode(fieldConfig);
        formData.fields.add(MapEntry('field_config', fieldConfigJson));
      }

      formData.files.add(MapEntry(
        'template',
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      ));

      final response = await _apiClient.postFormData(
        ApiConstants.certificateTemplates,
        formData,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadTemplates();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Failed to upload template'),
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

  Future<void> _uploadTemplate() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'svg'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Show dialog to configure template name, then open visual editor
        await _showTemplateConfigDialog(file, fileName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showTemplateConfigDialog(File file, String fileName) async {
    final nameController = TextEditingController(text: fileName);
    int? selectedServiceId;
    
    // Load services for dropdown
    try {
      final services = await _serviceService.getAllServices();
      setState(() {
        _services = services;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading services: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Configure Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name *',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Birth Certificate Template',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedServiceId,
                  decoration: const InputDecoration(
                    labelText: 'Select Service/Certificate Type *',
                    border: OutlineInputBorder(),
                    hintText: 'Choose which certificate this template is for',
                    prefixIcon: Icon(Icons.description),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Services (Default Template)'),
                    ),
                    ..._services.map((service) {
                      return DropdownMenuItem<int>(
                        value: service.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (service.description != null && service.description!.isNotEmpty)
                              Text(
                                service.description!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedServiceId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedServiceId == null
                              ? 'This template will be used as default for all services'
                              : 'This template will be used for: ${_services.firstWhere((s) => s.id == selectedServiceId).name}',
                          style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note: After uploading, you can configure field positions.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter template name'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                Navigator.pop(context);
                
                // Open visual editor to configure fields
                final fieldConfig = await Navigator.push<Map<String, Map<String, dynamic>>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TemplateVisualEditor(
                      templateFile: file,
                      templateName: nameController.text,
                    ),
                  ),
                );
                
                // Upload template with field configuration
                if (mounted && fieldConfig != null) {
                  await _uploadTemplateFile(
                    file, 
                    nameController.text, 
                    selectedServiceId,
                    fieldConfig,
                  );
                }
              },
              child: const Text('Next: Configure Fields'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Templates'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadTemplate,
        child: const Icon(Icons.upload_file),
        tooltip: 'Upload Template',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No templates uploaded yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload a template image (PNG, JPG, SVG)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _templates.length,
                      itemBuilder: (context, index) {
                        final template = _templates[index];
                        final templateName = template['name']?.toString() ?? 'Untitled';
                        final templatePath = template['path']?.toString() ?? template['url']?.toString() ?? '';
                        final serviceId = template['service_id'];
                        String serviceName = 'All Services';
                        if (serviceId != null && _services.isNotEmpty) {
                          try {
                            final id = serviceId is int ? serviceId : int.tryParse(serviceId.toString());
                            if (id != null) {
                              final service = _services.firstWhere(
                                (s) => s.id == id,
                                orElse: () => _services.first,
                              );
                              serviceName = service.name;
                            }
                          } catch (e) {
                            serviceName = 'Unknown Service';
                          }
                        }
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: serviceId != null ? Colors.blue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.image,
                                size: 32,
                                color: serviceId != null ? Colors.blue[700] : Colors.grey[600],
                              ),
                            ),
                            title: Text(
                              templateName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.description, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'For: $serviceName',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: serviceId != null ? Colors.blue[700] : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Path: $templatePath',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                // TODO: Open field configuration screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Field configuration coming soon!'),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              // Show template info
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(templateName),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Service: $serviceName'),
                                      const SizedBox(height: 8),
                                      Text('Template Path: $templatePath'),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'To use this template, configure field positions in the code or use the helper functions.',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                ),
    );
  }
}
