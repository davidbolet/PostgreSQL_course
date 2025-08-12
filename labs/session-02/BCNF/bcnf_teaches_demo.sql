-- BCNF Classroom Demo: 3NF but not BCNF (Teaches)
-- Relation: teaches(student, course, professor)
-- Functional dependencies (FDs):
--   1) (student, course) -> professor      -- each student-course pair has one professor
--   2) professor -> course                  -- each professor teaches exactly one course
-- Analysis:
--   Candidate keys: {student, course} and {student, professor}
--   'course' and 'professor' are prime attributes (each appears in some key)
--   This relation is in 3NF (RHS of non-key determinant is prime) but NOT in BCNF
--   because 'professor' is not a superkey in FD (2).
-- BCNF decomposition:
--   R1(prof_course): (professor PK) -> course
--   R2(enrollment):  (student, professor) PK
--   Lossless join on professor; dependencies enforced locally.

DROP SCHEMA IF EXISTS bcnf CASCADE;
CREATE SCHEMA bcnf;

-- 1) Denormalized single table (3NF but violates BCNF)
CREATE TABLE bcnf.teaches (
  student   TEXT NOT NULL,
  course    TEXT NOT NULL,
  professor TEXT NOT NULL,
  PRIMARY KEY (student, course)  -- encodes FD (student,course)->professor
);

-- sample data that respects the FDs:
-- - professor -> course (each prof has exactly one course)
-- - for a given (student,course) there is exactly one professor
INSERT INTO bcnf.teaches(student, course, professor) VALUES
('Ada',   'Databases',   'Smith'),
('Alan',  'Databases',   'Smith'),
('Grace', 'Algorithms',  'Jones'),
('Edsger','Algorithms',  'Jones'),
('Ada',   'Compilers',   'Aho');

-- 2) Show the BCNF problem (update anomaly)
-- If 'Smith' switches from 'Databases' to 'Data Systems', we must update many rows.
-- (Try to change the professor's course in ALL rows where professor='Smith')
-- This illustrates that 'professor' is a determinant (professor->course) but not a key.
-- SELECT professor, array_agg(DISTINCT course) FROM bcnf.teaches GROUP BY professor;

-- 3) Decompose to BCNF

-- R1: prof_course (professor determines course)
CREATE TABLE bcnf.prof_course (
  professor TEXT PRIMARY KEY,
  course    TEXT NOT NULL
);

INSERT INTO bcnf.prof_course(professor, course)
SELECT professor, MIN(course)  -- deterministic in case of accidental duplicates
FROM bcnf.teaches
GROUP BY professor;

-- R2: enrollment (student with their professor)
CREATE TABLE bcnf.enrollment (
  student   TEXT NOT NULL,
  professor TEXT NOT NULL REFERENCES bcnf.prof_course(professor),
  PRIMARY KEY (student, professor)
);

INSERT INTO bcnf.enrollment(student, professor)
SELECT DISTINCT student, professor
FROM bcnf.teaches;

-- 4) Verify lossless join: joining R2 with R1 reconstructs the original rows
-- (By set equality check via counts here; for full check compare row sets.)
SELECT
  (SELECT COUNT(*) FROM bcnf.teaches)                         AS teaches_rows,
  (SELECT COUNT(*) FROM (SELECT e.student, p.course, e.professor
                         FROM bcnf.enrollment e
                         JOIN bcnf.prof_course p USING (professor)) x) AS join_rows;

-- Optional: check exact set equality
-- EXCEPT should return zero rows if sets are identical.
(SELECT student, course, professor FROM bcnf.teaches
 EXCEPT
 SELECT e.student, p.course, e.professor
 FROM bcnf.enrollment e JOIN bcnf.prof_course p USING (professor))
UNION ALL
(SELECT e.student, p.course, e.professor
 FROM bcnf.enrollment e JOIN bcnf.prof_course p USING (professor)
 EXCEPT
 SELECT student, course, professor FROM bcnf.teaches);

-- 5) Show anomalies fixed: changing a professor's course is now a single-row UPDATE
-- Before:
-- SELECT * FROM bcnf.prof_course WHERE professor='Smith';
-- UPDATE bcnf.prof_course SET course='Data Systems' WHERE professor='Smith';
-- After update, the join automatically reflects the new course for all students of Smith.
-- SELECT e.student, p.course FROM bcnf.enrollment e JOIN bcnf.prof_course p USING (professor) WHERE professor='Smith';

