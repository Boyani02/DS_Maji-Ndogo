USE md_water_services;

SELECT
REPLACE(employee_name, ' ','.')  
FROM employee;

SELECT
LOWER(REPLACE(employee_name, ' ','.'))
FROM employee;

SELECT
CONCAT(
LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email 
FROM employee;

UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov');

SELECT
LENGTH(phone_number)
FROM employee;

UPDATE employee
SET phone_number = TRIM(phone_number);

SELECT town_name, COUNT(*) AS number_of_employees
FROM employee
GROUP BY town_name;

SELECT assigned_employee_id, COUNT(*) AS visit_count
FROM visits
GROUP BY assigned_employee_id
ORDER BY visit_count DESC
LIMIT 3;

SELECT employee_name, email, phone_number
FROM employee
WHERE assigned_employee_id IN (1, 30, 34);

SELECT town_name, COUNT(*) AS record_count
FROM location
GROUP BY town_name;

SELECT town_name, COUNT(*) AS record_count
FROM location
GROUP BY town_name
ORDER BY record_count DESC;

SELECT province_name, COUNT(*) AS record_count
FROM location
GROUP BY province_name
ORDER BY record_count DESC;

SELECT province_name, town_name, COUNT(*) AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name ASC, records_per_town DESC;

SELECT location_type, COUNT(*) AS record_count
FROM location
GROUP BY location_type
ORDER BY record_count DESC;

SELECT 23740 / (15910 + 23740) * 100;

SELECT type_of_water_source, COUNT(*) as count
FROM water_source
GROUP BY type_of_water_source
ORDER BY count DESC;

SELECT type_of_water_source, 
       ROUND(AVG(number_of_people_served)) AS average_people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY average_people_served DESC;

SELECT type_of_water_source, 
       SUM(number_of_people_served) AS total_people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY total_people_served DESC;

SELECT type_of_water_source, 
       ROUND((SUM(number_of_people_served) / 27628140) * 100, 2) AS percentage_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY percentage_served DESC;

SELECT type_of_water_source, 
       ROUND((SUM(number_of_people_served) / 27628140) * 100) AS percentage_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY percentage_served DESC;

SELECT SUM(number_of_people_served) AS total_people_surveyed
FROM water_source;

SELECT type_of_water_source, 
       SUM(number_of_people_served) AS total_people_served,
       RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS rank_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY total_people_served DESC;

SELECT  source_id, 
        type_of_water_source, 
       number_of_people_served,
       RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank
FROM water_source
ORDER BY type_of_water_source, priority_rank;

SELECT 
    DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS survey_duration_days
FROM visits;

SELECT AVG(NULLIF(time_in_queue, 0)) AS average_queue_time
FROM visits;

SELECT 
    DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(NULLIF(time_in_queue, 0))) AS average_queue_time
FROM  visits
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

SELECT 
    HOUR(time_of_record) AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue, 0))) AS average_queue_time
FROM visits
GROUP BY hour_of_day
ORDER BY hour_of_day;

SELECT 
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue, 0))) AS average_queue_time
FROM visits
GROUP BY hour_of_day
ORDER BY hour_of_day;

SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM visits
WHERE time_in_queue != 0; -- this exludes other sources with 0 queue times.

SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday
-- Tuesday
-- Wednesday
FROM visits
WHERE time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY hour_of_day
ORDER BY hour_of_day;

SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    -- Sunday
    ROUND(AVG(
        CASE
            WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
            ELSE NULL
        END), 0) AS Sunday,
    -- Monday
    ROUND(AVG(
        CASE
            WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
            ELSE NULL
        END), 0) AS Monday,
    -- Tuesday
    ROUND(AVG(
        CASE
            WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
            ELSE NULL
        END), 0) AS Tuesday,
    -- Wednesday
    ROUND(AVG(
        CASE
            WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
            ELSE NULL
        END), 0) AS Wednesday,
    -- Thursday
    ROUND(AVG(
        CASE
            WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
            ELSE NULL
        END), 0) AS Thursday,
    -- Friday
    ROUND(AVG(
        CASE
            WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
            ELSE NULL
        END), 0) AS Friday,
    -- Saturday
    ROUND(AVG(
        CASE
            WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
            ELSE NULL
        END), 0) AS Saturday
FROM visits
WHERE time_in_queue != 0 -- Excludes rows with 0 queue times
GROUP BY hour_of_day
ORDER BY hour_of_day;

SELECT CONCAT(day(time_of_record), " ", monthname(time_of_record), " ", year(time_of_record)) 
FROM visits;

SELECT
name,
wat_bas_r - LAG(wat_bas_r) OVER (PARTITION BY (name) ORDER BY (year)) 
FROM global_water_access
ORDER BY name;

SELECT assigned_employee_id,
COUNT(record_id) AS number_of_visits
FROM visits
GROUP BY assigned_employee_id
ORDER BY number_of_visits 
LIMIT 2;

SELECT 
    e.employee_name,
    v.assigned_employee_id,
    COUNT(v.record_id) AS number_of_visits
FROM 
    visits v
JOIN 
    employee e ON v.assigned_employee_id = e.assigned_employee_id
GROUP BY 
    v.assigned_employee_id, e.employee_name
ORDER BY 
    number_of_visits 
LIMIT 2;

SELECT 
    location_id,
    time_in_queue,
    AVG(time_in_queue) OVER (PARTITION BY location_id ORDER BY visit_count) AS total_avg_queue_time
FROM 
    visits
WHERE 
visit_count > 1 -- Only shared taps were visited > 1
ORDER BY 
    location_id, time_of_record;
    
SELECT 
    COUNT(*) AS number_of_employees
FROM employee
WHERE town_name = 'Dahabu';

SELECT 
    COUNT(*) AS number_of_employees
FROM employee
WHERE town_name = 'Harare' AND province_name = 'Kilimani';

SELECT 
    SUM(number_of_people_served) AS total_people_served,
    COUNT(*) AS total_wells,
    ROUND(SUM(number_of_people_served) / COUNT(*), 0) AS average_people_per_well
FROM water_source
WHERE type_of_water_source = 'well';

SELECT
    SUM(number_of_people_served) AS population_served
FROM water_source
WHERE type_of_water_source LIKE '%tap%'
ORDER BY population_served;


























