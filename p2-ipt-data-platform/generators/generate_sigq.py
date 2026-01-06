#!/usr/bin/env python3
"""
IPT SIGQ Platform - Seed Data Generator
Generates documents, audits, non-conformities, and improvement opportunities.
Run after the database is initialized with init.sql.

Usage:
    python generate_sigq.py [--output FILE]
"""

import argparse
import random
from datetime import date, datetime, timedelta

# Process IDs and codes (matching init.sql)
PROCESSES = {
    1: ("GES", "Gestão Estratégica"),
    2: ("GSA", "Gestão do Sistema, Avaliação e Melhoria"),
    3: ("IDI", "Investigação, Desenvolvimento e Inovação"),
    4: ("FOR", "Formativo"),
    5: ("ACA", "Académicos"),
    6: ("SAS", "Serviços de Ação Social"),
    7: ("GRH", "Gestão de Recursos Humanos"),
    8: ("GFP", "Gestão Financeira e Patrimonial"),
    9: ("INT", "Internacionalização"),
    10: ("GSI", "Gestão de Sistemas de Informação"),
    11: ("CRP", "Comunicação e Relações Públicas"),
    12: ("BIT", "Biblioteca e Tradução"),
    13: ("LAB", "Laboratórios"),
    14: ("MSA", "Manutenção, Segurança, Ambiente e Expediente"),
}

