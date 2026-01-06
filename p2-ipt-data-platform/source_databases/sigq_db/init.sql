-- =============================================================
-- IPT SIGQ Platform - Source Database Schema
-- =============================================================
-- Quality management system: documents, processes, audits,
-- non-conformities, and improvement opportunities.
-- This file creates the schema structure only.
-- Run the Python generator to populate with seed data.
-- =============================================================

-- Organizational processes
CREATE TABLE processes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    owner VARCHAR(100),
    is_active BOOLEAN DEFAULT true
);

-- Document types
CREATE TABLE document_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Documents in the quality system
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    process_id INTEGER NOT NULL REFERENCES processes(id),
    document_type_id INTEGER NOT NULL REFERENCES document_types(id),
    version VARCHAR(10) DEFAULT '1.0',
    status VARCHAR(20) DEFAULT 'active',
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_by VARCHAR(100),
    approved_at TIMESTAMP,
    last_review_date DATE,
    next_review_date DATE,
    file_path VARCHAR(300),
    description TEXT,
    
    CONSTRAINT chk_doc_status CHECK (status IN ('draft', 'in_review', 'active', 'obsolete'))
);

-- Audits (internal quality audits)
CREATE TABLE audits (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    audit_type VARCHAR(30) NOT NULL, -- internal, external, surveillance
    process_id INTEGER REFERENCES processes(id),
    scope TEXT,
    lead_auditor VARCHAR(100) NOT NULL,
    audit_team TEXT,
    planned_date DATE NOT NULL,
    actual_date DATE,
    status VARCHAR(20) DEFAULT 'planned',
    findings_summary TEXT,
    conclusion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_audit_status CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled'))
);

-- Non-conformities found in audits
CREATE TABLE non_conformities (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    audit_id INTEGER REFERENCES audits(id),
    process_id INTEGER REFERENCES processes(id),
    severity VARCHAR(20) NOT NULL, -- minor, major, critical
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    root_cause TEXT,
    detected_by VARCHAR(100),
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'open',
    responsible VARCHAR(100),
    due_date DATE,
    closed_at TIMESTAMP,
    closure_notes TEXT,
    
    CONSTRAINT chk_nc_severity CHECK (severity IN ('minor', 'major', 'critical')),
    CONSTRAINT chk_nc_status CHECK (status IN ('open', 'in_analysis', 'in_treatment', 'closed', 'verified'))
);

-- Improvement opportunities
CREATE TABLE improvement_opportunities (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    audit_id INTEGER REFERENCES audits(id),
    process_id INTEGER REFERENCES processes(id),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    expected_benefit TEXT,
    proposed_by VARCHAR(100),
    proposed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'proposed',
    priority VARCHAR(20) DEFAULT 'medium',
    responsible VARCHAR(100),
    implementation_date DATE,
    implemented_at TIMESTAMP,
    effectiveness_review TEXT,
    
    CONSTRAINT chk_io_status CHECK (status IN ('proposed', 'approved', 'in_progress', 'implemented', 'rejected', 'verified')),
    CONSTRAINT chk_io_priority CHECK (priority IN ('low', 'medium', 'high'))
);

-- Corrective actions (for non-conformities)
CREATE TABLE corrective_actions (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    non_conformity_id INTEGER NOT NULL REFERENCES non_conformities(id),
    action_type VARCHAR(20) NOT NULL, -- immediate, corrective, preventive
    description TEXT NOT NULL,
    responsible VARCHAR(100),
    due_date DATE,
    status VARCHAR(20) DEFAULT 'planned',
    completed_at TIMESTAMP,
    effectiveness_verified BOOLEAN DEFAULT false,
    verification_notes TEXT,
    
    CONSTRAINT chk_ca_status CHECK (status IN ('planned', 'in_progress', 'completed', 'verified'))
);

-- Indexes
CREATE INDEX idx_documents_process ON documents(process_id);
CREATE INDEX idx_documents_type ON documents(document_type_id);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_audits_process ON audits(process_id);
CREATE INDEX idx_audits_status ON audits(status);
CREATE INDEX idx_nc_audit ON non_conformities(audit_id);
CREATE INDEX idx_nc_status ON non_conformities(status);
CREATE INDEX idx_io_process ON improvement_opportunities(process_id);
CREATE INDEX idx_ca_nc ON corrective_actions(non_conformity_id);

-- =============================================================
-- REFERENCE DATA
-- =============================================================

INSERT INTO processes (code, name, description, owner) VALUES
('GES', 'Gestão Estratégica', 'Planeamento estratégico e governação institucional', 'Presidência'),
('GSA', 'Gestão do Sistema, Avaliação e Melhoria', 'Gestão do sistema de qualidade e melhoria contínua', 'Gabinete de Qualidade'),
('IDI', 'Investigação, Desenvolvimento e Inovação', 'Atividades de I&D e transferência de conhecimento', 'Pró-Presidência I&D'),
('FOR', 'Formativo', 'Processo de ensino-aprendizagem', 'Pró-Presidência Académica'),
('ACA', 'Académicos', 'Gestão académica e serviços aos estudantes', 'Serviços Académicos'),
('SAS', 'Serviços de Ação Social', 'Apoio social aos estudantes', 'SAS'),
('GRH', 'Gestão de Recursos Humanos', 'Gestão de pessoal docente e não docente', 'Recursos Humanos'),
('GFP', 'Gestão Financeira e Patrimonial', 'Gestão orçamental e patrimonial', 'Serviços Financeiros'),
('INT', 'Internacionalização', 'Mobilidade e cooperação internacional', 'GRI'),
('GSI', 'Gestão de Sistemas de Informação', 'Sistemas e infraestruturas TI', 'Gabinete de Informática'),
('CRP', 'Comunicação e Relações Públicas', 'Comunicação institucional e imagem', 'Gabinete de Comunicação'),
('BIT', 'Biblioteca e Tradução', 'Serviços de biblioteca e documentação', 'Biblioteca'),
('LAB', 'Laboratórios', 'Gestão de laboratórios e equipamentos', 'Coordenação de Labs'),
('MSA', 'Manutenção, Segurança, Ambiente e Expediente', 'Manutenção de instalações e segurança', 'Serviços Técnicos');

INSERT INTO document_types (code, name, description) VALUES
('PT', 'Procedimento de Trabalho', 'Procedimentos operacionais e instruções de trabalho'),
('REG', 'Regulamento', 'Regulamentos e normas internas'),
('IMP', 'Impresso/Formulário', 'Formulários e impressos padronizados'),
('MAN', 'Manual', 'Manuais e guias de referência'),
('POL', 'Política', 'Políticas institucionais'),
('PLN', 'Plano', 'Planos de atividades e estratégicos'),
('REL', 'Relatório', 'Relatórios de atividades e avaliação'),
('ATA', 'Ata', 'Atas de reuniões e deliberações');
