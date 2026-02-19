# Certificate Template Usage Guide

## ✅ Custom Certificate Templates Feature

You can now use your own certificate template images (like birth certificate templates) and overlay applicant details on them!

## 🎯 Quick Start

### Step 1: Prepare Your Template
1. Create or obtain a certificate template image:
   - **Format**: PNG, JPG, or SVG
   - **Size**: A4 size recommended (210mm x 297mm or 2480x3508 pixels at 300 DPI)
   - **Design**: Leave blank spaces where text should appear

### Step 2: Upload Template (Admin)
1. Login as admin
2. Go to Certificate Templates screen (to be added to admin dashboard)
3. Click "Upload Template"
4. Select your template image
5. Configure field positions (X, Y coordinates)

### Step 3: Generate Certificate
When approving an application, the system will:
- Load your template image
- Overlay applicant details at configured positions
- Generate PDF certificate
- Ready for download/print

## 📝 Example: Using Template in Code

```dart
import 'package:civicore/services/certificate_service.dart';
import 'package:civicore/models/application_model.dart';

// Initialize service
final certificateService = CertificateService();

// Generate certificate with template from URL
final certificate = await certificateService.generateCertificate(
  application,
  templateUrl: 'http://10.0.2.2/civicore/backend/uploads/templates/birth_cert.png',
  textFields: {
    'applicant_name': {
      'position': {'x': 150.0, 'y': 200.0},  // Position on template
      'fontSize': 18.0,
      'fontWeight': 'bold',
      'color': [0, 0, 0],  // Black text
    },
    'application_number': {
      'position': {'x': 150.0, 'y': 250.0},
      'fontSize': 12.0,
      'fontWeight': 'normal',
      'color': [0, 0, 0],
    },
    'date_of_issue': {
      'position': {'x': 150.0, 'y': 320.0},
      'fontSize': 12.0,
      'fontWeight': 'normal',
      'color': [0, 0, 0],
    },
  },
);

// Or use local template file
final certificate = await certificateService.generateCertificate(
  application,
  templateFile: File('/path/to/your/template.png'),
  textFields: customFields,
);
```

## 🎨 Field Configuration

### Available Fields
- `applicant_name` - Citizen's full name
- `application_number` - Application reference number
- `service_name` - Service name (e.g., "Birth Certificate")
- `date_of_issue` - Date certificate was issued
- `department` - Department name

### Position Coordinates
- **X**: Horizontal position (left to right)
- **Y**: Vertical position (top to bottom)
- **Units**: Points (1 point = 1/72 inch)
- **Origin**: Top-left corner (0, 0)

### Font Styling
- **fontSize**: Text size in points (e.g., 12.0, 18.0)
- **fontWeight**: 'normal' or 'bold'
- **color**: RGB array [R, G, B] (e.g., [0, 0, 0] for black)

## 📋 Template Requirements

### Image Specifications
- **Formats**: PNG (recommended), JPG, SVG
- **Resolution**: 300 DPI for print quality
- **Size**: A4 (210mm x 297mm) or custom
- **File Size**: Max 10MB

### Design Guidelines
1. Use high-quality images
2. Leave clear spaces for text fields
3. Use professional government-style design
4. Ensure text contrast for readability
5. Include official seals/logos if needed

## 🔧 Backend Setup

### Template Storage
Templates are stored in: `backend/uploads/templates/`

### API Endpoints
- `GET /api/admin/certificate-templates` - List all templates
- `POST /api/admin/certificate-templates` - Upload new template

### Upload Template (Multipart Form Data)
```
POST /api/admin/certificate-templates
Content-Type: multipart/form-data

Fields:
- template: (file) Template image
- name: (string) Template name
- service_id: (int, optional) Associate with specific service
- field_config: (JSON, optional) Field positions
```

## 💡 Tips for Best Results

1. **Test Positions**: Upload template and test with sample data
2. **Use High Resolution**: 300 DPI ensures print quality
3. **Simple Design**: Avoid complex backgrounds that interfere with text
4. **Contrast**: Ensure text is readable on background
5. **Standard Size**: Use A4 size for compatibility

## 🚀 Next Steps

1. Upload your birth certificate template
2. Configure field positions using the visual editor
3. Test certificate generation
4. Adjust positions as needed
5. Use for all approved applications!

## 📞 Support

If you need help:
- Check template image quality
- Verify field positions are correct
- Ensure template format is supported (PNG/JPG/SVG)
- Check file size is under 10MB