# Document templates by process and type
DOC_TEMPLATES = {
    "GES": [
        (
            "PT",
            "Planeamento Estratégico",
            "Procedimento para elaboração do plano estratégico",
        ),
        ("POL", "Política de Qualidade", "Política institucional de qualidade"),
        ("PLN", "Plano de Atividades", "Plano anual de atividades"),
        ("REL", "Relatório de Atividades", "Relatório anual de atividades"),
        ("REG", "Regulamento do Conselho Geral", "Funcionamento do Conselho Geral"),
    ],
    "GSA": [
        ("PT", "Controlo de Documentos", "Gestão documental do SGQ"),
        ("PT", "Auditorias Internas", "Procedimento de auditorias internas"),
        ("PT", "Não Conformidades e Ações Corretivas", "Tratamento de NC e AC"),
        ("PT", "Revisão pela Gestão", "Revisão anual do SGQ"),
        ("MAN", "Manual da Qualidade", "Manual do sistema de gestão da qualidade"),
        ("IMP", "Registo de Não Conformidade", "Formulário para registo de NC"),
        ("IMP", "Plano de Auditoria", "Template de plano de auditoria"),
        ("IMP", "Relatório de Auditoria", "Template de relatório de auditoria"),
    ],
    "IDI": [
        (
            "PT",
            "Gestão de Projetos de I&D",
            "Procedimento para projetos de investigação",
        ),
        ("REG", "Regulamento de I&D", "Regulamento das atividades de I&D"),
        ("IMP", "Proposta de Projeto", "Formulário de proposta de projeto"),
        ("REL", "Relatório de I&D", "Relatório anual de atividades de I&D"),
    ],
    "FOR": [
        ("PT", "Criação de Cursos", "Procedimento para criação de novos cursos"),
        (
            "PT",
            "Funcionamento de UC",
            "Procedimento de gestão de unidades curriculares",
        ),
        ("PT", "Avaliação Pedagógica", "Avaliação do desempenho pedagógico"),
        (
            "REG",
            "Regulamento de Avaliação",
            "Regulamento de avaliação de conhecimentos",
        ),
        ("REG", "Regulamento de Estágios", "Regulamento de estágios curriculares"),
        ("IMP", "Ficha de Unidade Curricular", "Template de FUC"),
        ("IMP", "Relatório de UC", "Relatório de funcionamento de UC"),
        ("REL", "Relatório de Curso", "Relatório anual de curso"),
    ],
    "ACA": [
        ("PT", "Matrículas e Inscrições", "Procedimento de matrícula"),
        ("PT", "Emissão de Documentos", "Emissão de certidões e diplomas"),
        ("REG", "Regulamento Académico", "Regulamento académico geral"),
        ("IMP", "Requerimento Geral", "Formulário de requerimento"),
        ("IMP", "Pedido de Certidão", "Formulário de pedido de certidão"),
    ],
    "SAS": [
        ("PT", "Atribuição de Bolsas", "Procedimento de bolsas de estudo"),
        ("PT", "Gestão de Residências", "Gestão das residências de estudantes"),
        ("REG", "Regulamento de Bolsas", "Regulamento de atribuição de bolsas"),
        ("IMP", "Candidatura a Bolsa", "Formulário de candidatura"),
    ],
    "GRH": [
        ("PT", "Recrutamento e Seleção", "Procedimento de contratação"),
        ("PT", "Avaliação de Desempenho", "Procedimento de avaliação SIADAP"),
        ("REG", "Regulamento de Horário", "Regulamento de horário de trabalho"),
        ("IMP", "Pedido de Férias", "Formulário de marcação de férias"),
        ("IMP", "Justificação de Faltas", "Formulário de justificação"),
    ],
    "GFP": [
        ("PT", "Aquisição de Bens e Serviços", "Procedimento de compras"),
        ("PT", "Gestão Orçamental", "Execução e controlo orçamental"),
        ("REG", "Regulamento de Despesas", "Regulamento de gestão de despesas"),
        ("IMP", "Requisição de Compra", "Formulário de requisição"),
        ("IMP", "Ordem de Pagamento", "Formulário de pagamento"),
    ],
    "INT": [
        ("PT", "Mobilidade Erasmus+", "Procedimento de mobilidade de estudantes"),
        ("PT", "Acordos Internacionais", "Estabelecimento de parcerias"),
        ("REG", "Regulamento de Mobilidade", "Regulamento Erasmus+"),
        ("IMP", "Candidatura a Mobilidade", "Formulário de candidatura Erasmus"),
    ],
    "GSI": [
        ("PT", "Gestão de Acessos", "Procedimento de gestão de acessos TI"),
        ("PT", "Backup e Recuperação", "Procedimento de backups"),
        ("PT", "Gestão de Incidentes TI", "Gestão de incidentes informáticos"),
        ("POL", "Política de Segurança TI", "Política de segurança da informação"),
        ("IMP", "Pedido de Acesso", "Formulário de pedido de acesso"),
    ],
    "CRP": [
        ("PT", "Comunicação Institucional", "Procedimento de comunicação"),
        ("PT", "Gestão de Eventos", "Organização de eventos"),
        ("IMP", "Pedido de Divulgação", "Formulário de pedido de divulgação"),
    ],
    "BIT": [
        ("PT", "Aquisição Bibliográfica", "Procedimento de aquisição de bibliografia"),
        ("PT", "Empréstimo Domiciliário", "Regulamento de empréstimo"),
        ("REG", "Regulamento da Biblioteca", "Regulamento de utilização"),
    ],
    "LAB": [
        ("PT", "Gestão de Equipamentos", "Procedimento de gestão de equipamentos"),
        ("PT", "Calibração e Manutenção", "Calibração de equipamentos"),
        ("IMP", "Requisição de Laboratório", "Pedido de utilização de laboratório"),
        ("IMP", "Ficha de Equipamento", "Registo de equipamento"),
    ],
    "MSA": [
        ("PT", "Manutenção de Instalações", "Procedimento de manutenção preventiva"),
        ("PT", "Gestão de Resíduos", "Gestão ambiental de resíduos"),
        ("PT", "Segurança e Emergência", "Plano de emergência interno"),
        ("IMP", "Pedido de Intervenção", "Formulário de pedido de manutenção"),
        ("PLN", "Plano de Manutenção", "Plano anual de manutenção"),
    ],
}

# Auditors
AUDITORS = [
    "Dr. Manuel Santos",
    "Dra. Ana Ferreira",
    "Eng. Pedro Costa",
    "Dr. João Oliveira",
    "Dra. Maria Silva",
    "Eng. Carlos Martins",
]

