#!/usr/bin/env python3
"""
IPT Room Reservations App - Seed Data Generator
Generates room reservations for the 1st semester 2025/2026.
Run after the database is initialized with init.sql.

Usage:
    python generate_reservations.py [--output FILE]
"""

import argparse
import random
from datetime import date, datetime, time, timedelta

# Semester dates
SEMESTER_START = date(2025, 9, 15)  # Monday
SEMESTER_END = date(2025, 12, 19)
EXAM_PERIOD_START = date(2026, 1, 6)
EXAM_PERIOD_END = date(2026, 1, 24)

# Time slots for classes (typical Portuguese academic schedule)
CLASS_SLOTS = [
    (time(9, 0), time(11, 0)),
    (time(11, 0), time(13, 0)),
    (time(14, 0), time(16, 0)),
    (time(16, 0), time(18, 0)),
    (time(18, 0), time(20, 0)),
    (time(20, 0), time(22, 0)),
]

# Room IDs by type (matching init.sql - 40 rooms total)
# O building: 1-8 (O101, O102, O103, O104, O105, O106, O201, O202)
# B building: 9-20 (B250-B260)
# I building: 21-31 (I153-I182)
# G building: 32-36 (G150-G154)
# H building: 37-40 (H201, H202, H216, H217)
COMPUTER_LABS = [3, 4] + list(range(21, 32))  # O103-O104, I153-I182 (IDs 3,4,21-31)
AMPHITHEATERS = [9, 10, 11, 14, 15, 20]  # B250-B252, B255, B256, B260
CLASSROOMS = [1, 2, 5, 6, 7, 8, 12, 13, 16, 17, 18, 19, 39, 40]  # O101-O202, B253-B259, H216-H217
MEETING_ROOMS = [37, 38]  # H201, H202
ENGINEERING_LABS = [32, 33, 34, 35, 36]  # G150-G154

# Course units with their preferred room types and weekly hours
COURSE_SCHEDULE = [
    # (course_unit_id, name, room_type, hours_per_week, day, slot_idx, teacher)
    # LEI Year 1
    (
        1,
        "Análise Matemática I",
        "classroom",
        4,
        0,
        0,
        "Prof. Luís Merca",
    ),  # Monday 9-11
    (
        1,
        "Análise Matemática I",
        "classroom",
        2,
        2,
        0,
        "Prof. Luís Merca",
    ),  # Wednesday 9-11
    (2, "Álgebra", "classroom", 4, 1, 0, "Prof. Carlos Perquilhas"),  # Tuesday 9-11
    (2, "Álgebra", "classroom", 2, 3, 0, "Prof. Carlos Perquilhas"),  # Thursday 9-11
    (
        3,
        "Introdução à Engenharia e à Tecnologia",
        "classroom",
        2,
        0,
        2,
        "Prof. Luís Miguel Oliveira",
    ),
    (4, "Introdução à Programação", "computer_lab", 4, 1, 2, "Prof. António Manso"),
    (4, "Introdução à Programação", "computer_lab", 2, 3, 2, "Prof. António Manso"),
    (5, "Sistemas Digitais", "lab", 4, 2, 2, "Prof. Manuel Barros"),
    (5, "Sistemas Digitais", "classroom", 2, 4, 0, "Prof. Manuel Barros"),
    # LEI Year 2
    (
        6,
        "Programação Orientada a Objetos",
        "computer_lab",
        4,
        0,
        3,
        "Prof. António Manso",
    ),
    (
        6,
        "Programação Orientada a Objetos",
        "computer_lab",
        2,
        2,
        3,
        "Prof. António Manso",
    ),
    (7, "Bases de Dados", "computer_lab", 4, 1, 3, "Prof. Hélder Pestana"),
    (7, "Bases de Dados", "classroom", 2, 3, 1, "Prof. Hélder Pestana"),
    (8, "Redes de Computadores", "computer_lab", 4, 2, 4, "Prof. José Pereira"),
    (8, "Redes de Computadores", "classroom", 2, 4, 1, "Prof. José Pereira"),
    (9, "Sistemas Operativos", "computer_lab", 4, 0, 4, "Prof. Pedro Correia"),
    (9, "Sistemas Operativos", "classroom", 2, 4, 2, "Prof. Pedro Correia"),
    # LEI Year 3
    (10, "Engenharia de Software", "computer_lab", 4, 0, 2, "Prof. Renato Panda"),
    (10, "Engenharia de Software", "classroom", 2, 2, 1, "Prof. Renato Panda"),
    (11, "Sistemas Distribuídos", "computer_lab", 4, 1, 4, "Prof. Gabriel Pires"),
    (11, "Sistemas Distribuídos", "classroom", 2, 3, 3, "Prof. Gabriel Pires"),
    (12, "Inteligência Artificial", "computer_lab", 4, 2, 2, "Prof. Ana Lopes"),
    (12, "Inteligência Artificial", "classroom", 2, 4, 3, "Prof. Ana Lopes"),
    (
        13,
        "Segurança Informática",
        "computer_lab",
        4,
        3,
        4,
        "Prof. Luís Miguel Oliveira",
    ),
    (13, "Segurança Informática", "classroom", 2, 4, 4, "Prof. Luís Miguel Oliveira"),
    # MEI-IoT Year 1 (evening classes)
    (
        14,
        "Análise de Grande Volume de Dados",
        "computer_lab",
        3,
        0,
        4,
        "Prof. Renato Panda",
    ),
    (
        14,
        "Análise de Grande Volume de Dados",
        "computer_lab",
        3,
        0,
        5,
        "Prof. Renato Panda",
    ),
    (15, "Aprendizagem Computacional", "computer_lab", 3, 1, 4, "Prof. Gabriel Pires"),
    (15, "Aprendizagem Computacional", "computer_lab", 3, 1, 5, "Prof. Gabriel Pires"),
    (16, "Engenharia de Software (MEI)", "computer_lab", 3, 2, 4, "Prof. Renato Panda"),
    (16, "Engenharia de Software (MEI)", "computer_lab", 3, 2, 5, "Prof. Renato Panda"),
]

