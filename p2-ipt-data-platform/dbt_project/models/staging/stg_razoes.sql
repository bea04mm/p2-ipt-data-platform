with source as (
    select * from {{ ref('razoes') }}
)

select

    "codeRaz" as code_razao,
    "razao" as motivo_escolha
    
from source