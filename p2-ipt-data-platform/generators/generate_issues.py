#!/usr/bin/env python3
"""
IPT Issues Reporting App - Seed Data Generator
Generates realistic maintenance issues for IPT campus.
Run after the database is initialized with init.sql.

Usage:
    python generate_issues.py [--count N] [--output FILE]

Options:
    --count N       Number of issues to generate (default: 250)
    --output FILE   Output SQL file (default: stdout or issues_seed.sql)
"""

import argparse
import random
from datetime import datetime, timedelta

# Configuration
SEMESTER_START = datetime(2025, 9, 15)
SEMESTER_END = datetime(2025, 12, 20)

BUILDINGS = ["O", "B", "I", "G", "H", "A", "RES"]

# Room codes by building (realistic IPT room numbers)
ROOMS_BY_BUILDING = {
    "O": [
        "O101",
        "O102",
        "O103",
        "O104",
        "O105",
        "O106",
        "O107",
        "O108",
        "O201",
        "O202",
        "O203",
        "O204",
        "O205",
        "O206",
    ],
    "B": [
        "B250",
        "B251",
        "B252",
        "B253",
        "B254",
        "B255",
        "B256",
        "B257",
        "B258",
        "B259",
        "B260",
    ],
    "I": [
        "I101",
        "I102",
        "I103",
        "I153",
        "I154",
        "I155",
        "I156",
        "I176",
        "I177",
        "I178",
        "I179",
        "I180",
        "I181",
        "I182",
        "I210",
        "I211",
        "I212",
        "I213",
        "I214",
        "I215",
    ],
    "G": ["G101", "G102", "G103", "G150", "G151", "G152", "G153", "G154"],
    "H": [
        "H101",
        "H102",
        "H201",
        "H202",
        "H203",
        "H204",
        "H205",
        "H216",
        "H217",
        "H218",
        "H219",
        "H220",
    ],
    "A": ["A101", "A102", "A103", "A201", "A202", "A203"],
    "RES": [
        "RES-A101",
        "RES-A102",
        "RES-A201",
        "RES-A202",
        "RES-B101",
        "RES-B102",
        "RES-B201",
        "RES-B202",
    ],
}

CATEGORIES = [
    "electrical",
    "hvac",
    "plumbing",
    "furniture",
    "equipment",
    "network",
    "structural",
    "cleaning",
    "security",
    "audio_visual",
    "accessibility",
    "exterior",
    "other",
]

# Weighted categories (some more common than others)
CATEGORY_WEIGHTS = {
    "electrical": 15,
    "hvac": 20,
    "equipment": 25,
    "furniture": 12,
    "network": 15,
    "cleaning": 8,
    "plumbing": 10,
    "structural": 8,
    "audio_visual": 10,
    "security": 5,
    "accessibility": 3,
    "exterior": 5,
    "other": 4,
}

PRIORITIES = ["low", "medium", "high", "urgent"]
PRIORITY_WEIGHTS = [25, 45, 22, 8]

STATUSES = ["open", "in_progress", "resolved", "closed", "cancelled"]

