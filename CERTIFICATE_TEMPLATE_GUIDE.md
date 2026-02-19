# Certificate Template System

## ✅ Feature: Custom Certificate Templates

You can now use custom certificate templates (images/SVG) and overlay applicant details on them!

## 🎯 How It Works

1. **Upload Template**: Admin uploads a certificate template image (PNG, JPG, SVG)
2. **Configure Fields**: Set positions for text fields (name, date, number, etc.)
3. **Generate Certificate**: System overlays applicant details on the template
4. **Download/Print**: Generated PDF certificate ready for download or printing

## 📋 Usage

### For Admin (Template Management)

1. **Upload Template**:
   - Go to Admin Dashboard → Certificate Templates (to be added)
   - Click "Upload Template" button
   - Select image file (PNG, JPG, or SVG)
   - Configure template name and service association

2. **Configure Field Positions**:
   - After uploading, configure where each field should appear
   - Set X, Y coordinates for:
     - Applicant Name
     - Application Number
     - Service Name
     - Date of Issue
     - Department
   - Adjust font size, weight, and color

### For Certificate Generation

```dart
// Using template from URL
final certificate = await certificateService.generateCertificate(
  application,
  templateUrl: 'http://your-server.com/templates/birth_certificate.png',
  textFields: {
    'applicant_name': {
      'position': {'x': 150.0, 'y': 200.0},
      'fontSize': 18.0,
      'fontWeight': 'bold',
      'color': [0, 0, 0], // RGB
    },
    // ... other fields
  },
);

// Using local template file
final certificate = await certificateService.generateCertificate(
  application,
  templateFile: File('/path/to/template.png'),
  textFields: customFields,
);
```

## 🎨 Template Requirements

### Supported Formats
- **PNG** - Recommended for best quality
- **JPG/JPEG** - Good for photos
- **SVG** - Vector graphics (scalable)

### Template Guidelines
1. **Size**: A4 size (210mm x 297mm) or similar
2. **Resolution**: 300 DPI for print quality
3. **Format**: Leave blank spaces where text will be overlaid
4. **Design**: Professional government-style design

### Field Positions
- Coordinates are in points (1 point = 1/72 inch)
- Origin (0,0) is at top-left corner
- X increases to the right
- Y increases downward

## 📝 Example Template Configuration

```dart
Map<String, Map<String, dynamic>> textFields = {
  'applicant_name': {
    'position': {'x': 150.0, 'y': 200.0},  // Position on template
    'fontSize': 18.0,                       // Font size
    'fontWeight': 'bold',                   // 'normal' or 'bold'
    'color': [0, 0, 0],                     // RGB: Black
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
};
```

## 🔧 Technical Details

### Packages Used
- `pdf` - PDF generation
- `printing` - PDF viewing/printing
- `image` - Image processing
- `flutter_svg` - SVG support (optional)

### Backend Support
- Template storage in `backend/uploads/templates/`
- API endpoint for template upload (to be implemented)
- Template metadata storage in database

## 📦 Database Schema (To Be Added)

```sql
CREATE TABLE certificate_templates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    service_id INT NULL,
    name VARCHAR(255) NOT NULL,
    template_path VARCHAR(255) NOT NULL,
    template_type ENUM('image', 'svg') DEFAULT 'image',
    field_config JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL
);
```

## 🚀 Next Steps

1. **Backend API**: Create endpoints for template upload/management
2. **Template Editor**: Visual editor for configuring field positions
3. **Template Preview**: Preview certificate before generation
4. **Multiple Templates**: Support different templates per service

## 💡 Tips

- Use high-resolution images for better print quality
- Test field positions with sample data
- Keep template design simple and professional
- Ensure text fields don't overlap with important template elements
- Use contrasting colors for text readability