# Attendee counts by course/year
ATTENDEE_RANGES = {
    "LEI-1": (60, 90),
    "LEI-2": (40, 60),
    "LEI-3": (25, 40),
    "MEI": (15, 25),
}


def get_room_for_type(room_type):
    """Get a random room ID for the given type."""
    if room_type == "computer_lab":
        return random.choice(COMPUTER_LABS)
    elif room_type == "classroom":
        return random.choice(CLASSROOMS)
    elif room_type == "amphitheater":
        return random.choice(AMPHITHEATERS)
    elif room_type == "lab":
        return random.choice(ENGINEERING_LABS)
    elif room_type == "meeting_room":
        return random.choice(MEETING_ROOMS)
    return random.choice(CLASSROOMS)


def escape_sql(s):
    """Escape single quotes for SQL."""
    if s is None:
        return "NULL"
    return s.replace("'", "''")


def format_time(t):
    """Format time for SQL."""
    return f"'{t.strftime('%H:%M:%S')}'"


def format_date(d):
    """Format date for SQL."""
    return f"'{d.strftime('%Y-%m-%d')}'"


def get_mondays_in_semester():
    """Get all Mondays in the semester."""
    current = SEMESTER_START
    # Find first Monday
    while current.weekday() != 0:
        current += timedelta(days=1)

    mondays = []
    while current <= SEMESTER_END:
        mondays.append(current)
        current += timedelta(days=7)
    return mondays


def generate_class_reservations():
    """Generate all class reservations for the semester."""
    reservations = []
    res_id = 1

    weeks = get_mondays_in_semester()

    for (
        cu_id,
        name,
        room_type,
        hours,
        day_of_week,
        slot_idx,
        teacher,
    ) in COURSE_SCHEDULE:
        # Assign a consistent room for this class
        room_id = get_room_for_type(room_type)
        start_time, end_time = CLASS_SLOTS[slot_idx]

        # Determine attendee range based on course
        if cu_id <= 5:
            att_min, att_max = ATTENDEE_RANGES["LEI-1"]
        elif cu_id <= 9:
            att_min, att_max = ATTENDEE_RANGES["LEI-2"]
        elif cu_id <= 13:
            att_min, att_max = ATTENDEE_RANGES["LEI-3"]
        else:
            att_min, att_max = ATTENDEE_RANGES["MEI"]

        base_attendees = random.randint(att_min, att_max)
        teacher_email = teacher.split()[-1].lower().replace(".", "") + "@ipt.pt"

        for week_monday in weeks:
            class_date = week_monday + timedelta(days=day_of_week)

            # Skip if outside semester
            if class_date < SEMESTER_START or class_date > SEMESTER_END:
                continue

            # Vary attendance slightly each week
            attendees = base_attendees + random.randint(-5, 5)
            attendees = max(10, min(attendees, att_max + 10))

            # Determine status (past classes are completed)
            today = date(2025, 12, 20)
            if class_date < today:
                status = "completed"
            else:
                status = "confirmed"

            reservations.append(
                {
                    "id": res_id,
                    "room_id": room_id,
                    "type_id": 1 if room_type == "classroom" else 2,  # class or lab
                    "course_unit_id": cu_id,
                    "title": name,
                    "description": f"Aula regular de {name}",
                    "reserved_by": teacher,
                    "email": teacher_email,
                    "date": class_date,
                    "start": start_time,
                    "end": end_time,
                    "status": status,
                    "attendees": attendees,
                }
            )
            res_id += 1

    return reservations, res_id


