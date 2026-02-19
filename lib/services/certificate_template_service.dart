/// CiviCore - Certificate Template Service
/// 
/// Handles certificate template management and generation
/// Supports custom image/SVG templates with text overlay

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../models/application_model.dart';

class CertificateTemplateService {
  // Generate certificate using custom template
  Future<File?> generateCertificateWithTemplate({
    required ApplicationModel application,
    required String templateUrl, // URL to template image
    Map<String, Map<String, dynamic>>? textFields, // Field positions and styles
  }) async {
    try {
      // Download template image
      final templateBytes = await _downloadTemplate(templateUrl);
      if (templateBytes == null) {
        throw Exception('Failed to download template');
      }

      // Load image
      final templateImage = img.decodeImage(templateBytes);
      if (templateImage == null) {
        throw Exception('Failed to decode template image');
      }

      // Create PDF with template as background
      final pdf = pw.Document();
      
      // Get image dimensions in points (PDF uses points, 1 point = 1/72 inch)
      // Convert pixels to points (assuming 72 DPI, adjust if needed)
      final imageWidthPoints = templateImage.width.toDouble();
      final imageHeightPoints = templateImage.height.toDouble();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            imageWidthPoints,
            imageHeightPoints,
          ),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Template as background - fill entire page, no scaling
                pw.Positioned.fill(
                  child: pw.Image(
                    pw.MemoryImage(templateBytes),
                    fit: pw.BoxFit.fill, // Fill entire page, no scaling
                  ),
                ),
                
                // Overlay text fields with proper coordinate conversion
                ..._buildTextOverlays(application, textFields, imageWidthPoints, imageHeightPoints),
              ],
            );
          },
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/certificate_${application.applicationNumber}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      print('Certificate generation error: $e');
      return null;
    }
  }

  // Generate certificate with template from local file
  Future<File?> generateCertificateWithLocalTemplate({
    required ApplicationModel application,
    required File templateFile,
    Map<String, Map<String, dynamic>>? textFields,
  }) async {
    try {
      final templateBytes = await templateFile.readAsBytes();
      
      final pdf = pw.Document();
      final templateImage = img.decodeImage(templateBytes);
      
      if (templateImage == null) {
        throw Exception('Failed to decode template image');
      }

      // Get image dimensions in points
      final imageWidthPoints = templateImage.width.toDouble();
      final imageHeightPoints = templateImage.height.toDouble();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            imageWidthPoints,
            imageHeightPoints,
          ),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Template as background - fill entire page
                pw.Positioned.fill(
                  child: pw.Image(
                    pw.MemoryImage(templateBytes),
                    fit: pw.BoxFit.fill, // Fill entire page, no scaling
                  ),
                ),
                ..._buildTextOverlays(application, textFields, imageWidthPoints, imageHeightPoints),
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/certificate_${application.applicationNumber}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      print('Certificate generation error: $e');
      return null;
    }
  }

  // Build text overlays for certificate
  // Coordinates are in screen pixels from visual editor, need to convert to PDF points
  List<pw.Widget> _buildTextOverlays(
    ApplicationModel application,
    Map<String, Map<String, dynamic>>? textFields,
    double imageWidthPoints,
    double imageHeightPoints,
  ) {
    final overlays = <pw.Widget>[];

    // Default field positions (can be customized)
    final defaultFields = textFields ?? _getDefaultFields(application);

    defaultFields.forEach((fieldName, fieldConfig) {
      final position = fieldConfig['position'] as Map<String, double>? ?? {};
      // Coordinates from visual editor are in screen pixels
      // For PDF, we use them directly as points (assuming 1:1 ratio for now)
      // If coordinates are too large, they might be in screen pixels - we'll use them as-is
      var x = position['x'] ?? 0.0;
      var y = position['y'] ?? 0.0;
      
      // If coordinates seem too large (likely screen pixels), scale them down
      // Typical screen: ~400-800px width, PDF A4: ~595 points width
      // But we're using image dimensions, so check if coordinates exceed image size
      if (x > imageWidthPoints * 2 || y > imageHeightPoints * 2) {
        // Likely screen pixels, scale down proportionally
        // Assume screen was ~800px wide, scale to image width
        final scaleX = imageWidthPoints / 800.0;
        final scaleY = imageHeightPoints / 1200.0; // Assume portrait screen
        x = x * scaleX;
        y = y * scaleY;
      }
      
      final fontSize = fieldConfig['fontSize'] as double? ?? 12.0;
      final fontWeight = fieldConfig['fontWeight'] as String? ?? 'normal';
      final color = fieldConfig['color'] as List<int>? ?? [0, 0, 0];
      final text = _getFieldValue(application, fieldName);

      if (text.isEmpty) return; // Skip empty fields

      overlays.add(
        pw.Positioned(
          left: x,
          top: y,
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight == 'bold' 
                  ? pw.FontWeight.bold 
                  : pw.FontWeight.normal,
              color: PdfColor.fromInt(
                (color[0] << 16) | (color[1] << 8) | color[2],
              ),
            ),
          ),
        ),
      );
    });

    return overlays;
  }

  // Get default field positions and styles
  Map<String, Map<String, dynamic>> _getDefaultFields(ApplicationModel application) {
    return {
      'applicant_name': {
        'position': {'x': 150.0, 'y': 200.0},
        'fontSize': 18.0,
        'fontWeight': 'bold',
        'color': [0, 0, 0],
      },
      'application_number': {
        'position': {'x': 150.0, 'y': 250.0},
        'fontSize': 12.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
      'service_name': {
        'position': {'x': 150.0, 'y': 280.0},
        'fontSize': 14.0,
        'fontWeight': 'bold',
        'color': [0, 0, 0],
      },
      'date_of_issue': {
        'position': {'x': 150.0, 'y': 320.0},
        'fontSize': 12.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
      'department': {
        'position': {'x': 150.0, 'y': 350.0},
        'fontSize': 12.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
    };
  }

  // Get field value from application
  String _getFieldValue(ApplicationModel application, String fieldName) {
    switch (fieldName) {
      case 'applicant_name':
        return application.citizenName;
      case 'application_number':
        return application.applicationNumber;
      case 'service_name':
        return application.serviceName;
      case 'date_of_issue':
        return _formatDate(application.approvedDate ?? DateTime.now());
      case 'department':
        return application.departmentName;
      default:
        return '';
    }
  }

  // Download template from URL
  Future<Uint8List?> _downloadTemplate(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('Template download error: $e');
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // View/Print certificate
  Future<void> viewCertificate(File certificateFile) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return await certificateFile.readAsBytes();
        },
      );
    } catch (e) {
      print('Print error: $e');
    }
  }
}
