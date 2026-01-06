-- =============================================================
-- IPT Issues Reporting App - Source Database Schema
-- =============================================================
-- Staff and students report maintenance issues on campus.
-- This file creates the schema structure only.
-- Run the Python generator to populate with seed data.
-- =============================================================

-- Buildings at IPT campus
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    code VARCHAR(5) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    campus VARCHAR(50) DEFAULT 'Tomar'
);

-- Issue categories for classification
CREATE TABLE issue_categories (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Main issues table
CREATE TABLE issues (
    id SERIAL PRIMARY KEY,
    room_code VARCHAR(10),
    building_code VARCHAR(5) NOT NULL REFERENCES buildings(code),
    category_code VARCHAR(30) NOT NULL REFERENCES issue_categories(code),
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    title VARCHAR(200) NOT NULL,
    description TEXT,
    reported_by VARCHAR(100),
    reporter_email VARCHAR(100),
    reporter_type VARCHAR(20), -- student, teacher, staff
    reported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'open',
    assigned_to VARCHAR(100),
    assigned_at TIMESTAMP,
    resolved_at TIMESTAMP,
    closed_at TIMESTAMP,
    resolution_notes TEXT,
    
    CONSTRAINT chk_priority CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT chk_status CHECK (status IN ('open', 'in_progress', 'resolved', 'closed', 'cancelled'))
);

-- Issue comments/updates
CREATE TABLE issue_comments (
    id SERIAL PRIMARY KEY,
    issue_id INTEGER NOT NULL REFERENCES issues(id),
    comment_by VARCHAR(100) NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for common queries
CREATE INDEX idx_issues_status ON issues(status);
CREATE INDEX idx_issues_building ON issues(building_code);
CREATE INDEX idx_issues_category ON issues(category_code);
CREATE INDEX idx_issues_reported_at ON issues(reported_at);
CREATE INDEX idx_issues_priority ON issues(priority);

-- =============================================================
-- REFERENCE DATA - Buildings and Categories
-- =============================================================

INSERT INTO buildings (code, name, description) VALUES
('A', 'Bloco A', 'Edifício administrativo principal e serviços centrais'),
('B', 'Bloco B', 'Anfiteatros e salas de aula de grande capacidade'),
('G', 'Bloco G', 'Laboratórios de engenharia e oficinas'),
('H', 'Bloco H', 'Gabinetes de docentes e salas de reunião'),
('I', 'Bloco I', 'Laboratórios de informática e salas de computadores'),
('O', 'Bloco O', 'Salas de aula e laboratórios de informática'),
('RES', 'Residências', 'Residências de estudantes do IPT');

INSERT INTO issue_categories (code, name, description) VALUES
('electrical', 'Elétrico', 'Problemas elétricos: tomadas, iluminação, quadros'),
('hvac', 'Climatização', 'Aquecimento, ar condicionado, ventilação'),
('plumbing', 'Canalização', 'Água, esgotos, sanitas, lavatórios'),
('furniture', 'Mobiliário', 'Mesas, cadeiras, armários, quadros'),
('equipment', 'Equipamento', 'Computadores, projetores, impressoras'),
('network', 'Rede/WiFi', 'Problemas de rede, WiFi, internet'),
('structural', 'Estrutural', 'Paredes, tetos, janelas, portas, infiltrações'),
('cleaning', 'Limpeza', 'Necessidade de limpeza ou higienização'),
('security', 'Segurança', 'Fechaduras, alarmes, extintores'),
('audio_visual', 'Audiovisual', 'Microfones, colunas, sistemas de som'),
('accessibility', 'Acessibilidade', 'Rampas, elevadores, sinalética'),
('exterior', 'Exterior', 'Jardins, estacionamento, iluminação exterior'),
('other', 'Outro', 'Outros problemas não categorizados');
