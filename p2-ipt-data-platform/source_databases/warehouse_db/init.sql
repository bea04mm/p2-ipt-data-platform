-- 1. Enable the Foreign Data Wrapper extension
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- =========================================================
-- CONNECTING ISSUES DATABASE
-- =========================================================
-- A. Create the Server Object (Points to the container)
CREATE SERVER issues_server 
FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS (host 'ipt_issues_db', dbname 'issues_app', port '5432');

-- B. Create User Mapping (Permissions)
CREATE USER MAPPING FOR warehouse_user
SERVER issues_server 
OPTIONS (user 'issues_user', password 'issues_pass');

-- C. Create a Schema and Import Tables
CREATE SCHEMA IF NOT EXISTS src_issues;

IMPORT FOREIGN SCHEMA public 
FROM SERVER issues_server 
INTO src_issues;


-- =========================================================
-- CONNECTING RESERVATIONS DATABASE
-- =========================================================
CREATE SERVER reservations_server 
FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS (host 'ipt_reservations_db', dbname 'reservations_app', port '5432');

CREATE USER MAPPING FOR warehouse_user
SERVER reservations_server 
OPTIONS (user 'reservations_user', password 'reservations_pass');

CREATE SCHEMA IF NOT EXISTS src_reservations;

IMPORT FOREIGN SCHEMA public 
FROM SERVER reservations_server 
INTO src_reservations;


-- =========================================================
-- CONNECTING ATTENDANCE DATABASE
-- =========================================================
CREATE SERVER attendance_server 
FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS (host 'ipt_attendance_db', dbname 'attendance_app', port '5432');

CREATE USER MAPPING FOR warehouse_user
SERVER attendance_server 
OPTIONS (user 'attendance_user', password 'attendance_pass');

CREATE SCHEMA IF NOT EXISTS src_attendance;

IMPORT FOREIGN SCHEMA public 
FROM SERVER attendance_server 
INTO src_attendance;


-- =========================================================
-- CONNECTING SIGQ DATABASE
-- =========================================================
CREATE SERVER sigq_server 
FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS (host 'ipt_sigq_db', dbname 'sigq_app', port '5432');

CREATE USER MAPPING FOR warehouse_user
SERVER sigq_server 
OPTIONS (user 'sigq_user', password 'sigq_pass');

CREATE SCHEMA IF NOT EXISTS src_sigq;

IMPORT FOREIGN SCHEMA public 
FROM SERVER sigq_server 
INTO src_sigq;