# NC and IO templates
NC_TEMPLATES = [
    ("Documentação desatualizada", "Documentos sem revisão há mais de 2 anos"),
    ("Registos incompletos", "Falta de registos obrigatórios no processo"),
    ("Desvio ao procedimento", "Não cumprimento do procedimento estabelecido"),
    ("Indicadores não monitorizados", "Falta de monitorização de indicadores-chave"),
    ("Formação insuficiente", "Colaboradores sem formação adequada"),
    ("Comunicação deficiente", "Falhas na comunicação entre áreas"),
    ("Equipamento não calibrado", "Equipamento sem calibração válida"),
    ("Prazo não cumprido", "Incumprimento de prazo definido"),
    ("Arquivo desorganizado", "Documentação sem organização adequada"),
    ("Falta de evidências", "Ausência de registos comprovativos"),
]

IO_TEMPLATES = [
    ("Digitalização de processos", "Automatizar processos manuais"),
    ("Melhoria de comunicação interna", "Implementar plataforma de comunicação"),
    ("Formação contínua", "Reforçar programa de formação"),
    ("Simplificação de procedimentos", "Reduzir burocracia em processos"),
    ("Indicadores de desempenho", "Definir novos KPIs"),
    ("Satisfação de stakeholders", "Implementar inquéritos de satisfação"),
    ("Gestão documental", "Melhorar sistema de gestão documental"),
    ("Partilha de boas práticas", "Criar repositório de boas práticas"),
    ("Eficiência energética", "Reduzir consumos energéticos"),
    ("Acessibilidade", "Melhorar acessibilidade de serviços"),
]


def escape_sql(s):
    if s is None:
        return "NULL"
    return s.replace("'", "''")


def format_date(d):
    if d is None:
        return "NULL"
    return f"'{d.strftime('%Y-%m-%d')}'"


def format_timestamp(dt):
    if dt is None:
        return "NULL"
    return f"'{dt.strftime('%Y-%m-%d %H:%M:%S')}'"


def random_date(start, end):
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))


def generate_documents():
    """Generate quality system documents."""
    documents = []
    doc_id = 1

    for process_id, (proc_code, proc_name) in PROCESSES.items():
        templates = DOC_TEMPLATES.get(proc_code, [])

        for doc_type_code, title, description in templates:
            # Map type code to ID
            type_map = {
                "PT": 1,
                "REG": 2,
                "IMP": 3,
                "MAN": 4,
                "POL": 5,
                "PLN": 6,
                "REL": 7,
                "ATA": 8,
            }
            type_id = type_map.get(doc_type_code, 1)

            # Generate document code
            doc_code = f"{proc_code}.{doc_type_code}.{doc_id:03d}"

            # Version (most are 1.0, some updated)
            version = random.choice(["1.0", "1.0", "1.0", "1.1", "2.0", "2.1"])

            # Dates
            created = random_date(date(2020, 1, 1), date(2024, 12, 31))
            approved = created + timedelta(days=random.randint(7, 30))
            last_review = random_date(date(2024, 1, 1), date(2025, 6, 30))
            next_review = last_review + timedelta(days=365)

            # Status
            status = random.choices(
                ["active", "active", "active", "in_review", "obsolete"],
                weights=[70, 10, 10, 7, 3],
            )[0]

            documents.append(
                {
                    "id": doc_id,
                    "code": doc_code,
                    "title": title,
                    "process_id": process_id,
                    "type_id": type_id,
                    "version": version,
                    "status": status,
                    "created_by": random.choice(AUDITORS),
                    "created_at": created,
                    "approved_by": random.choice(AUDITORS),
                    "approved_at": approved,
                    "last_review": last_review,
                    "next_review": next_review,
                    "description": description,
                }
            )
            doc_id += 1

    # Add more documents to reach 100+
    extra_titles = [
        "Instruções de Trabalho",
        "Checklist de Verificação",
        "Modelo de Relatório",
        "Guia de Procedimentos",
        "Template de Ata",
        "Ficha de Processo",
        "Matriz de Responsabilidades",
        "Fluxograma de Processo",
        "Lista de Verificação",
        "Formulário de Reclamação",
        "Registo de Ocorrências",
        "Mapa de Indicadores",
    ]

    while doc_id <= 120:
        process_id = random.randint(1, 14)
        proc_code = PROCESSES[process_id][0]
        type_id = random.randint(1, 8)
        type_codes = {
            1: "PT",
            2: "REG",
            3: "IMP",
            4: "MAN",
            5: "POL",
            6: "PLN",
            7: "REL",
            8: "ATA",
        }

        doc_code = f"{proc_code}.{type_codes[type_id]}.{doc_id:03d}"
        title = random.choice(extra_titles) + f" - {proc_code}"

        created = random_date(date(2021, 1, 1), date(2025, 6, 30))

        documents.append(
            {
                "id": doc_id,
                "code": doc_code,
                "title": title,
                "process_id": process_id,
                "type_id": type_id,
                "version": "1.0",
                "status": "active",
                "created_by": random.choice(AUDITORS),
                "created_at": created,
                "approved_by": random.choice(AUDITORS),
                "approved_at": created + timedelta(days=14),
                "last_review": random_date(date(2024, 6, 1), date(2025, 6, 30)),
                "next_review": date(2026, 6, 30),
                "description": f"Documento de apoio ao processo {proc_code}",
            }
        )
        doc_id += 1

    return documents