# Realistic issue templates by category
ISSUE_TEMPLATES = {
    "electrical": [
        ("Tomada não funciona", "A tomada {loc} não fornece energia."),
        ("Luz a piscar", "A iluminação da sala pisca intermitentemente."),
        ("Projetor não liga", "O projetor de teto não responde ao comando."),
        ("Lâmpada fundida", "Uma das lâmpadas fluorescentes fundiu."),
        ("Quadro elétrico com ruído", "O quadro elétrico faz um ruído estranho."),
        ("Falta de tomadas", "Não há tomadas suficientes para os equipamentos."),
    ],
    "hvac": [
        (
            "Aquecimento não funciona",
            "O sistema de aquecimento está avariado. Sala muito fria.",
        ),
        ("Ar condicionado com fuga", "O ar condicionado está a pingar água."),
        ("Temperatura excessiva", "A sala fica demasiado quente à tarde."),
        ("Radiador frio", "O radiador não aquece apesar de estar ligado."),
        ("Barulho no sistema AVAC", "O sistema de ventilação faz muito barulho."),
        ("Ar condicionado não arrefece", "O AC liga mas não arrefece a sala."),
    ],
    "equipment": [
        ("Computador não arranca", "O computador na posição {num} não inicia."),
        ("Monitor com defeito", "O monitor apresenta linhas verticais no ecrã."),
        ("Teclado danificado", "Várias teclas do teclado não respondem."),
        ("Rato não funciona", "O rato ótico não responde aos movimentos."),
        ("Impressora encravada", "A impressora encrava frequentemente o papel."),
        ("PC muito lento", "O computador está extremamente lento."),
    ],
    "network": [
        ("WiFi fraco", "O sinal WiFi é muito fraco nesta sala."),
        ("Sem acesso à internet", "Não há ligação à internet nesta sala."),
        ("Rede lenta", "A velocidade da rede está muito reduzida."),
        ("Cabo de rede danificado", "O cabo de rede da tomada de parede não funciona."),
        ("Eduroam não conecta", "Impossível ligar ao eduroam nesta zona."),
    ],
    "furniture": [
        ("Cadeira partida", "Uma cadeira tem o assento partido."),
        ("Mesa danificada", "A mesa está riscada e instável."),
        ("Quadro branco manchado", "O quadro branco tem manchas permanentes."),
        ("Armário não fecha", "A porta do armário não fecha corretamente."),
        ("Falta de cadeiras", "Faltam cadeiras para todos os alunos."),
    ],
    "plumbing": [
        ("Torneira a pingar", "A torneira do lavatório pinga constantemente."),
        ("Sanita entupida", "A sanita da casa de banho está entupida."),
        ("Fuga de água", "Há uma fuga de água visível no teto."),
        ("Sem água quente", "Não há água quente nos lavatórios."),
        ("Autoclismo avariado", "O autoclismo não funciona corretamente."),
    ],
    "structural": [
        ("Infiltração no teto", "Quando chove, entra água pelo teto."),
        ("Janela não fecha", "A janela não fecha completamente."),
        ("Porta com defeito", "A porta não tranca corretamente."),
        ("Parede com humidade", "Há manchas de humidade na parede."),
        ("Vidro partido", "Um vidro da janela está rachado."),
    ],
    "cleaning": [
        ("Sala necessita limpeza", "O chão da sala precisa de limpeza profunda."),
        ("Casas de banho sujas", "As casas de banho necessitam de higienização."),
        ("Lixo acumulado", "Os caixotes do lixo estão cheios."),
        ("Manchas no chão", "Há manchas persistentes no chão."),
    ],
    "audio_visual": [
        ("Microfone sem som", "O microfone sem fios não emite som."),
        ("Colunas com ruído", "As colunas fazem um ruído de fundo."),
        ("Sistema de som avariado", "O sistema de som do anfiteatro não funciona."),
        ("Telecomando do projetor perdido", "O telecomando do projetor desapareceu."),
    ],
    "security": [
        ("Fechadura avariada", "A fechadura da porta não funciona."),
        ("Extintor fora do prazo", "O extintor precisa de ser revisto."),
        ("Luz de emergência avariada", "A luz de emergência não acende."),
        ("Porta corta-fogo bloqueada", "A porta corta-fogo está obstruída."),
    ],
    "accessibility": [
        ("Rampa danificada", "A rampa de acesso está danificada."),
        ("Elevador avariado", "O elevador está fora de serviço."),
        ("Sinalética em falta", "Falta sinalética para orientação."),
    ],
    "exterior": [
        (
            "Iluminação exterior avariada",
            "Os candeeiros do estacionamento não funcionam.",
        ),
        ("Buraco no pavimento", "Há um buraco no pavimento do parque."),
        ("Banco partido", "Um banco do jardim está partido."),
        ("Ervas altas", "O jardim precisa de manutenção."),
    ],
    "other": [
        (
            "Problema não categorizado",
            "Necessita de avaliação por parte da manutenção.",
        ),
        ("Situação invulgar", "Detetada situação que requer intervenção."),
    ],
}

# Reporter names (mix of teachers and students)
TEACHERS = [
    ("Prof. Renato Panda", "renato.panda@ipt.pt"),
    ("Prof. Luís Oliveira", "luis.oliveira@ipt.pt"),
    ("Prof. Gabriel Pires", "gabriel.pires@ipt.pt"),
    ("Prof. Ana Lopes", "ana.lopes@ipt.pt"),
    ("Prof. José Pereira", "jose.pereira@ipt.pt"),
    ("Prof. António Manso", "antonio.manso@ipt.pt"),
    ("Prof. Manuel Barros", "manuel.barros@ipt.pt"),
    ("Prof. Cristina Costa", "cristina.costa@ipt.pt"),
    ("Prof. Paulo Santos", "paulo.santos@ipt.pt"),
    ("Prof. Hélder Pestana", "helder.pestana@ipt.pt"),
    ("Prof. Pedro Correia", "pedro.correia@ipt.pt"),
    ("Prof. Luís Merca", "luis.merca@ipt.pt"),
    ("Prof. Carlos Perquilhas", "carlos.perquilhas@ipt.pt"),
]

