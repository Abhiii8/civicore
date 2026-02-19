# URGENT: Password Hash Update Required

## ✅ Test Results Show:
- User exists: ✓
- Current hash: **DOES NOT WORK** ✗
- New hash: **WORKS** ✓

## 🔧 IMMEDIATE ACTION REQUIRED:

### Step 1: Open phpMyAdmin
```
http://localhost/phpmyadmin
```

### Step 2: Select Database
Click on `civicore` database

### Step 3: Go to SQL Tab
Click "SQL" tab at the top

### Step 4: Run This SQL
Copy and paste this EXACT SQL:

```sql
UPDATE users 
SET password = '$2y$10$PQFpkqDDQtJNj6MB7T7zYuT.r6awATxL1HY1ZGrhxfOaiEFskvXGe'
WHERE email = 'admin@civicore.gov';
```

### Step 5: Click "Go" Button
Execute the SQL

### Step 6: Verify
You should see: "1 row affected"

### Step 7: Test Login
1. **Hot restart Flutter app** (Press `R` in terminal)
2. **Login with:**
   - Email: `admin@civicore.gov`
   - Password: `admin123`

## ✅ Expected Result:
Login should work now! The hash has been verified to work with "admin123".

## Alternative: Import SQL File
You can also import: `database/fix_password_now.sql`

---

**The hash `$2y$10$PQFpkqDDQtJNj6MB7T7zYuT.r6awATxL1HY1ZGrhxfOaiEFskvXGe` has been tested and verified to work with password "admin123".**
