DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

SELECT 
    location_id, 
    true_water_source_score
FROM 
    auditor_report;

SELECT 
    ar.location_id,
    ar.true_water_source_score,
    v.record_id
FROM 
    auditor_report ar
JOIN 
    visits v ON ar.location_id = v.location_id;

SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score,
visits.location_id AS visit_location,
visits.record_id
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id;

SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score,
    v.location_id AS visit_location,
    v.record_id,
    w.subjective_quality_score
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality w ON v.record_id = w.record_id; -- Join water_quality using record_id
    
SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    v.record_id,
    w.subjective_quality_score AS surveyor_score
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality w ON v.record_id = w.record_id;
    
SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    v.record_id,
    w.subjective_quality_score AS surveyor_score
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality w ON v.record_id = w.record_id
WHERE
    ar.true_water_source_score = w.subjective_quality_score;-- Check for equality

SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    v.record_id,
    w.subjective_quality_score AS surveyor_score
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality w ON v.record_id = w.record_id
WHERE
    ar.true_water_source_score - w.subjective_quality_score = 0;  -- Check for zero difference
    
SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    v.record_id,
    w.subjective_quality_score AS surveyor_score
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality w ON v.record_id = w.record_id
WHERE
    ar.true_water_source_score = w.subjective_quality_score
    AND v.visit_count = 1;  -- Filter for visit_count equal to 1

SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    v.record_id,
    w.subjective_quality_score AS surveyor_score,
    ws.type_of_water_source AS survey_source,  -- Grab from water_source
    ar.type_of_water_source AS auditor_source   -- Grab from auditor_report
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality w ON v.record_id = w.record_id
JOIN
    water_source ws ON ar.type_of_water_source = ws.type_of_water_source  -- Join water_source using location_id
WHERE
    ar.true_water_source_score != w.subjective_quality_score  -- Not equal for incorrect records
    AND v.visit_count = 1;  -- Filter for visit_count equal to 1
    
SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    v.record_id,
    w.subjective_quality_score AS surveyor_score
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality w ON v.record_id = w.record_id
WHERE
    ar.true_water_source_score != w.subjective_quality_score  -- Not equal for incorrect records
    AND v.visit_count = 1;  -- Filter for visit_count equal to 1

SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    v.record_id,
    w.subjective_quality_score AS surveyor_score,
    v.assigned_employee_id  -- Include assigned_employee_id to see which employee made the record
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality w ON v.record_id = w.record_id
WHERE
    ar.true_water_source_score != w.subjective_quality_score  -- Not equal for incorrect records
    AND v.visit_count = 1;  -- Filter for visit_count equal to 1


SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    v.record_id,
    w.subjective_quality_score AS surveyor_score,
    e.employee_name  -- Fetch the employee's name instead of the ID
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality w ON v.record_id = w.record_id
JOIN
    employee e ON v.assigned_employee_id = e.assigned_employee_id  -- Join to fetch employee names
WHERE
    ar.true_water_source_score != w.subjective_quality_score  -- Not equal for incorrect records
    AND v.visit_count = 1;  -- Filter for visit_count equal to 1

WITH Incorrect_records AS (
    SELECT
        ar.location_id AS audit_location,
        ar.true_water_source_score AS auditor_score,
        v.record_id,
        w.subjective_quality_score AS surveyor_score,
        e.employee_name  -- Fetch the employee's name instead of the ID
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality w ON v.record_id = w.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id  -- Join to fetch employee names
    WHERE
        ar.true_water_source_score != w.subjective_quality_score  -- Not equal for incorrect records
        AND v.visit_count = 1  -- Filter for visit_count equal to 1
)
-- Now, select from the CTE
SELECT * FROM Incorrect_records;

WITH Incorrect_records AS (
    SELECT
        ar.location_id AS audit_location,
        ar.true_water_source_score AS auditor_score,
        v.record_id,
        w.subjective_quality_score AS surveyor_score,
        e.employee_name  -- Fetch the employee's name instead of the ID
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality w ON v.record_id = w.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id  -- Join to fetch employee names
    WHERE
        ar.true_water_source_score != w.subjective_quality_score  -- Not equal for incorrect records
        AND v.visit_count = 1  -- Filter for visit_count equal to 1
)

-- Get a unique list of employees
SELECT DISTINCT
    employee_name
FROM
    Incorrect_records;
    
WITH Incorrect_records AS (
    SELECT
        ar.location_id AS audit_location,
        ar.true_water_source_score AS auditor_score,
        v.record_id,
        w.subjective_quality_score AS surveyor_score,
        e.employee_name  -- Fetch the employee's name instead of the ID
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality w ON v.record_id = w.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id  -- Join to fetch employee names
    WHERE
        ar.true_water_source_score != w.subjective_quality_score  -- Not equal for incorrect records
        AND v.visit_count = 1  -- Filter for visit_count equal to 1
)

-- Count the number of mistakes each employee made
SELECT
    employee_name,
    COUNT(*) AS mistake_count  -- Count the occurrences of each employee's name
