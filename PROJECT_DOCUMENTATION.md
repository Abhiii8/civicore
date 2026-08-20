# CiviCore — Project Documentation (Flutter + PHP REST API + MySQL)

---

## Cover Page
**Project Title**: CiviCore — E‑Governance Platform  
**Document Title**: Project Documentation  
**Frontend Technology**: Flutter (Dart)  
**Backend Technology**: PHP (REST API)  
**Database**: MySQL / MariaDB  
**Submitted By**: ____________________________  
**Roll No. / Enrollment No.**: ____________________________  
**Course / Department**: ____________________________  
**Institute / College**: ____________________________  
**Submitted To**: ____________________________  
**Academic Year**: ____________________________  

--- (Page Break in Word) ---

## Certificate
This is to certify that the project entitled **“CiviCore — E‑Governance Platform”** is a bonafide work carried out by **____________________________** (Roll No. **________________**) in partial fulfillment of the requirements for the award of **____________________________** during the academic year **________________**.

**Guide / Supervisor Name**: ____________________________  
**Signature**: ____________________________  
**Date**: ____ / ____ / ______  
**Seal**: ____________________________  

--- (Page Break in Word) ---

## Table of Contents
- Cover Page ............................................................................. 1  
- Certificate .............................................................................. 2  
- Table of Contents ...................................................................... 3  
- Introduction ............................................................................ 4  
- Project Objective ....................................................................... 5  
- Purpose ................................................................................. 6  
- Modules ................................................................................. 7  
  - Front-End Module ..................................................................... 7  
  - Back-End Module ...................................................................... 9  
  - Database Module ...................................................................... 11  
- Screenshots with URL .................................................................. 11  
  - User-Side Screens .................................................................. 11–17  
  - Officer-Side Screens ............................................................... 17–18  
  - Admin-Side Screens .................................................................. 18–20  
- API Documentation ...................................................................... 21  
- Database Structure ..................................................................... 26  
- Architecture & Diagrams ................................................................ 30  
- End-to-End Workflows ................................................................... 32  
- Deployment & Environment Setup ...................................................... 35  
- Appendix ................................................................................ 38  

--- (Page Break in Word) ---

## Formatting Instructions for Word/PDF (Strict)
To comply with the required academic formatting:

1. Copy the contents of this document into **Microsoft Word**.
2. Apply **Times New Roman** to the whole document.
3. Set **Heading font size = 14** and **Body font size = 12**:
   - Use Word styles: **Heading 1 / Heading 2 / Heading 3** for headings.
   - Use **Normal** style for content.
4. Set alignment to **Justify** for all body paragraphs.
5. Replace the page numbers in the Table of Contents after final formatting (or use Word’s automatic TOC feature).

---

## Introduction

## Project Objective
**CiviCore** is an **E‑Governance platform** designed to digitize and streamline government service delivery. The system enables citizens to apply for services (e.g., certificates), upload supporting documents, track application status, and file complaints. Officers review applications and update outcomes, while administrators manage departments, users, and services, improving accountability and transparency.

## Purpose
This project was built to address common issues in public service delivery:

- **Manual paperwork delays**: Replace paper processes with online workflows.
- **Limited transparency**: Provide status timelines and audit logging.
- **Poor grievance handling**: Provide a structured complaints system with responses.
- **Operational efficiency**: Use role-based dashboards for citizens, officers, and admins.

**Target users**

- **Citizens**: Apply for services, upload documents, track progress, download certificates, file complaints.
- **Officers**: Review assigned applications, approve/reject with remarks, manage complaints.
- **Admins**: Manage services/departments/users, monitor audit logs, view platform analytics.

## Modules

### Front-End Module (Flutter)
**Functionality**
- Provides the complete UI for **Citizen**, **Officer**, and **Admin** roles.
- Handles navigation, form validation, file pickers/camera integration, charts, and certificate viewing/printing.

**Technologies used**
- Flutter (Material UI), Dart
- Networking: `Dio` (via `ApiClient`)
- Local storage: `shared_preferences`
- File/image handling: `file_picker`, `image_picker`
- PDF/print: `pdf`, `printing`, `pdfx`

**Workflow (high-level)**
1. User authenticates (login/register).
2. Dashboard is opened based on role.
3. Screens call service classes (`lib/services/**`) which call backend APIs.
4. UI updates based on API responses and shows success/error snackbars.

### Back-End Module (PHP REST API)
**Functionality**
- Exposes REST endpoints for authentication, services, applications, documents, complaints, admin management, and profile.
- Enforces **JWT authentication** and **role-based access control (RBAC)**.
- Logs critical actions into `audit_logs` and application transitions into `application_logs`.

**Technologies used**
- PHP (custom router `backend/index.php`)
- PDO (MySQL)
- JWT (HS256) via `backend/config/jwt.php`

**Workflow (high-level)**
1. Router reads `route` and HTTP method.
2. Middleware validates JWT and role permissions.
3. Controller performs validation + DB operations.
4. Controller returns JSON response (and stores uploaded files when needed).

### Database Module (MySQL / MariaDB)
**Functionality**
- Stores user accounts, roles, departments, services, applications, documents, complaints, and audit logs.
- Enforces referential integrity using foreign keys (InnoDB).

**Technology used**
- MySQL 5.7+ / MariaDB 10.3+ (utf8mb4, InnoDB)

### Functional Modules (Role-Based Breakdown)

#### A. Authentication Module
**Functionality**
- Citizen registration.
- Login for citizen/officer/admin.
- JWT token storage on client and validation on server.

**Technologies used**
- Flutter: `AuthService`, `SharedPreferences`, `Dio` via `ApiClient`
- PHP: `AuthController.php`, `JWT` (`backend/config/jwt.php`)