STAFF = [
    ("Secretariado", "secretariado@ipt.pt"),
    ("Serviços Técnicos", "servicos.tecnicos@ipt.pt"),
    ("Biblioteca", "biblioteca@ipt.pt"),
    ("Serviços Académicos", "sa@ipt.pt"),
    ("Gabinete de Informática", "gi@ipt.pt"),
]

ASSIGNED_TO = [
    "Manutenção Geral",
    "Eletricista",
    "Canalizador",
    "AVAC Técnico",
    "IT Support",
    "Serviços de Limpeza",
    "Segurança",
    "Obras",
    "Externo",
]


def weighted_choice(items, weights):
    """Choose item based on weights."""
    total = sum(weights)
    r = random.uniform(0, total)
    cumulative = 0
    for item, weight in zip(items, weights):
        cumulative += weight
        if r <= cumulative:
            return item
    return items[-1]


def random_date(start, end):
    """Generate random datetime between start and end."""
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    return start + timedelta(seconds=random_seconds)


def generate_student():
    """Generate a random student name and email."""
    first_names = [
        "João",
        "Maria",
        "Pedro",
        "Ana",
        "Miguel",
        "Sofia",
        "Tiago",
        "Inês",
        "Rui",
        "Catarina",
        "André",
        "Beatriz",
        "Diogo",
        "Carolina",
    ]
    last_names = [
        "Silva",
        "Santos",
        "Ferreira",
        "Costa",
        "Oliveira",
        "Rodrigues",
        "Martins",
        "Pereira",
        "Almeida",
        "Sousa",
        "Carvalho",
        "Gomes",
    ]
    first = random.choice(first_names)
    last = random.choice(last_names)
    student_num = random.randint(20200001, 20259999)
    return f"{first} {last}", f"aluno{student_num}@ipt.pt"


def escape_sql(s):
    """Escape single quotes for SQL."""
    if s is None:
        return "NULL"
    return s.replace("'", "''")


def generate_issue(issue_id):
    """Generate a single issue record."""
    # Choose building (weighted towards I, O, B - teaching areas)
    building_weights = {"O": 25, "B": 20, "I": 30, "G": 10, "H": 8, "A": 4, "RES": 3}
    building = weighted_choice(
        list(building_weights.keys()), list(building_weights.values())
    )

    # Choose room (or None for common areas)
    if random.random() < 0.9:
        room = random.choice(ROOMS_BY_BUILDING[building])
    else:
        room = None

    # Choose category
    category = weighted_choice(
        list(CATEGORY_WEIGHTS.keys()), list(CATEGORY_WEIGHTS.values())
    )

    # Choose template
    templates = ISSUE_TEMPLATES.get(category, ISSUE_TEMPLATES["other"])
    title_template, desc_template = random.choice(templates)

    # Fill in template variables
    title = title_template
    description = desc_template.format(
        loc=random.choice(
            ["junto à janela", "junto à porta", "na parede lateral", "no centro"]
        ),
        num=random.randint(1, 20),
    )

    # Priority
    priority = weighted_choice(PRIORITIES, PRIORITY_WEIGHTS)

    # Reporter
    reporter_type = random.choices(
        ["student", "teacher", "staff"], weights=[50, 40, 10]
    )[0]
    if reporter_type == "teacher":
        name, email = random.choice(TEACHERS)
    elif reporter_type == "staff":
        name, email = random.choice(STAFF)
    else:
        name, email = generate_student()

    # Dates
    reported_at = random_date(SEMESTER_START, SEMESTER_END)

    # Status (older issues more likely to be resolved)
    days_old = (SEMESTER_END - reported_at).days
    if days_old > 60:
        status = random.choices(STATUSES, weights=[5, 5, 30, 55, 5])[0]
    elif days_old > 30:
        status = random.choices(STATUSES, weights=[10, 15, 35, 35, 5])[0]
    elif days_old > 14:
        status = random.choices(STATUSES, weights=[20, 25, 30, 20, 5])[0]
    else:
        status = random.choices(STATUSES, weights=[50, 30, 10, 5, 5])[0]

    # Assigned to
    assigned_to = None
    assigned_at = None
    resolved_at = None
    closed_at = None
    resolution_notes = None

    if status in ["in_progress", "resolved", "closed"]:
        assigned_to = random.choice(ASSIGNED_TO)
        assigned_at = reported_at + timedelta(hours=random.randint(1, 72))

    if status in ["resolved", "closed"]:
        resolved_at = assigned_at + timedelta(hours=random.randint(2, 168))
        resolution_notes = random.choice(
            [
                "Problema resolvido.",
                "Situação corrigida conforme solicitado.",
                "Equipamento substituído.",
                "Reparação efetuada com sucesso.",
                "Intervenção concluída.",
                "Peça substituída, a funcionar normalmente.",
            ]
        )

    if status == "closed":
        closed_at = resolved_at + timedelta(hours=random.randint(1, 48))

    return {
        "room_code": room,
        "building_code": building,
        "category_code": category,
        "priority": priority,
        "title": title,
        "description": description,
        "reported_by": name,
        "reporter_email": email,
        "reporter_type": reporter_type,
        "reported_at": reported_at,
        "status": status,
        "assigned_to": assigned_to,
        "assigned_at": assigned_at,
        "resolved_at": resolved_at,
        "closed_at": closed_at,
        "resolution_notes": resolution_notes,
    }


