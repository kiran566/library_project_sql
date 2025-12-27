# library_project_sql

## **📌 Project Overview**
The Library Management System is a database-driven project designed to manage books, members, employees, branches, book issues, returns, overdue tracking, fines, and performance reporting.
This project demonstrates real-world SQL skills including joins, window functions, CTAS, stored procedures, and dashboard reporting.

![Library Dashboard](dashboard.png)

## **🛠️ Tech Stack**

Database: PostgreSQL

Language: SQL

Concepts Used:

Joins (INNER, LEFT)

Window Functions

Subqueries

CTAS (Create Table As Select)

Stored Procedures

Date calculations

Aggregations & Grouping

---------------------------------------------------------------------

![ER Diagram](library_erd.png)


## 🗂️** Database Schema**

## 📘 **1. branch**

| Column Name    | Data Type   |
| -------------- | ----------- |
| branch_id      | VARCHAR(10) |
| manager_id     | VARCHAR(10) |
| branch_address | VARCHAR(30) |
| contact_no     | VARCHAR(15) |


```sql

CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);
```
---

## 📘 **2. employees**

| Column Name | Data Type          |
| ----------- | ------------------ |
| emp_id      | VARCHAR(10)        |
| emp_name    | VARCHAR(30)        |
| position    | VARCHAR(30)        |
| salary      | DECIMAL(10,2)      |
| branch_id   | VARCHAR(10) *(FK)* |

🔗 **branch_id → branch(branch_id)**


```sql

CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);
```


## 📘 **3. members**

| Column Name    | Data Type   |
| -------------- | ----------- |
| member_id      | VARCHAR(10) |
| member_name    | VARCHAR(30) |
| member_address | VARCHAR(30) |
| reg_date       | DATE        |


```sql

CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);
```



## 📘 **4. books**

| Column Name  | Data Type     |
| ------------ | ------------- |
| isbn         | VARCHAR(50)   |
| book_title   | VARCHAR(80)   |
| category     | VARCHAR(30)   |
| rental_price | DECIMAL(10,2) |
| status       | VARCHAR(10)   |
| author       | VARCHAR(30)   |
| publisher    | VARCHAR(30)   |


```sql

CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);
```


## 📘 **5. issued_status**

| Column Name      | Data Type          |
| ---------------- | ------------------ |
| issued_id        | VARCHAR(10)        |
| issued_member_id | VARCHAR(30) *(FK)* |
| issued_book_name | VARCHAR(80)        |
| issued_date      | DATE               |
| issued_book_isbn | VARCHAR(50) *(FK)* |
| issued_emp_id    | VARCHAR(10) *(FK)* |

* issued_member_id → members(member_id)
* issued_emp_id → employees(emp_id)
* issued_book_isbn → books(isbn)

```sql

CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);
```


## 📘 **6. return_status**

| Column Name      | Data Type          |
| ---------------- | ------------------ |
| return_id        | VARCHAR(10)        |
| issued_id        | VARCHAR(30)        |
| return_book_name | VARCHAR(80)        |
| return_date      | DATE               |
| return_book_isbn | VARCHAR(50) *(FK)* |

🔗 **return_book_isbn → books(isbn)**


```sql
CREATE TABLE return_status
(
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```


## **🔄 End-to-End Process Flow**
## 1️⃣ Book Availability Check

Before issuing a book, its status is checked.

Only books with status = 'Yes' can be issued.

## 2️⃣ Book Issuance

Entry is made in issued_status

Book status is updated to No

Business Logic

Prevents double issuance

Tracks issuing employee and member

## 3️⃣ Book Return

Entry is added to return_status

Book quality is recorded (Good / Damaged)

Book status is updated back to Yes

##4️⃣ Overdue Book Detection

A book is overdue if not returned within 30 days

Calculated using:

CURRENT_DATE - issued_date

## 5️⃣ Fine Calculation

Fine starts after 30 days

Rate: $0.50 per day

## Formula: 
    (CURRENT_DATE - issued_date - 30) * 0.50

## 6️⃣ CTAS – Overdue Report Generation

A new table is created containing:

Member ID

Number of overdue books

Total fine amount

This table is used for reporting and dashboards.

## 7️⃣ Stored Procedure – Book Status Management

Input: book_isbn

If book is available → issue it → update status to No

If not available → throw error message

Purpose:

Enforces business rules

Prevents invalid operations

## 8️⃣ Branch Performance Reporting

Each branch report includes:

Number of books issued

Number of books returned

Total rental revenue

Used for:

Management insights

Operational efficiency tracking

## 9️⃣ Employee Performance Analysis

Identifies Top 3 employees by number of books issued

Helps evaluate employee contribution

## 🔟 High-Risk Member Identification

Members who returned damaged books more than twice

Helps in risk assessment and policy enforcement

## TASks DONE

Task 1: Create a New Book Record

Insert a new book into the books table with complete details such as ISBN, title, category, rental price, status, author, and publisher.

Task 2: Update an Existing Member’s Address

Update the address of an existing library member using their member_id.

Task 3: Delete a Record from Issued Status

Delete an issued book record from the issued_status table using a specific issued_id.

Task 4: Retrieve All Books Issued by a Specific Employee

Fetch all issued book records processed by a particular employee using issued_emp_id.

Task 5: List Members / Employees Who Have Issued More Than One Book

Use GROUP BY and HAVING to identify employees who have processed more than one book issue.

Task 6: CTAS – Create Book Issue Summary Table

Create a new table using CTAS that shows:

Book ISBN

Book title

Total number of times each book has been issued

Task 7: Retrieve All Books in a Specific Category

Fetch all books that belong to a given category (e.g., Classic).

Task 8: Find Total Rental Income by Category

Calculate total rental revenue and issue count for each book category using aggregation.

Task 9: List Members Who Registered in the Last 180 Days

Identify recently registered members using date filtering with CURRENT_DATE.

Task 10: List Employees with Their Branch Manager and Branch Details

Display employee details along with:

Branch manager ID

Manager name

Branch information

(Self-join on employees table)

Task 11: CTAS – Books Above Rental Price Threshold

Create a new table containing books whose rental price is greater than a specified value (e.g., $7).

Task 12: Retrieve Books Not Yet Returned

Identify books that have been issued but not yet returned using LEFT JOIN and NULL filtering.

Task 13: Identify Members with Overdue Books

Identify members who have issued books but not returned them within 30 days and calculate days overdue.

Task 14: Update Book Status on Return

Update the status of books to “Yes” (Available) in the books table when the books are returned.

Task 15: Branch Performance Report

Generate a report for each branch showing total books issued, books returned, and total rental revenue.

Task 16: CTAS – Create Table of Active Members

Create a new table containing members who have issued at least one book in the last 2 months.

Task 17: Find Employees with the Most Book Issues Processed

Identify the top 3 employees who have processed the highest number of book issues along with their branch.

Task 18: Identify Members Issuing High-Risk Books

Find members who have returned damaged books and count how many times they issued damaged books.

Task 19: Stored Procedure – Book Issue Management

Create a stored procedure that checks book availability and updates book status when issuing a book.

Task 20: CTAS – Overdue Books and Fine Calculation

Create a summary table showing member ID, number of overdue books, and total fines calculated at $0.50 per day.

