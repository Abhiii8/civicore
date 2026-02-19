# Certificate Template Setup Instructions

## 🎯 Quick Setup Guide

### Step 1: Prepare Your Template Image

1. **Create or obtain your certificate template**:
   - Birth Certificate template
   - Income Certificate template
   - Any other certificate template
   
2. **Template Requirements**:
   - Format: PNG, JPG, or SVG
   - Size: A4 (210mm x 297mm) recommended
   - Resolution: 300 DPI for print quality
   - Design: Leave blank spaces where text will appear

### Step 2: Upload Template to Server

**Option A: Manual Upload**
1. Copy your template image to: `backend/uploads/templates/`
2. Name it appropriately (e.g., `birth_certificate.png`)

**Option B: Via Admin Panel** (when implemented)
1. Login as admin
2. Go to Certificate Templates
3. Click "Upload Template"
4. Select your image file

### Step 3: Configure Field Positions

You need to determine X, Y coordinates for each field on your template:

1. **Open your template in an image editor**
2. **Note the pixel positions** where you want text to appear
3. **Convert to points** (1 point = 1/72 inch, or use pixels directly)

**Example:**
- If applicant name should be at pixel (200, 300) from top-left:
  - X = 200.0
  - Y = 300.0

### Step 4: Use Template in Code

```dart
import 'package:civicore/services/certificate_service.dart';
import 'package:civicore/utils/certificate_template_helper.dart';

final certificateService = CertificateService();

// Generate certificate with template
final certificate = await certificateService.generateCertificate(
  application,
  templateUrl: 'http://10.0.2.2/civicore/backend/uploads/templates/birth_certificate.png',
  textFields: CertificateTemplateHelper.getBirthCertificateFields(
    nameX: 200.0,    // Adjust based on your template
    nameY: 300.0,
    numberX: 200.0,
    numberY: 350.0,
    dateX: 200.0,
    dateY: 400.0,
  ),
);
```

## 📋 Field Configuration Example

### Birth Certificate Template

```dart
Map<String, Map<String, dynamic>> fields = {
  'applicant_name': {
    'position': {'x': 200.0, 'y': 300.0},  // Where name appears
    'fontSize': 18.0,
    'fontWeight': 'bold',
    'color': [0, 0, 0],  // Black
  },
  'application_number': {
    'position': {'x': 200.0, 'y': 350.0},  // Where number appears
    'fontSize': 12.0,
    'fontWeight': 'normal',
    'color': [0, 0, 0],
  },
  'date_of_issue': {
    'position': {'x': 200.0, 'y': 400.0},  // Where date appears
    'fontSize': 12.0,
    'fontWeight': 'normal',
    'color': [0, 0, 0],
  },
};
```

## 🎨 Finding Coordinates

### Method 1: Using Image Editor
1. Open template in Photoshop/GIMP/Paint
2. Hover over where text should go
3. Note X, Y coordinates from status bar
4. Use those coordinates

### Method 2: Trial and Error
1. Start with estimated positions
2. Generate test certificate
3. Check if text is in right place
4. Adjust coordinates
5. Repeat until perfect

### Method 3: Visual Editor (Future)
- Use the template field configuration screen
- Drag and drop fields on template preview
- Automatically saves coordinates

## 💡 Tips

1. **Test First**: Generate a test certificate with sample data
2. **Adjust Gradually**: Change coordinates by small amounts
3. **Use High Res**: 300 DPI templates give better results
4. **Simple Design**: Avoid complex backgrounds
5. **Contrast**: Ensure text is readable

## 📝 Template File Structure

```
backend/uploads/templates/
├── birth_certificate.png
├── income_certificate.png
├── residence_certificate.png
└── ...
```

## 🔧 Integration Example

When approving an application, you can use:

```dart
// In application_review_screen.dart or similar
final certificate = await certificateService.generateCertificate(
  application,
  templateUrl: CertificateTemplateHelper.getTemplateUrlForService(
    application.serviceName,
  ),
  textFields: CertificateTemplateHelper.getBirthCertificateFields(),
);

// Then save or display the certificate
if (certificate != null) {
  await certificateService.viewCertificate(
    application,
    templateUrl: templateUrl,
    textFields: fields,
  );
}
```

## ✅ Checklist

- [ ] Template image prepared (PNG/JPG/SVG)
- [ ] Template uploaded to server
- [ ] Field positions determined
- [ ] Template URL configured
- [ ] Test certificate generated
- [ ] Positions adjusted if needed
- [ ] Ready for production use!
