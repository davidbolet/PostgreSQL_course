-- BCNF Mini-Lab — Denormalized seeds (3NF but NOT BCNF)
-- Schema: bcnflab
-- Two scenarios designed to be in 3NF yet violate BCNF.

DROP SCHEMA IF EXISTS bcnflab CASCADE;
CREATE SCHEMA bcnflab;

-- ================================================
-- Scenario A: teaches(student, course, professor)
-- FDs:
--   1) (student, course) -> professor
--   2) professor -> course       -- determinant not a key
-- Keys: {student, course} and {student, professor}
-- 3NF: yes (RHS of FD2 is prime: 'course' is in a key)
-- BCNF: no (determinant 'professor' not a superkey)
-- ================================================
CREATE TABLE bcnflab.teaches (
  student   TEXT NOT NULL,
  course    TEXT NOT NULL,
  professor TEXT NOT NULL,
  PRIMARY KEY(student, course)
);

INSERT INTO bcnflab.teaches(student, course, professor) VALUES
('Ada',    'Databases',   'Smith'),
('Alan',   'Databases',   'Smith'),
('Grace',  'Algorithms',  'Jones'),
('Edsger', 'Algorithms',  'Jones'),
('Ada',    'Compilers',   'Aho');

-- Optional probe: each professor teaches exactly one course (FD2)
-- SELECT professor, array_agg(DISTINCT course) FROM bcnflab.teaches GROUP BY professor;

-- ================================================
-- Scenario B: runs(train_no, route, driver)
-- FDs:
--   1) (train_no, route) -> driver
--   2) driver -> route            -- determinant not a key
-- Keys: {train_no, route} and {train_no, driver}
-- 3NF: yes (RHS of FD2 is prime: 'route' is in a key)
-- BCNF: no (determinant 'driver' not a superkey)
-- ================================================
CREATE TABLE bcnflab.runs (
  train_no INT  NOT NULL,
  route    TEXT NOT NULL,
  driver   TEXT NOT NULL,
  PRIMARY KEY(train_no, route)
);

INSERT INTO bcnflab.runs(train_no, route, driver) VALUES
(101, 'Coastal',  'Kim'),
(102, 'Coastal',  'Kim'),
(103, 'Mountain', 'Lee'),
(104, 'City',     'Patel'),
(105, 'City',     'Patel');

-- Optional probe: each driver drives exactly one route (FD2)
-- SELECT driver, array_agg(DISTINCT route) FROM bcnflab.runs GROUP BY driver;
