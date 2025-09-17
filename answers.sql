-- Library Management System Database
-- Created by: Josiah

-- Create the database
CREATE DATABASE IF NOT EXISTS LibraryManagementSystem;
USE LibraryManagementSystem;

-- Table 1: Members (Library Members)
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    library_card_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    date_of_birth DATE NOT NULL,
    membership_start_date DATE NOT NULL,
    membership_end_date DATE,
    membership_status ENUM('Active', 'Suspended', 'Expired', 'Cancelled') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CHECK (membership_start_date <= COALESCE(membership_end_date, '9999-12-31')),
    CHECK (date_of_birth <= CURDATE())
);

-- Table 2: Authors
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CHECK (birth_date <= COALESCE(death_date, '9999-12-31')),
    CHECK (death_date IS NULL OR birth_date <= death_date)
);

-- Table 3: Publishers
CREATE TABLE Publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    address TEXT,
    phone VARCHAR(15),
    email VARCHAR(100),
    website VARCHAR(200),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table 4: Books
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    edition VARCHAR(20),
    publication_year YEAR,
    genre VARCHAR(50) NOT NULL,
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    description TEXT,
    publisher_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id) ON DELETE SET NULL,
    CHECK (publication_year <= YEAR(CURDATE())),
    CHECK (page_count > 0 OR page_count IS NULL)
);

-- Table 5: Book_Authors (Many-to-Many relationship between Books and Authors)
CREATE TABLE Book_Authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

-- Table 6: Book_Copies
CREATE TABLE Book_Copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    acquisition_date DATE NOT NULL,
    condition ENUM('New', 'Good', 'Fair', 'Poor', 'Damaged') DEFAULT 'Good',
    status ENUM('Available', 'Checked Out', 'Reserved', 'Under Maintenance', 'Lost') DEFAULT 'Available',
    location VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    CHECK (acquisition_date <= CURDATE())
);

-- Table 7: Loans
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    checkout_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    late_fee DECIMAL(10, 2) DEFAULT 0.00,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (copy_id) REFERENCES Book_Copies(copy_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    CHECK (checkout_date <= due_date),
    CHECK (return_date IS NULL OR checkout_date <= return_date),
    CHECK (late_fee >= 0)
);

-- Table 8: Reservations
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Pending',
    priority INT DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    CHECK (reservation_date <= CURDATE()),
    CHECK (priority > 0)
);

-- Table 9: Fines
CREATE TABLE Fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    loan_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    issue_date DATE NOT NULL,
    paid_date DATE,
    status ENUM('Outstanding', 'Paid', 'Waived') DEFAULT 'Outstanding',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id) ON DELETE SET NULL,
    CHECK (amount > 0),
    CHECK (issue_date <= CURDATE()),
    CHECK (paid_date IS NULL OR issue_date <= paid_date)
);

-- Table 10: Staff
CREATE TABLE Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2),
    department VARCHAR(50),
    status ENUM('Active', 'On Leave', 'Terminated') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CHECK (hire_date <= CURDATE()),
    CHECK (salary IS NULL OR salary >= 0)
);

-- Table 11: Loan_History (Archive of completed loans)
CREATE TABLE Loan_History (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    checkout_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NOT NULL,
    days_late INT DEFAULT 0,
    total_fee DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CHECK (checkout_date <= due_date),
    CHECK (return_date >= checkout_date),
    CHECK (days_late >= 0),
    CHECK (total_fee >= 0)
);

-- Create indexes for better performance
CREATE INDEX idx_members_email ON Members(email);
CREATE INDEX idx_members_status ON Members(membership_status);
CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_books_genre ON Books(genre);
CREATE INDEX idx_book_copies_status ON Book_Copies(status);
CREATE INDEX idx_loans_status ON Loans(status);
CREATE INDEX idx_loans_due_date ON Loans(due_date);
CREATE INDEX idx_reservations_status ON Reservations(status);
CREATE INDEX idx_fines_status ON Fines(status);
CREATE INDEX idx_staff_department ON Staff(department);

-- Create a view for currently available books
CREATE VIEW Available_Books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    b.genre,
    COUNT(bc.copy_id) AS available_copies
FROM Books b
JOIN Book_Copies bc ON b.book_id = bc.book_id
WHERE bc.status = 'Available'
GROUP BY b.book_id, b.title, b.isbn, b.genre;

-- Create a view for overdue loans
CREATE VIEW Overdue_Loans AS
SELECT 
    l.loan_id,
    m.first_name,
    m.last_name,
    m.email,
    b.title,
    bc.barcode,
    l.checkout_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) AS days_overdue,
    l.late_fee
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN Book_Copies bc ON l.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE l.status = 'Active' 
AND l.return_date IS NULL 
AND l.due_date < CURDATE();

-- Insert sample data for demonstration
INSERT INTO Publishers (name, address, phone, email, website, established_year) VALUES
('Penguin Random House', '1745 Broadway, New York, NY', '212-782-9000', 'info@penguinrandomhouse.com', 'https://www.penguinrandomhouse.com', 2013),
('HarperCollins', '195 Broadway, New York, NY', '212-207-7000', 'contact@harpercollins.com', 'https://www.harpercollins.com', 1989),
('Macmillan Publishers', '120 Broadway, New York, NY', '646-307-5151', 'info@macmillan.com', 'https://www.macmillan.com', 1843);

INSERT INTO Authors (first_name, last_name, birth_date, death_date, nationality) VALUES
('George', 'Orwell', '1903-06-25', '1950-01-21', 'British'),
('J.K.', 'Rowling', '1965-07-31', NULL, 'British'),
('Stephen', 'King', '1947-09-21', NULL, 'American');

INSERT INTO Books (isbn, title, edition, publication_year, genre, language, page_count, publisher_id) VALUES
('978-0451524935', '1984', '1st', 1949, 'Dystopian Fiction', 'English', 328, 1),
('978-0439064866', 'Harry Potter and the Chamber of Secrets', '1st', 1998, 'Fantasy', 'English', 341, 2),
('978-1501142970', 'It', 'Reprint', 2016, 'Horror', 'English', 1168, 3);

INSERT INTO Book_Authors (book_id, author_id) VALUES
(1, 1), -- 1984 by George Orwell
(2, 2), -- Harry Potter by J.K. Rowling
(3, 3); -- It by Stephen King

-- Display database structure confirmation
SELECT 'Library Management System Database Created Successfully!' AS Status;