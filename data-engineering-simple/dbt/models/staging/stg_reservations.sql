-- Staging model: Clean reservations data

SELECT
    r.id as reservation_id,
    r.room_id,
    rm.code as room_code,
    rt.code as reservation_type,
    rt.name as reservation_type_name,
    r.title,
    r.reserved_by,
    r.contact_email,
    r.reservation_date,
    r.start_time,
    r.end_time,
    LOWER(TRIM(r.status)) as status,
    COALESCE(r.attendee_count, 0) as attendee_count,
    r.created_at,
    r.cancelled_at,
    r.cancellation_reason,
    
    -- Calculated fields
    EXTRACT(EPOCH FROM (r.end_time - r.start_time)) / 3600.0 as duration_hours,
    EXTRACT(DOW FROM r.reservation_date) as day_of_week,
    
    r._loaded_at

FROM {{ source('raw', 'reservations') }} r
LEFT JOIN {{ source('raw', 'rooms') }} rm ON r.room_id = rm.id
LEFT JOIN {{ source('raw', 'reservation_types') }} rt ON r.reservation_type_id = rt.id
