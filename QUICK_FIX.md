# Quick Fix for Network Error

## Problem
App shows "Network error. Please check your connection"

## Solution 1: Test Backend First

1. **Open in Browser:**
   ```
   http://localhost/civicore/backend/test.php
   ```
   Should show: `{"success":true,"message":"Backend is working!"}`

2. **If test.php works, try:**
   ```
   http://localhost/civicore/backend/index.php?route=/api/services
   ```
   Should return JSON with services list.

## Solution 2: Enable .htaccess (If test.php works but API doesn't)

1. Open: `C:\xampp\apache\conf\httpd.conf`
2. Find line with: `AllowOverride none`
3. Change to: `AllowOverride All`
4. Restart Apache in XAMPP Control Panel

## Solution 3: Use Direct PHP Access (Temporary)

If .htaccess doesn't work, update Flutter API calls to use query parameter:

Update `lib/core/constants/api_constants.dart`:
```dart
// Change baseUrl to:
static const String baseUrl = 'http://10.0.2.2/civicore/backend/index.php?route=';
```

Then endpoints become:
- Login: `baseUrl + '/api/auth/login'`
- Services: `baseUrl + '/api/services'`

## Solution 4: Check Apache is Running

1. Open XAMPP Control Panel
2. Ensure Apache shows "Running" (green)
3. If not, click "Start"

## Solution 5: Check Firewall

Windows Firewall might be blocking Apache. Temporarily disable to test.

## After Any Fix

1. **Restart Apache** (XAMPP Control Panel → Stop → Start)
2. **Hot restart Flutter app** (Press `R` in terminal)
3. **Try login again**

## Test Credentials
- Email: `admin@civicore.gov`
- Password: `admin123`
