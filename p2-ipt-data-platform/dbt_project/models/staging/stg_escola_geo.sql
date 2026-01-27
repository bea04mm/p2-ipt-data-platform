with source as (
    select * from {{ ref('escola_geo') }}
)

select

    "codeEscola" as code_escola_geo,
    "concelho" as concelho_escola,
    "latitude" as latitude_escola,
    "longitude" as longitude_escola
    
from source