# CiviCore - E-Governance Platform

A complete cross-platform E-Governance system that enables citizens to apply for government services online, officers to review and approve applications, and admins to manage the system.

## 🎯 Project Overview

CiviCore is a full-stack E-Governance platform built for college/semester projects. It implements transparency, accountability, and efficiency in government service delivery through digital means (Paperless Governance).

## 🛠️ Tech Stack

### Frontend
- **Flutter** (Dart) - Cross-platform mobile and desktop application
- **Material 3** - Modern UI design
- **State Management** - Provider pattern
- **HTTP Client** - Dio for API communication

### Backend
- **PHP** - Core PHP (no frameworks)
- **MySQL** - Relational database
- **JWT** - Token-based authentication
- **REST API** - RESTful architecture

### Database
- **MySQL** - Primary database

## 📋 Features

### Citizen Module
- ✅ User registration and login
- ✅ View available government services
- ✅ Apply for services online
- ✅ Upload supporting documents (PDF, JPG, PNG)
- ✅ Track application status with timeline
- ✅ Download approved certificates (PDF)
- ✅ Submit complaints/grievances

### Officer Module
- ✅ Secure login
- ✅ View assigned applications
- ✅ Review application details and documents
- ✅ Approve or reject applications
- ✅ Add remarks and rejection reasons
- ✅ View processing history

### Admin Module
- ✅ Admin dashboard with analytics
- ✅ Manage departments
- ✅ Create and manage services
- ✅ Assign officers to departments
- ✅ Manage users (citizens & officers)
- ✅ View all applications
- ✅ View audit logs
- ✅ Export data capabilities

## 📁 Project Structure

```
civicore/
├── backend/                 # PHP Backend
│   ├── config/             # Database & JWT config
│   ├── controllers/        # API controllers
│   ├── middleware/         # Auth middleware
│   ├── uploads/            # Document storage
│   └── index.php          # Main router
├── database/               # SQL files
│   ├── civicore.sql      # Database schema
│   └── sample_data.sql    # Sample data
├── lib/                   # Flutter frontend
│   ├── core/             # Core utilities
│   │   ├── api/          # API client
│   │   ├── constants/    # App constants
│   │   └── theme/        # Theme configuration
│   ├── features/         # Feature modules
│   │   ├── auth/         # Authentication
│   │   ├── citizen/      # Citizen features
│   │   ├── officer/      # Officer features
│   │   ├── admin/        # Admin features
│   │   └── complaints/   # Complaints
│   ├── models/           # Data models
│   ├── services/         # Business logic
│   └── main.dart        # App entry point
└── README.md            # This file
```

## 🚀 Setup Instructions

### Prerequisites
- XAMPP/WAMP (PHP 7.4+, MySQL 5.7+)
- Flutter SDK 3.10.7+
- Android Studio / VS Code
- MySQL Workbench (optional)

### Backend Setup

1. **Database Setup**
   ```sql
   -- Import the database schema
   mysql -u root -p < database/civicore.sql
   
   -- Import sample data (optional)
   mysql -u root -p < database/sample_data.sql
   ```

2. **Backend Configuration**
   - Copy the `backend` folder to your XAMPP `htdocs` directory
   - Update database credentials in `backend/config/database.php`:
     ```php
     private $host = "localhost";
     private $db_name = "civicore";
     private $username = "root";
     private $password = "";
     ```

3. **File Permissions**
   - Create `backend/uploads` directory
   - Set write permissions: `chmod 777 backend/uploads`

4. **Test Backend**
   - Start Apache and MySQL in XAMPP
   - Visit: `http://localhost/civicore/backend/api/services`
   - Should return JSON response

### Frontend Setup

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Update API Base URL**
   - Open `lib/core/constants/api_constants.dart`
   - Update `baseUrl` to match your backend:
     ```dart
     static const String baseUrl = 'http://localhost/civicore/backend';
     ```
   - For Android emulator, use: `http://10.0.2.2/civicore/backend`
   - For physical device, use your computer's IP: `http://192.168.x.x/civicore/backend`

