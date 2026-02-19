# Network Connection Fix Guide

## Issue
The app shows "Network error. Please check your connection" when trying to login.

## Solution

### For Android Emulator (Current Setup)
The API URL is now set to: `http://10.0.2.2/civicore/backend`

This is correct for Android emulators. `10.0.2.2` is a special IP that maps to your host machine's `localhost`.

### For Physical Android Device
If testing on a real phone, update `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://10.162.255.34/civicore/backend';
```
(Use your computer's IP address - found above)

### For Windows Desktop
If running on Windows desktop, use:
```dart
static const String baseUrl = 'http://localhost/civicore/backend';
```

## Verification Steps

1. **Check XAMPP is Running**
   - Apache must be running
   - MySQL must be running

2. **Test Backend in Browser**
   Open: `http://localhost/civicore/backend/api/services`
   - Should return JSON data
   - If 404, check file path: `C:\xampp\htdocs\civicore\backend\index.php`

3. **Check Database Connection**
   - Verify database `civicore` exists
   - Verify `users` table has data (you already checked this in phpMyAdmin ✓)

4. **Hot Restart the App**
   After changing API URL:
   ```bash
   flutter run
   ```
   Or press `r` in the terminal for hot reload

## Current Admin Credentials (from Database)
- **Email:** `admin@civicore.gov`
- **Password:** `admin123`

## Quick Test
1. Make sure XAMPP Apache is running
2. Test backend: Open `http://localhost/civicore/backend/api/services` in browser
3. If that works, the app should connect using `10.0.2.2`
4. Try login again

## Still Not Working?
- Check Windows Firewall isn't blocking Apache
- Verify `.htaccess` is enabled in Apache
- Check Apache error logs: `C:\xampp\apache\logs\error.log`