**Workflow**
1. User enters email + password on `LoginScreen`.
2. Flutter calls `POST /api/auth/login`.
3. Backend validates credentials and returns `{ token, user }`.
4. Flutter saves token under `auth_token` and uses it in `Authorization: Bearer <token>` for future calls (via `ApiClient` interceptor).

#### B. User (Citizen) Module
**Functionality**
- Browse services and apply.
- Track “My Applications”.
- Upload supporting documents (PDF/JPG/PNG).
- View application details and timeline logs.
- Download/view certificate for approved applications (client-side PDF generation).
- Manage profile (name/phone + profile picture).
- Submit and track complaints (with optional photo).

**Technologies used**
- Flutter screens under `lib/features/citizen/**` and `lib/features/complaints/**`
- Flutter services: `ServiceService`, `ApplicationService`, `UserService`, `ComplaintService`
- Backend controllers: `ServiceController`, `ApplicationController`, `DocumentController`, `ComplaintController`, `UserController`

**Workflow (Citizen application)**
1. Open Services screen → search/filter → “Apply”.
2. Backend creates an `applications` record with status `pending`.
3. Citizen uploads documents for the application.
4. Officer/Admin reviews and updates status.
5. If approved, citizen downloads/views a generated certificate PDF.

#### C. Officer Module
**Functionality**
- View assigned applications with status filters.
- Review application details and attached documents.
- Approve with optional **certificate type** and **certificate value** (e.g., income amount).
- Reject with mandatory rejection reason.
- Manage complaints (view all, filter, respond, update status).

**Technologies used**
- Flutter: `OfficerDashboardEnhanced`, `ApplicationReviewScreen`, `ComplaintsManagementScreen`
- Backend: `ApplicationController`, `ComplaintController`

**Workflow**
1. Officer logs in → dashboard loads assigned applications from `GET /api/applications/assigned`.
2. Officer opens an application and approves/rejects:
   - Approve: `POST /api/applications/{id}/approve`
   - Reject: `POST /api/applications/{id}/reject`

#### D. Admin Module
**Functionality**
- Dashboard analytics (applications/users/complaints + recent applications).
- Create departments.
- Create and view users (citizen/officer/admin) and assign departments.
- Create services and view services list.
- View all applications (and open review screen).
- Manage certificate templates (upload image/SVG + configure fields for overlay).
- View audit logs.

**Technologies used**
- Flutter admin screens under `lib/features/admin/**`
- Backend: `AdminController.php`, `ServiceController.php`, `CertificateTemplateController.php`

**Workflow**
1. Admin dashboard calls `GET /api/admin/dashboard`.
2. Admin performs management operations; backend logs actions to `audit_logs`.

#### E. API/Backend Module
**Core behavior**
- Central router: `backend/index.php`
- Controllers in `backend/controllers/**`
- JWT middleware: `backend/middleware/auth.php`
- Database access: `backend/config/database.php` (PDO)

**Routing compatibility**
Flutter’s `ApiClient` uses **query-parameter routing** for reliability:
`{baseUrl}/index.php?route=/api/...`

#### F. Database Module
**Core schema file**
- `database/civicore.sql` (primary schema)

**Feature add-ons**
- `database/add_profile_picture.sql`
- `database/add_complaint_photo.sql`
- `database/add_certificate_type.sql`
- `database/add_certificate_value.sql`

---

## 2. System Overview

### 2.1 Technology Stack
| Layer | Technology | Purpose |
|---|---|---|
| Mobile App (Frontend) | Flutter (Dart), Material UI | Cross-platform UI (Citizen/Officer/Admin portals) |
| Networking | Dio, HTTP | REST API calls, file uploads (multipart/form-data) |
| State/Storage | SharedPreferences | Persist JWT + user data locally |
| Backend API | PHP (custom router + controllers) | REST endpoints, validation, access control |
| Authentication | JWT (HS256) | Stateless secure access tokens |
| Database | MySQL / MariaDB (InnoDB) | Persistent storage with foreign keys |
| File Storage | Server filesystem under `backend/uploads/**` | Documents, complaint photos, profile photos, templates |
| PDF/Printing | `pdf`, `printing` Flutter packages | Certificate generation and printing/viewing |

### 2.2 Project Structure (High-Level)
| Path | Description |
|---|---|
| `lib/main.dart` | App entry + named routes (`/`, `/login`, `/register`) + Splash |
| `lib/features/**` | UI screens by role (auth, citizen, officer, admin, complaints) |
| `lib/services/**` | API service wrappers (auth, user, applications, complaints, templates) |
| `lib/models/**` | Data models (`UserModel`, `ServiceModel`, `ApplicationModel`) |
| `lib/core/**` | API client and constants, theme, app constants |
| `backend/index.php` | REST router (maps route + method to controller action) |
| `backend/controllers/**` | Controllers for each domain |
| `backend/middleware/auth.php` | JWT validation + RBAC enforcement |
| `database/*.sql` | Schema + feature alter scripts + sample data |

### 2.3 User Roles and Permissions (RBAC)
Roles are stored in DB table `roles` and enforced by JWT middleware.

| Role | Key Abilities (System-Level) |
|---|---|
| `citizen` | Register/login, view services, create applications, upload documents for own applications, view own applications, submit complaints, view own complaints |
| `officer` | View assigned applications, approve/reject assigned applications, view/manage complaints, add responses, update complaint status |
| `admin` | Full administrative access (dashboard, manage departments/users/services, assign applications, view all data, audit logs, templates) |

---

## 3. Architecture & Diagrams

### 3.1 System Architecture Diagram (Text Description)
**Client–Server architecture**:

- **Flutter App** (Citizen / Officer / Admin UI)  
  ↕ (HTTPS/HTTP REST using Dio; JWT in Authorization header)  
- **PHP Backend Router** (`backend/index.php`)  
  ↕ (PDO)  
- **MySQL Database** (`civicore` schema)  
  + **File Storage**: `backend/uploads/**` for documents, complaint photos, profile photos, templates.

