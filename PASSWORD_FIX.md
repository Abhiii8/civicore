# Password Fix for Admin Login

## Issue
Getting "Invalid credentials" error when trying to login with:
- Email: `admin@civicore.gov`
- Password: `admin123`

## Solution

The password hash in the database might be incorrect. Update it using the SQL script.

### Option 1: Run SQL Update (Recommended)

1. Open phpMyAdmin: `http://localhost/phpmyadmin`
2. Select `civicore` database
3. Go to SQL tab
4. Run this SQL:

```sql
UPDATE users 
SET password = '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE email = 'admin@civicore.gov';
```

Or import: `database/update_admin_password.sql`

### Option 2: Generate New Hash

1. Open: `http://localhost/civicore/backend/generate_password.php`
2. Copy the generated hash
3. Update the database with the new hash

### Option 3: Reset Password via SQL

If you want to set a different password, run this in phpMyAdmin:

```sql
-- For password "admin123"
UPDATE users 
SET password = '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE email = 'admin@civicore.gov';

-- Or generate your own hash using PHP:
-- $hash = password_hash('your_password', PASSWORD_BCRYPT);
```

## After Updating

1. **Hot restart Flutter app** (Press `R` in terminal)
2. **Try login again:**
   - Email: `admin@civicore.gov`
   - Password: `admin123`

## Verify Password Hash

To verify the hash is correct, you can test in PHP:

```php
$hash = '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';
$password = 'admin123';
var_dump(password_verify($password, $hash)); // Should return true
```

## Alternative: Create New Admin User

If updating doesn't work, create a fresh admin:

```sql
INSERT INTO users (role_id, email, password, full_name, phone, is_active, email_verified)
VALUES (
    3, 
    'admin@civicore.gov', 
    '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'System Administrator', 
    '1234567890', 
    TRUE, 
    TRUE
);
```