def generate_audits():
    """Generate internal audits."""
    audits = []
    audit_id = 1

    # Annual audit plan - each process audited once per year
    years = [2024, 2025]

    for year in years:
        for process_id in range(1, 15):
            proc_code = PROCESSES[process_id][0]

            # Schedule audit
            month = random.randint(2, 11)
            planned = date(year, month, random.randint(1, 28))

            # Determine status based on date
            today = date(2025, 12, 20)
            if planned < today - timedelta(days=30):
                status = "completed"
                actual = planned + timedelta(days=random.randint(-3, 7))
            elif planned < today:
                status = random.choice(["completed", "in_progress"])
                actual = (
                    planned
                    if status == "in_progress"
                    else planned + timedelta(days=random.randint(0, 5))
                )
            else:
                status = "planned"
                actual = None

            audits.append(
                {
                    "id": audit_id,
                    "code": f"AUD-{year}-{audit_id:03d}",
                    "type": "internal",
                    "process_id": process_id,
                    "scope": f"Auditoria ao processo {proc_code} - {PROCESSES[process_id][1]}",
                    "lead_auditor": random.choice(AUDITORS),
                    "team": random.choice([None, "Equipa A", "Equipa B"]),
                    "planned_date": planned,
                    "actual_date": actual,
                    "status": status,
                    "findings": (
                        f"Auditoria realizada ao processo {proc_code}."
                        if status == "completed"
                        else None
                    ),
                    "conclusion": (
                        random.choice(
                            [
                                "Conforme",
                                "Conforme com observações",
                                "Não conforme menor",
                            ]
                        )
                        if status == "completed"
                        else None
                    ),
                }
            )
            audit_id += 1

    return audits


def generate_non_conformities(audits):
    """Generate non-conformities."""
    ncs = []
    nc_id = 1

    completed_audits = [a for a in audits if a["status"] == "completed"]

    for audit in completed_audits:
        # 60% of audits have at least one NC
        if random.random() < 0.6:
            num_ncs = random.choices([1, 2, 3], weights=[60, 30, 10])[0]

            for _ in range(num_ncs):
                title, desc = random.choice(NC_TEMPLATES)
                severity = random.choices(
                    ["minor", "major", "critical"], weights=[60, 35, 5]
                )[0]

                detected = audit["actual_date"]
                due = detected + timedelta(
                    days=(
                        30 if severity == "minor" else 60 if severity == "major" else 90
                    )
                )

                # Status based on age
                days_old = (date(2025, 12, 20) - detected).days
                if days_old > 60:
                    status = random.choices(
                        ["closed", "verified", "in_treatment"], weights=[50, 30, 20]
                    )[0]
                elif days_old > 30:
                    status = random.choices(
                        ["in_treatment", "closed", "in_analysis"], weights=[40, 30, 30]
                    )[0]
                else:
                    status = random.choices(
                        ["open", "in_analysis", "in_treatment"], weights=[40, 40, 20]
                    )[0]

                closed = None
                if status in ["closed", "verified"]:
                    closed = datetime.combine(
                        detected + timedelta(days=random.randint(20, 50)),
                        datetime.min.time(),
                    )

                ncs.append(
                    {
                        "id": nc_id,
                        "code": f"NC-{detected.year}-{nc_id:04d}",
                        "audit_id": audit["id"],
                        "process_id": audit["process_id"],
                        "severity": severity,
                        "title": title,
                        "description": desc,
                        "root_cause": (
                            "Análise de causa raiz em curso"
                            if status not in ["closed", "verified"]
                            else "Causa identificada e tratada"
                        ),
                        "detected_by": audit["lead_auditor"],
                        "detected_at": datetime.combine(detected, datetime.min.time()),
                        "status": status,
                        "responsible": random.choice(AUDITORS),
                        "due_date": due,
                        "closed_at": closed,
                        "closure_notes": (
                            "NC encerrada após implementação de ações corretivas"
                            if closed
                            else None
                        ),
                    }
                )
                nc_id += 1

    return ncs


