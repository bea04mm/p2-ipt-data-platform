-- =============================================================
-- IPT Room Reservations App - Source Database
-- =============================================================
-- This simulates the operational database of an app for
-- booking rooms at IPT (classes, exams, meetings, events).
-- =============================================================

-- Rooms catalog
CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    building VARCHAR(5) NOT NULL,
    name VARCHAR(100),
    room_type VARCHAR(50) NOT NULL,
    capacity INTEGER NOT NULL,
    has_projector BOOLEAN DEFAULT false,
    has_video_conference BOOLEAN DEFAULT false,
    has_computers BOOLEAN DEFAULT false,
    computer_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    notes TEXT
);

-- Insert IPT rooms (matching the issues app)
INSERT INTO rooms (code, building, name, room_type, capacity, has_projector, has_video_conference, has_computers, computer_count, notes) VALUES
-- Building O - Regular classrooms
('O103', 'O', 'Sala O103', 'classroom', 30, true, false, true, 15, 'Informatics classroom with computers'),
('O104', 'O', 'Sala O104', 'classroom', 25, true, false, false, 0, 'Regular classroom'),
('O105', 'O', 'Sala O105', 'classroom', 28, true, false, false, 0, 'Regular classroom'),
('O106', 'O', 'Sala O106', 'classroom', 30, true, true, true, 20, 'Informatics classroom with video conference'),

-- Building B - Amphitheaters
('B255', 'B', 'Anfiteatro B255', 'amphitheater', 120, true, true, false, 0, 'Large amphitheater with audio system'),
('B256', 'B', 'Anfiteatro B256', 'amphitheater', 80, true, false, false, 0, 'Medium amphitheater'),

-- Building I - Informatics labs
('I153', 'I', 'Laboratório I153', 'computer_lab', 24, true, false, true, 24, 'Full computer lab'),
('I154', 'I', 'Laboratório I154', 'computer_lab', 24, true, false, true, 24, 'Full computer lab - window issue'),
('I178', 'I', 'Laboratório I178', 'computer_lab', 20, true, true, true, 20, 'Computer lab with video conference');

-- Reservation types
CREATE TABLE reservation_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    requires_approval BOOLEAN DEFAULT false
);

INSERT INTO reservation_types (code, name, requires_approval) VALUES
('class', 'Aula Regular', false),
('exam', 'Exame', false),
('defense', 'Defesa de Tese/Projeto', true),
('meeting', 'Reunião', false),
('event', 'Evento', true),
('maintenance', 'Manutenção', false);

-- Reservations table (main operational data)
CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    room_id INTEGER NOT NULL REFERENCES rooms(id),
    reservation_type_id INTEGER NOT NULL REFERENCES reservation_types(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    reserved_by VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    reservation_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'confirmed',
    attendee_count INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    
    CONSTRAINT chk_status CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    CONSTRAINT chk_time CHECK (end_time > start_time)
);

CREATE INDEX idx_reservations_date ON reservations(reservation_date);
CREATE INDEX idx_reservations_room ON reservations(room_id);
CREATE INDEX idx_reservations_status ON reservations(status);

-- =============================================================
-- SAMPLE DATA - Generate reservations for past 3 months
-- =============================================================

-- Helper: Class reservations (recurring weekly)
-- Fall semester classes (Oct-Dec 2025)

-- Monday classes
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
-- Big Data classes in I153 (Mondays 9:00-12:00)
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-10-06', '09:00', '12:00', 'completed', 18, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-10-13', '09:00', '12:00', 'completed', 20, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-10-20', '09:00', '12:00', 'completed', 19, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-10-27', '09:00', '12:00', 'completed', 17, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-11-03', '09:00', '12:00', 'completed', 21, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-11-10', '09:00', '12:00', 'completed', 18, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-11-17', '09:00', '12:00', 'completed', 20, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-11-24', '09:00', '12:00', 'completed', 16, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-12-01', '09:00', '12:00', 'completed', 22, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-12-08', '09:00', '12:00', 'completed', 19, '2025-09-15'),
(7, 1, 'Big Data - MEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-12-15', '09:00', '12:00', 'confirmed', 20, '2025-09-15');

