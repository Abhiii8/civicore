# Authorization Debug Guide

## Issue: "Unauthorized" Error When Applying for Services

### Possible Causes:
1. Token not being sent in request
2. Token expired or invalid
3. Header not being read correctly by PHP
4. User not logged in properly

### Debug Steps:

#### 1. Check if Token is Stored
In Flutter app, add this debug code temporarily:
```dart
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('auth_token');
print('Token exists: ${token != null}');
print('Token length: ${token?.length ?? 0}');
```

#### 2. Test Backend Auth Endpoint
Visit in browser or use Postman:
```
http://10.0.2.2/civicore/backend/test_auth.php
```

This will show:
- Whether headers are being received
- If token is being parsed correctly
- What the auth middleware sees

#### 3. Check PHP Error Logs
Look in XAMPP error logs:
- Windows: `C:\xampp\apache\logs\error.log`
- Look for "CiviCore Auth:" messages

#### 4. Verify Login
Make sure you're logged in as a **citizen** user:
- Email: `citizen1@example.com`
- Password: `password` (from sample data)

Or register a new citizen account.

### Quick Fixes Applied:

1. **Improved Header Reading**: Middleware now checks multiple sources:
   - `getallheaders()` (Apache)
   - `$_SERVER['HTTP_AUTHORIZATION']` (FastCGI)
   - `$_SERVER['REDIRECT_HTTP_AUTHORIZATION']` (Redirects)

2. **Better Error Messages**: Application service now shows specific error messages

3. **Token Verification**: Checks if token exists before making request

### If Still Not Working:

1. **Logout and Login Again**: Token might be corrupted
2. **Check User Role**: Make sure you're logged in as "citizen" not "admin" or "officer"
3. **Clear App Data**: Uninstall and reinstall the app to clear SharedPreferences
4. **Check Backend Logs**: Look for authentication errors in PHP error log

### Test Endpoint:
```
GET http://10.0.2.2/civicore/backend/test_auth.php
```
Send with Authorization header:
```
Authorization: Bearer YOUR_TOKEN_HERE
```
