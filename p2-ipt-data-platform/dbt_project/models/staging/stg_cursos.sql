with source as (
    select * from {{ ref('curso') }}
)

select

    "codeCourse" as code_course,
    "curso" as nome_curso
    
from source