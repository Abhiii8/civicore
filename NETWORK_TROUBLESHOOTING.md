# Network Connection Troubleshooting Guide

## Error: "Connection timeout" or "Network error"

### Step 1: Verify XAMPP Apache is Running

1. Open **XAMPP Control Panel**
2. Check if **Apache** shows "Running" (green status)
3. If not running, click **Start** button
4. Wait for Apache to start (should show green)

### Step 2: Test Backend in Browser

Open these URLs in your browser to verify backend is accessible:

1. **Test Backend:**
   ```
   http://localhost/civicore/backend/test.php
   ```
   Should show: `{"success":true,"message":"Backend is working!"}`

2. **Test API Endpoint:**
   ```
   http://localhost/civicore/backend/index.php?route=/api/services
   ```
   Should return JSON with services list

3. **Test Login Endpoint:**
   ```
   http://localhost/civicore/backend/index.php?route=/api/auth/login
   ```
   Should return JSON (even if error, means backend is reachable)

### Step 3: Check Android Emulator Network

**For Android Emulator:**
- Base URL should be: `http://10.0.2.2/civicore/backend`
- `10.0.2.2` is the special IP that maps to host's `localhost`

**Test from Emulator Browser:**
1. Open browser in Android emulator
2. Navigate to: `http://10.0.2.2/civicore/backend/test.php`
3. Should show backend response

### Step 4: Check Firewall

Windows Firewall might be blocking Apache:

1. Open **Windows Defender Firewall**
2. Check if Apache is blocked
3. Temporarily disable firewall to test
4. If it works, add Apache to firewall exceptions

### Step 5: Verify Backend Path

Check that your backend files are in:
```
C:\xampp\htdocs\civicore\backend\
```

Files should include:
- `index.php`
- `config/database.php`
- `controllers/`
- `middleware/`

### Step 6: Check Apache Configuration

1. Open: `C:\xampp\apache\conf\httpd.conf`
2. Find: `AllowOverride none`
3. Change to: `AllowOverride All`
4. Restart Apache

### Step 7: Check Port Conflicts

1. Apache default port is **80**
2. If port 80 is in use, change Apache port in XAMPP
3. Update baseUrl in `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8080/civicore/backend';
   ```

### Step 8: Verify Database Connection

1. Open phpMyAdmin: `http://localhost/phpmyadmin`
2. Check if `civicore` database exists
3. Verify tables are created

### Step 9: Check Error Logs

1. XAMPP Control Panel → Apache → Logs
2. Check `error.log` for any errors
3. Look for permission or configuration issues

### Step 10: Quick Test Script

Create `backend/test_connection.php`:
```php
<?php
header('Content-Type: application/json');
echo json_encode([
    'success' => true,
    'message' => 'Backend connection successful',
    'timestamp' => date('Y-m-d H:i:s'),
    'server' => $_SERVER['SERVER_NAME'] ?? 'unknown'
]);
```

Then test: `http://localhost/civicore/backend/test_connection.php`

## Common Solutions

### Solution 1: Restart Everything
1. Stop Apache in XAMPP
2. Start Apache again
3. Hot restart Flutter app (press `R` in terminal)

### Solution 2: Clear Flutter Cache
```bash
flutter clean
flutter pub get
flutter run
```

### Solution 3: Use Physical Device IP
If emulator doesn't work, use your computer's IP:

1. Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
2. Look for IPv4 address (e.g., `192.168.1.100`)
3. Update `api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://192.168.1.100/civicore/backend';
   ```
4. Ensure phone/emulator is on same network

### Solution 4: Check .htaccess
Verify `backend/.htaccess` exists and contains:
```apache
RewriteEngine On
RewriteBase /civicore/backend/
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php?route=/$1 [QSA,L]
```

## Still Not Working?

1. Check XAMPP error logs
2. Verify PHP is enabled in Apache
3. Test with Postman/curl to isolate Flutter issue
4. Check if antivirus is blocking Apache
5. Try accessing backend from another device on same network

## Test Credentials
- Email: `admin@civicore.gov`
- Password: `admin123`