3. **Run the App**
   ```bash
   flutter run
   ```

## 👥 Default Login Credentials

### Admin
- **Email:** admin@civicore.gov
- **Password:** admin123

### Sample Citizens
- **Email:** citizen1@example.com
- **Password:** admin123

### Sample Officers
- **Email:** officer1@civicore.gov
- **Password:** admin123

> **Note:** All default passwords are `admin123` (bcrypt hash in database)

## 📱 Supported Platforms

- ✅ Android
- ✅ Windows Desktop
- ✅ iOS (with minor adjustments)
- ✅ Web (with minor adjustments)

## 🔐 Security Features

- JWT-based authentication
- Password hashing (bcrypt)
- Role-based access control (RBAC)
- Input validation
- Secure file upload handling
- Audit logging for accountability

## 📊 Database Schema

### Core Tables
- `users` - All users (citizens, officers, admins)
- `roles` - User roles
- `departments` - Government departments
- `services` - Available services
- `applications` - Citizen applications
- `application_documents` - Uploaded documents
- `application_logs` - Status change history
- `complaints` - Grievances
- `audit_logs` - System audit trail

## 📝 API Documentation

See `API_DOCUMENTATION.md` for complete API endpoint documentation.

## 🎨 UI Features

- Material 3 design
- Light & Dark mode support
- Responsive layout (mobile + desktop)
- Professional government-style UI
- Status timeline visualization
- Document upload interface

## 🧪 Testing

### Backend Testing
Use Postman or curl to test API endpoints:
```bash
# Test login
curl -X POST http://localhost/civicore/backend/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@civicore.gov","password":"admin123"}'
```

### Frontend Testing
```bash
flutter test
```

## 📦 Dependencies

### Flutter (pubspec.yaml)
- `http` - HTTP requests
- `dio` - Advanced HTTP client
- `provider` - State management
- `shared_preferences` - Local storage
- `file_picker` - File selection
- `pdf` - PDF generation
- `printing` - PDF printing
- `qr_flutter` - QR code generation
- `fl_chart` - Charts for analytics

## 🐛 Troubleshooting

### Backend Issues
- **404 Error:** Check Apache is running and `.htaccess` is enabled
- **Database Connection Error:** Verify MySQL credentials in `database.php`
- **CORS Error:** Add CORS headers in `index.php` (already included)

### Frontend Issues
- **API Connection Failed:** Check base URL in `api_constants.dart`
- **Build Errors:** Run `flutter clean` and `flutter pub get`
- **Token Expired:** Logout and login again

## 📄 License

This project is created for educational purposes (college/semester project).

## 👨‍💻 Development

### Code Structure
- **Backend:** MVC-style architecture with controllers
- **Frontend:** Feature-based modular structure
- **Database:** Normalized relational schema

### Governance Principles
- **Transparency:** All actions logged in audit trail
- **Accountability:** Role-based access control
- **Efficiency:** RESTful API design
- **Paperless:** Digital document management

## 🎓 Viva Preparation

### Key Points to Explain
1. **Architecture:** Client-Server REST API
2. **Security:** JWT authentication, password hashing
3. **Database Design:** Normalized schema with relationships
4. **Features:** Role-based access, application tracking
5. **Governance:** Transparency, accountability, efficiency

### Demo Flow
1. Citizen registration → Login
2. Browse services → Apply for service
3. Upload documents
4. Officer login → Review application
5. Approve/Reject application
6. Citizen views status
7. Admin dashboard overview

## 📞 Support

For issues or questions, refer to:
- API Documentation: `API_DOCUMENTATION.md`
- Database Schema: `database/civicore.sql`
- Code Comments: Well-documented throughout

---

**Built with ❤️ for E-Governance**