FROM
    Incorrect_records
GROUP BY
    employee_name  -- Group by employee name to get counts
ORDER BY
    mistake_count DESC;-- Optional: order by the number of mistakes, highest first

WITH Incorrect_records AS (
    SELECT
        ar.location_id AS audit_location,
        ar.true_water_source_score AS auditor_score,
        v.record_id,
        w.subjective_quality_score AS surveyor_score,
        e.employee_name  -- Fetch the employee's name instead of the ID
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality w ON v.record_id = w.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id  -- Join to fetch employee names
    WHERE
        ar.true_water_source_score != w.subjective_quality_score  -- Not equal for incorrect records
        AND v.visit_count = 1  -- Filter for visit_count equal to 1
),
Error_Count AS (
    -- Count the number of mistakes each employee made
    SELECT
        employee_name,
        COUNT(*) AS mistake_count  -- Count the occurrences of each employee's name
    FROM
        Incorrect_records
    GROUP BY
        employee_name  -- Group by employee name to get counts
)

-- Calculate the average number of mistakes per employee
SELECT
    AVG(mistake_count) AS avg_error_count_per_empl  -- Average of mistake counts
FROM
    Error_Count;  -- Reference the second CTE
    
WITH Incorrect_records AS (
    SELECT
        ar.location_id AS audit_location,
        ar.true_water_source_score AS auditor_score,
        v.record_id,
        w.subjective_quality_score AS surveyor_score,
        e.employee_name  -- Fetch the employee's name instead of the ID
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality w ON v.record_id = w.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id  -- Join to fetch employee names
    WHERE
        ar.true_water_source_score != w.subjective_quality_score  -- Not equal for incorrect records
        AND v.visit_count = 1  -- Filter for visit_count equal to 1
),
Error_Count AS (
    -- Count the number of mistakes each employee made
    SELECT
        employee_name,
        COUNT(*) AS mistake_count  -- Count the occurrences of each employee's name
    FROM
        Incorrect_records
    GROUP BY
        employee_name  -- Group by employee name to get counts
),
Average_Error_Count AS (
    -- Calculate the average number of mistakes per employee
    SELECT
        AVG(mistake_count) AS avg_error_count_per_empl  -- Average of mistake counts
    FROM
        Error_Count  -- Reference the second CTE
)

-- Create the suspect list comparing each employee's mistake count with the average
SELECT
    ec.employee_name,
    ec.mistake_count AS number_of_mistakes
FROM
    Error_Count ec
WHERE
    ec.mistake_count > (SELECT avg_error_count_per_empl FROM Average_Error_Count);-- Subquery to compare with the average


CREATE VIEW Incorrect_records AS (
SELECT
auditor_report.location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
auditor_report.statements AS statements
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality AS wq
ON visits.record_id = wq.record_id
JOIN
employee
ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE
visits.visit_count =1
AND auditor_report.true_water_source_score != wq.subjective_quality_score);

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*
*/
GROUP BY
employee_name)
-- Query
SELECT * FROM error_count;

WITH error_count AS (
    -- This CTE calculates the number of mistakes each employee made
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
    FROM
        Incorrect_records
    GROUP BY
        employee_name
)
-- Query to find employees with above-average mistakes
SELECT *
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count);

WITH error_count AS (
    -- This CTE calculates the number of mistakes each employee made
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
    FROM
        Incorrect_records
    GROUP BY
        employee_name
),
suspect_list AS (
    -- This CTE selects employees from error_count who meet the criteria for being suspects
    SELECT employee_name
    FROM error_count
    WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count) -- Adjust the criteria as needed
    LIMIT 4  -- Limit to 4 suspects
)
-- Query to get the suspect names and their mistake count
SELECT 
    ec.employee_name,
    ec.number_of_mistakes
FROM 
    error_count ec
JOIN 
    suspect_list sl ON ec.employee_name = sl.employee_name;


WITH suspect_list AS (
    -- This CTE selects the employee names who are considered suspects
    SELECT employee_name
    FROM (
        SELECT employee_name
        FROM Incorrect_records
        GROUP BY employee_name
        HAVING COUNT(*) > 1  -- Example condition to identify suspects; adjust as needed
    ) AS subquery
)
-- Main query to pull records from Incorrect_records for suspects
SELECT *
FROM Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list);

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*
*/
GROUP BY
employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
employee_name,
location_id,
statements
FROM
Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list);

WITH suspect_list AS (
    -- This CTE selects the employee names who are considered suspects
    SELECT employee_name
    FROM (
        SELECT employee_name
        FROM Incorrect_records
        GROUP BY employee_name
        HAVING COUNT(*) > 1  -- Example condition to identify suspects; adjust as needed
    ) AS subquery
)
-- Main query to find employees with "cash" in statements who are not in the suspect list
SELECT *
FROM Incorrect_records
WHERE employee_name NOT IN (SELECT employee_name FROM suspect_list)
AND statements LIKE '%cash%';  -- Check for the word "cash" in statements

