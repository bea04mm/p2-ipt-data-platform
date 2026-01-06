#!/usr/bin/env python3
"""
IPT Summaries & Attendance App - Seed Data Generator
Generates students, class summaries, and attendance records.
Run after the database is initialized with init.sql.

Usage:
    python generate_attendance.py [--output FILE]
"""

import argparse
import random
from datetime import date, datetime, time, timedelta

# Configuration
SEMESTER_START = date(2025, 9, 15)
SEMESTER_END = date(2025, 12, 19)
ACADEMIC_YEAR = "2025/2026"

# Portuguese first and last names for generating students
FIRST_NAMES_M = [
    "João",
    "Pedro",
    "Miguel",
    "Tiago",
    "Rui",
    "André",
    "Diogo",
    "Bruno",
    "Ricardo",
    "Filipe",
    "Daniel",
    "Hugo",
    "Gonçalo",
    "David",
    "Nuno",
    "Rafael",
    "Luís",
    "Carlos",
    "Paulo",
    "Francisco",
]
FIRST_NAMES_F = [
    "Maria",
    "Ana",
    "Sofia",
    "Inês",
    "Catarina",
    "Beatriz",
    "Carolina",
    "Mariana",
    "Joana",
    "Rita",
    "Marta",
    "Sara",
    "Francisca",
    "Leonor",
    "Diana",
    "Patrícia",
    "Raquel",
    "Cláudia",
    "Teresa",
    "Helena",
]
LAST_NAMES = [
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
    "Ribeiro",
    "Fernandes",
    "Lopes",
    "Marques",
    "Vieira",
    "Nunes",
    "Gonçalves",
    "Teixeira",
    "Moreira",
    "Pinto",
    "Correia",
    "Mendes",
]

# Course units with schedule info (cu_id, code, classes_per_week, class_type, teacher, room_code)
COURSE_UNITS = {
    # LEI Year 1
    1: {
        "code": "LEI-AM1",
        "name": "Análise Matemática I",
        "classes": 3,
        "type": "theoretical",
        "teacher": "Prof. Luís Merca",
        "room": "B255",
        "year": 1,
        "course": 1,
    },
    2: {
        "code": "LEI-ALG",
        "name": "Álgebra",
        "classes": 3,
        "type": "theoretical",
        "teacher": "Prof. Carlos Perquilhas",
        "room": "B256",
        "year": 1,
        "course": 1,
    },
    3: {
        "code": "LEI-IET",
        "name": "Introdução à Engenharia e à Tecnologia",
        "classes": 1,
        "type": "theoretical",
        "teacher": "Prof. Luís Miguel Oliveira",
        "room": "B250",
        "year": 1,
        "course": 1,
    },
    4: {
        "code": "LEI-IPRP",
        "name": "Introdução à Programação",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. António Manso",
        "room": "I153",
        "year": 1,
        "course": 1,
    },
    5: {
        "code": "LEI-SD",
        "name": "Sistemas Digitais",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. Manuel Barros",
        "room": "G150",
        "year": 1,
        "course": 1,
    },
    # LEI Year 2
    6: {
        "code": "LEI-POO",
        "name": "Programação Orientada a Objetos",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. António Manso",
        "room": "I154",
        "year": 2,
        "course": 1,
    },
    7: {
        "code": "LEI-BD",
        "name": "Bases de Dados",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. Hélder Pestana",
        "room": "I176",
        "year": 2,
        "course": 1,
    },
    8: {
        "code": "LEI-RC",
        "name": "Redes de Computadores",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. José Pereira",
        "room": "I155",
        "year": 2,
        "course": 1,
    },
    9: {
        "code": "LEI-SO",
        "name": "Sistemas Operativos",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. Pedro Correia",
        "room": "I177",
        "year": 2,
        "course": 1,
    },
    # LEI Year 3
    10: {
        "code": "LEI-ES",
        "name": "Engenharia de Software",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. Renato Panda",
        "room": "I178",
        "year": 3,
        "course": 1,
    },
    11: {
        "code": "LEI-SDist",
        "name": "Sistemas Distribuídos",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. Gabriel Pires",
        "room": "I179",
        "year": 3,
        "course": 1,
    },
    12: {
        "code": "LEI-IA",
        "name": "Inteligência Artificial",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. Ana Lopes",
        "room": "I180",
        "year": 3,
        "course": 1,
    },
    13: {
        "code": "LEI-SEG",
        "name": "Segurança Informática",
        "classes": 3,
        "type": "practical",
        "teacher": "Prof. Luís Miguel Oliveira",
        "room": "I181",
        "year": 3,
        "course": 1,
    },
    # MEI Year 1
    14: {
        "code": "MEI-AGVD",
        "name": "Análise de Grande Volume de Dados",
        "classes": 2,
        "type": "practical",
        "teacher": "Prof. Renato Panda",
        "room": "I182",
        "year": 1,
        "course": 2,
    },
    15: {
        "code": "MEI-AC",
        "name": "Aprendizagem Computacional",
        "classes": 2,
        "type": "practical",
        "teacher": "Prof. Gabriel Pires",
        "room": "I178",
        "year": 1,
        "course": 2,
    },
    16: {
        "code": "MEI-ES",
        "name": "Engenharia de Software",
        "classes": 2,
        "type": "practical",
        "teacher": "Prof. Renato Panda",
        "room": "I179",
        "year": 1,
        "course": 2,
    },
}

