--task 1--
-- Find courses priced below the average; format cost as $9,999 and sort by highest cost first. --
-- Max Ramos --

--
SELECT
    c.description,
    c.course_no,
    TO_CHAR(c.cost, '$9,999') AS cost
FROM course c
WHERE c.cost < (SELECT AVG(cost) FROM course)
ORDER BY c.cost DESC;
--

--task 2--
-- Join COURSE to SECTION so every row is a real course+section (no null sections). --
-- Max Ramos --

--
SELECT
    CASE WHEN rn = 1 THEN course_no END AS course_no,
    CASE WHEN rn = 1 THEN description END AS description,
    CASE WHEN rn = 1 THEN cost END AS cost,
    start_date_time
FROM (
    SELECT
        c.course_no,
        c.description,
        TO_CHAR(c.cost, '$9,999') AS cost,
        s.start_date_time,
        ROW_NUMBER() OVER (
            PARTITION BY c.course_no, c.description, c.cost
            ORDER BY s.start_date_time
        ) AS rn
    FROM course c
    JOIN section s
        ON s.course_no = c.course_no
)
ORDER BY
    course_no,
    description,
    start_date_time;
--

--task 3--
-- Show each zipcode and how many instructors live there (include zips with zero instructors). --
-- Max Ramos --

--
SELECT
    z.zip,
    COUNT(i.instructor_id) AS instructor_count
FROM zipcode z
LEFT JOIN instructor i
    ON i.zip = z.zip
GROUP BY z.zip
ORDER BY z.zip;
--

--task 4--
-- Show students who live in Brooklyn (use ZIPCODE table for the city/state). --
-- Max Ramos --

--
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    s.street_address,
    z.state,
    z.zip
FROM student s
JOIN zipcode z
    ON z.zip = s.zip
WHERE UPPER(z.city) = 'BROOKLYN'
ORDER BY s.last_name, s.first_name;
--

--task 5--
-- Count how many sections each instructor teaches (include instructors with 0 sections). --
-- Max Ramos --

--
SELECT
    i.first_name,
    i.last_name,
    COUNT(s.section_id) AS num_sections
FROM instructor i
LEFT JOIN section s
    ON s.instructor_id = i.instructor_id
GROUP BY i.first_name, i.last_name
ORDER BY num_sections DESC;
--

--task 6--
-- Find Tom Wojick’s zipcode, then list students who live in that same zipcode. --
-- Max Ramos --

--
SELECT
    s.first_name,
    s.last_name,
    s.street_address,
    s.zip
FROM student s
WHERE s.zip = (
    SELECT i.zip
    FROM instructor i
    WHERE i.first_name = 'Tom'
      AND i.last_name  = 'Wojick'
)
ORDER BY s.last_name, s.first_name;
--

--task 7--
-- Use Vera Wetcel’s registration date as a cutoff, then list students who registered earlier. --
-- Max Ramos --

--
SELECT
    s.student_id,
    s.salutation,
    s.first_name,
    s.last_name
FROM student s
WHERE s.registration_date < (
    SELECT registration_date
    FROM student
    WHERE first_name = 'Vera'
      AND last_name  = 'Wetcel'
)
ORDER BY s.registration_date, s.last_name, s.first_name;
--

--task 8--
-- Find students with no matching rows in ENROLLMENT (i.e., never enrolled). --
-- Max Ramos --

--
SELECT
    s.student_id
FROM student s
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollment e
    WHERE e.student_id = s.student_id
)
ORDER BY s.student_id;
--

--task 9--
-- Create a view combining STUDENT + INSTRUCTOR into one “people” list with a computed full_name. --
-- Max Ramos --

--
CREATE OR REPLACE VIEW all_people_view AS
SELECT
    s.salutation,
    s.first_name || ' ' || s.last_name AS full_name,
    s.street_address,
    s.zip,
    s.phone
FROM student s
UNION ALL
SELECT
    i.salutation,
    i.first_name || ' ' || i.last_name AS full_name,
    i.street_address,
    i.zip,
    i.phone
FROM instructor i;
--

-- Display the view results --
--
SELECT
    salutation,
    full_name,
    street_address,
    zip,
    phone
FROM all_people_view
ORDER BY full_name;
--

--task 10--
-- Student(s) with the highest final_grade (includes ties). --
-- Max Ramos --

--
SELECT
    s.first_name,
    s.last_name,
    s.student_id
FROM student s
JOIN enrollment e
    ON e.student_id = s.student_id
WHERE e.final_grade = (SELECT MAX(final_grade) FROM enrollment);
--

--task 11--
-- Courses that have more than 5 sections (with section counts). --
-- Max Ramos --

--
SELECT
    c.course_no,
    c.description,
    COUNT(*) AS num_sections
FROM course c
JOIN section s
    ON s.course_no = c.course_no
GROUP BY c.course_no, c.description
HAVING COUNT(*) > 5;
--

--task 12--
-- List all courses with their prerequisites (if any), including course and prerequisite details. --
-- Max Ramos --

--
SELECT
    c.course_no,
    c.description,
    c.cost,
    p.course_no   AS prereq_course_no,
    p.description AS prereq_description
FROM course c
LEFT JOIN course p
    ON c.prerequisite = p.course_no
ORDER BY c.course_no;
--

--task 13--
-- List the course(s) that have the most sections, showing course_no, description, and number of sections. --
-- Max Ramos --

--
WITH section_counts AS (
    SELECT
        course_no,
        COUNT(*) AS num_sections
    FROM section
    GROUP BY course_no
)
SELECT
    c.course_no,
    c.description,
    sc.num_sections
FROM section_counts sc
JOIN course c
    ON c.course_no = sc.course_no
WHERE sc.num_sections = (SELECT MAX(num_sections) FROM section_counts)
ORDER BY c.course_no;
--

--task 14--
-- List courses/sections where enrolled students exceed the section capacity, showing course_no, description, start_date_time, capacity, and current enrolled count. --
-- Max Ramos --

--
SELECT
    c.course_no,
    c.description,
    s.start_date_time,
    s.capacity,
    COUNT(e.student_id) AS enrolled_students
FROM course c
JOIN section s
    ON s.course_no = c.course_no
JOIN enrollment e
    ON e.section_id = s.section_id
GROUP BY
    c.course_no,
    c.description,
    s.start_date_time,
    s.capacity
HAVING COUNT(e.student_id) > s.capacity
ORDER BY
    c.course_no,
    s.start_date_time;
--
