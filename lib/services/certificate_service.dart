/// CiviCore - Certificate Service
/// 
/// Handles certificate generation and download
/// Supports both default and custom template-based certificates

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/application_model.dart';
import '../utils/certificate_type_helper.dart';
import 'package:printing/printing.dart';

class CertificateService {
  // Generate PDF certificate for approved application
  // Uses built-in professional certificate template
  Future<File?> generateCertificate(ApplicationModel application) async {
    return await _generateDefaultCertificate(application);
  }

  // Generate professional certificate with built-in template
  Future<File?> _generateDefaultCertificate(ApplicationModel application) async {
    try {
      final pdf = pw.Document();

      // Add certificate page with professional design
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Decorative border
                pw.Positioned.fill(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.blue900,
                        width: 3,
                      ),
                    ),
                  ),
                ),
                
                // Inner decorative border
                pw.Positioned(
                  left: 20,
                  top: 20,
                  right: 20,
                  bottom: 20,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.blue700,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                
                // Main content
                pw.Padding(
                  padding: const pw.EdgeInsets.all(60),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Government Emblem/Logo area (placeholder)
                      pw.Container(
                        height: 80,
                        width: 80,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColors.blue900,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'GOI',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      
                      // Government Title
                      pw.Text(
                        'GOVERNMENT OF INDIA',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      
                      // Certificate Title
                      pw.Text(
                        'CERTIFICATE',
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                          letterSpacing: 3,
                        ),
                      ),
                      pw.SizedBox(height: 40),
                      
                      // Decorative line
                      pw.Container(
                        height: 2,
                        width: 200,
                        color: PdfColors.blue900,
                      ),
                      pw.SizedBox(height: 40),
                      
                      // Certificate Body
                      pw.Text(
                        'This is to certify that',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      
                      // Applicant Name
                      pw.Text(
                        application.citizenName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      
                      // Service Description
                      pw.Text(
                        'has successfully applied for and been granted',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      
                      // Service Name
                      pw.Text(
                        application.serviceName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                          letterSpacing: 1,
                        ),
                      ),
                      // Certificate Type (if specified)
                      if (application.certificateType != null && application.certificateType!.isNotEmpty) ...[
                        pw.SizedBox(height: 15),
                        pw.Text(
                          'Type: ${application.certificateType}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.normal,
                            color: PdfColors.grey700,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                      // Certificate Value (if specified) - e.g., Income amount
                      if (application.certificateValue != null && application.certificateValue!.isNotEmpty) ...[
                        pw.SizedBox(height: 20),
                        // Value in a highlighted box
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            border: pw.Border.all(
                              color: PdfColors.blue700,
                              width: 2,
                            ),
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Column(
                            children: [
                              pw.Text(
                                CertificateTypeHelper.getValueLabel(
                                  application.serviceCode,
                                  application.serviceName,
                                ),
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.normal,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                CertificateTypeHelper.formatValue(
                                  application.serviceCode,
                                  application.serviceName,
                                  application.certificateValue!,
                                ),
                                style: pw.TextStyle(
                                  fontSize: 28,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 30),
                      ],
                      pw.SizedBox(height: 50),
                      
                      // Details Box
                      pw.Container(
                        padding: const pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.blue700,
                            width: 1.5,
                          ),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Application Number', application.applicationNumber),
                            pw.SizedBox(height: 12),
                            _buildDetailRow('Department', application.departmentName),
                            pw.SizedBox(height: 12),
                            if (application.certificateType != null && application.certificateType!.isNotEmpty) ...[
                              _buildDetailRow('Certificate Type', application.certificateType!),
                              pw.SizedBox(height: 12),
                            ],
                            if (application.certificateValue != null && application.certificateValue!.isNotEmpty) ...[
                              _buildDetailRow(
                                CertificateTypeHelper.getValueLabel(
                                  application.serviceCode,
                                  application.serviceName,
                                ),
                                CertificateTypeHelper.formatValue(
                                  application.serviceCode,
                                  application.serviceName,
                                  application.certificateValue!,
                                ),
                              ),
                              pw.SizedBox(height: 12),
                            ],
                            _buildDetailRow(
                              'Date of Issue',
                              _formatDate(application.approvedDate ?? DateTime.now()),
                            ),
                            if (application.officerName != null) ...[
                              pw.SizedBox(height: 12),
                              _buildDetailRow('Issued By', application.officerName!),
                            ],
                          ],
                        ),
                      ),
                      pw.Spacer(),
                      
                      // Certificate ID
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'Certificate ID: ${application.applicationNumber}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 40),
                      
                      // Footer with signatures
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Issued By:',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 30),
                              pw.Container(
                                width: 150,
                                height: 1,
                                color: PdfColors.black,
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                application.officerName ?? 'Authorized Officer',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'Date:',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 30),
                              pw.Container(
                                width: 120,
                                height: 1,
                                color: PdfColors.black,
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                _formatDate(application.approvedDate ?? DateTime.now()),
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
      return null;
    }
  }

  // View/Print certificate
  Future<void> viewCertificate(ApplicationModel application) async {
    try {
      final file = await generateCertificate(application);
      if (file != null) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async {
            return await file.readAsBytes();
          },
        );
      }
    } catch (e) {
      print('View certificate error: $e');
    }
  }

  // Helper to build detail rows
  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 140,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
