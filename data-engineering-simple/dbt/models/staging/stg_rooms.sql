-- Staging model: Clean rooms data

SELECT
    id as room_id,
    code as room_code,
    building,
    name as room_name,
    LOWER(TRIM(room_type)) as room_type,
    capacity,
    has_projector,
    has_video_conference,
    has_computers,
    COALESCE(computer_count, 0) as computer_count,
    COALESCE(is_active, true) as is_active,
    notes,
    _loaded_at

FROM {{ source('raw', 'rooms') }}
