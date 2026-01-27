with source as (
    select * from {{ ref('origemGeo') }}
)

select

    "codeOrigem" as code_origem_geo,
    "concelho" as concelho_origem,
    "latitude" as latitude_origem,
    "longitude" as longitude_origem
    
from source