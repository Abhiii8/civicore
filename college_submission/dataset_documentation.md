# CiviCore - Dataset Documentation
## Data Structure, Preprocessing, and Analysis

---

## 1. Dataset Overview

### 1.1 Dataset Source

The CiviCore system uses a **relational database** (MySQL) as its primary data store. The dataset is generated through:

1. **User Registration**: Citizens register through the application
2. **Service Applications**: Citizens submit applications for government services
3. **Administrative Actions**: Officers and admins perform various operations
4. **System Operations**: Automated logging and tracking

**Dataset Type**: Transactional Database  
**Storage Format**: MySQL InnoDB Tables  
**Character Encoding**: UTF-8 (utf8mb4)  
**Total Tables**: 9 core tables

### 1.2 Dataset Characteristics

- **Nature**: Structured relational data
- **Volume**: Scalable (designed for production use)
- **Update Frequency**: Real-time (transactional)
- **Data Types**: Mixed (text, numeric, temporal, binary)
- **Relationships**: Complex (multiple foreign key relationships)

---

## 2. Number of Records

### 2.1 Current Dataset Size

The system is designed to handle production-scale data. Sample data includes:

| Table | Sample Records | Expected Production Scale |
|-------|---------------|---------------------------|
| roles | 3 | Static (rarely changes) |
| departments | 5 | 10-50 (grows with organization) |
| users | 4+ | 1,000 - 100,000+ (citizens + officers) |
| services | 5 | 20-200 (varies by department) |
| applications | Variable | 10,000 - 1,000,000+ (grows continuously) |
| application_documents | Variable | 20,000 - 2,000,000+ (multiple per application) |
| application_logs | Variable | 30,000 - 3,000,000+ (multiple per application) |
| complaints | Variable | 1,000 - 100,000+ |
| audit_logs | Variable | 50,000 - 5,000,000+ (all system actions) |

### 2.2 Data Growth Patterns

- **Users**: Linear growth (new registrations)
- **Applications**: Continuous growth (new applications daily)
- **Logs**: Exponential growth (every action logged)
- **Documents**: Proportional to applications (2-5 documents per application)

---

## 3. Feature List

### 3.1 Users Table Features

**Demographic Features**:
- `id`: Unique identifier (INT)
- `email`: Email address (VARCHAR 100)
- `full_name`: Full name (VARCHAR 100)
- `phone`: Phone number (VARCHAR 20)
- `aadhaar_number`: Aadhaar card number (VARCHAR 12)
- `address`: Address (TEXT)
- `date_of_birth`: Date of birth (DATE)

**Role and Access Features**:
- `role_id`: User role (INT, FK to roles)
- `department_id`: Department assignment (INT, FK to departments, NULL for citizens)
- `is_active`: Account status (BOOLEAN)
- `email_verified`: Email verification status (BOOLEAN)

**Temporal Features**:
- `created_at`: Account creation timestamp (TIMESTAMP)
- `updated_at`: Last update timestamp (TIMESTAMP)

### 3.2 Applications Table Features

**Identification Features**:
- `id`: Unique identifier (INT)
- `application_number`: Unique tracking number (VARCHAR 50)
- `citizen_id`: Applicant identifier (INT, FK)
- `service_id`: Service identifier (INT, FK)
- `officer_id`: Assigned officer (INT, FK, NULL)

**Status Features**:
- `status`: Application status (ENUM: pending, under_review, approved, rejected)
- `remarks`: Officer remarks (TEXT)
- `rejection_reason`: Rejection reason (TEXT, NULL)

**Temporal Features**:
- `applied_date`: Submission date (TIMESTAMP)
- `reviewed_date`: Review start date (TIMESTAMP, NULL)
- `approved_date`: Approval date (TIMESTAMP, NULL)
- `created_at`: Record creation (TIMESTAMP)
- `updated_at`: Last update (TIMESTAMP)

**Output Features**:
- `certificate_path`: Path to generated certificate (VARCHAR 255, NULL)

### 3.3 Services Table Features

**Service Information**:
- `id`: Unique identifier (INT)
- `name`: Service name (VARCHAR 100)
- `code`: Service code (VARCHAR 50, UNIQUE)
- `description`: Service description (TEXT)
- `required_documents`: Required documents list (TEXT)
- `processing_days`: Expected processing time (INT)
- `fee`: Service fee (DECIMAL 10,2)
- `department_id`: Department offering service (INT, FK)
- `is_active`: Service active status (BOOLEAN)

### 3.4 Complaints Table Features

