-- =============================================================
-- IPT Issues Reporting App - Source Database
-- =============================================================
-- This simulates the operational database of an app where
-- IPT staff and students can report maintenance issues.
-- =============================================================

-- Buildings reference table
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    code VARCHAR(5) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

INSERT INTO buildings (code, name, description) VALUES
('O', 'Bloco O', 'Salas de aula de informática e escritórios'),
('B', 'Bloco B', 'Anfiteatros e salas de aulas grandes'),
('I', 'Bloco I', 'Laboratórios de informática');

-- Issues table (main operational data)
CREATE TABLE issues (
    id SERIAL PRIMARY KEY,
    room_code VARCHAR(10) NOT NULL,
    building_code VARCHAR(5) NOT NULL REFERENCES buildings(code),
    category VARCHAR(50) NOT NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    title VARCHAR(200) NOT NULL,
    description TEXT,
    reported_by VARCHAR(100),
    reported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'open',
    assigned_to VARCHAR(100),
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    
    CONSTRAINT chk_priority CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT chk_status CHECK (status IN ('open', 'in_progress', 'resolved', 'closed'))
);

-- Create indexes for common queries
CREATE INDEX idx_issues_status ON issues(status);
CREATE INDEX idx_issues_building ON issues(building_code);
CREATE INDEX idx_issues_reported_at ON issues(reported_at);

-- =============================================================
-- SAMPLE DATA - Realistic IPT maintenance issues
-- =============================================================

-- BUILDING O - Informatics classrooms
INSERT INTO issues (room_code, building_code, category, priority, title, description, reported_by, reported_at, status, assigned_to, resolved_at, resolution_notes) VALUES
('O103', 'O', 'electrical', 'high', 'Projector not working', 'The ceiling projector does not turn on. Lamp might need replacement.', 'Prof. Silva', NOW() - INTERVAL '45 days', 'closed', 'Manutenção Geral', NOW() - INTERVAL '43 days', 'Lamp replaced, working correctly now.'),
('O104', 'O', 'electrical', 'medium', 'Flickering lights', 'Lights flicker intermittently, especially in the morning.', 'Prof. Costa', NOW() - INTERVAL '30 days', 'closed', 'Electricista', NOW() - INTERVAL '28 days', 'Replaced faulty ballast.'),
('O105', 'O', 'furniture', 'low', 'Broken chair', 'One student chair has a broken leg.', 'Estudante', NOW() - INTERVAL '20 days', 'resolved', 'Manutenção Geral', NOW() - INTERVAL '15 days', 'Chair replaced from storage.'),
('O106', 'O', 'equipment', 'medium', 'Computer #5 not booting', 'Computer in position 5 shows blue screen on startup.', 'Prof. Martins', NOW() - INTERVAL '10 days', 'in_progress', 'IT Support', NULL, NULL),
('O103', 'O', 'cleaning', 'low', 'Room needs deep cleaning', 'Floor is dirty and whiteboard has permanent marks.', 'Prof. Silva', NOW() - INTERVAL '5 days', 'open', NULL, NULL, NULL);

-- BUILDING B - Amphitheaters
INSERT INTO issues (room_code, building_code, category, priority, title, description, reported_by, reported_at, status, assigned_to, resolved_at, resolution_notes) VALUES
('B255', 'B', 'audio_visual', 'high', 'Microphone not working', 'The wireless microphone has no sound. Batteries replaced but issue persists.', 'Prof. Ferreira', NOW() - INTERVAL '60 days', 'closed', 'IT Support', NOW() - INTERVAL '58 days', 'Receiver was unplugged, fixed.'),
('B256', 'B', 'hvac', 'urgent', 'No air conditioning', 'AC unit not working, room extremely hot in the afternoon.', 'Prof. Santos', NOW() - INTERVAL '25 days', 'closed', 'HVAC Técnico', NOW() - INTERVAL '20 days', 'Compressor replaced.'),
('B255', 'B', 'furniture', 'medium', 'Broken seat row 3', 'Seat 3C is broken and unstable.', 'Estudante', NOW() - INTERVAL '15 days', 'resolved', 'Manutenção Geral', NOW() - INTERVAL '12 days', 'Seat mechanism fixed.'),
('B256', 'B', 'electrical', 'low', 'Power outlet not working', 'Outlet near the podium does not work.', 'Prof. Almeida', NOW() - INTERVAL '8 days', 'open', NULL, NULL, NULL);

-- BUILDING I - Informatics labs (with specific issues you mentioned)
INSERT INTO issues (room_code, building_code, category, priority, title, description, reported_by, reported_at, status, assigned_to, resolved_at, resolution_notes) VALUES
('I153', 'I', 'hvac', 'high', 'Heating system malfunction', 'Heating system does not work. Room is very cold in winter months.', 'Prof. Oliveira', NOW() - INTERVAL '90 days', 'in_progress', 'HVAC Técnico', NULL, NULL),
('I154', 'I', 'hvac', 'high', 'Heating not functioning', 'Similar to I153, heating radiators are cold.', 'Prof. Pereira', NOW() - INTERVAL '85 days', 'in_progress', 'HVAC Técnico', NULL, NULL),
('I154', 'I', 'structural', 'urgent', 'Water leak when raining', 'Water enters through the window area when it rains heavily. Computers at risk.', 'IT Support', NOW() - INTERVAL '40 days', 'in_progress', 'Obras', NULL, NULL),
('I178', 'I', 'maintenance', 'low', 'Room needs repainting', 'Walls have marks and paint is peeling in some areas. Needs fresh coat.', 'Direção', NOW() - INTERVAL '120 days', 'open', NULL, NULL, NULL),
('I153', 'I', 'equipment', 'medium', 'Printer paper jam', 'Printer frequently jams. Needs servicing.', 'Prof. Rodrigues', NOW() - INTERVAL '7 days', 'open', NULL, NULL, NULL),
('I178', 'I', 'network', 'high', 'WiFi signal weak', 'WiFi signal is very weak in this room. Students cannot connect reliably.', 'Estudante', NOW() - INTERVAL '3 days', 'open', NULL, NULL, NULL);

-- Some older resolved issues for historical data
INSERT INTO issues (room_code, building_code, category, priority, title, description, reported_by, reported_at, status, assigned_to, resolved_at, resolution_notes) VALUES
('O103', 'O', 'equipment', 'medium', 'Mouse not working', 'Computer 3 mouse is broken.', 'Estudante', NOW() - INTERVAL '180 days', 'closed', 'IT Support', NOW() - INTERVAL '178 days', 'Mouse replaced.'),
('B255', 'B', 'cleaning', 'low', 'Dirty windows', 'Windows need cleaning, affecting visibility.', 'Prof. Ferreira', NOW() - INTERVAL '150 days', 'closed', 'Limpeza', NOW() - INTERVAL '148 days', 'Windows cleaned.'),
('I153', 'I', 'electrical', 'medium', 'Extension cord needed', 'Not enough power outlets for all computers.', 'Prof. Oliveira', NOW() - INTERVAL '200 days', 'closed', 'Manutenção Geral', NOW() - INTERVAL '195 days', 'Installed power strip.');