def format_timestamp(dt):
    """Format datetime for SQL."""
    if dt is None:
        return "NULL"
    return f"'{dt.strftime('%Y-%m-%d %H:%M:%S')}'"


def format_string(s):
    """Format string for SQL."""
    if s is None:
        return "NULL"
    return f"'{escape_sql(s)}'"


def generate_sql(num_issues=250):
    """Generate SQL insert statements."""
    lines = []
    lines.append("-- =============================================================")
    lines.append("-- IPT Issues Reporting App - Seed Data")
    lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"-- Total issues: {num_issues}")
    lines.append("-- =============================================================")
    lines.append("")
    lines.append("-- Issues data")

    for i in range(1, num_issues + 1):
        issue = generate_issue(i)

        sql = f"""INSERT INTO issues (room_code, building_code, category_code, priority, title, description, reported_by, reporter_email, reporter_type, reported_at, status, assigned_to, assigned_at, resolved_at, closed_at, resolution_notes) VALUES (
    {format_string(issue['room_code'])},
    {format_string(issue['building_code'])},
    {format_string(issue['category_code'])},
    {format_string(issue['priority'])},
    {format_string(issue['title'])},
    {format_string(issue['description'])},
    {format_string(issue['reported_by'])},
    {format_string(issue['reporter_email'])},
    {format_string(issue['reporter_type'])},
    {format_timestamp(issue['reported_at'])},
    {format_string(issue['status'])},
    {format_string(issue['assigned_to'])},
    {format_timestamp(issue['assigned_at'])},
    {format_timestamp(issue['resolved_at'])},
    {format_timestamp(issue['closed_at'])},
    {format_string(issue['resolution_notes'])}
);"""
        lines.append(sql)

    # Generate some comments for resolved issues
    lines.append("")
    lines.append("-- Issue comments")
    comment_id = 1
    for issue_id in range(1, num_issues + 1):
        if random.random() < 0.3:  # 30% of issues have comments
            num_comments = random.randint(1, 3)
            for _ in range(num_comments):
                commenter = random.choice(ASSIGNED_TO + [t[0] for t in TEACHERS[:5]])
                comment = random.choice(
                    [
                        "Situação em análise.",
                        "Aguarda peça de substituição.",
                        "Técnico destacado para o local.",
                        "Intervenção agendada para esta semana.",
                        "Problema mais complexo do que esperado.",
                        "Em contacto com fornecedor externo.",
                        "Visita técnica efetuada.",
                    ]
                )
                lines.append(
                    f"INSERT INTO issue_comments (issue_id, comment_by, comment_text) VALUES ({issue_id}, '{commenter}', '{comment}');"
                )
                comment_id += 1

    return "\n".join(lines)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate IPT Issues seed data")
    parser.add_argument(
        "--count", type=int, default=250, help="Number of issues to generate"
    )
    parser.add_argument("--output", type=str, help="Output file (default: stdout)")
    args = parser.parse_args()

    sql = generate_sql(args.count)

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(sql)
        print(f"Generated {args.count} issues to {args.output}")
    else:
        print(sql)
