-- Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include: 
-- The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines

CREATE TABLE overdue_summary AS
SELECT
    ist.issued_member_id AS member_id,

    COUNT(*) AS overdue_books,

    SUM(
        (CURRENT_DATE - ist.issued_date - 30) * 0.50
    ) AS total_fines

FROM issued_status ist
LEFT JOIN return_status rst
    ON ist.issued_id = rst.issued_id

WHERE
    rst.return_id IS NULL              -- Not returned
    AND CURRENT_DATE - ist.issued_date > 30

GROUP BY ist.issued_member_id;

Select * from overdue_summary;

