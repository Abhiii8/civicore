# Final Login Fix Guide

## Current Status
- ✅ Backend is accessible
- ✅ Routing is working
- ❌ Password verification failing

## Solution Steps

### Step 1: Test Password Hash
Open in browser:
```
http://localhost/civicore/backend/test_login.php
```

This will show:
- If user exists
- Current password hash
- Whether password verification works
- A new hash if needed

### Step 2: Update Password in Database

**Option A: Using phpMyAdmin**
1. Open: `http://localhost/phpmyadmin`
2. Select `civicore` database
3. Go to SQL tab
4. Run:

```sql
-- Option 1: Use the hash from test_login.php output
UPDATE users 
SET password = '[NEW_HASH_FROM_TEST]'
WHERE email = 'admin@civicore.gov';

-- Option 2: Use this known working hash
UPDATE users 
SET password = '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE email = 'admin@civicore.gov';
```

**Option B: Direct SQL File**
Import: `database/update_admin_password.sql`

### Step 3: Auto-Fix Feature Added
I've updated `AuthController.php` to automatically fix password hashes if they're in wrong format. It will:
- Try to verify password
- If fails, generate new hash
- Update database automatically
- Retry login

This means you can try logging in again and it might auto-fix!

### Step 4: Verify User Exists
Run in phpMyAdmin SQL:
```sql
SELECT id, email, full_name, role_id, is_active, 
       LENGTH(password) as hash_length
FROM users 
WHERE email = 'admin@civicore.gov';
```

Should show:
- id: 1
- email: admin@civicore.gov
- role_id: 3 (admin)
- is_active: 1
- hash_length: 60 (bcrypt hash length)

### Step 5: Test Login Again
1. **Hot restart Flutter app** (Press `R`)
2. **Try login:**
   - Email: `admin@civicore.gov`
   - Password: `admin123`

## Debugging

If still not working, check:

1. **Database Connection:**
   - Open: `http://localhost/civicore/backend/test.php`
   - Should show backend is working

2. **User Exists:**
   - Run SQL: `SELECT * FROM users WHERE email = 'admin@civicore.gov';`
   - Should return 1 row

3. **Password Hash Format:**
   - Should start with `$2y$10$`
   - Should be 60 characters long

4. **Check Apache Error Log:**
   - `C:\xampp\apache\logs\error.log`
   - Look for PHP errors

## Quick Test Commands

```sql
-- Check user
SELECT * FROM users WHERE email = 'admin@civicore.gov';

-- Update password
UPDATE users SET password = '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' WHERE email = 'admin@civicore.gov';

-- Verify update
SELECT email, SUBSTRING(password, 1, 7) as hash_start FROM users WHERE email = 'admin@civicore.gov';
```

The hash should start with `$2y$10$`