# Class topics by course unit (realistic Portuguese academic content)
TOPICS = {
    1: [
        "Introdução ao cálculo diferencial",
        "Limites e continuidade",
        "Derivadas - conceito e regras",
        "Derivadas de funções compostas",
        "Aplicações das derivadas",
        "Teoremas fundamentais",
        "Primitivas imediatas",
        "Técnicas de primitivação",
        "Integral definido",
        "Aplicações do integral",
        "Séries numéricas",
        "Critérios de convergência",
        "Revisões para frequência",
    ],
    2: [
        "Matrizes e operações",
        "Determinantes",
        "Sistemas de equações lineares",
        "Método de Gauss",
        "Espaços vetoriais",
        "Dependência linear",
        "Base e dimensão",
        "Transformações lineares",
        "Valores e vetores próprios",
        "Diagonalização",
        "Aplicações em informática",
        "Revisões e exercícios",
    ],
    3: [
        "Apresentação da licenciatura",
        "O perfil do engenheiro informático",
        "Ética profissional",
        "Visita às instalações",
        "Metodologias de trabalho",
        "Ferramentas de produtividade",
    ],
    4: [
        "Introdução à programação",
        "Variáveis e tipos de dados",
        "Estruturas condicionais",
        "Ciclos while e for",
        "Funções e procedimentos",
        "Arrays e listas",
        "Strings e manipulação",
        "Ficheiros - leitura e escrita",
        "Debugging e testes",
        "Projeto prático - Parte 1",
        "Projeto prático - Parte 2",
        "Apresentação de projetos",
        "Revisões para exame",
    ],
    5: [
        "Sistemas de numeração",
        "Álgebra de Boole",
        "Portas lógicas",
        "Circuitos combinatórios",
        "Mapas de Karnaugh",
        "Flip-flops",
        "Contadores",
        "Registos",
        "Memórias",
        "Arquitetura de processadores",
        "Projeto de circuitos",
        "Simulação de circuitos",
    ],
    6: [
        "Revisão de programação estruturada",
        "Introdução à POO",
        "Classes e objetos",
        "Construtores e destrutores",
        "Encapsulamento",
        "Herança",
        "Polimorfismo",
        "Classes abstratas e interfaces",
        "Exceções",
        "Coleções",
        "Padrões de desenho básicos",
        "Projeto POO",
        "Revisões",
    ],
    7: [
        "Introdução às bases de dados",
        "Modelo relacional",
        "SQL - SELECT básico",
        "SQL - JOINs",
        "SQL - Agregações",
        "SQL - Subqueries",
        "Modelação E-R",
        "Normalização",
        "Índices e otimização",
        "Transações",
        "Projeto prático BD",
        "Apresentação de projetos",
    ],
    8: [
        "Introdução às redes",
        "Modelo OSI",
        "Camada física",
        "Camada de ligação",
        "Ethernet e WiFi",
        "Camada de rede - IP",
        "Routing",
        "Camada de transporte",
        "TCP e UDP",
        "DNS e DHCP",
        "Configuração de redes",
        "Segurança de redes",
    ],
    9: [
        "Introdução aos SOs",
        "Gestão de processos",
        "Escalonamento",
        "Threads",
        "Sincronização",
        "Deadlocks",
        "Gestão de memória",
        "Memória virtual",
        "Sistema de ficheiros",
        "I/O",
        "Linux básico",
        "Scripting bash",
    ],
    10: [
        "Introdução à ES",
        "Metodologias ágeis",
        "Scrum",
        "User stories e backlog",
        "UML - Use cases",
        "UML - Classes",
        "UML - Sequência",
        "Design patterns",
        "Testes de software",
        "CI/CD",
        "Git avançado",
        "Projeto em equipa",
    ],
    11: [
        "Sistemas distribuídos - conceitos",
        "Comunicação entre processos",
        "RPC e RMI",
        "Sockets",
        "Web services REST",
        "Microserviços",
        "Docker",
        "Kubernetes básico",
        "Consistência e replicação",
        "Tolerância a falhas",
        "Projeto distribuído",
    ],
    12: [
        "Introdução à IA",
        "Agentes inteligentes",
        "Pesquisa em espaço de estados",
        "Pesquisa informada",
        "Jogos e minimax",
        "Machine learning - conceitos",
        "Regressão linear",
        "Classificação",
        "Árvores de decisão",
        "Redes neuronais",
        "Deep learning básico",
        "Projeto IA",
    ],
    13: [
        "Conceitos de segurança",
        "Criptografia simétrica",
        "Criptografia assimétrica",
        "Hashing",
        "Certificados digitais",
        "Autenticação",
        "Controlo de acesso",
        "Vulnerabilidades web",
        "Testes de penetração",
        "RGPD",
        "Projeto segurança",
    ],
    14: [
        "Introdução ao Big Data",
        "Ecossistema Hadoop",
        "HDFS",
        "MapReduce",
        "Spark - conceitos",
        "Spark - RDDs",
        "Spark SQL",
        "Data warehousing",
        "ETL vs ELT",
        "dbt",
        "Dashboards",
        "Projeto Big Data",
    ],
    15: [
        "Machine Learning - revisão",
        "Aprendizagem supervisionada",
        "Regressão",
        "Classificação",
        "Ensemble methods",
        "Aprendizagem não supervisionada",
        "Clustering",
        "Redução de dimensionalidade",
        "Deep learning",
        "CNNs",
        "RNNs",
        "Projeto ML",
    ],
    16: [
        "Engenharia de requisitos",
        "Arquitetura de software",
        "Design patterns avançados",
        "Clean code",
        "Refactoring",
        "Testes automatizados",
        "TDD",
        "BDD",
        "DevOps",
        "Monitorização",
        "Qualidade de software",
        "Projeto ES",
    ],
}

