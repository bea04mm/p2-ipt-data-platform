with source as (
    select * from {{ ref('conhecimento') }}
)

select

    "codeConhecimento" as code_conhecimento,
    "conhecimento" as canal_divulgacao
    
from source