-- Software Engineering in I154 (Mondays 14:00-17:00)
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-10-06', '14:00', '17:00', 'completed', 22, '2025-09-15'),
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-10-13', '14:00', '17:00', 'completed', 24, '2025-09-15'),
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-10-20', '14:00', '17:00', 'completed', 21, '2025-09-15'),
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-10-27', '14:00', '17:00', 'completed', 23, '2025-09-15'),
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-11-03', '14:00', '17:00', 'completed', 20, '2025-09-15'),
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-11-10', '14:00', '17:00', 'completed', 24, '2025-09-15'),
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-11-17', '14:00', '17:00', 'completed', 22, '2025-09-15'),
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-11-24', '14:00', '17:00', 'completed', 19, '2025-09-15'),
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-12-01', '14:00', '17:00', 'completed', 23, '2025-09-15'),
(8, 1, 'Engenharia de Software - LEI', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-12-08', '14:00', '17:00', 'completed', 21, '2025-09-15');

-- Amphitheater events and classes
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
-- B255 - Large lectures
(5, 1, 'Introdução à Programação - LEI', 'Prof. Ferreira', 'ferreira@ipt.pt', '2025-10-07', '09:00', '11:00', 'completed', 95, '2025-09-10'),
(5, 1, 'Introdução à Programação - LEI', 'Prof. Ferreira', 'ferreira@ipt.pt', '2025-10-14', '09:00', '11:00', 'completed', 92, '2025-09-10'),
(5, 1, 'Introdução à Programação - LEI', 'Prof. Ferreira', 'ferreira@ipt.pt', '2025-10-21', '09:00', '11:00', 'completed', 88, '2025-09-10'),
(5, 1, 'Introdução à Programação - LEI', 'Prof. Ferreira', 'ferreira@ipt.pt', '2025-10-28', '09:00', '11:00', 'completed', 90, '2025-09-10'),
(5, 1, 'Introdução à Programação - LEI', 'Prof. Ferreira', 'ferreira@ipt.pt', '2025-11-04', '09:00', '11:00', 'completed', 85, '2025-09-10'),
(5, 1, 'Introdução à Programação - LEI', 'Prof. Ferreira', 'ferreira@ipt.pt', '2025-11-11', '09:00', '11:00', 'completed', 87, '2025-09-10'),
(5, 1, 'Introdução à Programação - LEI', 'Prof. Ferreira', 'ferreira@ipt.pt', '2025-11-18', '09:00', '11:00', 'completed', 82, '2025-09-10'),
(5, 1, 'Introdução à Programação - LEI', 'Prof. Ferreira', 'ferreira@ipt.pt', '2025-11-25', '09:00', '11:00', 'completed', 80, '2025-09-10'),
(5, 1, 'Introdução à Programação - LEI', 'Prof. Ferreira', 'ferreira@ipt.pt', '2025-12-02', '09:00', '11:00', 'completed', 78, '2025-09-10');

-- Events and special reservations
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
(5, 5, 'Semana da Informática - Abertura', 'Núcleo de Estudantes', 'nei@ipt.pt', '2025-11-15', '14:00', '18:00', 'completed', 110, '2025-10-01'),
(5, 3, 'Defesa de Mestrado - João Silva', 'Secretariado', 'secretariado@ipt.pt', '2025-11-20', '10:00', '12:00', 'completed', 25, '2025-11-01'),
(6, 3, 'Defesa de Mestrado - Maria Santos', 'Secretariado', 'secretariado@ipt.pt', '2025-11-22', '14:30', '16:30', 'completed', 30, '2025-11-05'),
(5, 5, 'Workshop IoT', 'IEEE Student Branch', 'ieee@ipt.pt', '2025-12-05', '09:00', '13:00', 'completed', 75, '2025-11-10');

-- Exams
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
(5, 2, 'Exame - Introdução à Programação', 'Secretariado', 'secretariado@ipt.pt', '2025-12-18', '09:00', '12:00', 'confirmed', 100, '2025-11-15'),
(6, 2, 'Exame - Bases de Dados', 'Secretariado', 'secretariado@ipt.pt', '2025-12-19', '14:00', '17:00', 'confirmed', 65, '2025-11-15'),
(7, 2, 'Exame - Big Data', 'Secretariado', 'secretariado@ipt.pt', '2025-12-20', '09:00', '12:00', 'confirmed', 20, '2025-11-15');

-- Meetings
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
(9, 4, 'Reunião Departamento Informática', 'Prof. Director', 'diretor.di@ipt.pt', '2025-10-15', '14:00', '16:00', 'completed', 12, '2025-10-10'),
(9, 4, 'Reunião Departamento Informática', 'Prof. Director', 'diretor.di@ipt.pt', '2025-11-12', '14:00', '16:00', 'completed', 10, '2025-11-05'),
(9, 4, 'Reunião Departamento Informática', 'Prof. Director', 'diretor.di@ipt.pt', '2025-12-10', '14:00', '16:00', 'confirmed', 15, '2025-12-01');

-- Regular classroom usage
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
(1, 1, 'Redes de Computadores', 'Prof. Alves', 'alves@ipt.pt', '2025-10-08', '09:00', '11:00', 'completed', 25, '2025-09-10'),
(1, 1, 'Redes de Computadores', 'Prof. Alves', 'alves@ipt.pt', '2025-10-15', '09:00', '11:00', 'completed', 24, '2025-09-10'),
(1, 1, 'Redes de Computadores', 'Prof. Alves', 'alves@ipt.pt', '2025-10-22', '09:00', '11:00', 'completed', 26, '2025-09-10'),
(1, 1, 'Redes de Computadores', 'Prof. Alves', 'alves@ipt.pt', '2025-10-29', '09:00', '11:00', 'completed', 23, '2025-09-10'),
(1, 1, 'Redes de Computadores', 'Prof. Alves', 'alves@ipt.pt', '2025-11-05', '09:00', '11:00', 'completed', 25, '2025-09-10'),
(1, 1, 'Redes de Computadores', 'Prof. Alves', 'alves@ipt.pt', '2025-11-12', '09:00', '11:00', 'completed', 22, '2025-09-10'),
(1, 1, 'Redes de Computadores', 'Prof. Alves', 'alves@ipt.pt', '2025-11-19', '09:00', '11:00', 'completed', 24, '2025-09-10'),
(1, 1, 'Redes de Computadores', 'Prof. Alves', 'alves@ipt.pt', '2025-11-26', '09:00', '11:00', 'completed', 21, '2025-09-10'),
(1, 1, 'Redes de Computadores', 'Prof. Alves', 'alves@ipt.pt', '2025-12-03', '09:00', '11:00', 'completed', 23, '2025-09-10');

-- More varied usage in O104, O105, O106
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
(2, 1, 'Matemática I', 'Prof. Sousa', 'sousa@ipt.pt', '2025-10-09', '11:00', '13:00', 'completed', 20, '2025-09-10'),
(3, 1, 'Física', 'Prof. Lima', 'lima@ipt.pt', '2025-10-09', '14:00', '16:00', 'completed', 22, '2025-09-10'),
(4, 1, 'Sistemas Operativos', 'Prof. Mendes', 'mendes@ipt.pt', '2025-10-10', '09:00', '12:00', 'completed', 28, '2025-09-10');

-- Cancelled reservations (realistic scenarios)
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at, cancelled_at, cancellation_reason) VALUES
(7, 4, 'Reunião Projeto', 'Prof. Rodrigues', 'rodrigues@ipt.pt', '2025-11-08', '10:00', '11:00', 'cancelled', 5, '2025-11-01', '2025-11-07', 'Meeting moved online'),
(5, 5, 'Palestra Convidado', 'Coordenação', 'coord@ipt.pt', '2025-11-28', '14:00', '16:00', 'cancelled', 80, '2025-11-10', '2025-11-25', 'Speaker unavailable - rescheduled');

-- Completed maintenance
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
(8, 6, 'Manutenção HVAC', 'Manutenção', 'manutencao@ipt.pt', '2025-10-20', '08:00', '12:00', 'completed', 2, '2025-10-15');

-- I178 usage (with video conference room)
INSERT INTO reservations (room_id, reservation_type_id, title, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at) VALUES
(9, 4, 'Videoconferência - Parceiro Erasmus', 'Gabinete Internacional', 'gri@ipt.pt', '2025-10-25', '10:00', '11:30', 'completed', 8, '2025-10-20'),
(9, 4, 'Entrevista Online - Candidato', 'RH', 'rh@ipt.pt', '2025-11-05', '15:00', '16:00', 'completed', 3, '2025-11-01'),
(9, 1, 'Seminário IoT', 'Prof. Panda', 'renato.panda@ipt.pt', '2025-11-28', '09:00', '12:00', 'completed', 15, '2025-11-20');
