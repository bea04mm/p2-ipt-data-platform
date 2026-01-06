-- =============================================================
-- IPT Summaries & Attendance App - Source Database Schema
-- =============================================================
-- Class summaries (lesson records) and student attendance.
-- This file creates the schema structure only.
-- Run the Python generator to populate with seed data.
-- =============================================================

-- Courses
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    degree_type VARCHAR(20) NOT NULL
);

-- Course units (disciplines)
CREATE TABLE course_units (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    course_id INTEGER REFERENCES courses(id),
    semester INTEGER,
    year INTEGER,
    ects INTEGER,
    teacher_name VARCHAR(100),
    teacher_email VARCHAR(100)
);

-- Students
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(100),
    course_id INTEGER REFERENCES courses(id),
    year INTEGER,
    status VARCHAR(20) DEFAULT 'active'
);

-- Course unit enrollments
CREATE TABLE enrollments (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id),
    course_unit_id INTEGER NOT NULL REFERENCES course_units(id),
    academic_year VARCHAR(9) NOT NULL,
    status VARCHAR(20) DEFAULT 'enrolled',
    UNIQUE(student_id, course_unit_id, academic_year)
);

-- Class summaries (sumários)
CREATE TABLE summaries (
    id SERIAL PRIMARY KEY,
    course_unit_id INTEGER NOT NULL REFERENCES course_units(id),
    class_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_code VARCHAR(10),
    summary_number INTEGER,
    topic VARCHAR(500) NOT NULL,
    description TEXT,
    class_type VARCHAR(20) DEFAULT 'theoretical', -- theoretical, practical, lab
    teacher_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Attendance records
CREATE TABLE attendance (
    id SERIAL PRIMARY KEY,
    summary_id INTEGER NOT NULL REFERENCES summaries(id),
    student_id INTEGER NOT NULL REFERENCES students(id),
    present BOOLEAN NOT NULL DEFAULT false,
    arrival_time TIME,
    notes VARCHAR(200),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(summary_id, student_id)
);

-- Indexes
CREATE INDEX idx_summaries_course_unit ON summaries(course_unit_id);
CREATE INDEX idx_summaries_date ON summaries(class_date);
CREATE INDEX idx_attendance_summary ON attendance(summary_id);
CREATE INDEX idx_attendance_student ON attendance(student_id);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course_unit ON enrollments(course_unit_id);
CREATE INDEX idx_students_course ON students(course_id);

-- =============================================================
-- REFERENCE DATA
-- =============================================================

INSERT INTO courses (code, name, degree_type) VALUES
('LEI', 'Licenciatura em Engenharia Informática', 'licenciatura'),
('MEI-IoT', 'Mestrado em Engenharia Informática - Internet das Coisas', 'mestrado');

-- LEI Course Units (1st semester)
INSERT INTO course_units (code, name, course_id, semester, year, ects, teacher_name, teacher_email) VALUES
-- Year 1
('LEI-AM1', 'Análise Matemática I', 1, 1, 1, 6, 'Prof. Luís Merca', 'luis.merca@ipt.pt'),
('LEI-ALG', 'Álgebra', 1, 1, 1, 6, 'Prof. Carlos Perquilhas', 'carlos.perquilhas@ipt.pt'),
('LEI-IET', 'Introdução à Engenharia e à Tecnologia', 1, 1, 1, 3, 'Prof. Luís Miguel Oliveira', 'luis.oliveira@ipt.pt'),
('LEI-IPRP', 'Introdução à Programação e à Resolução de Problemas', 1, 1, 1, 6, 'Prof. António Manso', 'antonio.manso@ipt.pt'),
('LEI-SD', 'Sistemas Digitais', 1, 1, 1, 6, 'Prof. Manuel Barros', 'manuel.barros@ipt.pt'),
-- Year 2
('LEI-POO', 'Programação Orientada a Objetos', 1, 1, 2, 6, 'Prof. António Manso', 'antonio.manso@ipt.pt'),
('LEI-BD', 'Bases de Dados', 1, 1, 2, 6, 'Prof. Hélder Pestana', 'helder.pestana@ipt.pt'),
('LEI-RC', 'Redes de Computadores', 1, 1, 2, 6, 'Prof. José Pereira', 'jose.pereira@ipt.pt'),
('LEI-SO', 'Sistemas Operativos', 1, 1, 2, 6, 'Prof. Pedro Correia', 'pedro.correia@ipt.pt'),
-- Year 3
('LEI-ES', 'Engenharia de Software', 1, 1, 3, 6, 'Prof. Renato Panda', 'renato.panda@ipt.pt'),
('LEI-SDist', 'Sistemas Distribuídos', 1, 1, 3, 6, 'Prof. Gabriel Pires', 'gabriel.pires@ipt.pt'),
('LEI-IA', 'Inteligência Artificial', 1, 1, 3, 6, 'Prof. Ana Lopes', 'ana.lopes@ipt.pt'),
('LEI-SEG', 'Segurança Informática', 1, 1, 3, 6, 'Prof. Luís Miguel Oliveira', 'luis.oliveira@ipt.pt');

-- MEI-IoT Course Units (1st semester)
INSERT INTO course_units (code, name, course_id, semester, year, ects, teacher_name, teacher_email) VALUES
('MEI-AGVD', 'Análise de Grande Volume de Dados', 2, 1, 1, 6, 'Prof. Renato Panda', 'renato.panda@ipt.pt'),
('MEI-AC', 'Aprendizagem Computacional', 2, 1, 1, 6, 'Prof. Gabriel Pires', 'gabriel.pires@ipt.pt'),
('MEI-ES', 'Engenharia de Software', 2, 1, 1, 6, 'Prof. Renato Panda', 'renato.panda@ipt.pt');