### 3.2 Data Flow Diagram (Text Description)
Example: **Citizen applies for a service**

1. Citizen selects service in Flutter → calls `POST /api/applications` with `service_id`.
2. Backend creates `applications` row (status `pending`) and writes `application_logs` entry.
3. Citizen uploads document → calls `POST /api/documents/upload` (multipart/form-data).
4. Backend stores file under `uploads/` and inserts `application_documents`.
5. Officer approves/rejects → backend updates `applications` and logs status changes.
6. Citizen views application details → `GET /api/applications/{id}` returns application + documents + logs.
7. For approved applications, Flutter generates certificate PDF using `CertificateService`.

### 3.3 Module Interaction Diagram (Text Description)
- **Auth Module** issues token → **ApiClient** attaches token on every request.
- **Service Module** lists services → **Application Module** creates applications.
- **Document Module** attaches evidence to an application.
- **Officer Module** updates application status and writes logs/audit.
- **Admin Module** manages users/departments/services and monitors audit logs.
- **Complaints Module** provides citizen grievance workflows and officer/admin responses.

---

## 4. Screenshots (Simulated) with Route/URL and Description
**Note on “Screenshots”**: Actual image files are not committed for UI screenshots in this repository. Therefore, each screenshot below is provided as a **simulated description** of what the UI contains and how it behaves.

### 4.1 User-Side (Citizen) Screens

#### 4.1.1 Splash Screen
- **Screen Name**: Splash  
- **Widget Name**: `SplashScreen` (`StatefulWidget`)  
- **URL / Route**: `/` (named route)  
- **Screenshot (Simulated)**: App icon (bank/government icon), “CiviCore”, subtitle “E‑Governance Platform”, loading spinner.  
- **Description**:
  - Waits ~2 seconds then checks `AuthService.isLoggedIn()`.
  - Current navigation logic redirects to `/login` for both logged-in and logged-out users (placeholder behavior).

#### 4.1.2 Login
- **Screen Name**: Login  
- **Widget Name**: `LoginScreen` (`StatefulWidget`)  
- **URL / Route**: `/login` (named route)  
- **Screenshot (Simulated)**: Email + password fields; Login button; link to Register.  
- **Inputs (sample)**:
  - Email: `admin@civicore.gov`
  - Password: `admin123`
- **Outputs/Behavior**:
  - On success navigates based on role:
    - `citizen` → `CitizenDashboard`
    - `officer` → `OfficerDashboard`
    - `admin` → `AdminDashboard`
  - Shows snackbar error on failed login.

#### 4.1.3 Register (Citizen Registration)
- **Screen Name**: Register  
- **Widget Name**: `RegisterScreen` (`StatefulWidget`)  
- **URL / Route**: `/register` (named route)  
- **Screenshot (Simulated)**: Form with full name, email, password/confirm, phone, Aadhaar, address.  
- **Inputs (sample)**:
  - Full Name: `Rajesh Kumar`
  - Email: `citizen1@example.com`
  - Password: `citizen123`
  - Phone: `9876543210`
  - Aadhaar: `123456789012`
  - Address: `123 Main Street, City`
- **Outputs/Behavior**:
  - Calls `POST /api/auth/register`.
  - On success shows “Registration successful!” and navigates to `CitizenDashboard`.

#### 4.1.4 Citizen Dashboard (Enhanced)
- **Screen Name**: Citizen Dashboard  
- **Widget Name**: `CitizenDashboardEnhanced` (`StatefulWidget`)  
- **URL / Route**: Not a named route (opened by `MaterialPageRoute`)  
- **Screenshot (Simulated)**:
  - Gradient app bar with “CiviCore”
  - Quick stats cards (Total/Pending/Approved)
  - Pie chart “My Applications Status”
  - Quick actions grid (Services, My Applications, Complaints, Profile)
  - Popular services carousel + recent applications list
- **Description**:
  - Loads:
    - `ApplicationService.getMyApplications()` → `GET /api/applications/my-applications`
    - `ServiceService.getAllServices()` → `GET /api/services`
  - Logout clears token and routes to `/login`.

#### 4.1.5 Services Listing (Enhanced)
- **Screen Name**: Services  
- **Widget Name**: `ServicesScreenEnhanced` (`StatefulWidget`)  
- **URL / Route**: Not a named route (opened by `MaterialPageRoute`)  
- **Screenshot (Simulated)**: Search bar; list of services with department, processing days, fee; “Apply Now” button.  
- **Inputs (sample)**:
  - Search query: `Income`
  - Service selected: `Income Certificate (IC001)`
- **Outputs/Behavior**:
  - Applying calls `ApplicationService.createApplication(serviceId)` → `POST /api/applications` with `{ "service_id": 2 }`.
  - On success navigates to `ApplicationDetailScreen(applicationId: <newId>)`.

#### 4.1.6 My Applications
- **Screen Name**: My Applications  
- **Widget Name**: `MyApplicationsScreen` (`StatefulWidget`)  
- **URL / Route**: Not a named route  
- **Screenshot (Simulated)**: Filter chips (All/Pending/Under Review/Approved/Rejected); list of applications.  
- **Outputs/Behavior**:
  - Loads from `GET /api/applications/my-applications`.
  - Tapping opens `ApplicationDetailScreen`.

#### 4.1.7 Application Details
- **Screen Name**: Application Details  
- **Widget Name**: `ApplicationDetailScreen` (`StatefulWidget`)  
- **URL / Route**: Not a named route; requires `applicationId`  
- **Screenshot (Simulated)**:
  - Service name + status chip
  - Application number, department, applied/review/approved dates
  - Timeline list from `application_logs`
  - Documents list with upload action
  - “Download Certificate” button when approved