def generate_exam_reservations(start_id):
    """Generate exam reservations."""
    reservations = []
    res_id = start_id

    # Exam period exams
    exam_dates = []
    current = EXAM_PERIOD_START
    while current <= EXAM_PERIOD_END:
        if current.weekday() < 5:  # Weekdays only
            exam_dates.append(current)
        current += timedelta(days=1)

    course_units = [
        (1, "Exame de Análise Matemática I", 80),
        (2, "Exame de Álgebra", 75),
        (4, "Exame de Introdução à Programação", 85),
        (5, "Exame de Sistemas Digitais", 70),
        (6, "Exame de Programação Orientada a Objetos", 55),
        (7, "Exame de Bases de Dados", 50),
        (8, "Exame de Redes de Computadores", 45),
        (9, "Exame de Sistemas Operativos", 48),
        (10, "Exame de Engenharia de Software", 35),
        (11, "Exame de Sistemas Distribuídos", 32),
        (12, "Exame de Inteligência Artificial", 30),
        (13, "Exame de Segurança Informática", 28),
        (14, "Exame de Análise de Grande Volume de Dados", 20),
        (15, "Exame de Aprendizagem Computacional", 18),
        (16, "Exame de Engenharia de Software (MEI)", 18),
    ]

    random.shuffle(exam_dates)

    for i, (cu_id, name, attendees) in enumerate(course_units):
        if i >= len(exam_dates):
            break

        exam_date = exam_dates[i]
        room_id = random.choice(AMPHITHEATERS)

        reservations.append(
            {
                "id": res_id,
                "room_id": room_id,
                "type_id": 3,  # exam
                "course_unit_id": cu_id,
                "title": name,
                "description": f"Exame da época normal",
                "reserved_by": "Secretariado",
                "email": "secretariado@ipt.pt",
                "date": exam_date,
                "start": time(9, 0),
                "end": time(12, 0),
                "status": "confirmed",
                "attendees": attendees,
            }
        )
        res_id += 1

    return reservations, res_id