# Student counts per year
STUDENTS_PER_YEAR = {
    (1, 1): 85,  # LEI Year 1
    (1, 2): 55,  # LEI Year 2
    (1, 3): 35,  # LEI Year 3
    (2, 1): 20,  # MEI Year 1
}


def generate_student_name():
    """Generate a random Portuguese name."""
    if random.random() < 0.65:  # 65% male in informatics
        first = random.choice(FIRST_NAMES_M)
    else:
        first = random.choice(FIRST_NAMES_F)
    last1 = random.choice(LAST_NAMES)
    last2 = random.choice(LAST_NAMES)
    while last2 == last1:
        last2 = random.choice(LAST_NAMES)
    return f"{first} {last1} {last2}"


def escape_sql(s):
    """Escape single quotes for SQL."""
    if s is None:
        return "NULL"
    return s.replace("'", "''")


def generate_students():
    """Generate all students."""
    students = []
    student_id = 1
    used_numbers = set()

    for (course_id, year), count in STUDENTS_PER_YEAR.items():
        # Student numbers based on entry year, although IPT uses different patterns
        # LEI students: 2025XXXX for year 1, 2024XXXX for year 2, 2023XXXX for year 3
        # MEI students: 2025MXXX
        if course_id == 1:  # LEI
            entry_year = 2025 - year + 1
            num_base = entry_year * 10000
        else:  # MEI
            num_base = 20250000  # MEI students use 2025MXXX pattern

        seq = 1
        for i in range(count):
            name = generate_student_name()
            # Use sequential numbers to guarantee uniqueness
            student_num = f"{num_base + seq:08d}"
            while student_num in used_numbers:
                seq += 1
                student_num = f"{num_base + seq:08d}"
            used_numbers.add(student_num)
            seq += 1

            email = f"aluno{student_num}@ipt.pt"

            students.append(
                {
                    "id": student_id,
                    "student_number": student_num,
                    "name": name,
                    "email": email,
                    "course_id": course_id,
                    "year": year,
                }
            )
            student_id += 1

    return students


