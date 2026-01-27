with source as (
    select * from {{ ref('ingresso') }}
)

select

    "codeIngresso" as code_ingresso,
    "ingresso" as descricao_ingresso
    
from source