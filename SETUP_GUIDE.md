# CiviCore Setup Guide

## Quick Start

### 1. Backend Setup (5 minutes)

1. **Start XAMPP**
   - Open XAMPP Control Panel
   - Start Apache and MySQL

2. **Import Database**
   ```sql
   -- Option 1: Using phpMyAdmin
   - Open http://localhost/phpmyadmin
   - Create database: civicore
   - Import: database/civicore.sql
   - Import: database/sample_data.sql (optional)

   -- Option 2: Using Command Line
   mysql -u root -p
   source database/civicore.sql
   source database/sample_data.sql
   ```

3. **Copy Backend Files**
   - Copy `backend` folder to `C:\xampp\htdocs\civicore\`
   - Ensure path: `C:\xampp\htdocs\civicore\backend\index.php`

4. **Create Upload Directory**
   ```bash
   mkdir C:\xampp\htdocs\civicore\backend\uploads
   ```

5. **Test Backend**
   - Visit: http://localhost/civicore/backend/api/services
   - Should see JSON response

### 2. Frontend Setup (3 minutes)

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Update API URL**
   - Open `lib/core/constants/api_constants.dart`
   - For Android Emulator:
     ```dart
     static const String baseUrl = 'http://10.0.2.2/civicore/backend';
     ```
   - For Physical Device:
     ```dart
     static const String baseUrl = 'http://YOUR_COMPUTER_IP/civicore/backend';
     ```
   - For Windows Desktop:
     ```dart
     static const String baseUrl = 'http://localhost/civicore/backend';
     ```

3. **Run App**
   ```bash
   flutter run
   ```

## Testing the System

### Test Login
1. Open app
2. Login with:
   - Email: `admin@civicore.gov`
   - Password: `admin123`

### Test Citizen Flow
1. Register new citizen
2. Browse services
3. Apply for "Birth Certificate"
4. Upload document (optional)
5. View application status

### Test Officer Flow
1. Login as officer: `officer1@civicore.gov` / `admin123`
2. View assigned applications
3. Review and approve/reject

### Test Admin Flow
1. Login as admin
2. View dashboard statistics
3. Manage departments
4. Manage users

## Common Issues

### Backend 404 Error
- Check Apache is running
- Verify `.htaccess` is enabled in Apache
- Check file path: `htdocs/civicore/backend/index.php`

### Database Connection Error
- Check MySQL is running
- Verify credentials in `backend/config/database.php`
- Ensure database `civicore` exists

### Flutter API Connection Failed
- Check base URL in `api_constants.dart`
- For emulator: use `10.0.2.2` instead of `localhost`
- For device: use computer's IP address
- Check firewall settings

### Package Errors
```bash
flutter clean
flutter pub get
```

## File Structure Check

Ensure these files exist:
```
✓ backend/index.php
✓ backend/config/database.php
✓ backend/config/jwt.php
✓ backend/controllers/*.php
✓ lib/main.dart
✓ lib/core/constants/api_constants.dart
✓ database/civicore.sql
```

## Next Steps

1. ✅ Backend running
2. ✅ Database imported
3. ✅ Flutter dependencies installed
4. ✅ API URL configured
5. ✅ App running

**You're ready to demo! 🎉**
