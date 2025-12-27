SELECT * from books;
select * from branch;
select * from members;
select * from issued_status;
select * from return_status;
select * from employees;
--queries
-- Task 13: Identify Members with Overdue Books Write a query to identify members who have overdue books 
-- (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
SELECT 
    m.member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    (CURRENT_DATE - ist.issued_date - 30) AS days_overdue
FROM members m
JOIN issued_status ist 
    ON m.member_id = ist.issued_member_id
JOIN books b 
    ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status rst 
    ON ist.issued_id = rst.issued_id
WHERE rst.return_date IS NULL
  AND (CURRENT_DATE - ist.issued_date) > 30;
-- Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
UPDATE books
SET status = 'Yes'
WHERE isbn IN (
    SELECT return_book_isbn
    FROM return_status
);
SELECT * FROM books;
-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
SELECT 
    b.branch_id,
    COUNT(DISTINCT ist.issued_id) AS books_issued,
    COUNT(DISTINCT rst.return_id) AS books_returned,
    COALESCE(SUM(bk.rental_price), 0) AS total_revenue
FROM branch b
LEFT JOIN employees e 
    ON b.branch_id = e.branch_id
LEFT JOIN issued_status ist 
    ON e.emp_id = ist.issued_emp_id
LEFT JOIN return_status rst 
    ON ist.issued_id = rst.issued_id
LEFT JOIN books bk 
    ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
CREATE TABLE active_members AS
SELECT DISTINCT
    m.member_id,
    m.member_name,
    m.member_address,
    m.reg_date
FROM members m
JOIN issued_status i
    ON m.member_id = i.issued_member_id
WHERE i.issued_date >= CURRENT_DATE - INTERVAL '2 months';

SELECT * FROM active_members;
-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
SELECT emp_name, books_processed, branch_id
FROM (
    SELECT 
        e.emp_name,
        e.branch_id,
        COUNT(ist.issued_id) AS books_processed,
        RANK() OVER (ORDER BY COUNT(ist.issued_id) DESC) AS rnk
    FROM employees e
    JOIN issued_status ist ON e.emp_id = ist.issued_emp_id
    GROUP BY e.emp_name, e.branch_id
) t
WHERE t.rnk <= 3;

-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.
select * from books;
select * from issued_Status;
select * from return_status;

SELECT 
    m.member_name,
    COUNT(*) AS damaged_count
FROM members m
JOIN issued_status ist 
    ON m.member_id = ist.issued_member_id
JOIN return_status rst 
    ON ist.issued_id = rst.issued_id
WHERE rst.book_quality = 'Damaged'
GROUP BY m.member_name;


-- Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a 
-- book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first 
-- check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available
-- (status = 'no'), the procedure should return an error message indicating that the book is currently not available.


CREATE OR REPLACE PROCEDURE issue_book(p_isbn VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR;
BEGIN
    -- Step 1: Get current book status
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_isbn;

    -- Step 2: Check if book exists
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Book with ISBN % does not exist', p_isbn;
    END IF;

    -- Step 3: Check availability
    IF v_status = 'yes' THEN
        -- Issue the book
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_isbn;

        RAISE NOTICE 'Book % issued successfully', p_isbn;
    ELSE
        -- Book not available
        RAISE EXCEPTION 'Book % is currently not available', p_isbn;
    END IF;
END;
$$;

CALL issue_book('978-0-553-29698-2');

