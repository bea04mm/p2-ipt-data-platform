{{ config(materialized='table') }}

with
-- 1. Import Staging Models
questions as (
    select * from {{ ref('stg_questionarios') }}
),

courses as (
    select * from {{ ref('stg_cursos') }}
),

origem as (
    select * from {{ ref('stg_origem_geo') }}
),

escola as (
    select * from {{ ref('stg_escola_geo') }}
),

ingressos as (
    select * from {{ ref('stg_ingressos') }}
),

conhecimento as (
    select * from {{ ref('stg_conhecimento') }}
),

razoes as (
    select * from {{ ref('stg_razoes') }}
),

questions_with_id as (
    select
        row_number() over (order by code_course, code_ingresso, code_origem_geo) as student_id,
        *
    from questions
),

students_by_region_course as (
    select
        o.code_origem_geo,
        o.concelho_origem,
        o.latitude_origem,
        o.longitude_origem,
        c.code_course,
        c.nome_curso,
        count(*) as total_students,
        count(case when q.is_primeira_opcao = true then 1 end) as first_choice_students,
        count(case when q.is_primeira_opcao = false then 1 end) as second_choice_students,
        round(
            (count(case when q.is_primeira_opcao = true then 1 end)::float 
            / count(*) * 100)::numeric, 2
        ) as first_choice_percentage
    from questions_with_id q
    left join courses c on q.code_course = c.code_course
    left join origem o on q.code_origem_geo = o.code_origem_geo
    group by o.code_origem_geo, o.concelho_origem, o.latitude_origem, o.longitude_origem, 
             c.code_course, c.nome_curso
),


students_by_course_admission as (
    select
        c.code_course,
        c.nome_curso,
        i.code_ingresso,
        i.descricao_ingresso as admission_type,
        count(*) as total_students,
        count(case when q.is_primeira_opcao = true then 1 end) as first_choice_students,
        round(
            (count(case when q.is_primeira_opcao = true then 1 end)::float 
            / count(*) * 100)::numeric, 2
        ) as first_choice_percentage,
        count(distinct o.code_origem_geo) as distinct_regions
    from questions_with_id q
    left join courses c on q.code_course = c.code_course
    left join ingressos i on q.code_ingresso = i.code_ingresso
    left join origem o on q.code_origem_geo = o.code_origem_geo
    group by c.code_course, c.nome_curso, i.code_ingresso, i.descricao_ingresso
),

course_knowledge_drivers as (
    select
        c.code_course,
        c.nome_curso,
        array_agg(distinct k.canal_divulgacao) filter (where k.canal_divulgacao is not null) as knowledge_areas,
        count(*) as students_citing_knowledge
    from questions_with_id q
    left join courses c on q.code_course = c.code_course
    left join conhecimento k on q.lista_codigos_conhecimento like '%' || k.code_conhecimento || '%'
    where q.lista_codigos_conhecimento is not null
    group by c.code_course, c.nome_curso
),

course_reason_drivers as (
    select
        c.code_course,
        c.nome_curso,
        array_agg(distinct r.motivo_escolha) filter (where r.motivo_escolha is not null) as enrollment_reasons,
        count(*) as students_citing_reasons
    from questions_with_id q
    left join courses c on q.code_course = c.code_course
    left join razoes r on q.lista_codigos_razoes like '%' || r.code_razao || '%'
    where q.lista_codigos_razoes is not null
    group by c.code_course, c.nome_curso
),

final as (
    select
        sbc.code_origem_geo,
        sbc.concelho_origem,
        sbc.latitude_origem,
        sbc.longitude_origem,
        
        sca.code_course,
        sca.nome_curso,
        
        sbc.total_students as students_from_region_for_course,
        sbc.first_choice_students as first_choice_from_region,
        sbc.second_choice_students as second_choice_from_region,
        sbc.first_choice_percentage as region_first_choice_pct,
        
        sca.code_ingresso,
        sca.admission_type,
        sca.total_students as students_via_admission_type,
        sca.first_choice_students as first_choice_via_admission,
        sca.first_choice_percentage as admission_first_choice_pct,
        sca.distinct_regions as regions_using_admission_type,
        
        ckd.knowledge_areas,
        ckd.students_citing_knowledge,
        
        crd.enrollment_reasons,
        crd.students_citing_reasons,
        
        current_timestamp as _dbt_created_at
    
    from students_by_region_course sbc
    full outer join students_by_course_admission sca 
        on sbc.code_course = sca.code_course
    left join course_knowledge_drivers ckd 
        on sca.code_course = ckd.code_course
    left join course_reason_drivers crd 
        on sca.code_course = crd.code_course
)

select * from final
