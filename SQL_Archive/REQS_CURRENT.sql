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
  SELECT DISTINCT reports_to_level_6_employee_login, reports_to_level_6_employee_name, employee_login
  FROM masterhr.employee_hc
  WHERE 1=1
  AND reports_to_level_3_employee_login = 'darcie' 
  AND reports_to_level_4_employee_login = 'kdknight'
  AND reports_to_level_5_employee_login = 'lacall' 
  AND reports_to_level_6_employee_login IN ('mataalej', 'kttaylor', 'khouseho', 'wilsctt')
),

dwell_min_max AS (

    SELECT DISTINCT

    reqs.job_id
    ,reqs.job_guid
    ,reqs.current_job_state
    ,MIN(TRUNC(reqs.enter_state_time)) as event_min_date_time
    ,MAX(TRUNC(reqs.enter_state_time)) as event_max_date_time


    FROM masterhr.requisition reqs

    WHERE 1=1 

    AND reqs.job_state IN ('SUSPENDED', 'APPROVED', 'OPEN')
    
    AND reqs.requisition_opened_time >= '2019-01-01 00:00:00'
   -- AND job_guid = '00b3f513-2bcc-4184-b5aa-7f41a1abf0b0'

    GROUP BY
    reqs.job_id
    ,reqs.job_guid
    ,reqs.current_job_state

),

dwellraw AS (

        SELECT 

        dmm.job_id
        --,dmm.job_icims_id
        ,dmm.job_guid
        ,dmm.current_job_state
        
        ,dmm.event_min_date_time AS start_dwell
        ,dmm.event_max_date_time AS check_of_max_offer
        ,MIN(TRUNC(reqs.enter_state_time)) AS end_dwell
        ,MAX(TRUNC(reqs.enter_state_time)) AS event_max_date_time
        ,final_approval_date
        ,reqs.job_level
        ,job_tech_indicator
        ,reqs.requisition_opened_time
        ,reqs.city
        ,reqs.country
        ,reqs.current_sourcer_employee_login
        ,reqs.current_recruiter_employee_login
       -- ,department_short_name

        FROM dwell_min_max dmm
        LEFT JOIN masterhr.requisition reqs ON dmm.job_id = reqs.job_id AND dmm.job_guid = reqs.job_guid AND TRUNC(reqs.enter_state_time) > TRUNC(dmm.event_max_date_time)
       -- FROM masterhr.requisition reqs
       -- LEFT JOIN dwell_min_max dmm ON dmm.job_id = reqs.job_id AND dmm.job_guid = reqs.job_guid AND TRUNC(reqs.enter_state_time) > TRUNC(dmm.event_max_date_time)
    --    LEFT JOIN dwell_min_max dmm ON dmm.job_id = reqs.job_id AND dmm.job_icims_id = reqs.job_icims_id AND dmm.job_guid = reqs.job_guid --AND TRUNC(reqs.enter_state_time) > TRUNC(dmm.event_max_date_time)
        WHERE 1=1
        AND reqs.job_id IS NOT NULL
        AND dmm.job_id IS NOT NULL
        AND reqs.current_job_state != 'POOLING'
       -- AND reqs.job_icims_id is not null

        GROUP BY
        dmm.job_id
       -- ,dmm.job_icims_id
        ,dmm.job_guid
        ,dmm.event_max_date_time
        ,reqs.job_level
        ,reqs.final_approval_date
        ,requisition_opened_time
        ,job_tech_indicator
        ,reqs.city
        ,reqs.country
       -- ,department_short_name
        ,current_sourcer_employee_login
        ,current_recruiter_employee_login
        ,dmm.event_min_date_time
        ,dmm.event_max_date_time
        ,dmm.current_job_state
        
),


TEST AS (

SELECT DISTINCT
        dr.job_id
        --,dr.job_icims_id
        ,dr.job_guid
       -- ,DATEDIFF(day, start_dwell, end_dwell) AS total_dwelling_time
       -- ,DATEDIFF(day, start_dwell, CASE WHEN (TRUNC(calendar_day) + INTERVAL '6 DAY') > end_dwell THEN end_dwell ELSE (TRUNC(calendar_day) + INTERVAL '6 DAY') END) AS dwelling_time
        --,dr.requisition_age
       -- ,reporting_week_of_year
       -- ,calendar_month_of_year
       -- ,calendar_qtr
       -- ,reporting_year
        ,start_dwell
        ,end_dwell
        ,final_approval_date
        ,dr.job_level
        ,current_job_state
        ,job_tech_indicator
        --,sourcer_employee_login
        ,dr.requisition_opened_time
        ,dr.city
        ,dr.country
        ,current_sourcer_employee_login
        ,current_recruiter_employee_login
        --,department_short_name
        ,reports_to_level_6_employee_login
        ,TRUNC(SYSDATE) AS generated_date

FROM dwellraw dr
   -- INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND SYSDATE
  --  INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND end_dwell
    INNER JOIN reporting_line ON reporting_line.employee_login = dr.current_recruiter_employee_login

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

select 
*


FROM test t
--LEFT JOIN current_data cd on t.reporting_year = cd.reporting_year
WHERE 1=1
--AND reporting_week_of_year = current_week
--AND current_job_state = 'OPEN'