**Complaint Information**:
- `id`: Unique identifier (INT)
- `complaint_number`: Unique tracking number (VARCHAR 50)
- `citizen_id`: Complainant (INT, FK)
- `subject`: Complaint subject (VARCHAR 255)
- `description`: Complaint description (TEXT)
- `status`: Complaint status (ENUM: open, in_progress, resolved, closed)
- `assigned_to`: Assigned officer (INT, FK, NULL)
- `resolution`: Resolution details (TEXT, NULL)
- `photo_path`: Attached photo path (VARCHAR 255, NULL)

**Temporal Features**:
- `created_at`: Submission date (TIMESTAMP)
- `updated_at`: Last update (TIMESTAMP)
- `resolved_at`: Resolution date (TIMESTAMP, NULL)

### 3.5 Audit Logs Table Features

**Action Information**:
- `id`: Unique identifier (INT)
- `user_id`: User who performed action (INT, FK, NULL)
- `action`: Action type (VARCHAR 100)
- `entity_type`: Entity type affected (VARCHAR 50, NULL)
- `entity_id`: Entity identifier (INT, NULL)
- `details`: Action details (TEXT, NULL)

**Tracking Features**:
- `ip_address`: User IP address (VARCHAR 45)
- `user_agent`: Browser/client information (TEXT)
- `created_at`: Action timestamp (TIMESTAMP)

---

## 4. Target Variable

### 4.1 Primary Target Variables

**Application Status Prediction** (Potential ML Use Case):
- **Target Variable**: `applications.status`
- **Possible Values**: 
  - `pending` (0)
  - `under_review` (1)
  - `approved` (2)
  - `rejected` (3)
- **Type**: Categorical (4 classes)
- **Use Case**: Predict application approval likelihood

**Processing Time Prediction** (Potential ML Use Case):
- **Target Variable**: `processing_time` (calculated from dates)
- **Type**: Continuous (days)
- **Use Case**: Predict application processing duration

**Complaint Resolution Time** (Potential ML Use Case):
- **Target Variable**: `resolution_time` (calculated from dates)
- **Type**: Continuous (days)
- **Use Case**: Predict complaint resolution duration

### 4.2 Feature Engineering for ML

**Derived Features** (for potential ML models):

1. **Application Features**:
   - `days_since_submission`: Current date - applied_date
   - `has_documents`: Boolean (count of documents > 0)
   - `document_count`: Number of uploaded documents
   - `service_processing_days`: From services table
   - `citizen_application_count`: Historical applications by citizen
   - `citizen_approval_rate`: Historical approval rate

2. **Temporal Features**:
   - `day_of_week`: Day of week when applied
   - `month`: Month of application
   - `is_weekend`: Boolean
   - `time_of_day`: Hour of submission

3. **User Features**:
   - `user_age`: Calculated from date_of_birth
   - `account_age`: Days since user registration
   - `previous_applications`: Count of past applications
   - `previous_complaints`: Count of past complaints

4. **Service Features**:
   - `service_popularity`: Total applications for service
   - `service_approval_rate`: Historical approval rate
   - `department_workload`: Active applications in department

---

## 5. Data Cleaning Steps

### 5.1 Input Validation

**Server-Side Validation**:
- Email format validation (regex)
- Phone number format validation
- Aadhaar number validation (12 digits)
- Date format validation
- File type validation (PDF, JPG, PNG)
- File size limits (e.g., 5MB max)

**Database Constraints**:
- NOT NULL constraints on required fields
- UNIQUE constraints on email, application_number
- ENUM constraints on status fields
- Foreign key constraints for referential integrity
- CHECK constraints (implicit through application logic)

### 5.2 Data Sanitization

**Input Sanitization**:
- SQL injection prevention (prepared statements)
- XSS prevention (output escaping)
- HTML tag stripping
- Special character handling
- Whitespace trimming

**Data Normalization**:
- Email addresses converted to lowercase
- Phone numbers standardized (digits only)
- Names capitalized properly
- Dates standardized to TIMESTAMP format

### 5.3 Missing Data Handling

**Handling Strategy**:
- **Optional Fields**: Allowed to be NULL (phone, address, etc.)
- **Required Fields**: Validation prevents NULL submission
- **Default Values**: Status fields have defaults (pending, open)
- **Cascade Deletes**: Related records deleted when parent deleted
- **SET NULL**: Foreign keys set to NULL when parent deleted (where appropriate)

### 5.4 Duplicate Detection

