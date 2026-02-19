# CiviCore API Documentation

## Base URL
```
http://localhost/civicore/backend
```

## Authentication
All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

---

## Authentication Endpoints

### Register
**POST** `/api/auth/register`

Request Body:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "phone": "1234567890",
  "aadhaar_number": "123456789012",
  "address": "123 Main St",
  "date_of_birth": "1990-01-01"
}
```

Response:
```json
{
  "success": true,
  "message": "Registration successful",
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "role": "citizen"
  }
}
```

### Login
**POST** `/api/auth/login`

Request Body:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "success": true,
  "message": "Login successful",
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "role": "citizen"
  }
}
```

---

## Service Endpoints

### Get All Services
**GET** `/api/services`

Response:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Birth Certificate",
      "code": "BC001",
      "description": "Official birth certificate",
      "required_documents": "Aadhaar Card",
      "processing_days": 5,
      "fee": 0.00,
      "department_name": "Civil Registration"
    }
  ]
}
```

### Get Service by ID
**GET** `/api/services/{id}`

### Create Service (Admin)
**POST** `/api/services`

Request Body:
```json
{
  "department_id": 1,
  "name": "Service Name",
  "code": "CODE001",
  "description": "Service description",
  "required_documents": "Documents required",
  "processing_days": 7,
  "fee": 0.00
}
```

---

## Application Endpoints

### Create Application (Citizen)
**POST** `/api/applications`

Request Body:
```json
{
  "service_id": 1
}
```

Response:
```json
{
  "success": true,
  "message": "Application created successfully",
  "data": {
    "id": 1,
    "application_number": "APP2024001"
  }
}
```

### Get My Applications (Citizen)
**GET** `/api/applications/my-applications`

### Get Application by ID
**GET** `/api/applications/{id}`

### Get Assigned Applications (Officer)
**GET** `/api/applications/assigned?status=pending`

### Get All Applications (Admin/Officer)
**GET** `/api/applications?status=pending`

### Assign Application (Admin)
**POST** `/api/applications/{id}/assign`

Request Body:
```json
{
  "officer_id": 2
}
```

### Approve Application (Officer)
**POST** `/api/applications/{id}/approve`

Request Body:
```json
{
  "remarks": "All documents verified"
}
```

### Reject Application (Officer)
**POST** `/api/applications/{id}/reject`

Request Body:
```json
{
  "rejection_reason": "Incomplete documents",
  "remarks": "Please submit all required documents"
}
```

---

## Document Endpoints

### Upload Document
**POST** `/api/documents/upload`

Content-Type: `multipart/form-data`

Form Data:
- `application_id`: Application ID
- `document`: File (PDF, JPG, PNG)

### Get Document
**GET** `/api/documents/{id}`

### Download Document
**GET** `/api/documents/{id}/download`

---

## Complaint Endpoints

### Create Complaint (Citizen)
**POST** `/api/complaints`

Request Body:
```json
{
  "subject": "Complaint Subject",
  "description": "Complaint description"
}
```

### Get My Complaints (Citizen)
**GET** `/api/complaints/my-complaints`

### Get All Complaints (Admin/Officer)
**GET** `/api/complaints?status=open`

### Get Complaint by ID
**GET** `/api/complaints/{id}`

### Update Complaint Status (Officer/Admin)
**PUT** `/api/complaints/{id}/status`

Request Body:
```json
{
  "status": "in_progress",
  "resolution": "Working on it",
  "assigned_to": 2
}
```

---

## Admin Endpoints

### Get Dashboard Statistics
**GET** `/api/admin/dashboard`

### Get Departments
**GET** `/api/admin/departments`

### Create Department
**POST** `/api/admin/departments`

Request Body:
```json
{
  "name": "Department Name",
  "code": "DEPT001",
  "description": "Department description"
}
```

### Get Users
**GET** `/api/admin/users?role=citizen`

### Create User
**POST** `/api/admin/users`

Request Body:
```json
{
  "email": "officer@civicore.gov",
  "password": "password123",
  "full_name": "Officer Name",
  "role_id": 2,
  "department_id": 1,
  "phone": "1234567890"
}
```

### Update User
**PUT** `/api/admin/users/{id}`

Request Body:
```json
{
  "full_name": "Updated Name",
  "is_active": true
}
```

### Get Audit Logs
**GET** `/api/admin/audit-logs?limit=100&offset=0`

---

## Error Responses

All endpoints return errors in the following format:

```json
{
  "success": false,
  "message": "Error message here"
}
```

HTTP Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

---

## Application Status Values
- `pending` - Application submitted, awaiting assignment
- `under_review` - Assigned to officer, under review
- `approved` - Application approved
- `rejected` - Application rejected

## Complaint Status Values
- `open` - Complaint submitted
- `in_progress` - Complaint being processed
- `resolved` - Complaint resolved
- `closed` - Complaint closed