- **Inputs (sample)**: `applicationId = 1`  
- **Outputs/Behavior**:
  - Loads `GET /api/applications/{id}` returning application + documents + logs.
  - Upload document opens `DocumentUploadScreen(applicationId)`.
  - Certificate: uses `CertificateService.viewCertificate(application)` (generates PDF client-side).

#### 4.1.8 Document Upload
- **Screen Name**: Upload Document  
- **Widget Name**: `DocumentUploadScreen` (`StatefulWidget`)  
- **URL / Route**: Not a named route; requires `applicationId`  
- **Screenshot (Simulated)**: “Choose File”, file preview, “Upload Document” button.  
- **Inputs (sample)**:
  - `application_id`: `1`
  - File: `aadhaar.pdf` (or `photo.png`)
- **Outputs/Behavior**:
  - Calls `POST /api/documents/upload` as multipart/form-data:
    - `application_id`
    - `document` file
  - Backend validates MIME + size ≤ 5MB and stores in `uploads/`.

#### 4.1.9 Profile
- **Screen Name**: My Profile  
- **Widget Name**: `ProfileScreen` (`StatefulWidget`)  
- **URL / Route**: Not a named route  
- **Screenshot (Simulated)**: Avatar (network or local), edit icon, name/phone form, email read-only, role read-only.  
- **Inputs (sample)**:
  - Full Name: `Priya Sharma`
  - Phone: `9876543211`
  - Profile Picture: `selfie.jpg`
- **Outputs/Behavior**:
  - Reads current user from local storage or `GET /api/user/profile`.
  - Updates via multipart `POST /api/user/profile` with `profile_picture` file.

#### 4.1.10 Complaints List (Citizen)
- **Screen Name**: Complaints & Grievances  
- **Widget Name**: `ComplaintsScreen` (`StatefulWidget`)  
- **URL / Route**: Not a named route  
- **Screenshot (Simulated)**: List of complaints with status chip and created date; FAB “Submit Complaint”.  
- **Behavior**:
  - Loads `GET /api/complaints/my-complaints`.
  - Tapping opens `ComplaintDetailScreen(complaintId, isOfficerView: false)`.

#### 4.1.11 Complaint Submit
- **Screen Name**: Submit Complaint  
- **Widget Name**: `ComplaintSubmitScreen` (`StatefulWidget`)  
- **URL / Route**: Not a named route  
- **Screenshot (Simulated)**: Subject field, description field, optional image attachment (camera/gallery), submit button.  
- **Inputs (sample)**:
  - Subject: `Delayed Certificate`
  - Description: `Birth certificate application is taking longer than expected.`
  - Photo: `evidence.jpg` (optional)
- **Outputs/Behavior**:
  - Calls `POST /api/complaints`:
    - JSON (without photo) OR multipart (with `photo`).

#### 4.1.12 Complaint Details (Citizen View)
- **Screen Name**: Complaint Details  
- **Widget Name**: `ComplaintDetailScreen` (`StatefulWidget`)  
- **URL / Route**: Not a named route; requires `complaintId`  
- **Screenshot (Simulated)**:
  - Complaint number, status, subject, description
  - Citizen name/email, submitted date
  - Optional attached photo preview
  - Responses list (officer/admin replies)
- **Behavior**:
  - `GET /api/complaints/{id}`
  - `GET /api/complaints/{id}/responses`

---

### 4.2 Officer-Side Screens

#### 4.2.1 Officer Dashboard (Enhanced)
- **Page Name**: Officer Portal Dashboard  
- **Widget Name**: `OfficerDashboardEnhanced` (`StatefulWidget`)  
- **API Endpoint used**: `GET /api/applications/assigned`  
- **Screenshot (Simulated)**: Stats cards; chart; filters; list of assigned applications.  
- **Admin/Officer actions**:
  - Open application review.
  - Manage complaints.
  - Logout.

#### 4.2.2 Application Review
- **Page Name**: Review Application  
- **Widget Name**: `ApplicationReviewScreen` (`StatefulWidget`)  
- **API Endpoints used**:
  - `GET /api/applications/{id}`
  - `POST /api/applications/{id}/approve`
  - `POST /api/applications/{id}/reject`
- **Validation logic (client-side)**:
  - Rejection requires `rejection_reason`.
  - Some services require **certificate type selection** and/or **value input** (validated via `CertificateTypeHelper`).
- **Approve sample payload**:
  - `remarks`: `Application approved`
  - `certificate_type`: `Annual Income: ₹2,50,001 - ₹5,00,000`
  - `certificate_value`: `300000`
- **Reject sample payload**:
  - `rejection_reason`: `Incomplete documents`
  - `remarks`: `Please upload Aadhaar document`

#### 4.2.3 Complaints Management
- **Page Name**: Complaints Management  
- **Widget Name**: `ComplaintsManagementScreen` (`StatefulWidget`)  
- **API Endpoints used**:
  - `GET /api/complaints` (optional `?status=open|in_progress|resolved|closed`)
  - Uses `ComplaintDetailScreen(isOfficerView: true)` for updates/responses.
- **Admin actions (Officer)**:
  - Filter and open complaint.
  - Update status.
  - Add response text.

#### 4.2.4 Complaint Details (Officer View)
- **Page Name**: Complaint Details (Officer/Admin)  
- **Widget Name**: `ComplaintDetailScreen` (`StatefulWidget`) with `isOfficerView: true`  
- **API Endpoints used**:
  - `PUT /api/complaints/{id}/status`
  - `POST /api/complaints/{id}/response`
- **Validation logic**:
  - Response must not be empty.
  - Status must be one of `open`, `in_progress`, `resolved`, `closed`.

---

### 4.3 Admin-Side Screens

