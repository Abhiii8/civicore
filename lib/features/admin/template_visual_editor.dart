/// CiviCore - Template Visual Editor (Fixed)
/// 
/// Visual editor for configuring certificate template fields
/// Full screen image with transparent overlay panel

import 'dart:io';
import 'package:flutter/material.dart';
import 'template_coordinate_helper.dart';

class TemplateVisualEditor extends StatefulWidget {
  final File templateFile;
  final String templateName;

  const TemplateVisualEditor({
    super.key,
    required this.templateFile,
    required this.templateName,
  });

  @override
  State<TemplateVisualEditor> createState() => _TemplateVisualEditorState();
}

class _TemplateVisualEditorState extends State<TemplateVisualEditor> {
  Map<String, FieldConfig> _fields = {};
  String? _selectedField;
  bool _panelVisible = true;
  Size _imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final size = await TemplateCoordinateHelper.getImageSize(widget.templateFile);
    if (mounted) {
      setState(() {
        _imageSize = size;
      });
    }
  }

  void _initializeFields() {
    _fields = {
      'applicant_name': FieldConfig(
        label: 'Applicant Name',
        x: 200.0,
        y: 300.0,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      'application_number': FieldConfig(
        label: 'Application Number',
        x: 200.0,
        y: 350.0,
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      'service_name': FieldConfig(
        label: 'Service Name',
        x: 200.0,
        y: 280.0,
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      'date_of_issue': FieldConfig(
        label: 'Date of Issue',
        x: 200.0,
        y: 400.0,
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      'expiry_date': FieldConfig(
        label: 'Expiry Date (Optional)',
        x: 200.0,
        y: 450.0,
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: Colors.black,
        isVisible: false,
      ),
      'department': FieldConfig(
        label: 'Department',
        x: 200.0,
        y: 500.0,
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
    };
  }

  void _adjustPosition(String fieldName, double dx, double dy) {
    setState(() {
      _fields[fieldName] = _fields[fieldName]!.copyWith(
        x: _fields[fieldName]!.x + dx,
        y: _fields[fieldName]!.y + dy,
      );
    });
  }

  Map<String, Map<String, dynamic>> _getFieldConfig() {
    final config = <String, Map<String, dynamic>>{};
    _fields.forEach((key, field) {
      if (field.isVisible) {
        config[key] = {
          'position': {'x': field.x, 'y': field.y},
          'fontSize': field.fontSize,
          'fontWeight': field.fontWeight == FontWeight.bold ? 'bold' : 'normal',
          'color': [field.color.red, field.color.green, field.color.blue],
        };
      }
    });
    return config;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure: ${widget.templateName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context, _getFieldConfig());
            },
            tooltip: 'Save Configuration',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full Screen Template Image
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[200],
            child: InteractiveViewer(
              minScale: 0.1,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(100),
              child: GestureDetector(
                onTapDown: (details) {
                  if (_selectedField == null || _imageSize.width == 0) return;
                  
                  // Get the container size
                  final containerBox = context.findRenderObject() as RenderBox?;
                  if (containerBox == null) return;
                  
                  final containerSize = containerBox.size;
                  final tapPosition = containerBox.globalToLocal(details.globalPosition);
                  
                  // Convert screen coordinates to image coordinates
                  final imagePosition = TemplateCoordinateHelper.convertToImageCoordinates(
                    tapPosition,
                    containerSize,
                    _imageSize,
                  );
                  
                  // Only update if within image bounds
                  if (imagePosition.dx >= 0 && imagePosition.dx <= _imageSize.width &&
                      imagePosition.dy >= 0 && imagePosition.dy <= _imageSize.height) {
                    setState(() {
                      _fields[_selectedField!] = _fields[_selectedField!]!.copyWith(
                        x: imagePosition.dx,
                        y: imagePosition.dy,
                      );
                    });
                  }
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Template Image - Full Screen with proper sizing
                        Positioned.fill(
                          child: Center(
                            child: Image.file(
                              widget.templateFile,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading image',
                                        style: TextStyle(color: Colors.red[700], fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.templateFile.path,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    // Field Position Indicators
                    Builder(
                      builder: (context) {
                        final containerBox = context.findRenderObject() as RenderBox?;
                        if (containerBox == null || _imageSize.width == 0) {
                          return const SizedBox.shrink();
                        }
                        
                        return Stack(
                          children: _fields.entries.map((entry) {
                            final field = entry.value;
                            if (!field.isVisible) return const SizedBox.shrink();
                            
                            // Convert image coordinates to screen coordinates for display
                            final screenPos = TemplateCoordinateHelper.convertToScreenCoordinates(
                              Offset(field.x, field.y),
                              containerBox.size,
                              _imageSize,
                            );
                            
                            return Positioned(
                              left: screenPos.dx - 60,
                              top: screenPos.dy - 20,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedField = entry.key;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _selectedField == entry.key 
                                        ? Colors.blue.withOpacity(0.9)
                                        : Colors.red.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _selectedField == entry.key 
                                          ? Colors.blue
                                          : Colors.red,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _selectedField == entry.key 
                                            ? Icons.edit_location
                                            : Icons.location_on,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        field.label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                      );
                    },
                  ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Toggle Button for Panel
          Positioned(
            right: _panelVisible ? 320 : 0,
            top: 80,
            child: Material(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_panelVisible ? 0 : 8),
                bottomLeft: Radius.circular(_panelVisible ? 0 : 8),
              ),
              child: IconButton(
                icon: Icon(_panelVisible ? Icons.chevron_right : Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _panelVisible = !_panelVisible;
                  });
                },
                tooltip: _panelVisible ? 'Hide Panel' : 'Show Panel',
              ),
            ),
          ),

          // Transparent Overlay Configuration Panel (Right Side)
          if (_panelVisible)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 320,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Draggable Handle
                  Container(
                    height: 4,
                    width: 60,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: (Colors.blue[50] ?? Colors.blue).withOpacity(0.9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'How to Configure',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Select a field from the list\n'
                          '2. Click on the template image to set position\n'
                          '3. Use arrow buttons to fine-tune\n'
                          '4. Adjust font size and style\n'
                          '5. Click Save when done',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Field List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: _fields.entries.map((entry) {
                        final field = entry.value;
                        final isSelected = _selectedField == entry.key;
                        
                        return Card(
                          color: isSelected ? Colors.blue[50] : null,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: Checkbox(
                              value: field.isVisible,
                              onChanged: (value) {
                                setState(() {
                                  _fields[entry.key] = field.copyWith(
                                    isVisible: value ?? true,
                                  );
                                  if (value == true) {
                                    _selectedField = entry.key;
                                  }
                                });
                              },
                            ),
                            title: Text(
                              field.label,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blue : null,
                              ),
                            ),
                            subtitle: field.isVisible
                                ? Text('X: ${field.x.toStringAsFixed(0)}, Y: ${field.y.toStringAsFixed(0)}')
                                : const Text('Disabled'),
                            onExpansionChanged: (expanded) {
                              if (expanded) {
                                setState(() {
                                  _selectedField = entry.key;
                                });
                              }
                            },
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Position Controls
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _ArrowButton(
                                          icon: Icons.arrow_upward,
                                          onPressed: () => _adjustPosition(entry.key, 0, -5),
                                        ),
                                        _ArrowButton(
                                          icon: Icons.arrow_downward,
                                          onPressed: () => _adjustPosition(entry.key, 0, 5),
                                        ),
                                        _ArrowButton(
                                          icon: Icons.arrow_back,
                                          onPressed: () => _adjustPosition(entry.key, -5, 0),
                                        ),
                                        _ArrowButton(
                                          icon: Icons.arrow_forward,
                                          onPressed: () => _adjustPosition(entry.key, 5, 0),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Font Size
                                    Row(
                                      children: [
                                        const Text('Font Size: '),
                                        Expanded(
                                          child: Slider(
                                            value: field.fontSize,
                                            min: 8,
                                            max: 30,
                                            divisions: 22,
                                            label: field.fontSize.toStringAsFixed(0),
                                            onChanged: (value) {
                                              setState(() {
                                                _fields[entry.key] = field.copyWith(fontSize: value);
                                              });
                                            },
                                          ),
                                        ),
                                        Text('${field.fontSize.toStringAsFixed(0)}'),
                                      ],
                                    ),
                                    
                                    // Font Weight
                                    Row(
                                      children: [
                                        const Text('Bold: '),
                                        Switch(
                                          value: field.fontWeight == FontWeight.bold,
                                          onChanged: (value) {
                                            setState(() {
                                              _fields[entry.key] = field.copyWith(
                                                fontWeight: value ? FontWeight.bold : FontWeight.normal,
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    
                                    // Color Picker
                                    Row(
                                      children: [
                                        const Text('Color: '),
                                        Expanded(
                                          child: Wrap(
                                            spacing: 8,
                                            children: [
                                              _ColorChip(
                                                color: Colors.black,
                                                isSelected: field.color == Colors.black,
                                                onTap: () {
                                                  setState(() {
                                                    _fields[entry.key] = field.copyWith(color: Colors.black);
                                                  });
                                                },
                                              ),
                                              _ColorChip(
                                                color: Colors.blue[900]!,
                                                isSelected: field.color == Colors.blue[900],
                                                onTap: () {
                                                  setState(() {
                                                    _fields[entry.key] = field.copyWith(color: Colors.blue[900]!);
                                                  });
                                                },
                                              ),
                                              _ColorChip(
                                                color: Colors.red[900]!,
                                                isSelected: field.color == Colors.red[900],
                                                onTap: () {
                                                  setState(() {
                                                    _fields[entry.key] = field.copyWith(color: Colors.red[900]!);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Manual Position Input
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              labelText: 'X Position',
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            controller: TextEditingController(text: field.x.toStringAsFixed(0)),
                                            onChanged: (value) {
                                              final x = double.tryParse(value) ?? field.x;
                                              setState(() {
                                                _fields[entry.key] = field.copyWith(x: x);
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              labelText: 'Y Position',
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            controller: TextEditingController(text: field.y.toStringAsFixed(0)),
                                            onChanged: (value) {
                                              final y = double.tryParse(value) ?? field.y;
                                              setState(() {
                                                _fields[entry.key] = field.copyWith(y: y);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// FieldConfig and helper widgets remain the same
class FieldConfig {
  final String label;
  final double x;
  final double y;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final bool isVisible;

  FieldConfig({
    required this.label,
    required this.x,
    required this.y,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    this.isVisible = true,
  });

  FieldConfig copyWith({
    String? label,
    double? x,
    double? y,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    bool? isVisible,
  }) {
    return FieldConfig(
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      color: color ?? this.color,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ArrowButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.blue[100],
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorChip({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}
