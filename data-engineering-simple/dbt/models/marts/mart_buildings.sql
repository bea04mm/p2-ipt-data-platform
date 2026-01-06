-- Mart: Aggregated metrics by building

WITH building_issues AS (
    SELECT
        building_code,
        COUNT(*) as total_issues,
        COUNT(*) FILTER (WHERE status = 'open') as open_issues,
        COUNT(*) FILTER (WHERE priority IN ('high', 'urgent')) as critical_issues,
        AVG(resolution_hours) FILTER (WHERE resolution_hours IS NOT NULL) as avg_resolution_hours
    FROM {{ ref('stg_issues') }}
    GROUP BY building_code
),

building_reservations AS (
    SELECT
        rm.building,
        COUNT(*) as total_reservations,
        SUM(r.duration_hours) as total_hours,
        COUNT(DISTINCT r.room_code) as rooms_used,
        SUM(r.attendee_count) as total_attendees
    FROM {{ ref('stg_reservations') }} r
    JOIN {{ ref('stg_rooms') }} rm ON r.room_code = rm.room_code
    WHERE r.reservation_date >= CURRENT_DATE - INTERVAL '90 days'
      AND r.status IN ('completed', 'confirmed')
    GROUP BY rm.building
),

building_rooms AS (
    SELECT
        building,
        COUNT(*) as total_rooms,
        SUM(capacity) as total_capacity
    FROM {{ ref('stg_rooms') }}
    WHERE is_active = true
    GROUP BY building
)

SELECT
    COALESCE(br.building, bi.building_code) as building_code,
    
    -- Room stats
    COALESCE(brm.total_rooms, 0) as total_rooms,
    COALESCE(brm.total_capacity, 0) as total_capacity,
    
    -- Issues stats
    COALESCE(bi.total_issues, 0) as total_issues,
    COALESCE(bi.open_issues, 0) as open_issues,
    COALESCE(bi.critical_issues, 0) as critical_issues,
    ROUND(bi.avg_resolution_hours::numeric, 1) as avg_resolution_hours,
    
    -- Reservations stats (90 days)
    COALESCE(br.total_reservations, 0) as reservations_90d,
    ROUND(br.total_hours::numeric, 1) as hours_booked_90d,
    COALESCE(br.rooms_used, 0) as rooms_used_90d,
    COALESCE(br.total_attendees, 0) as total_attendees_90d

FROM building_rooms brm
FULL OUTER JOIN building_issues bi ON brm.building = bi.building_code
FULL OUTER JOIN building_reservations br ON brm.building = br.building
