# Week-8-Database-assignment-

# Library Management System Database

A comprehensive relational database system designed for managing library operations including book cataloging, member management, loan tracking, reservations, and financial transactions.

## 📋 Database Overview

This MySQL database provides a complete solution for library management with normalized tables, proper constraints, and optimized relationships.

## 🗃️ Database Schema

### Core Tables

#### 1. Members
Stores library member information including personal details and membership status.
- **Primary Key**: `member_id`
- **Unique Constraints**: `library_card_number`, `email`
- **Status Tracking**: Active, Suspended, Expired, Cancelled

#### 2. Books
Main catalog of books in the library collection.
- **Primary Key**: `book_id`
- **Unique Constraints**: `isbn`
- **Relationships**: Many-to-many with Authors, One-to-many with Publishers

#### 3. Book_Copies
Tracks individual physical copies of books.
- **Primary Key**: `copy_id`
- **Status**: Available, Checked Out, Reserved, Under Maintenance, Lost
- **Condition**: New, Good, Fair, Poor, Damaged

#### 4. Loans
Manages book borrowing transactions.
- **Primary Key**: `loan_id`
- **Status**: Active, Returned, Overdue, Lost
- **Automatic late fee calculation**

#### 5. Authors & Book_Authors
Author information and book-author relationships (many-to-many).
- **Junction Table**: `Book_Authors`

#### 6. Publishers
Publishing company information.

#### 7. Reservations
Book reservation system with priority queuing.

#### 8. Fines
Financial transactions for late returns and other penalties.

#### 9. Staff
Library personnel management.

#### 10. Loan_History
Archival table for completed loan transactions.

## 🔗 Relationships

### One-to-Many Relationships
- `Publishers` → `Books`
- `Members` → `Loans`
- `Members` → `Reservations`
- `Members` → `Fines`
- `Book_Copies` → `Loans`
- `Loans` → `Fines`

### Many-to-Many Relationships
- `Books` ↔ `Authors` (via `Book_Authors` junction table)

## 🛠️ Constraints Implemented

### Primary Keys
All tables have proper primary keys with auto-increment where appropriate.

### Foreign Keys
Referential integrity maintained through foreign key constraints with proper `ON DELETE` actions.

### Unique Constraints
- `Members`: library_card_number, email
- `Books`: isbn
- `Publishers`: name
- `Book_Copies`: barcode
- `Staff`: email

### Check Constraints
- Date validation (birth dates, publication dates, loan dates)
- Numeric validation (positive values for quantities, fees, etc.)
- Status field validation using ENUM types

### Default Values
- Timestamps for record creation and updates
- Default status values
- Zero values for financial fields

## 📊 Views

### Available_Books
Shows currently available books with copy counts:
```sql
SELECT * FROM Available_Books;


Overdue_Loans

Displays currently overdue loans with calculated days overdue:

```sql
SELECT * FROM Overdue_Loans;
```

🚀 Installation

1. Create the database:
   ```sql
   mysql -u username -p < library_management_system.sql
   ```
2. Or execute manually:
   ```sql
   SOURCE library_management_system.sql;
   ```

📝 Sample Queries

Find available books by genre

```sql
SELECT * FROM Available_Books WHERE genre = 'Fantasy';
```

Check member's current loans

```sql
SELECT m.first_name, m.last_name, b.title, l.checkout_date, l.due_date
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN Book_Copies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE m.member_id = 1 AND l.status = 'Active';
```

Calculate total fines for a member

```sql
SELECT m.first_name, m.last_name, SUM(f.amount) as total_fines
FROM Fines f
JOIN Members m ON f.member_id = m.member_id
WHERE m.member_id = 1 AND f.status = 'Outstanding'
GROUP BY m.member_id;
```

🔍 Indexes

Performance-optimized indexes on:

· Frequently searched fields (email, names, titles)
· Status fields for filtering
· Date fields for reporting
· Foreign key columns

📈 Features

· Member Management: Complete lifecycle from registration to membership expiration
· Inventory Control: Track multiple copies of books with condition monitoring
· Loan System: Automated due date calculation and late fee tracking
· Reservation System: Priority-based book reservations
· Financial Management: Fine assessment and payment tracking
· Reporting: Built-in views for common operational queries
· Data Integrity: Comprehensive constraint validation

🎯 Use Cases

· Public libraries
· School and university libraries
· Corporate library systems
· Special collection libraries
· Archive management

📊 Data Validation

The database includes extensive validation:

· Date range checking
· Email format validation (through application layer)
· Numeric value validation
· Status field validation
· Referential integrity enforcement

🔒 Security Considerations

· Sensitive data should be encrypted at application level
· Proper user role management recommended
· Regular database backups essential
· Audit logging implementation suggested

📋 Future Enhancements

· Digital resource management
· Integration with RFID systems
· Advanced reporting module
· Mobile application integration
· Predictive analytics for popular books

🛠️ Technical Specifications

· Database: MySQL 5.7+ / MySQL 8.0+
· Character Set: UTF-8
· Storage Engine: InnoDB (recommended)
· Collation: utf8_general_ci

📞 Support

For database structure questions or modification requests, please contact the database administrator.

---

Note: This database design follows Third Normal Form (3NF) principles ensuring data integrity and minimizing redundancy while maintaining optimal performance for library operations.