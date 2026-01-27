-- Mart: Room summary combining data from both systems
-- This is where we JOIN data from different sources!

WITH room_issues AS (
    SELECT 
        room_code,
        COUNT(*) as total_issues,
        COUNT(*) FILTER (WHERE status = 'open') as open_issues,
        COUNT(*) FILTER (WHERE status = 'in_progress') as in_progress_issues,
        COUNT(*) FILTER (WHERE status IN ('resolved', 'closed')) as resolved_issues,
        COUNT(*) FILTER (WHERE priority IN ('high', 'urgent')) as high_priority_issues,
        AVG(resolution_hours) FILTER (WHERE resolution_hours IS NOT NULL) as avg_resolution_hours
    FROM {{ ref('stg_issues') }}
    GROUP BY room_code
),

room_reservations AS (
    SELECT 
        room_code,
        COUNT(*) as total_reservations,
        COUNT(*) FILTER (WHERE status = 'completed') as completed_reservations,
        COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_reservations,
        SUM(duration_hours) as total_hours_booked,
        AVG(attendee_count) FILTER (WHERE attendee_count > 0) as avg_attendees
    FROM {{ ref('stg_reservations') }}
    WHERE reservation_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY room_code
)

SELECT
    r.room_id,
    r.room_code,
    r.building,
    r.room_name,
    r.room_type,
    r.capacity,
    r.has_projector,
    r.has_video_conference,
    r.has_computers,
    r.computer_count,
    r.is_active,
    
    -- Issues metrics
    COALESCE(i.total_issues, 0) as total_issues,
    COALESCE(i.open_issues, 0) as open_issues,
    COALESCE(i.in_progress_issues, 0) as in_progress_issues,
    COALESCE(i.resolved_issues, 0) as resolved_issues,
    COALESCE(i.high_priority_issues, 0) as high_priority_issues,
    ROUND(i.avg_resolution_hours::numeric, 1) as avg_resolution_hours,
    
    -- Reservations metrics (last 90 days)
    COALESCE(res.total_reservations, 0) as reservations_90d,
    COALESCE(res.completed_reservations, 0) as completed_reservations_90d,
    COALESCE(res.cancelled_reservations, 0) as cancelled_reservations_90d,
    ROUND(res.total_hours_booked::numeric, 1) as hours_booked_90d,
    ROUND(res.avg_attendees::numeric, 0) as avg_attendees,
    
    -- Utilization estimate (assuming 8h/day, 5 days/week for 13 weeks)
    ROUND(
        (COALESCE(res.total_hours_booked, 0) / (8 * 5 * 13)) * 100, 
        1
    ) as utilization_pct_90d,
    
    -- Health score (simple heuristic)
    CASE
        WHEN COALESCE(i.open_issues, 0) + COALESCE(i.in_progress_issues, 0) = 0 THEN 'good'
        WHEN COALESCE(i.high_priority_issues, 0) > 0 THEN 'critical'
        WHEN COALESCE(i.open_issues, 0) > 2 THEN 'needs_attention'
        ELSE 'fair'
    END as health_status

FROM {{ ref('stg_rooms') }} r
LEFT JOIN room_issues i ON r.room_code = i.room_code
LEFT JOIN room_reservations res ON r.room_code = res.room_code
