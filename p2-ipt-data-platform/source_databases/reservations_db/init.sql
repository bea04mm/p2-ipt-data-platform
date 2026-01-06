-- =============================================================
-- IPT Room Reservations App - Source Database Schema
-- =============================================================
-- Room bookings for classes, exams, meetings, events.
-- This file creates the schema structure only.
-- Run the Python generator to populate with seed data.
-- =============================================================

-- Buildings at IPT
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    code VARCHAR(5) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    address TEXT
);

-- Rooms catalog
CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    building_code VARCHAR(5) NOT NULL REFERENCES buildings(code),
    name VARCHAR(100),
    room_type VARCHAR(50) NOT NULL,
    capacity INTEGER NOT NULL,
    has_projector BOOLEAN DEFAULT false,
    has_video_conference BOOLEAN DEFAULT false,
    has_computers BOOLEAN DEFAULT false,
    computer_count INTEGER DEFAULT 0,
    has_whiteboard BOOLEAN DEFAULT true,
    has_air_conditioning BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    notes TEXT
);

-- Reservation categories
CREATE TABLE reservation_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    requires_approval BOOLEAN DEFAULT false,
    color VARCHAR(7) -- hex color for calendar display
);

-- Courses at IPT (for class reservations)
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    degree_type VARCHAR(20) NOT NULL, -- licenciatura, mestrado
    department VARCHAR(100),
    is_active BOOLEAN DEFAULT true
);

-- Course units (disciplines)
CREATE TABLE course_units (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    course_id INTEGER REFERENCES courses(id),
    semester INTEGER, -- 1 or 2
    year INTEGER, -- 1, 2, 3
    ects INTEGER,
    teacher VARCHAR(100),
    teacher_email VARCHAR(100)
);

-- Main reservations table
CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    room_id INTEGER NOT NULL REFERENCES rooms(id),
    reservation_type_id INTEGER NOT NULL REFERENCES reservation_types(id),
    course_unit_id INTEGER REFERENCES course_units(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    reserved_by VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    reservation_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    recurrence_rule VARCHAR(100), -- weekly, etc
    status VARCHAR(20) NOT NULL DEFAULT 'confirmed',
    attendee_count INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    
    CONSTRAINT chk_status CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    CONSTRAINT chk_time CHECK (end_time > start_time)
);

-- Indexes
CREATE INDEX idx_reservations_date ON reservations(reservation_date);
CREATE INDEX idx_reservations_room ON reservations(room_id);
CREATE INDEX idx_reservations_status ON reservations(status);
CREATE INDEX idx_reservations_type ON reservations(reservation_type_id);
CREATE INDEX idx_rooms_building ON rooms(building_code);

-- =============================================================
-- REFERENCE DATA
-- =============================================================

INSERT INTO buildings (code, name, address) VALUES
('A', 'Bloco A', 'Campus IPT - Tomar'),
('B', 'Bloco B', 'Campus IPT - Tomar'),
('G', 'Bloco G', 'Campus IPT - Tomar'),
('H', 'Bloco H', 'Campus IPT - Tomar'),
('I', 'Bloco I', 'Campus IPT - Tomar'),
('O', 'Bloco O', 'Campus IPT - Tomar');

INSERT INTO reservation_types (code, name, requires_approval, color) VALUES
('class', 'Aula Regular', false, '#4CAF50'),
('lab', 'Aula Laboratorial', false, '#2196F3'),
('exam', 'Exame', false, '#F44336'),
('exam_recurso', 'Exame de Recurso', false, '#E91E63'),
('defense', 'Defesa de Tese/Projeto', true, '#9C27B0'),
('meeting', 'Reunião', false, '#FF9800'),
('event', 'Evento', true, '#00BCD4'),
('workshop', 'Workshop', true, '#795548'),
('maintenance', 'Manutenção', false, '#607D8B');

INSERT INTO courses (code, name, degree_type, department) VALUES
('LEI', 'Licenciatura em Engenharia Informática', 'licenciatura', 'Departamento de Engenharia Informática'),
('MEI-IoT', 'Mestrado em Engenharia Informática - Internet das Coisas', 'mestrado', 'Departamento de Engenharia Informática'),
('LEEC', 'Licenciatura em Engenharia Eletrotécnica e de Computadores', 'licenciatura', 'Departamento de Engenharia'),
('LITM', 'Licenciatura em Informática e Tecnologias Multimédia', 'licenciatura', 'Departamento de Engenharia Informática'),
('LCL', 'Licenciatura em Computação e Logística', 'licenciatura', 'Departamento de Engenharia'),
('MAIO', 'Mestrado em Analítica e Inteligência Organizacional', 'mestrado', 'Departamento de Gestão');