#### 4.3.1 Admin Dashboard (Enhanced)
- **Page Name**: Admin Portal Dashboard  
- **Widget Name**: `AdminDashboardEnhanced` (`StatefulWidget`)  
- **API Endpoint used**: `GET /api/admin/dashboard`  
- **Screenshot (Simulated)**:
  - Quick statistics grid
  - Charts: applications by status, users by role, complaints by status
  - Management grid links to Departments/Users/Services/Applications/Complaints
  - Recent applications list

#### 4.3.2 Departments Management
- **Page Name**: Departments  
- **Widget Name**: `DepartmentsScreen` (`StatefulWidget`)  
- **API Endpoints used**:
  - `GET /api/admin/departments`
  - `POST /api/admin/departments`
- **Admin actions**:
  - Create department with:
    - Name (required)
    - Code (optional)
    - Description (optional)

#### 4.3.3 Users Management
- **Page Name**: Users  
- **Widget Name**: `UsersScreen` (`StatefulWidget`)  
- **API Endpoints used**:
  - `GET /api/admin/users` (optional `?role=citizen|officer|admin`)
  - `POST /api/admin/users`
- **Admin actions**:
  - Create users:
    - Role selection determines `role_id`:
      - `citizen` → 1
      - `officer` → 2
      - `admin` → 3
    - Department required for officer/admin in UI flow.

#### 4.3.4 Services Management
- **Page Name**: Services Management  
- **Widget Name**: `ServicesManagementScreen` (`StatefulWidget`)  
- **API Endpoints used**:
  - `GET /api/services`
  - `POST /api/services` (Admin only)
- **Admin actions**:
  - Create service with:
    - `department_id` (required)
    - `name` (required)
    - `code`, `description`, `required_documents`, `processing_days`, `fee` (optional)

#### 4.3.5 Applications Management
- **Page Name**: All Applications  
- **Widget Name**: `ApplicationsScreen` (`StatefulWidget`)  
- **API Endpoint used**: `GET /api/applications` (optional `?status=`)  
- **Admin actions**:
  - View all applications and open `ApplicationReviewScreen` for decisioning.

#### 4.3.6 Certificate Templates Management
- **Page Name**: Certificate Templates  
- **Widget Name**: `CertificateTemplatesScreen` (`StatefulWidget`)  
- **API Endpoints used**:
  - `GET /api/admin/certificate-templates`
  - `POST /api/admin/certificate-templates` (multipart)
- **Admin actions**:
  - Upload image/SVG template.
  - Choose service association (optional).
  - Configure overlay text fields using `TemplateVisualEditor`.

#### 4.3.7 Template Visual Editor
- **Page Name**: Configure Template Fields (Visual)  
- **Widget Name**: `TemplateVisualEditor` (`StatefulWidget`)  
- **API Endpoint used**: Used indirectly (returns a field-config map that is uploaded with template).  
- **Description**:
  - Admin selects fields (applicant name, application number, service name, date of issue, department, etc.).
  - Positions are stored as:
    - `position: { x, y }`
    - `fontSize`, `fontWeight`, `color: [r,g,b]`

#### 4.3.8 Template Visual Editor (Alternative)
- **Page Name**: Configure Template Fields (Fixed alternative)  
- **Widget Name**: `TemplateVisualEditorFixed` (`StatefulWidget`)  
- **Description**:
  - Similar purpose; uses screen coordinates directly (simpler approach).

#### 4.3.9 Template Field Config Screen
- **Page Name**: Configure Template Fields (Form)  
- **Widget Name**: `TemplateFieldConfigScreen` (`StatefulWidget`)  
- **Description**:
  - Manual X/Y + font size per field (non-visual).

---

## 5. API Documentation (Backend)

### 5.0 Base URL and Routing
Flutter is configured with:
- **Base URL**: `http://10.0.2.2/civicore/backend`

Requests are executed using query-route fallback:
- **Actual request URL format**:  
  `http://10.0.2.2/civicore/backend/index.php?route=/api/...`

### 5.1 API Summary Table
| Endpoint | Method | Auth | Role | Description |
|---|---|---|---|---|
| `/api/debug` | ANY | No | Public (dev) | Debug route echo (router diagnostic) |
| `/api/auth/register` | POST | No | Public | Register citizen account |
| `/api/auth/login` | POST | No | Public | Login and get JWT |
| `/api/services` | GET | No | Public | List active services |
| `/api/services/{id}` | GET | No | Public | Get service details |
| `/api/services` | POST | Yes | Admin | Create new service |
| `/api/services/{id}` | PUT | Yes | Admin | Update service |
| `/api/applications` | GET | Yes | Officer/Admin | List all applications |
| `/api/applications` | POST | Yes | Citizen/Admin | Create application |
| `/api/applications/my-applications` | GET | Yes | Citizen/Admin | Citizen’s own applications |
| `/api/applications/assigned` | GET | Yes | Officer/Admin | Officer’s assigned applications |
| `/api/applications/{id}` | GET | Yes | All roles | Get application detail (with access rules) |
| `/api/applications/{id}/assign` | POST | Yes | Admin | Assign to officer |
| `/api/applications/{id}/approve` | POST | Yes | Officer/Admin | Approve application |
| `/api/applications/{id}/reject` | POST | Yes | Officer/Admin | Reject application |
| `/api/documents/upload` | POST | Yes | Citizen/Admin | Upload application document |
| `/api/documents/{id}` | GET | Yes | All roles | Get document metadata (access rules) |
| `/api/documents/{id}/download` | GET | Yes | All roles | Download document file |
| `/api/complaints` | GET | Yes | Officer/Admin | List all complaints |
| `/api/complaints` | POST | Yes | Citizen/Admin | Create complaint (supports photo) |
| `/api/complaints/my-complaints` | GET | Yes | Citizen/Admin | Citizen’s own complaints |
| `/api/complaints/{id}` | GET | Yes | All roles | Get complaint detail (access rules) |
| `/api/complaints/{id}/status` | PUT | Yes | Officer/Admin | Update complaint status |
| `/api/complaints/{id}/response` | POST | Yes | Officer/Admin | Add response |
| `/api/complaints/{id}/responses` | GET | Yes | All roles | List responses |
| `/api/complaints/{id}/assign` | PUT | Yes | Admin | Assign complaint to officer |
| `/api/admin/dashboard` | GET | Yes | Admin | Dashboard analytics |
| `/api/admin/departments` | GET | Yes | Admin | List departments |
| `/api/admin/departments` | POST | Yes | Admin | Create department |
| `/api/admin/users` | GET | Yes | Admin | List users |
| `/api/admin/users` | POST | Yes | Admin | Create user |
| `/api/admin/users/{id}` | PUT | Yes | Admin | Update user |
| `/api/admin/audit-logs` | GET | Yes | Admin | List audit logs |
| `/api/admin/certificate-templates` | GET | Yes | Any auth | List templates (optional `service_id`) |
| `/api/admin/certificate-templates` | POST | Yes | Admin | Upload template (multipart) |

