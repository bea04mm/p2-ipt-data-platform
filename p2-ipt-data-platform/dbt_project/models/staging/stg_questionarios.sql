with source as (
    select * from {{ ref('questionarios') }}
)

select

    "codeCourse" as code_course,
    "ingresso" as code_ingresso,
    "OrigemGeo" as code_origem_geo,
    "EscolaGeo" as code_escola_geo,
    "primeiraOpc" as is_primeira_opcao,
    "conhecimento" as lista_codigos_conhecimento,
    "razoes" as lista_codigos_razoes,
    "razoesText" as razoes_texto_livre

from source