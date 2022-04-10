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

),

dwell_min_max AS (

    SELECT DISTINCT

    reqs.job_id
    ,reqs.job_guid
    ,reqs.current_job_state
    ,MIN(TRUNC(reqs.enter_state_time)) as event_min_date_time
    ,MAX(TRUNC(reqs.enter_state_time)) as event_max_date_time


    FROM masterhr.requisition reqs
    INNER JOIN reporting_line ON reporting_line.employee_login = reqs.current_recruiter_employee_login

    WHERE 1=1 
    AND reqs.job_state IN ('SUSPENDED', 'APPROVED', 'OPEN')    
    AND reqs.requisition_opened_time >= '2019-01-01 00:00:00'
   -- AND reqs.job_guid = '224ec595-7bef-4561-b7b8-88eab69ed4fc'
    --AND job_guid = '55779a81-b09e-4711-a289-24ba8c2ea79d' --open

    GROUP BY
    reqs.job_id
    ,reqs.job_guid
    ,reqs.current_job_state


),

dwellraw AS (

        SELECT DISTINCT

        reqs.job_id
        ,reqs.job_icims_id
        ,reqs.job_guid
        ,reqs.current_job_state
        ,dmm.event_min_date_time AS start_dwell
        ,dmm.event_max_date_time AS check_of_max_offer
        ,MIN(TRUNC(reqs.enter_state_time)) AS end_dwell
        ,(CASE WHEN reqs.current_job_state IN ( 'OPEN', 'APPROVED') THEN SYSDATE ELSE MIN(TRUNC(reqs.enter_state_time)) END) AS test_end
       -- ,MAX(TRUNC(reqs.enter_state_time)) AS event_max_date_time
        ,final_approval_date
    --    ,reqs.job_level
      --  ,job_tech_indicator
        ,reqs.requisition_opened_time
     --   ,reqs.city
     --   ,reqs.country
      --  ,MAX(TRUNC(reqs.snapshot_end_timestamp)) AS test_end
        --,current_sourcer_employee_login
        --,current_recruiter_employee_login
       -- ,department_short_name


        FROM dwell_min_max dmm
        LEFT JOIN masterhr.requisition reqs ON dmm.job_id = reqs.job_id AND dmm.job_guid = reqs.job_guid AND TRUNC(reqs.enter_state_time) >= TRUNC(dmm.event_max_date_time)

        INNER JOIN reporting_line ON reporting_line.employee_login = reqs.current_recruiter_employee_login

        WHERE 1=1
        AND reqs.job_id IS NOT NULL
        AND reqs.current_job_state != 'POOLING'
        AND reqs.requisition_opened_time >= '2019-01-01 00:00:00'



        GROUP BY
        reqs.job_id
        ,reqs.job_icims_id
        ,reqs.job_guid
       -- ,reqs.job_level
        ,reqs.final_approval_date
        ,reqs.requisition_opened_time
       -- ,reqs.job_tech_indicator
       -- ,reqs.city
       -- ,reqs.country
       -- ,department_short_name
       -- ,current_sourcer_employee_login
       -- ,current_recruiter_employee_login
        ,dmm.event_min_date_time
        ,dmm.event_max_date_time
        ,reqs.current_job_state
),

prep AS (

SELECT DISTINCT
        dr.job_id
        --,dr.job_icims_id
        ,dr.job_guid
        
        --,DATEDIFF(day, start_dwell, end_dwell) AS total_dwelling_time
       -- ,DATEDIFF(day, start_dwell, CASE WHEN (TRUNC(calendar_day) + INTERVAL '6 DAY') > end_dwell THEN end_dwell ELSE (TRUNC(calendar_day) + INTERVAL '6 DAY') END) AS dwelling_time
       
        ,DATEDIFF(day, start_dwell, CASE WHEN (test_end > SYSDATE or current_job_state IN ('FILLED', 'OFFER ACCEPTED')) THEN SYSDATE ELSE test_end END) AS total_dwelling_time
        ,DATEDIFF(day, start_dwell, CASE WHEN ((TRUNC(calendar_day) + INTERVAL '6 DAY') > SYSDATE OR current_job_state IN ('FILLED', 'OFFER ACCEPTED')) THEN SYSDATE ELSE (TRUNC(calendar_day) + INTERVAL '6 DAY') END) AS dwelling_time
        ,reporting_week_of_year
        ,calendar_month_of_year
        ,calendar_qtr
        ,reporting_year
        ,start_dwell
  --      ,end_dwell
        ,test_end
   --     ,final_approval_date
      --,dr.job_level
        ,current_job_state
      --  ,job_tech_indicator
        --,sourcer_employee_login
        ,dr.requisition_opened_time
     --   ,dr.city
     --   ,dr.country
        --,current_sourcer_employee_login
        --,current_recruiter_employee_login
        --,department_short_name
        --,reports_to_level_6_employee_login
        ,TRUNC(SYSDATE) AS generated_date

FROM dwellraw dr
    INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND test_end
  --  INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND end_dwell
    --INNER JOIN reporting_line ON reporting_line.employee_login = dr.current_recruiter_employee_login

WHERE 1=1

--AND reporting_week_of_year = 40
--AND calendar_month_of_year = 9
--AND dwelling_time > 100 
        
),

current_data AS (
    SELECT 
    max(reporting_week_of_year) AS current_week
    ,max(calendar_month_of_year) AS current_month
    ,max(calendar_qtr) AS current_quarter
    ,reporting_year

    FROM hrmetrics.o_reporting_days

    WHERE 1=1
    AND calendar_day_of_week = 1 
    AND reporting_year = DATEPART(year, sysdate)
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
    AND calendar_month_of_year <= DATEPART(month, sysdate)

    GROUP BY
    reporting_year
    
)

select *

FROM prep p
LEFT JOIN current_data cd on p.reporting_year = cd.reporting_year

WHERE 1=1
AND reporting_week_of_year = 42
AND reporting_week_of_year in(current_week, (current_week)-1)
--AND job_guid = '05ca7d01-5ddd-4cf4-bae4-c60870e1ce4b'