### 5.1.1 Debug Endpoint (Development Only)
- **Endpoint**: `/api/debug` (or `/debug`)
- **Method**: Any
- **Description**: Returns the routed URI, request method, and received GET/POST values. Useful to confirm that route parsing works in the current server configuration.

### 5.2 Authentication APIs

#### 5.2.1 Register
- **Endpoint**: `/api/auth/register`
- **Method**: POST
- **Request Body (JSON)**:
```json
{
  "email": "citizen1@example.com",
  "password": "citizen123",
  "full_name": "Rajesh Kumar",
  "phone": "9876543210",
  "aadhaar_number": "123456789012",
  "address": "123 Main Street, City",
  "date_of_birth": "1990-05-15"
}
```
- **Success Response (201)**:
```json
{
  "success": true,
  "message": "Registration successful",
  "token": "<jwt>",
  "user": { "id": 10, "email": "citizen1@example.com", "full_name": "Rajesh Kumar", "role": "citizen" }
}
```
- **Validation**:
  - Requires `email`, `password`, `full_name`.
  - Rejects duplicate email.

#### 5.2.2 Login
- **Endpoint**: `/api/auth/login`
- **Method**: POST
- **Request Body (JSON)**:
```json
{ "email": "admin@civicore.gov", "password": "admin123" }
```
- **Success Response (200)**:
```json
{
  "success": true,
  "message": "Login successful",
  "token": "<jwt>",
  "user": { "id": 1, "email": "admin@civicore.gov", "full_name": "System Administrator", "role": "admin", "department": null }
}
```

### 5.3 Service APIs

#### 5.3.1 Get All Services
- **Endpoint**: `/api/services`
- **Method**: GET
- **Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Birth Certificate",
      "code": "BC001",
      "description": "Official birth certificate issuance",
      "required_documents": "Aadhaar Card, Hospital Certificate",
      "processing_days": 5,
      "fee": "0.00",
      "department_name": "Civil Registration"
    }
  ]
}
```

#### 5.3.2 Create Service (Admin)
- **Endpoint**: `/api/services`
- **Method**: POST
- **Auth**: Bearer JWT (Admin)
- **Request Body**:
```json
{
  "name": "Residence Certificate",
  "department_id": 1,
  "code": "RC001",
  "description": "Proof of residence certificate",
  "required_documents": "Aadhaar Card, Utility Bills",
  "processing_days": 3,
  "fee": 0
}
```

### 5.4 Application APIs

#### 5.4.1 Create Application
- **Endpoint**: `/api/applications`
- **Method**: POST
- **Auth**: Citizen/Admin
- **Request Body**:
```json
{ "service_id": 2 }
```
- **Response (201)**:
```json
{
  "success": true,
  "message": "Application created successfully",
  "data": { "id": 21, "application_number": "APP20260012" }
}
```

#### 5.4.2 Get Application Details (with documents + logs)
- **Endpoint**: `/api/applications/{id}`
- **Method**: GET
- **Auth**: All roles (with access rules)
- **Response (200)** (simplified):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "application_number": "APP2024001",
    "status": "approved",
    "service_id": 1,
    "service_name": "Birth Certificate",
    "service_code": "BC001",
    "department_name": "Civil Registration",
    "citizen_name": "Rajesh Kumar",
    "officer_name": "Officer John Doe",
    "documents": [
      { "id": 3, "document_name": "aadhaar.pdf", "file_path": "uploads/doc_1_...", "file_type": "application/pdf", "file_size": 120000, "uploaded_at": "2024-01-15 11:00:00" }
    ],
    "logs": [
      { "action": "Application Submitted", "old_status": null, "new_status": "pending", "created_at": "2024-01-15 10:00:00" }
    ]
  }
}
```

#### 5.4.3 Approve Application
- **Endpoint**: `/api/applications/{id}/approve`
- **Method**: POST
- **Auth**: Officer/Admin
- **Request Body**:
```json
{
  "remarks": "All documents verified and approved",
  "certificate_type": "Annual Income: ₹2,50,001 - ₹5,00,000",
  "certificate_value": "300000"
}
```

#### 5.4.4 Reject Application
- **Endpoint**: `/api/applications/{id}/reject`
- **Method**: POST
- **Auth**: Officer/Admin
- **Request Body**:
```json
{
  "rejection_reason": "Incomplete documents",
  "remarks": "Please upload Aadhaar document"
}
```

### 5.5 Document APIs

#### 5.5.1 Upload Document
- **Endpoint**: `/api/documents/upload`
- **Method**: POST
- **Auth**: Citizen/Admin
- **Request Body**: `multipart/form-data`
  - `application_id`: `1`
  - `document`: file (PDF/JPG/PNG), max size 5MB
- **Response**:
```json
{
  "success": true,
  "message": "Document uploaded successfully",
  "data": { "id": 8, "file_path": "uploads/doc_1_..." }
}
```