-- LEI Course Units (1st semester courses from years 1, 2, 3)
INSERT INTO course_units (code, name, course_id, semester, year, ects, teacher, teacher_email) VALUES
-- LEI Year 1
('LEI-AM1', 'Análise Matemática I', 1, 1, 1, 6, 'Prof. Luís Merca', 'luis.merca@ipt.pt'),
('LEI-ALG', 'Álgebra', 1, 1, 1, 6, 'Prof. Carlos Perquilhas', 'carlos.perquilhas@ipt.pt'),
('LEI-IET', 'Introdução à Engenharia e à Tecnologia', 1, 1, 1, 3, 'Prof. Luís Miguel Oliveira', 'luis.oliveira@ipt.pt'),
('LEI-IPRP', 'Introdução à Programação e à Resolução de Problemas', 1, 1, 1, 6, 'Prof. António Manso', 'antonio.manso@ipt.pt'),
('LEI-SD', 'Sistemas Digitais', 1, 1, 1, 6, 'Prof. Manuel Barros', 'manuel.barros@ipt.pt'),
-- LEI Year 2
('LEI-POO', 'Programação Orientada a Objetos', 1, 1, 2, 6, 'Prof. António Manso', 'antonio.manso@ipt.pt'),
('LEI-BD', 'Bases de Dados', 1, 1, 2, 6, 'Prof. Hélder Pestana', 'helder.pestana@ipt.pt'),
('LEI-RC', 'Redes de Computadores', 1, 1, 2, 6, 'Prof. José Pereira', 'jose.pereira@ipt.pt'),
('LEI-SO', 'Sistemas Operativos', 1, 1, 2, 6, 'Prof. Pedro Correia', 'pedro.correia@ipt.pt'),
-- LEI Year 3
('LEI-ES', 'Engenharia de Software', 1, 1, 3, 6, 'Prof. Renato Panda', 'renato.panda@ipt.pt'),
('LEI-SD3', 'Sistemas Distribuídos', 1, 1, 3, 6, 'Prof. Gabriel Pires', 'gabriel.pires@ipt.pt'),
('LEI-IA', 'Inteligência Artificial', 1, 1, 3, 6, 'Prof. Ana Lopes', 'ana.lopes@ipt.pt'),
('LEI-SEG', 'Segurança Informática', 1, 1, 3, 6, 'Prof. Luís Miguel Oliveira', 'luis.oliveira@ipt.pt');

-- MEI-IoT Course Units (1st semester)
INSERT INTO course_units (code, name, course_id, semester, year, ects, teacher, teacher_email) VALUES
('MEI-AGVD', 'Análise de Grande Volume de Dados', 2, 1, 1, 6, 'Prof. Renato Panda', 'renato.panda@ipt.pt'),
('MEI-AC', 'Aprendizagem Computacional', 2, 1, 1, 6, 'Prof. Gabriel Pires', 'gabriel.pires@ipt.pt'),
('MEI-ES', 'Engenharia de Software', 2, 1, 1, 6, 'Prof. Renato Panda', 'renato.panda@ipt.pt');