def generate_improvement_opportunities(audits):
    """Generate improvement opportunities."""
    ios = []
    io_id = 1

    completed_audits = [a for a in audits if a["status"] == "completed"]

    for audit in completed_audits:
        # 40% of audits have improvement opportunities
        if random.random() < 0.4:
            num_ios = random.randint(1, 2)

            for _ in range(num_ios):
                title, desc = random.choice(IO_TEMPLATES)
                proposed = audit["actual_date"]

                status = random.choices(
                    ["proposed", "approved", "in_progress", "implemented", "verified"],
                    weights=[20, 20, 25, 25, 10],
                )[0]

                impl_date = None
                implemented_at = None
                if status in ["implemented", "verified"]:
                    impl_date = proposed + timedelta(days=random.randint(30, 120))
                    implemented_at = datetime.combine(impl_date, datetime.min.time())

                ios.append(
                    {
                        "id": io_id,
                        "code": f"OM-{proposed.year}-{io_id:04d}",
                        "audit_id": audit["id"],
                        "process_id": audit["process_id"],
                        "title": title,
                        "description": desc,
                        "expected_benefit": "Melhoria da eficiência e eficácia do processo",
                        "proposed_by": audit["lead_auditor"],
                        "proposed_at": datetime.combine(proposed, datetime.min.time()),
                        "status": status,
                        "priority": random.choice(["low", "medium", "high"]),
                        "responsible": random.choice(AUDITORS),
                        "implementation_date": impl_date,
                        "implemented_at": implemented_at,
                    }
                )
                io_id += 1

    return ios


def generate_corrective_actions(ncs):
    """Generate corrective actions for non-conformities."""
    cas = []
    ca_id = 1

    for nc in ncs:
        # Each NC has 1-3 corrective actions
        num_actions = random.randint(1, 3)

        for i in range(num_actions):
            action_type = ["immediate", "corrective", "preventive"][min(i, 2)]

            status = (
                "completed"
                if nc["status"] in ["closed", "verified"]
                else random.choice(["planned", "in_progress"])
            )

            cas.append(
                {
                    "id": ca_id,
                    "code": f"AC-{nc['code'][-9:]}-{i+1:02d}",
                    "nc_id": nc["id"],
                    "action_type": action_type,
                    "description": f"Ação {action_type} para tratar NC {nc['code']}",
                    "responsible": nc["responsible"],
                    "due_date": nc["due_date"] - timedelta(days=7 * (num_actions - i)),
                    "status": status,
                    "completed_at": nc["closed_at"] if status == "completed" else None,
                    "verified": nc["status"] == "verified",
                }
            )
            ca_id += 1

    return cas


