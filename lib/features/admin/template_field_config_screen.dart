/// CiviCore - Template Field Configuration Screen
/// 
/// Visual editor for configuring text field positions on certificate templates

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class TemplateFieldConfigScreen extends StatefulWidget {
  final File templateFile;
  final Map<String, Map<String, dynamic>> currentFields;

  const TemplateFieldConfigScreen({
    super.key,
    required this.templateFile,
    required this.currentFields,
  });

  @override
  State<TemplateFieldConfigScreen> createState() => _TemplateFieldConfigScreenState();
}

class _TemplateFieldConfigScreenState extends State<TemplateFieldConfigScreen> {
  Map<String, Map<String, dynamic>> _fields = {};
  String? _selectedField;

  @override
  void initState() {
    super.initState();
    _fields = Map.from(widget.currentFields);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Template Fields'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfiguration,
            tooltip: 'Save Configuration',
          ),
        ],
      ),
      body: Row(
        children: [
          // Template Preview
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: kIsWeb
                    ? Image.network(
                        widget.templateFile.path,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        widget.templateFile,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
          
          // Field Configuration Panel
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Text Fields',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: _fields.keys.map((fieldName) {
                      return _FieldConfigCard(
                        fieldName: fieldName,
                        fieldConfig: _fields[fieldName]!,
                        isSelected: _selectedField == fieldName,
                        onTap: () {
                          setState(() {
                            _selectedField = fieldName;
                          });
                        },
                        onUpdate: (config) {
                          setState(() {
                            _fields[fieldName] = config;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveConfiguration() {
    Navigator.pop(context, _fields);
  }
}

class _FieldConfigCard extends StatelessWidget {
  final String fieldName;
  final Map<String, dynamic> fieldConfig;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(Map<String, dynamic>) onUpdate;

  const _FieldConfigCard({
    required this.fieldName,
    required this.fieldConfig,
    required this.isSelected,
    required this.onTap,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final position = fieldConfig['position'] as Map<String, double>? ?? {};
    final x = position['x'] ?? 0.0;
    final y = position['y'] ?? 0.0;
    final fontSize = fieldConfig['fontSize'] as double? ?? 12.0;

    return Card(
      color: isSelected ? Colors.blue[50] : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatFieldName(fieldName),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : null,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'X',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: x.toString()),
                      onChanged: (value) {
                        final newX = double.tryParse(value) ?? x;
                        onUpdate({
                          ...fieldConfig,
                          'position': {
                            'x': newX,
                            'y': y,
                          },
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Y',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: y.toString()),
                      onChanged: (value) {
                        final newY = double.tryParse(value) ?? y;
                        onUpdate({
                          ...fieldConfig,
                          'position': {
                            'x': x,
                            'y': newY,
                          },
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Font Size',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: fontSize.toString()),
                onChanged: (value) {
                  final newSize = double.tryParse(value) ?? fontSize;
                  onUpdate({
                    ...fieldConfig,
                    'fontSize': newSize,
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFieldName(String name) {
    return name.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
