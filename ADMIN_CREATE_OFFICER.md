# Admin Create Officer Account Feature

## ✅ Feature Added

Admins can now create officer accounts (and citizen accounts) from the Users Management screen.

## 🎯 How to Use

1. **Navigate to Users Management**
   - Login as admin
   - Go to Admin Dashboard
   - Click "Users" in System Management

2. **Create Officer Account**
   - Click the floating action button (+ icon) in bottom right
   - Fill in the form:
     - **Role**: Select "Officer" (default) or "Citizen"
     - **Department**: Required for officers (select from dropdown)
     - **Full Name**: Officer's full name
     - **Email**: Unique email address
     - **Password**: Initial password for the officer
     - **Phone**: Optional phone number
   - Click "Create"

3. **Officer Can Login**
   - Officer can now login with the created email and password
   - They will see the Officer Dashboard
   - They can review applications assigned to their department

## 📋 Features

- **Role Selection**: Create Officer or Citizen accounts
- **Department Assignment**: Officers must be assigned to a department
- **Email Validation**: Checks if email already exists
- **Password Hashing**: Secure password storage using bcrypt
- **Auto-Activation**: New accounts are automatically active and email verified

## 🔧 Technical Details

- **Backend Endpoint**: `POST /api/admin/users`
- **Required Fields**: email, password, full_name, role_id
- **Optional Fields**: phone, department_id (required for officers)
- **Role IDs**:
  - Citizen: 1
  - Officer: 2
  - Admin: 3

## 📝 Notes

- Only admins can create user accounts
- Officers must be assigned to a department
- Citizens don't need department assignment
- Email must be unique across all users
- Passwords are hashed using bcrypt before storage