### 5.6 Complaint APIs

#### 5.6.1 Create Complaint (JSON or Multipart)
- **Endpoint**: `/api/complaints`
- **Method**: POST
- **Auth**: Citizen/Admin
- **JSON Request**:
```json
{ "subject": "Delayed Certificate", "description": "Application taking longer than expected." }
```
- **Multipart Request** (optional photo):
  - `subject`, `description`, `photo`

#### 5.6.2 Add Complaint Response (Officer/Admin)
- **Endpoint**: `/api/complaints/{id}/response`
- **Method**: POST
- **Request Body**:
```json
{ "response": "We are reviewing your request.", "update_status": "in_progress" }
```

### 5.7 Admin APIs

#### 5.7.1 Dashboard Analytics
- **Endpoint**: `/api/admin/dashboard`
- **Method**: GET
- **Response Data Sections**:
  - `applications`: counts by status
  - `users`: counts by role
  - `complaints`: counts by status
  - `recent_applications`: last 10 applications

### 5.8 User Profile APIs

#### 5.8.1 Get Profile
- **Endpoint**: `/api/user/profile`
- **Method**: GET
- **Response**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "email": "citizen1@example.com",
    "full_name": "Rajesh Kumar",
    "phone": "9876543210",
    "profile_picture": "uploads/profiles/profile_2_...",
    "role": "citizen",
    "department": null
  }
}
```

#### 5.8.2 Update Profile (with optional profile picture)
- **Endpoint**: `/api/user/profile`
- **Method**: POST
- **Request**: `multipart/form-data`
  - `full_name`, `phone`, optional `profile_picture`

### 5.9 Certificate Template APIs

#### 5.9.1 Upload Template (Admin)
- **Endpoint**: `/api/admin/certificate-templates`
- **Method**: POST
- **Request**: `multipart/form-data`
  - `name`: template name
  - `service_id`: optional
  - `field_config`: JSON string of overlay configs
  - `template`: image/SVG file

#### 5.9.2 Get Templates (Any authenticated user)
- **Endpoint**: `/api/admin/certificate-templates`
- **Method**: GET
- **Query Param**: `service_id` (optional)

---

## 6. Database Structure (MySQL)

### 6.1 Core Tables (from `database/civicore.sql`)

#### 6.1.1 `roles`
| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | Role ID |
| `name` | VARCHAR(50) | `citizen`, `officer`, `admin` |
| `description` | TEXT | Role description |
| `created_at` | TIMESTAMP | Created time |
| `updated_at` | TIMESTAMP | Updated time |

#### 6.1.2 `departments`
| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | Department ID |
| `name` | VARCHAR(100) | Department name |
| `code` | VARCHAR(20) | Department code (unique) |
| `description` | TEXT | Description |
| `is_active` | BOOLEAN | Active/inactive |
| `created_at` | TIMESTAMP | Created time |
| `updated_at` | TIMESTAMP | Updated time |

#### 6.1.3 `users`
| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | User ID |
| `role_id` | INT (FK roles.id) | Role assignment |
| `department_id` | INT (FK departments.id) | Officer/Admin department (nullable) |
| `email` | VARCHAR(100) | Unique login email |
| `password` | VARCHAR(255) | bcrypt hash |
| `full_name` | VARCHAR(100) | User name |
| `phone` | VARCHAR(20) | Phone number |
| `aadhaar_number` | VARCHAR(12) | Unique Aadhaar (optional) |
| `address` | TEXT | Address (optional) |
| `date_of_birth` | DATE | DOB (optional) |
| `is_active` | BOOLEAN | Account active |
| `email_verified` | BOOLEAN | Email verification |
| `created_at` | TIMESTAMP | Created time |
| `updated_at` | TIMESTAMP | Updated time |

#### 6.1.4 `services`
| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | Service ID |
| `department_id` | INT (FK departments.id) | Owning department |
| `name` | VARCHAR(100) | Service name |
| `code` | VARCHAR(50) | Unique service code (e.g., `BC001`) |
| `description` | TEXT | Details |
| `required_documents` | TEXT | Document checklist |
| `processing_days` | INT | Expected processing time |
| `fee` | DECIMAL(10,2) | Service fee |
| `is_active` | BOOLEAN | Service active |
| `created_at` | TIMESTAMP | Created time |
| `updated_at` | TIMESTAMP | Updated time |

#### 6.1.5 `applications`
| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | Application ID |
| `application_number` | VARCHAR(50) | Unique tracking no. (e.g., `APP2024001`) |
| `citizen_id` | INT (FK users.id) | Applicant |
| `service_id` | INT (FK services.id) | Requested service |
| `officer_id` | INT (FK users.id) | Assigned officer (nullable) |
| `status` | ENUM | `pending`, `under_review`, `approved`, `rejected` |
| `remarks` | TEXT | Officer remarks |
| `rejection_reason` | TEXT | Rejection reason |
| `applied_date` | TIMESTAMP | Submitted date |
| `reviewed_date` | TIMESTAMP | Review start/decision time |
| `approved_date` | TIMESTAMP | Approval time |
| `certificate_path` | VARCHAR(255) | Placeholder certificate path |
| `created_at` | TIMESTAMP | Created time |
| `updated_at` | TIMESTAMP | Updated time |

#### 6.1.6 `application_documents`
| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | Document ID |
| `application_id` | INT (FK applications.id) | Application |
| `document_name` | VARCHAR(255) | Original filename |
| `file_path` | VARCHAR(255) | Relative server path (`uploads/...`) |
| `file_type` | VARCHAR(50) | MIME type |
| `file_size` | INT | Bytes |
| `uploaded_at` | TIMESTAMP | Upload time |

#### 6.1.7 `application_logs`
| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | Log ID |
| `application_id` | INT (FK applications.id) | Application |
| `user_id` | INT (FK users.id) | Actor user |
| `action` | VARCHAR(100) | Action label |
| `old_status` | VARCHAR(50) | Old status |
| `new_status` | VARCHAR(50) | New status |
| `remarks` | TEXT | Remarks |
| `created_at` | TIMESTAMP | Time |

#### 6.1.8 `complaints`
| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | Complaint ID |
| `complaint_number` | VARCHAR(50) | Unique tracking no. |
| `citizen_id` | INT (FK users.id) | Citizen |
| `subject` | VARCHAR(255) | Complaint subject |
| `description` | TEXT | Complaint details |
| `status` | ENUM | `open`, `in_progress`, `resolved`, `closed` |
| `assigned_to` | INT (FK users.id) | Officer assigned |
| `resolution` | TEXT | Resolution notes |
| `created_at` | TIMESTAMP | Submitted time |
| `updated_at` | TIMESTAMP | Updated time |
| `resolved_at` | TIMESTAMP | Resolved time |

#### 6.1.9 `audit_logs`
| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | Audit ID |
| `user_id` | INT (FK users.id) | Actor user |
| `action` | VARCHAR(100) | Action code (LOGIN, CREATE_USER, etc.) |
| `entity_type` | VARCHAR(50) | Entity type (user/service/application/complaint) |
| `entity_id` | INT | Entity id |
| `details` | TEXT | Details |
| `ip_address` | VARCHAR(45) | IP |
| `user_agent` | TEXT | Client user-agent |
| `created_at` | TIMESTAMP | Time |

### 6.2 Optional/Runtime-Created Tables

#### 6.2.1 `complaint_responses` (created automatically if missing)
Created by backend when first response is posted.

| Field | Type | Description |
|---|---|---|
| `id` | INT (PK, AI) | Response ID |
| `complaint_id` | INT (FK complaints.id) | Complaint |
| `user_id` | INT (FK users.id) | Responder |
| `response` | TEXT | Response text |
| `created_at` | TIMESTAMP | Time |

### 6.3 Alter Scripts (Feature Additions)
| SQL File | Change |
|---|---|
| `database/add_profile_picture.sql` | Adds `users.profile_picture` |
| `database/add_complaint_photo.sql` | Adds `complaints.photo_path` |
| `database/add_certificate_type.sql` | Adds `applications.certificate_type` |
| `database/add_certificate_value.sql` | Adds `applications.certificate_value` |

---

## 7. End-to-End Workflows (Beginner-Friendly)

### 7.1 Citizen: Register → Login → Apply → Upload Docs → Track
1. Open app → Splash → Login.
2. If new user: Register → submit required fields.
3. Login → citizen dashboard.
4. Go to Services → choose service → Apply.
5. Open Application Details → Upload required documents.
6. Track status timeline until Approved/Rejected.
7. If approved: “Download Certificate” opens printable PDF.

### 7.2 Officer: Assigned Applications → Review → Approve/Reject
1. Officer logs in.
2. Dashboard shows assigned applications.
3. Open an application → review citizen/service data.
4. Approve:
   - Select certificate type (if required)
   - Enter certificate value (if required)
   - Submit remarks
5. Reject:
   - Enter rejection reason (mandatory)
   - Submit optional remarks

### 7.3 Complaint Lifecycle: Submit → Track → Response → Resolve
1. Citizen submits complaint (optional photo).
2. Citizen views complaint status on complaints list.
3. Officer/admin responds and can update status.
4. Citizen reads responses; status changes to resolved/closed.

### 7.4 Admin: Dashboard → Manage → Monitor
1. Admin logs in → dashboard analytics loads.
2. Admin creates departments.
3. Admin creates users and assigns departments for officers.
4. Admin creates services.
5. Admin monitors applications and complaints.
6. Audit logs provide traceability for critical actions.

---

## 8. Deployment & Environment Setup (Local XAMPP + Flutter)

### 8.1 Backend Setup (XAMPP)
1. Place project in `C:\xampp\htdocs\civicore`.
2. Start **Apache** and **MySQL** in XAMPP Control Panel.
3. Create database and schema:
   - Import `database/civicore.sql` in phpMyAdmin.
   - (Optional) import:
     - `database/add_profile_picture.sql`
     - `database/add_complaint_photo.sql`
     - `database/add_certificate_type.sql`
     - `database/add_certificate_value.sql`
   - (Optional) import `database/sample_data.sql`.

### 8.2 Flutter Setup
1. Ensure Flutter SDK is installed and configured.
2. Verify `ApiConstants.baseUrl`:
   - Emulator: `http://10.0.2.2/civicore/backend`
   - Windows desktop (if needed): `http://localhost/civicore/backend`
3. Install dependencies:
   - `flutter pub get`
4. Run app:
   - `flutter run`

---

## 9. Appendix

### 9.1 Sample Data (from `database/sample_data.sql`)
The repository includes test users and data.

**Sample credentials (password hash indicates `admin123` commonly used in seed scripts)**
- Admin:
  - Email: `admin@civicore.gov`
  - Password: `admin123`
- Officers:
  - `officer1@civicore.gov`
  - `officer2@civicore.gov`
- Citizens:
  - `citizen1@example.com`
  - `citizen2@example.com`

### 9.2 Common Error Messages and Meaning
| Message | Typical Cause | Fix |
|---|---|---|
| `Cannot connect to server... ensure XAMPP Apache is running` | Apache not running / wrong base URL | Start Apache; verify `ApiConstants.baseUrl` |
| `Unauthorized` | Missing/expired JWT | Login again; verify token saved in SharedPreferences |
| `Forbidden - Insufficient permissions` | Wrong role accessing admin/officer APIs | Use correct account role |
| `Invalid file type...` | Upload MIME type not allowed | Upload PDF/JPG/PNG only |
| `File size exceeds 5MB limit` | Document/photo too large | Compress or select smaller file |