def generate_events_and_meetings(start_id):
    """Generate events, meetings, and other reservations."""
    reservations = []
    res_id = start_id

    # Department meetings (monthly)
    meeting_dates = [
        date(2025, 9, 25),
        date(2025, 10, 23),
        date(2025, 11, 20),
        date(2025, 12, 18),
    ]
    for d in meeting_dates:
        reservations.append(
            {
                "id": res_id,
                "room_id": 35,  # H201
                "type_id": 6,  # meeting
                "course_unit_id": None,
                "title": "Reunião Departamento de Informática",
                "description": "Reunião mensal do departamento",
                "reserved_by": "Prof. Luís Miguel Oliveira",
                "email": "luis.oliveira@ipt.pt",
                "date": d,
                "start": time(14, 30),
                "end": time(16, 30),
                "status": "completed" if d < date(2025, 12, 20) else "confirmed",
                "attendees": 12,
            }
        )
        res_id += 1

    # Events
    events = [
        (
            date(2025, 10, 15),
            "Semana da Informática - Abertura",
            9,
            time(14, 0),
            time(18, 0),
            100,
        ),
        (
            date(2025, 10, 16),
            "Semana da Informática - Workshop Python",
            22,
            time(10, 0),
            time(13, 0),
            30,
        ),
        (
            date(2025, 10, 17),
            "Semana da Informática - Palestra IA",
            9,
            time(14, 0),
            time(16, 0),
            80,
        ),
        (
            date(2025, 11, 5),
            "IEEE Workshop - IoT na Prática",
            15,
            time(14, 0),
            time(17, 0),
            45,
        ),
        (
            date(2025, 11, 20),
            "Defesa de Mestrado - João Silva",
            10,
            time(10, 0),
            time(12, 0),
            20,
        ),
        (
            date(2025, 11, 22),
            "Defesa de Mestrado - Maria Santos",
            10,
            time(14, 30),
            time(16, 30),
            25,
        ),
        (date(2025, 11, 28), "Hackathon IPT 2025", 9, time(9, 0), time(22, 0), 60),
        (
            date(2025, 12, 3),
            "Apresentação Projetos LEI",
            15,
            time(14, 0),
            time(18, 0),
            50,
        ),
        (
            date(2025, 12, 10),
            "Workshop Docker e Kubernetes",
            22,
            time(18, 0),
            time(21, 0),
            25,
        ),
        (
            date(2025, 12, 12),
            "Conferência Cibersegurança",
            9,
            time(9, 0),
            time(17, 0),
            90,
        ),
    ]

    for d, title, room_id, start, end, att in events:
        ev_type = (
            5
            if "Defesa" in title
            else 7 if "Workshop" in title or "Hackathon" in title else 7
        )
        reservations.append(
            {
                "id": res_id,
                "room_id": room_id,
                "type_id": ev_type,
                "course_unit_id": None,
                "title": title,
                "description": None,
                "reserved_by": random.choice(
                    [
                        "NEI - Núcleo de Estudantes",
                        "IEEE Student Branch",
                        "Secretariado",
                        "Coordenação LEI",
                    ]
                ),
                "email": "eventos@ipt.pt",
                "date": d,
                "start": start,
                "end": end,
                "status": "completed" if d < date(2025, 12, 20) else "confirmed",
                "attendees": att,
            }
        )
        res_id += 1

    # Random sporadic meetings
    for _ in range(30):
        d = SEMESTER_START + timedelta(
            days=random.randint(0, (SEMESTER_END - SEMESTER_START).days)
        )
        if d.weekday() >= 5:
            continue

        slot = random.choice(CLASS_SLOTS)
        reservations.append(
            {
                "id": res_id,
                "room_id": random.choice(MEETING_ROOMS + [37, 38]),
                "type_id": 6,
                "course_unit_id": None,
                "title": random.choice(
                    [
                        "Reunião de coordenação",
                        "Reunião de projeto",
                        "Orientação de estágio",
                        "Reunião de trabalho",
                    ]
                ),
                "description": None,
                "reserved_by": random.choice(
                    [
                        "Prof. Renato Panda",
                        "Prof. Gabriel Pires",
                        "Prof. Ana Lopes",
                        "Prof. José Pereira",
                    ]
                ),
                "email": "docente@ipt.pt",
                "date": d,
                "start": slot[0],
                "end": slot[1],
                "status": "completed" if d < date(2025, 12, 20) else "confirmed",
                "attendees": random.randint(3, 10),
            }
        )
        res_id += 1

    return reservations, res_id


def generate_sql():
    """Generate all SQL statements."""
    lines = []
    lines.append("-- =============================================================")
    lines.append("-- IPT Room Reservations App - Seed Data")
    lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("-- =============================================================")
    lines.append("")

    # Generate class reservations
    class_res, next_id = generate_class_reservations()
    exam_res, next_id = generate_exam_reservations(next_id)
    event_res, _ = generate_events_and_meetings(next_id)

    all_reservations = class_res + exam_res + event_res

    lines.append(f"-- Total reservations: {len(all_reservations)}")
    lines.append("")

    for r in all_reservations:
        cu_id = "NULL" if r["course_unit_id"] is None else r["course_unit_id"]
        desc = (
            "NULL" if r["description"] is None else f"'{escape_sql(r['description'])}'"
        )

        sql = f"""INSERT INTO reservations (room_id, reservation_type_id, course_unit_id, title, description, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count) VALUES ({r['room_id']}, {r['type_id']}, {cu_id}, '{escape_sql(r['title'])}', {desc}, '{escape_sql(r['reserved_by'])}', '{r['email']}', {format_date(r['date'])}, {format_time(r['start'])}, {format_time(r['end'])}, '{r['status']}', {r['attendees']});"""
        lines.append(sql)

    return "\n".join(lines)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate IPT Reservations seed data")
    parser.add_argument("--output", type=str, help="Output file (default: stdout)")
    args = parser.parse_args()

    sql = generate_sql()

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(sql)
        print(f"Generated reservations to {args.output}")
    else:
        print(sql)
