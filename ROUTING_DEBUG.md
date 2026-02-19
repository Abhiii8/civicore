# Routing Debug Guide

## Current Issue
Getting "Endpoint not found" error, which means the backend is accessible but routing isn't matching.

## Debug Steps

### 1. Test Debug Endpoint
Open in browser:
```
http://localhost/civicore/backend/index.php?route=/api/debug
```
or
```
http://localhost/civicore/backend/api/debug
```

This will show:
- What URI is being received
- What method is being used
- Full request details

### 2. Check Apache Error Log
Look at: `C:\xampp\apache\logs\error.log`

You should see lines like:
```
CiviCore API: Method=POST, URI=/api/auth/login, Full REQUEST_URI=...
```

### 3. Test Login Endpoint Directly
Using curl or Postman:
```bash
POST http://localhost/civicore/backend/index.php?route=/api/auth/login
Content-Type: application/json

{
  "email": "admin@civicore.gov",
  "password": "admin123"
}
```

### 4. Common URI Formats
The router handles these formats:
- `/api/auth/login` (direct)
- `/civicore/backend/api/auth/login` (with prefix)
- `/backend/api/auth/login` (with backend prefix)
- Query param: `?route=/api/auth/login`

## Quick Fix: Update Flutter to Use Query Parameter

If routing still doesn't work, update the API client to use query parameters:

**File:** `lib/core/api/api_client.dart`

Add this method:
```dart
String _buildUrl(String endpoint) {
  // Remove leading slash if present
  endpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
  return '${ApiConstants.baseUrl}/index.php?route=/$endpoint';
}
```

Then update all `_dio.get()`, `_dio.post()` calls to use `_buildUrl(endpoint)` instead of just `endpoint`.

## Alternative: Simple Router Fix

If the issue persists, we can simplify the router to be more flexible with URI matching.
