-- Mart: Issues summary for dashboards

SELECT
    issue_id,
    room_code,
    building_code,
    category,
    priority,
    title,
    status,
    reported_by,
    reported_at,
    assigned_to,
    resolved_at,
    resolution_hours,
    
    -- Time dimensions for filtering
    DATE_TRUNC('month', reported_at) as reported_month,
    DATE_TRUNC('week', reported_at) as reported_week,
    
    -- Age in days (for open issues)
    CASE 
        WHEN status NOT IN ('resolved', 'closed')
        THEN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - reported_at))
        ELSE NULL
    END as age_days,
    
    -- Is overdue? (open issues older than 7 days)
    CASE
        WHEN status NOT IN ('resolved', 'closed') 
             AND reported_at < CURRENT_TIMESTAMP - INTERVAL '7 days'
        THEN true
        ELSE false
    END as is_overdue

FROM {{ ref('stg_issues') }}