-- Rooms
INSERT INTO rooms (code, building_code, name, room_type, capacity, has_projector, has_video_conference, has_computers, computer_count, has_air_conditioning, notes) VALUES
-- Building O - Classrooms and computer labs
('O101', 'O', 'Sala O101', 'classroom', 35, true, false, false, 0, true, NULL),
('O102', 'O', 'Sala O102', 'classroom', 35, true, false, false, 0, true, NULL),
('O103', 'O', 'Sala O103', 'computer_lab', 25, true, false, true, 25, true, 'Laboratório de informática'),
('O104', 'O', 'Sala O104', 'computer_lab', 25, true, false, true, 25, true, 'Laboratório de informática'),
('O105', 'O', 'Sala O105', 'classroom', 30, true, false, false, 0, true, NULL),
('O106', 'O', 'Sala O106', 'classroom', 30, true, true, false, 0, true, 'Sala com videoconferência'),
('O201', 'O', 'Sala O201', 'classroom', 40, true, false, false, 0, false, NULL),
('O202', 'O', 'Sala O202', 'classroom', 40, true, false, false, 0, false, NULL),
-- Building B - Amphitheaters
('B250', 'B', 'Anfiteatro B250', 'amphitheater', 100, true, true, false, 0, true, 'Anfiteatro principal'),
('B251', 'B', 'Anfiteatro B251', 'amphitheater', 80, true, false, false, 0, true, NULL),
('B252', 'B', 'Anfiteatro B252', 'amphitheater', 80, true, false, false, 0, true, NULL),
('B253', 'B', 'Sala B253', 'classroom', 50, true, false, false, 0, true, NULL),
('B254', 'B', 'Sala B254', 'classroom', 50, true, false, false, 0, true, NULL),
('B255', 'B', 'Anfiteatro B255', 'amphitheater', 120, true, true, false, 0, true, 'Anfiteatro grande com sistema de som'),
('B256', 'B', 'Anfiteatro B256', 'amphitheater', 90, true, false, false, 0, true, NULL),
('B257', 'B', 'Sala B257', 'classroom', 45, true, false, false, 0, false, NULL),
('B258', 'B', 'Sala B258', 'classroom', 45, true, false, false, 0, false, NULL),
('B259', 'B', 'Sala B259', 'classroom', 40, true, false, false, 0, false, NULL),
('B260', 'B', 'Anfiteatro B260', 'amphitheater', 70, true, false, false, 0, true, NULL),
-- Building I - Computer Labs
('I153', 'I', 'Laboratório I153', 'computer_lab', 24, true, false, true, 24, false, 'Laboratório de informática'),
('I154', 'I', 'Laboratório I154', 'computer_lab', 24, true, false, true, 24, false, 'Laboratório de informática'),
('I155', 'I', 'Laboratório I155', 'computer_lab', 20, true, false, true, 20, false, 'Laboratório de redes'),
('I156', 'I', 'Laboratório I156', 'computer_lab', 20, true, false, true, 20, false, 'Laboratório de sistemas'),
('I176', 'I', 'Laboratório I176', 'computer_lab', 24, true, false, true, 24, true, 'Lab informática com AC'),
('I177', 'I', 'Laboratório I177', 'computer_lab', 24, true, false, true, 24, true, NULL),
('I178', 'I', 'Laboratório I178', 'computer_lab', 22, true, true, true, 22, true, 'Lab com videoconferência'),
('I179', 'I', 'Laboratório I179', 'computer_lab', 22, true, false, true, 22, true, NULL),
('I180', 'I', 'Laboratório I180', 'computer_lab', 20, true, false, true, 20, false, NULL),
('I181', 'I', 'Laboratório I181', 'computer_lab', 20, true, false, true, 20, false, NULL),
('I182', 'I', 'Laboratório I182', 'computer_lab', 18, true, false, true, 18, false, 'Laboratório de projeto'),
-- Building G - Engineering Labs
('G150', 'G', 'Laboratório G150', 'lab', 30, true, false, false, 0, false, 'Laboratório de eletrónica'),
('G151', 'G', 'Laboratório G151', 'lab', 30, true, false, false, 0, false, 'Laboratório de eletrotecnia'),
('G152', 'G', 'Laboratório G152', 'lab', 25, true, false, true, 10, false, 'Lab de automação'),
('G153', 'G', 'Laboratório G153', 'lab', 25, true, false, false, 0, false, 'Oficinas'),
('G154', 'G', 'Laboratório G154', 'lab', 20, true, false, false, 0, false, 'Laboratório de ensaios'),
-- Building H - Meeting rooms and offices
('H201', 'H', 'Sala de Reuniões H201', 'meeting_room', 12, true, true, false, 0, true, 'Sala de reuniões principal'),
('H202', 'H', 'Sala de Reuniões H202', 'meeting_room', 8, true, false, false, 0, true, 'Sala de reuniões pequena'),
('H216', 'H', 'Sala H216', 'classroom', 20, true, false, false, 0, false, 'Sala de seminários'),
('H217', 'H', 'Sala H217', 'classroom', 20, true, false, false, 0, false, NULL);
