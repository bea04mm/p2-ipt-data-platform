-- Staging model: Clean and standardize issues data
-- This is the "T" (Transform) in ELT

SELECT
    id as issue_id,
    room_code,
    building_code,
    LOWER(TRIM(category)) as category,
    LOWER(TRIM(priority)) as priority,
    title,
    description,
    reported_by,
    reported_at,
    LOWER(TRIM(status)) as status,
    assigned_to,
    resolved_at,
    resolution_notes,
    
    -- Calculated fields
    CASE 
        WHEN resolved_at IS NOT NULL 
        THEN EXTRACT(EPOCH FROM (resolved_at - reported_at)) / 3600.0
        ELSE NULL 
    END as resolution_hours,
    
    _loaded_at

FROM {{ source('raw', 'issues') }}
