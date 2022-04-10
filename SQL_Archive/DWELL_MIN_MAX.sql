WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year

    FROM hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = 2019
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
),


reporting_line AS (
  SELECT DISTINCT reports_to_level_6_employee_login, reports_to_level_6_employee_name, employee_login
  FROM masterhr.employee_hc
  WHERE reports_to_level_6_employee_login = 'amandam'
),


dwell_min_max AS (


    SELECT 

    reqs.job_id
    ,reqs.job_icims_id
    ,reqs.job_guid
    ,reqs.current_job_state
    ,MIN(TRUNC(reqs.enter_state_time)) as event_min_date_time
    ,MAX(TRUNC(reqs.enter_state_time)) as event_max_date_time


    FROM masterhr.requisition reqs
   -- LEFT JOIN masterhr.requisition_upd test ON test.job_id = reqs.job_id AND test.job_icims_id = reqs.job_icims_id
    WHERE 1=1 

    AND reqs.job_state IN ( 'OPEN', 'SUSPENDED', 'APPROVED')
    --AND reqs.job_guid = '33a1546f-c2d5-446e-8979-8abb4539ff1e'
    AND reqs.final_approval_date >= '2019-01-01 00:00:00'

    GROUP BY
    reqs.job_id
    ,reqs.job_icims_id
    ,reqs.job_guid
    ,reqs.current_job_state

),

dwellraw AS (

    SELECT 

        dmm.job_id
        ,dmm.job_icims_id
        ,dmm.job_guid
        ,dmm.current_job_state
        
        ,dmm.event_min_date_time AS start_dwell
        ,dmm.event_max_date_time AS check_of_max_offer
        ,MIN(TRUNC(reqs.enter_state_time)) AS end_dwell
        ,MAX(TRUNC(reqs.enter_state_time)) AS event_max_date_time
        ,final_approval_date
        ,reqs.requisition_age
        ,reqs.job_level
        ,job_tech_indicator
        ,sourcer_employee_login
        ,reqs.requisition_opened_time
        ,reqs.city
        ,reqs.country
        ,current_sourcer_employee_login
        ,current_recruiter_employee_login
        ,reqs.updated_date
        ,department_short_name

        FROM dwell_min_max dmm
    
        LEFT JOIN masterhr.requisition reqs ON dmm.job_id = reqs.job_id AND dmm.job_icims_id = reqs.job_icims_id AND dmm.job_guid = reqs.job_guid AND TRUNC(reqs.enter_state_time) > TRUNC(dmm.event_max_date_time)

        GROUP BY
        dmm.job_id
        ,dmm.job_icims_id
        ,dmm.job_guid
        ,dmm.event_max_date_time
        ,reqs.job_level
        ,sourcer_employee_login
        ,reqs.final_approval_date
        ,requisition_opened_time
        ,job_tech_indicator
        ,reqs.requisition_age
        ,reqs.city
        ,reqs.country
        ,department_short_name
        ,current_sourcer_employee_login
        ,current_recruiter_employee_login
        ,dmm.event_min_date_time
        ,dmm.event_max_date_time
        ,reqs.updated_date
        ,dmm.current_job_state
        
)

SELECT
        dr.job_id
        ,dr.job_icims_id
        ,dr.job_guid
        ,DATEDIFF(day, start_dwell, end_dwell) AS dwelling_time
        ,dr.requisition_age
        ,reporting_week_of_year
        ,calendar_month_of_year
        ,calendar_qtr
        ,reporting_year
        ,start_dwell
        --,dr.event_max_date_time AS check_of_max_offer
        ,end_dwell
        --,event_max_date_time
        ,final_approval_date
        ,dr.job_level
        ,current_job_state
        ,job_tech_indicator
        ,sourcer_employee_login
        ,dr.requisition_opened_time
        ,dr.city
        ,dr.country
        ,current_sourcer_employee_login
        ,current_recruiter_employee_login
        ,dr.updated_date
        ,department_short_name

FROM dwellraw dr
    INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND end_dwell
    INNER JOIN reporting_line ON reporting_line.employee_login = dr.current_recruiter_employee_login

WHERE 1=1
--AND job_guid = '33a1546f-c2d5-446e-8979-8abb4539ff1e'
AND reporting_week_of_year = 37
--AND calendar_month_of_year = 9
AND dwelling_time > 100 
--AND current_job_state IN ( 'OPEN', 'SUSPENDED', 'APPROVED')
