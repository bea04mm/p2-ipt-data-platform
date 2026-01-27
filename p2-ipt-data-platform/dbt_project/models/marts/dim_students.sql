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
)

-- 2. Perform the Business Logic (Joins)
select 
    -- Student Details
    q.is_primeira_opcao,
    q.razoes_texto_livre,
    q.lista_codigos_conhecimento,
    q.lista_codigos_razoes,

    -- Course Details
    c.nome_curso,
    
    -- Admission Details
    i.descricao_ingresso as tipo_ingresso,

    -- Location Details: Origin (Where they live)
    o.concelho_origem,
    o.latitude_origem as lat_origem,
    o.longitude_origem as long_origem,

    -- Location Details: Previous School (Where they studied)
    e.concelho_escola,
    e.latitude_escola as lat_escola,
    e.longitude_escola as long_escola

from questions q
-- Join Course Name
left join courses c on q.code_course = c.code_course
-- Join Admission Type
left join ingressos i on q.code_ingresso = i.code_ingresso
-- Join Origin Location
left join origem o on q.code_origem_geo = o.code_origem_geo
-- Join School Location
left join escola e on q.code_escola_geo = e.code_escola_geo