def generate_enrollments(students):
    """Generate course unit enrollments."""
    enrollments = []
    enroll_id = 1

    for student in students:
        course_id = student["course_id"]
        year = student["year"]

        # Get course units for this student's year
        for cu_id, cu_info in COURSE_UNITS.items():
            if cu_info["course"] == course_id and cu_info["year"] == year:
                enrollments.append(
                    {
                        "id": enroll_id,
                        "student_id": student["id"],
                        "course_unit_id": cu_id,
                    }
                )
                enroll_id += 1

    return enrollments


def get_class_dates(classes_per_week):
    """Get all class dates for the semester."""
    dates = []
    current = SEMESTER_START

    # Distribute classes across weekdays
    if classes_per_week == 1:
        days = [2]  # Wednesday
    elif classes_per_week == 2:
        days = [0, 3]  # Monday, Thursday
    else:
        days = [0, 2, 4]  # Monday, Wednesday, Friday

    while current <= SEMESTER_END:
        if current.weekday() in days:
            dates.append(current)
        current += timedelta(days=1)

    return dates


def generate_summaries():
    """Generate class summaries."""
    summaries = []
    summary_id = 1

    for cu_id, cu_info in COURSE_UNITS.items():
        dates = get_class_dates(cu_info["classes"])
        topics = TOPICS.get(cu_id, ["Aula prática"])

        for i, class_date in enumerate(dates):
            topic = topics[i % len(topics)]

            # Determine class time based on course
            if cu_info["course"] == 2:  # MEI - evening
                start = time(18, 0)
                end = time(21, 0)
            else:
                hour = 9 + (i % 4) * 2
                start = time(hour, 0)
                end = time(hour + 2, 0)

            summaries.append(
                {
                    "id": summary_id,
                    "course_unit_id": cu_id,
                    "class_date": class_date,
                    "start_time": start,
                    "end_time": end,
                    "room_code": cu_info["room"],
                    "summary_number": i + 1,
                    "topic": topic,
                    "class_type": cu_info["type"],
                    "teacher_name": cu_info["teacher"],
                }
            )
            summary_id += 1

    return summaries


