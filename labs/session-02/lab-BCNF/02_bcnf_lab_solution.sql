-- BCNF Mini-Lab — Reference Solution
-- Decompose to BCNF and prove lossless join; show anomaly is fixed.

BEGIN;

-- =======================
-- Task A — Teaches → BCNF
-- =======================

-- R1: professor determines course
CREATE TABLE bcnflab.prof_course (
  professor TEXT PRIMARY KEY,
  course    TEXT NOT NULL
);

INSERT INTO bcnflab.prof_course(professor, course)
SELECT professor, MIN(course)  -- deterministic if duplicates appear
FROM bcnflab.teaches
GROUP BY professor;

-- R2: students linked to their professor
CREATE TABLE bcnflab.enrollment (
  student   TEXT NOT NULL,
  professor TEXT NOT NULL REFERENCES bcnflab.prof_course(professor),
  PRIMARY KEY(student, professor)
);

INSERT INTO bcnflab.enrollment(student, professor)
SELECT DISTINCT student, professor
FROM bcnflab.teaches;

-- Lossless join check (set equality via EXCEPT should return 0 rows)
(SELECT student, course, professor FROM bcnflab.teaches
 EXCEPT
 SELECT e.student, p.course, e.professor
 FROM bcnflab.enrollment e JOIN bcnflab.prof_course p USING (professor))
UNION ALL
(SELECT e.student, p.course, e.professor
 FROM bcnflab.enrollment e JOIN bcnflab.prof_course p USING (professor)
 EXCEPT
 SELECT student, course, professor FROM bcnflab.teaches);

-- Optional: indexes
CREATE INDEX IF NOT EXISTS ix_enrollment_prof ON bcnflab.enrollment(professor);


-- =====================
-- Task B — Runs → BCNF
-- =====================

-- R1: driver determines route
CREATE TABLE bcnflab.driver_route (
  driver TEXT PRIMARY KEY,
  route  TEXT NOT NULL
);

INSERT INTO bcnflab.driver_route(driver, route)
SELECT driver, MIN(route)
FROM bcnflab.runs
GROUP BY driver;

-- R2: assignments by train and driver
CREATE TABLE bcnflab.assignments (
  train_no INT  NOT NULL,
  driver   TEXT NOT NULL REFERENCES bcnflab.driver_route(driver),
  PRIMARY KEY(train_no, driver)
);

INSERT INTO bcnflab.assignments(train_no, driver)
SELECT DISTINCT train_no, driver
FROM bcnflab.runs;

-- Lossless join check (set equality)
(SELECT train_no, route, driver FROM bcnflab.runs
 EXCEPT
 SELECT a.train_no, d.route, a.driver
 FROM bcnflab.assignments a JOIN bcnflab.driver_route d USING (driver))
UNION ALL
(SELECT a.train_no, d.route, a.driver
 FROM bcnflab.assignments a JOIN bcnflab.driver_route d USING (driver)
 EXCEPT
 SELECT train_no, route, driver FROM bcnflab.runs);

-- Optional: indexes
CREATE INDEX IF NOT EXISTS ix_assignments_driver ON bcnflab.assignments(driver);

COMMIT;

-- =====================
-- Demonstrate the win
-- =====================
-- Before: changing a professor's course in the single-table design required
-- multiple row updates. After BCNF, it's a single row:
-- UPDATE bcnflab.prof_course SET course='Data Systems' WHERE professor='Smith';
-- SELECT e.student, p.course FROM bcnflab.enrollment e JOIN bcnflab.prof_course p USING (professor) WHERE professor='Smith';

-- Likewise for drivers changing routes:
-- UPDATE bcnflab.driver_route SET route='Airport' WHERE driver='Patel';
-- SELECT a.train_no, d.route FROM bcnflab.assignments a JOIN bcnflab.driver_route d USING (driver) WHERE driver='Patel';
