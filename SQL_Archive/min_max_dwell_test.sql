WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year

    FROM hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = DATEPART(year, sysdate)
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
),


reporting_line AS (
    SELECT DISTINCT 
    employee_login, employee_full_name,
    employee_internal_email_address,
  --  department_name, employee_business_title,
  --  reports_to_supervisor_employee_login, reports_to_supervisor_employee_name,
    reports_to_level_3_employee_login, reports_to_level_3_employee_name, 
    reports_to_level_4_employee_login, reports_to_level_4_employee_name, 
    reports_to_level_4_employee_login, reports_to_level_5_employee_name, 
    reports_to_level_6_employee_login, reports_to_level_6_employee_name
    FROM masterhr.employee_hc
    WHERE 1=1
    AND reports_to_level_3_employee_login = 'darcie' 
    AND reports_to_level_4_employee_login = 'kelleyse'
    AND reports_to_level_5_employee_login = 'chaluleu' 
    AND reports_to_level_6_employee_login = 'kevrodge'

)

    SELECT DISTINCT

    reqs.job_id
    ,reqs.job_guid
    ,reqs.current_job_state
    ,MIN(TRUNC(reqs.enter_state_time)) as event_min_date_time
    ,MAX(TRUNC(reqs.enter_state_time)) as event_max_date_time


    FROM masterhr.requisition reqs
    INNER JOIN reporting_line ON reporting_line.employee_login = reqs.current_recruiter_employee_login

    WHERE 1=1 
  --  AND reqs.job_state IN ('SUSPENDED', 'APPROVED', 'OPEN')
    AND reqs.job_state IN ('FILLED', 'ELIMINATED', 'OFFER ACCEPTED')    
    AND reqs.requisition_opened_time >= '2019-01-01 00:00:00'
   -- AND reqs.job_guid = '224ec595-7bef-4561-b7b8-88eab69ed4fc'
    --AND job_guid = '55779a81-b09e-4711-a289-24ba8c2ea79d' --open

    GROUP BY
    reqs.job_id
    ,reqs.job_guid
    ,reqs.current_job_state
