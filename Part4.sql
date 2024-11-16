USE md_water_services;

SELECT *
FROM location l
JOIN visits v ON v.location_id = l.location_id;

SELECT 
    l.location_id,
    l.province_name,
    l.town_name,
    v.visit_count AS visit_count
FROM 
    visits v
JOIN 
    location l ON v.location_id = l.location_id;
    
SELECT 
    l.location_id,
    l.province_name,
    l.town_name,
    v.visit_count AS visit_count,
    w.type_of_water_source,
    w.number_of_people_served
FROM 
    visits v
JOIN 
    location l ON v.location_id = l.location_id
JOIN 
    water_source w ON v.source_id = w.source_id;

SELECT 
    l.location_id,
    l.province_name,
    l.town_name,
    v.visit_count AS visit_count,
    w.type_of_water_source,
    w.number_of_people_served
FROM 
    visits v
JOIN 
    location l ON v.location_id = l.location_id
JOIN 
    water_source w ON v.source_id = w.source_id
WHERE 
    v.visit_count = 1;

SELECT 
    l.province_name,
    l.town_name,
    w.type_of_water_source,
    l.location_type,
    w.number_of_people_served,
    v.time_in_queue
FROM 
    visits v
JOIN 
    location l ON v.location_id = l.location_id
JOIN 
    water_source w ON v.source_id = w.source_id;
    
SELECT
water_source.type_of_water_source,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;

CREATE VIEW combined_analysis_table AS 
SELECT
water_source.type_of_water_source AS source_type,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served AS people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;

WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN 
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY 
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;


SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access;

CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same

source more than once in the future.

*/
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist,

and should refer to the source table. This ensures data integrity.

*/
Address VARCHAR(50), 
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50), 
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/
Date_of_completion DATE,
Comments TEXT 
);

SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution_copy.results
FROM
water_source
LEFT JOIN
well_pollution_copy ON water_source.source_id = well_pollution_copy.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 
AND ( well_pollution_copy.results!= 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue>30)
);

SELECT 
    l.province_name,
    l.town_name,
    w.type_of_water_source,
    l.location_type,
    w.number_of_people_served,
    v.time_in_queue,
    well_pollution_copy.results AS pollution_results,  -- Assume 'wp' is the alias for well_pollution
    
    CASE 
        WHEN w.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30 THEN 
            CONCAT("Install ", FLOOR(v.time_in_queue / 30), " taps nearby")
        WHEN w.type_of_water_source IN ('tap_in_home_broken', 'tap_outside_broken') THEN 
            'Diagnose local infrastructure'  -- For broken taps
        WHEN well_pollution_copy.results = 'Contaminated: Biological' THEN 
            'Install UV filter'
        WHEN well_pollution_copy.results = 'Contaminated: Chemical' THEN 
            'Install RO filter'
        WHEN w.type_of_water_source = 'River' THEN 
            'Drill well'
        ELSE NULL
    END AS Improvement
FROM 
    visits v
JOIN 
    location l ON v.location_id = l.location_id
JOIN 
    water_source w ON v.source_id = w.source_id
LEFT JOIN  -- Use LEFT JOIN to include all records from visits even if there's no matching pollution result
    well_pollution_copy wp ON v.source_id = wp.source_id;-- Adjust this join condition as needed based on your schema

SELECT 
    l.province_name,
    l.town_name,
    w.type_of_water_source,
    l.location_type,
    w.number_of_people_served,
    v.time_in_queue,
    well_pollution_copy.results AS pollution_results,  -- Using the full table name here
    
    CASE 
        WHEN w.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30 THEN 
            CONCAT("Install ", FLOOR(v.time_in_queue / 30), " taps nearby")
        WHEN w.type_of_water_source IN ('tap_in_home_broken', 'tap_outside_broken') THEN 
            'Diagnose local infrastructure'  -- For broken taps
        WHEN well_pollution_copy.results = 'Contaminated: Biological' THEN  -- Using the full table name here
            'Install UV filter'
        WHEN well_pollution_copy.results = 'Contaminated: Chemical' THEN  -- Using the full table name here
            'Install RO filter'
        WHEN w.type_of_water_source = 'River' THEN 
            'Drill well'
        ELSE NULL
    END AS Improvement
FROM 
    visits v
JOIN 
    location l ON v.location_id = l.location_id
JOIN 
    water_source w ON v.source_id = w.source_id
LEFT JOIN  -- Use LEFT JOIN to include all records from visits even if there's no matching pollution result
    well_pollution_copy ON v.source_id = well_pollution_copy.source_id;  -- Keep the table name here as well

DESCRIBE Project_progress;

DROP TABLE project_progress;

CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Comments TEXT
);

INSERT INTO Project_progress (
    source_id,
    Address,
    Town,
    Province,
    Source_type,
    Improvement,
    Source_status,
    Date_of_completion,
    Comments
)
SELECT 
    w.source_id,                          -- source_id from water_source
    CONCAT(l.town_name, ', ', l.province_name) AS Address,  -- Combined Address, adjust as needed
    l.town_name,                          -- Town from location
    l.province_name,                      -- Province from location
    w.type_of_water_source AS Source_type,  -- Type of water source
    CASE 
        WHEN w.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30 THEN 
            CONCAT("Install ", FLOOR(v.time_in_queue / 30), " taps nearby")
        WHEN w.type_of_water_source IN ('tap_in_home_broken', 'tap_outside_broken') THEN 
            'Diagnose local infrastructure'  -- For broken taps
        WHEN well_pollution_copy.results = 'Contaminated: Biological' THEN  -- Use the correct table here
            'Install UV filter'
        WHEN well_pollution_copy.results = 'Contaminated: Chemical' THEN  -- Use the correct table here
            'Install RO filter'
        WHEN w.type_of_water_source = 'River' THEN 
            'Drill well'
        ELSE NULL
    END AS Improvement,
    'Backlog' AS Source_status,          -- Default status
    NULL AS Date_of_completion,          -- Set to NULL if not completed yet
    NULL AS Comments                      -- Set to NULL if no comments
FROM 
    visits v
JOIN 
    location l ON v.location_id = l.location_id
JOIN 
    water_source w ON v.source_id = w.source_id
LEFT JOIN 
    well_pollution_copy ON v.source_id = well_pollution_copy.source_id;  -- Changed here

SELECT 
    COUNT(*) AS total_uv_filters
FROM 
    Project_progress
WHERE 
    Improvement = 'Install UV filter';

SELECT Province, COUNT(*) AS Project_Count
FROM Project_progress
WHERE Source_type IN ('river')
GROUP BY Province
ORDER BY Project_Count DESC
LIMIT 5;

SELECT Town, COUNT(*) AS Project_Count
FROM Project_progress
WHERE Source_type IN ('shared_tap')
GROUP BY Town
ORDER BY Project_Count DESC;

SELECT MAX(river)
FROM town_aggregated_water_access
WHERE province_name = 'Amanzi';

SELECT province_name
FROM town_aggregated_water_access
GROUP BY province_name
HAVING max(tap_in_home + tap_in_home_broken) < 50;



