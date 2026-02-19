# Backend Connection Fix

## Issue
The app shows "Network error. Please check your connection" because the backend API is not accessible.

## Fixes Applied

### 1. Updated `.htaccess` RewriteBase
Changed from `/backend/` to `/civicore/backend/` to match the actual path.

### 2. Updated URI Parsing in `index.php`
Added better URI handling to remove both `/civicore/backend` and `/backend` prefixes.

## Testing Steps

### 1. Verify Apache mod_rewrite is Enabled
1. Open XAMPP Control Panel
2. Click "Config" next to Apache
3. Select "httpd.conf"
4. Search for: `LoadModule rewrite_module`
5. Make sure it's NOT commented out (no `#` at the start)
6. If commented, uncomment it and restart Apache

### 2. Test Backend Directly
Open in browser:
- Test endpoint: `http://localhost/civicore/backend/test.php`
- Services API: `http://localhost/civicore/backend/api/services`

Both should return JSON.

### 3. Check Apache Error Logs
If still not working, check:
`C:\xampp\apache\logs\error.log`

Look for:
- "mod_rewrite" errors
- "File does not exist" errors
- Permission errors

### 4. Alternative: Disable .htaccess (Temporary)
If mod_rewrite doesn't work, you can access directly:
- `http://localhost/civicore/backend/index.php?route=/api/services`

But this requires updating the Flutter app to use query parameters.

## Quick Fix Commands

```powershell
# Check if mod_rewrite is enabled
Select-String -Path "C:\xampp\apache\conf\httpd.conf" -Pattern "rewrite_module"

# Restart Apache (in XAMPP Control Panel)
# Or via command:
net stop Apache2.4
net start Apache2.4
```

## After Fixing

1. **Restart Apache** in XAMPP Control Panel
2. **Test in browser**: `http://localhost/civicore/backend/test.php`
3. **Hot restart Flutter app**: Press `R` in terminal
4. **Try login again**

## Current API URL
The app is configured to use: `http://10.0.2.2/civicore/backend`

This is correct for Android emulator. The emulator's `10.0.2.2` maps to your host's `localhost`.