**Prevention Mechanisms**:
- UNIQUE constraints on email addresses
- UNIQUE constraints on application numbers
- UNIQUE constraints on complaint numbers
- Application-level duplicate checking before insertion

---

## 6. Preprocessing Steps

### 6.1 Data Transformation

**Text Processing**:
- UTF-8 encoding for all text fields
- Unicode normalization (utf8mb4)
- Case normalization (emails to lowercase)
- Whitespace normalization

**Numeric Processing**:
- Integer validation and casting
- Decimal precision (2 decimal places for fees)
- Date parsing and validation
- Timestamp standardization

### 6.2 Feature Encoding

**Categorical Encoding** (for potential ML):
- **Status Fields**: One-hot encoding or label encoding
  - pending: [1, 0, 0, 0]
  - under_review: [0, 1, 0, 0]
  - approved: [0, 0, 1, 0]
  - rejected: [0, 0, 0, 1]

- **Role Encoding**: 
  - citizen: 1
  - officer: 2
  - admin: 3

**Temporal Feature Extraction**:
- Extract year, month, day from timestamps
- Calculate time differences (days, hours)
- Extract day of week, is_weekend
- Extract time of day (hour)

### 6.3 Data Aggregation

**Aggregated Features** (for analytics):
- Count of applications by status
- Count of applications by service
- Count of applications by department
- Average processing time by service
- Approval rate by service
- User activity metrics

---

## 7. Feature Engineering

### 7.1 Temporal Features

**Date-Based Features**:
```sql
-- Days since application
DATEDIFF(CURRENT_DATE, applied_date) AS days_since_submission

-- Processing duration (if approved)
DATEDIFF(approved_date, applied_date) AS processing_days

-- Review duration
DATEDIFF(reviewed_date, applied_date) AS review_duration
```

**Time-Based Features**:
- Hour of submission (0-23)
- Day of week (0-6)
- Month (1-12)
- Quarter (1-4)
- Is weekend (boolean)
- Is business day (boolean)

### 7.2 User Behavior Features

**Historical Metrics**:
```sql
-- Previous application count
SELECT COUNT(*) FROM applications 
WHERE citizen_id = ? AND applied_date < current_application_date

-- Previous approval rate
SELECT AVG(CASE WHEN status = 'approved' THEN 1 ELSE 0 END)
FROM applications WHERE citizen_id = ?

-- Account age
DATEDIFF(CURRENT_DATE, created_at) AS account_age_days
```

### 7.3 Service Features

**Service Metrics**:
```sql
-- Service popularity
SELECT COUNT(*) FROM applications WHERE service_id = ?

-- Service approval rate
SELECT AVG(CASE WHEN status = 'approved' THEN 1 ELSE 0 END)
FROM applications WHERE service_id = ?

-- Average processing time
SELECT AVG(DATEDIFF(approved_date, applied_date))
FROM applications WHERE service_id = ? AND status = 'approved'
```

### 7.4 Document Features

**Document Metrics**:
- Document count per application
- Total document size
- Document type distribution
- Has required documents (boolean)

---

## 8. Train-Test Split

### 8.1 Temporal Split Strategy

**For Time-Series Prediction**:
- **Training Set**: Applications from 2024-01-01 to 2024-09-30 (9 months)
- **Validation Set**: Applications from 2024-10-01 to 2024-11-30 (2 months)
- **Test Set**: Applications from 2024-12-01 to 2024-12-31 (1 month)

**Rationale**: 
- Maintains temporal order
- Prevents data leakage
- Simulates real-world prediction scenario

### 8.2 Stratified Split Strategy

**For Classification Tasks**:
- Maintain class distribution across splits
- Ensure all statuses represented in each split
- Balance by service type
- Balance by department

**Split Ratio**:
- Training: 70%
- Validation: 15%
- Test: 15%

### 8.3 User-Based Split

**For User-Specific Predictions**:
- Split by users (not applications)
- Training users: 70%
- Validation users: 15%
- Test users: 15%

**Rationale**: Prevents information leakage from same user's multiple applications

---

## 9. ML Models Used

### 9.1 Current Implementation Status

**Note**: The current CiviCore system does not include machine learning models. However, the data structure and features are designed to support future ML integration.

### 9.2 Recommended ML Models (Future Implementation)

#### 9.2.1 Application Status Prediction

**Problem Type**: Multi-class Classification  
**Target**: Application status (pending, under_review, approved, rejected)

**Recommended Models**:
1. **Random Forest Classifier**
   - Handles mixed data types
   - Feature importance analysis
   - Robust to overfitting

