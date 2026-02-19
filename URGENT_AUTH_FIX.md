# URGENT: Authorization Fix

## Problem
Still getting "Unauthorized" error when applying for services.

## Root Cause
The Authorization header might not be read correctly by PHP, especially when using query parameter routing.

## Fixes Applied

### 1. Enhanced Header Reading (backend/middleware/auth.php)
- Now checks multiple sources for Authorization header:
  - `getallheaders()` (Apache)
  - `$_SERVER['HTTP_AUTHORIZATION']` (FastCGI/Nginx)
  - `$_SERVER['REDIRECT_HTTP_AUTHORIZATION']` (Redirects)
- Added error logging for debugging

### 2. Token Verification (lib/services/application_service.dart)
- Checks if token exists before making request
- Shows better error messages
- Handles DioException properly

### 3. Token Storage (lib/services/auth_service.dart)
- Ensures token is saved properly after login/register
- Also saves user data for profile access

## Testing Steps

1. **Logout and Login Again**
   - This ensures a fresh token is generated
   - Old tokens might be corrupted

2. **Verify You're Logged In as Citizen**
   - Check the dashboard - should show "Citizen Portal"
   - If logged in as admin/officer, logout and login as citizen

3. **Test the Auth Endpoint**
   - Visit: `http://10.0.2.2/civicore/backend/test_auth.php`
   - This shows what headers PHP receives

4. **Check Error Logs**
   - Look in: `C:\xampp\apache\logs\error.log`
   - Search for "CiviCore Auth:" messages

## Quick Test

1. Open Flutter app
2. Logout if logged in
3. Login as citizen (or register new account)
4. Try applying for a service
5. If still fails, check the error message - it should be more specific now

## If Still Not Working

The issue might be:
1. **Token not being sent**: Check if token is in SharedPreferences
2. **Header not reaching PHP**: Check Apache configuration
3. **Token expired**: Login again to get new token

## Debug Endpoint

Created `backend/test_auth.php` to help debug:
- Shows all headers received
- Shows if token is valid
- Shows user info from token

Access it at: `http://10.0.2.2/civicore/backend/test_auth.php`