def generate_sql():
    """Generate all SQL statements."""
    lines = []
    lines.append("-- =============================================================")
    lines.append("-- IPT SIGQ Platform - Seed Data")
    lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("-- =============================================================")
    lines.append("")

    documents = generate_documents()
    audits = generate_audits()
    ncs = generate_non_conformities(audits)
    ios = generate_improvement_opportunities(audits)
    cas = generate_corrective_actions(ncs)

    lines.append(f"-- Documents: {len(documents)}")
    lines.append(f"-- Audits: {len(audits)}")
    lines.append(f"-- Non-conformities: {len(ncs)}")
    lines.append(f"-- Improvement opportunities: {len(ios)}")
    lines.append(f"-- Corrective actions: {len(cas)}")
    lines.append("")

    # Documents
    lines.append("-- Documents")
    for d in documents:
        lines.append(
            f"INSERT INTO documents (code, title, process_id, document_type_id, version, status, created_by, created_at, approved_by, approved_at, last_review_date, next_review_date, description) VALUES ('{d['code']}', '{escape_sql(d['title'])}', {d['process_id']}, {d['type_id']}, '{d['version']}', '{d['status']}', '{escape_sql(d['created_by'])}', '{d['created_at']}', '{escape_sql(d['approved_by'])}', '{d['approved_at']}', '{d['last_review']}', '{d['next_review']}', '{escape_sql(d['description'])}');"
        )

    lines.append("")
    lines.append("-- Audits")
    for a in audits:
        actual = f"'{a['actual_date']}'" if a["actual_date"] else "NULL"
        team = f"'{escape_sql(a['team'])}'" if a["team"] else "NULL"
        findings = f"'{escape_sql(a['findings'])}'" if a["findings"] else "NULL"
        conclusion = f"'{escape_sql(a['conclusion'])}'" if a["conclusion"] else "NULL"
        lines.append(
            f"INSERT INTO audits (code, audit_type, process_id, scope, lead_auditor, audit_team, planned_date, actual_date, status, findings_summary, conclusion) VALUES ('{a['code']}', '{a['type']}', {a['process_id']}, '{escape_sql(a['scope'])}', '{escape_sql(a['lead_auditor'])}', {team}, '{a['planned_date']}', {actual}, '{a['status']}', {findings}, {conclusion});"
        )

    lines.append("")
    lines.append("-- Non-conformities")
    for nc in ncs:
        closed = format_timestamp(nc["closed_at"])
        notes = (
            f"'{escape_sql(nc['closure_notes'])}'" if nc["closure_notes"] else "NULL"
        )
        lines.append(
            f"INSERT INTO non_conformities (code, audit_id, process_id, severity, title, description, root_cause, detected_by, detected_at, status, responsible, due_date, closed_at, closure_notes) VALUES ('{nc['code']}', {nc['audit_id']}, {nc['process_id']}, '{nc['severity']}', '{escape_sql(nc['title'])}', '{escape_sql(nc['description'])}', '{escape_sql(nc['root_cause'])}', '{escape_sql(nc['detected_by'])}', '{nc['detected_at']}', '{nc['status']}', '{escape_sql(nc['responsible'])}', '{nc['due_date']}', {closed}, {notes});"
        )

    lines.append("")
    lines.append("-- Improvement opportunities")
    for io in ios:
        impl = f"'{io['implementation_date']}'" if io["implementation_date"] else "NULL"
        impl_at = format_timestamp(io["implemented_at"])
        lines.append(
            f"INSERT INTO improvement_opportunities (code, audit_id, process_id, title, description, expected_benefit, proposed_by, proposed_at, status, priority, responsible, implementation_date, implemented_at) VALUES ('{io['code']}', {io['audit_id']}, {io['process_id']}, '{escape_sql(io['title'])}', '{escape_sql(io['description'])}', '{escape_sql(io['expected_benefit'])}', '{escape_sql(io['proposed_by'])}', '{io['proposed_at']}', '{io['status']}', '{io['priority']}', '{escape_sql(io['responsible'])}', {impl}, {impl_at});"
        )

    lines.append("")
    lines.append("-- Corrective actions")
    for ca in cas:
        completed = format_timestamp(ca["completed_at"])
        verified = "true" if ca["verified"] else "false"
        lines.append(
            f"INSERT INTO corrective_actions (code, non_conformity_id, action_type, description, responsible, due_date, status, completed_at, effectiveness_verified) VALUES ('{ca['code']}', {ca['nc_id']}, '{ca['action_type']}', '{escape_sql(ca['description'])}', '{escape_sql(ca['responsible'])}', '{ca['due_date']}', '{ca['status']}', {completed}, {verified});"
        )

    return "\n".join(lines)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate IPT SIGQ seed data")
    parser.add_argument("--output", type=str, help="Output file (default: stdout)")
    args = parser.parse_args()

    sql = generate_sql()

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(sql)
        print(f"Generated SIGQ data to {args.output}")
    else:
        print(sql)
