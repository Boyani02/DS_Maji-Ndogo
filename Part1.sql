USE md_water_services;
SHOW TABLES;

SELECT * FROM location LIMIT 10;

SELECT * FROM visits LIMIT 10;

SELECT DISTINCT type_of_water_source
FROM water_source;

SELECT *
FROM visits
WHERE time_in_queue > 500;

SELECT *
FROM visits
WHERE time_in_queue = 0;

SELECT * FROM water_source;

SELECT * FROM well_pollution
LIMIT 5;

SELECT *
FROM well_pollution
WHERE results = 'Clean'
AND biological > 0.01;

SELECT *
FROM well_pollution
WHERE  description LIKE 'Clean%'
AND biological > 0.01;

CREATE TABLE
md_water_services.well_pollution_copy
AS (SELECT * FROM
md_water_services.well_pollution
);

CREATE TABLE md_water_services.well_pollution_copy AS
SELECT * FROM md_water_services.well_pollution;

select * from well_pollution_copy;

UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
AND results = 'Clean';

SELECT address
FROM employee
WHERE employee_name = 'Bello Azibo';

SELECT employee_name, phone_number
FROM employee
WHERE position = 'Micro Biologist';

SELECT *
FROM water_source
ORDER BY number_of_people_served DESC;

SELECT *
FROM water_source
WHERE number_of_people_served > 3997;

SELECT *
FROM data_dictionary WHERE description LIKE '%population%' ;

SELECT * 
FROM global_water_access 
WHERE name = 'Maji Ndogo';

SELECT *
FROM employee
WHERE position = 'Civil Engineer' AND (province_name = 'Dahabu' OR address LIKE '%Avenue%');

SELECT employee_name
FROM employee
WHERE 
    (phone_number LIKE '%86%'
    OR phone_number LIKE '%11%')
    AND (employee_name LIKE '% A%' 
    OR employee_name LIKE '% M%')
    AND position = 'Field Surveyor';
    
SELECT *
FROM well_pollution_copy
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01;

SELECT * FROM water_quality WHERE visit_count >= 2 AND subjective_quality_score = 10;

UPDATE employee
SET phone_number = '+99643864786'
WHERE employee_name = 'Bello Azibo';

SELECT * 
FROM well_pollution_copy
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);