def generate_attendance(students, enrollments, summaries):
    """Generate attendance records."""
    attendance = []
    att_id = 1

    # Create lookup for enrollments
    enrollment_lookup = {}
    for e in enrollments:
        key = (e["student_id"], e["course_unit_id"])
        enrollment_lookup[key] = True

    # Student attendance tendencies (some students more regular than others)
    student_tendency = {}
    for s in students:
        student_tendency[s["id"]] = random.uniform(0.6, 0.98)

    for summary in summaries:
        cu_id = summary["course_unit_id"]

        # Find enrolled students for this course unit
        for student in students:
            if (student["id"], cu_id) not in enrollment_lookup:
                continue

            # Determine if present based on tendency
            base_prob = student_tendency[student["id"]]

            # Adjust for day of week (Friday lower attendance)
            if summary["class_date"].weekday() == 4:
                base_prob -= 0.1

            # Adjust for time of semester (drops near end)
            days_into_semester = (summary["class_date"] - SEMESTER_START).days
            if days_into_semester > 70:
                base_prob -= 0.05

            present = random.random() < base_prob

            # Arrival time for present students
            arrival_time = None
            if present:
                late_minutes = random.choices(
                    [0, 5, 10, 15, 30], weights=[70, 15, 8, 5, 2]
                )[0]
                if late_minutes > 0:
                    arrival = datetime.combine(
                        summary["class_date"], summary["start_time"]
                    )
                    arrival += timedelta(minutes=late_minutes)
                    arrival_time = arrival.time()

            attendance.append(
                {
                    "id": att_id,
                    "summary_id": summary["id"],
                    "student_id": student["id"],
                    "present": present,
                    "arrival_time": arrival_time,
                }
            )
            att_id += 1

    return attendance


def generate_sql():
    """Generate all SQL statements."""
    lines = []
    lines.append("-- =============================================================")
    lines.append("-- IPT Summaries & Attendance App - Seed Data")
    lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("-- =============================================================")
    lines.append("")

    students = generate_students()
    enrollments = generate_enrollments(students)
    summaries = generate_summaries()
    attendance = generate_attendance(students, enrollments, summaries)

    lines.append(f"-- Students: {len(students)}")
    lines.append(f"-- Enrollments: {len(enrollments)}")
    lines.append(f"-- Summaries: {len(summaries)}")
    lines.append(f"-- Attendance records: {len(attendance)}")
    lines.append("")

    # Students
    lines.append("-- Students")
    for s in students:
        lines.append(
            f"INSERT INTO students (student_number, name, email, course_id, year) VALUES ('{s['student_number']}', '{escape_sql(s['name'])}', '{s['email']}', {s['course_id']}, {s['year']});"
        )

    lines.append("")
    lines.append("-- Enrollments")
    for e in enrollments:
        lines.append(
            f"INSERT INTO enrollments (student_id, course_unit_id, academic_year) VALUES ({e['student_id']}, {e['course_unit_id']}, '{ACADEMIC_YEAR}');"
        )

    lines.append("")
    lines.append("-- Summaries")
    for s in summaries:
        lines.append(
            f"INSERT INTO summaries (course_unit_id, class_date, start_time, end_time, room_code, summary_number, topic, class_type, teacher_name) VALUES ({s['course_unit_id']}, '{s['class_date']}', '{s['start_time']}', '{s['end_time']}', '{s['room_code']}', {s['summary_number']}, '{escape_sql(s['topic'])}', '{s['class_type']}', '{escape_sql(s['teacher_name'])}');"
        )

    lines.append("")
    lines.append("-- Attendance")
    for a in attendance:
        present = "true" if a["present"] else "false"
        arrival = f"'{a['arrival_time']}'" if a["arrival_time"] else "NULL"
        lines.append(
            f"INSERT INTO attendance (summary_id, student_id, present, arrival_time) VALUES ({a['summary_id']}, {a['student_id']}, {present}, {arrival});"
        )

    return "\n".join(lines)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate IPT Attendance seed data")
    parser.add_argument("--output", type=str, help="Output file (default: stdout)")
    args = parser.parse_args()

    sql = generate_sql()

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(sql)
        print(f"Generated attendance data to {args.output}")
    else:
        print(sql)