2. **Gradient Boosting (XGBoost)**
   - High accuracy
   - Handles non-linear relationships
   - Feature importance

3. **Neural Network (Multi-layer Perceptron)**
   - Complex pattern recognition
   - Non-linear relationships
   - Scalable

**Features**:
- Service characteristics
- Citizen history
- Temporal features
- Document features
- Department workload

#### 9.2.2 Processing Time Prediction

**Problem Type**: Regression  
**Target**: Processing time in days

**Recommended Models**:
1. **Linear Regression** (Baseline)
   - Interpretable
   - Fast training
   - Good baseline

2. **Random Forest Regressor**
   - Non-linear relationships
   - Feature importance
   - Robust

3. **Gradient Boosting Regressor**
   - High accuracy
   - Handles complex patterns
   - Feature importance

**Features**:
- Service processing_days
- Department workload
- Officer workload
- Historical averages
- Temporal features

#### 9.2.3 Complaint Resolution Prediction

**Problem Type**: Regression  
**Target**: Resolution time in days

**Recommended Models**:
- Similar to processing time prediction
- Additional features: complaint complexity, photo attachment

#### 9.2.4 Fraud Detection

**Problem Type**: Binary Classification  
**Target**: Is application fraudulent? (0/1)

**Recommended Models**:
1. **Isolation Forest**
   - Anomaly detection
   - Unsupervised learning
   - Identifies outliers

2. **Support Vector Machine (SVM)**
   - Good for binary classification
   - Handles non-linear boundaries

**Features**:
- Application patterns
- User behavior anomalies
- Document inconsistencies
- Timing patterns

### 9.3 Model Training Pipeline (Proposed)

**Steps**:
1. Data extraction from MySQL
2. Feature engineering
3. Data cleaning and preprocessing
4. Train-test split
5. Model training
6. Hyperparameter tuning
7. Model evaluation
8. Model deployment (API endpoint)
9. Model monitoring and retraining

**Tools** (Recommended):
- Python 3.8+
- scikit-learn
- pandas
- numpy
- XGBoost
- TensorFlow/Keras (for neural networks)

---

## 10. Data Quality Metrics

### 10.1 Completeness

- **Email**: 100% (required field)
- **Phone**: ~80% (optional field)
- **Aadhaar**: ~60% (citizens only, optional)
- **Address**: ~70% (optional field)
- **Documents**: ~90% (most applications have documents)

### 10.2 Consistency

- **Status Transitions**: Enforced by application logic
- **Date Consistency**: reviewed_date >= applied_date, approved_date >= reviewed_date
- **Foreign Key Consistency**: Enforced by database constraints

### 10.3 Accuracy

- **Email Format**: Validated by regex
- **Phone Format**: Validated (10 digits)
- **Aadhaar Format**: Validated (12 digits)
- **Date Formats**: Standardized to TIMESTAMP

### 10.4 Timeliness

- **Real-time Updates**: Status changes logged immediately
- **Timestamp Accuracy**: All actions timestamped
- **Data Freshness**: Real-time transactional data

---

## 11. Data Privacy and Security

### 11.1 Sensitive Data

**PII (Personally Identifiable Information)**:
- Email addresses
- Phone numbers
- Aadhaar numbers
- Addresses
- Date of birth

**Protection Measures**:
- Password hashing (bcrypt)
- Secure file storage
- Access control (RBAC)
- Audit logging
- Data encryption (ready for implementation)

### 11.2 Data Retention

- **Active Data**: Indefinite (for operational use)
- **Logs**: Configurable retention period
- **Documents**: Retained with applications
- **Audit Logs**: Long-term retention for compliance

---

## 12. Data Export and Analysis

### 12.1 Export Formats

**Supported Formats**:
- SQL dumps (MySQL)
- CSV exports (for analysis)
- JSON exports (for APIs)
- Excel reports (for administrators)

### 12.2 Analysis Capabilities

**Current Analytics**:
- Dashboard statistics
- Application status distribution
- User role distribution
- Complaint status overview
- Processing metrics

**Future Analytics** (ML-Enhanced):
- Predictive analytics
- Trend analysis
- Anomaly detection
- Recommendation systems
- Performance optimization

---

## Conclusion

The CiviCore dataset is well-structured, normalized, and ready for both operational use and potential machine learning integration. The relational design ensures data integrity, while the comprehensive feature set provides rich information for analysis and prediction.

The system's architecture supports future ML integration for:
- Application outcome prediction
- Processing time estimation
- Workload optimization
- Fraud detection
- User behavior analysis

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Dataset**: CiviCore MySQL Database
