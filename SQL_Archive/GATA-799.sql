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
  WHERE 1=1
  AND reports_to_level_3_employee_login = 'darcie' 
  AND reports_to_level_4_employee_login = 'kdknight'
  AND reports_to_level_5_employee_login = 'lacall' 
  AND reports_to_level_6_employee_login IN ('mataalej', 'kttaylor', 'khouseho', 'wilsctt')
            
),


test AS (  
 
SELECT 
reqs.job_id
,reqs.job_icims_id
,reqs.job_guid
,reqs.current_job_state
,reqs.enter_state_time
--,MAX(TRUNC(reqs.enter_state_time)) as event_max_date_time
--,final_approval_date
,reqs.final_approval_date
,job_level
,job_tech_indicator
--,requisition_opened_time
,city
,country
,current_sourcer_employee_login
,current_recruiter_employee_login
,reports_to_level_6_employee_login
,TRUNC(SYSDATE) AS generated_date


FROM masterhr.requisition reqs
INNER JOIN reporting_line ON reporting_line.employee_login = reqs.current_recruiter_employee_login
--INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND end_dwell
-- LEFT JOIN masterhr.requisition_upd test ON test.job_id = reqs.job_id AND test.job_icims_id = reqs.job_icims_id
   
WHERE 1=1 
AND reqs.current_job_state IN ('OPEN', 'APPROVED')
AND reqs.job_icims_id <> ''
    
GROUP BY
reqs.job_id
,reqs.job_icims_id
,reqs.job_guid
,reqs.current_job_state
,final_approval_date
,job_level
,current_job_state
,job_tech_indicator
,reqs.enter_state_time
--,requisition_opened_time
,city
,country
,current_sourcer_employee_login
,current_recruiter_employee_login
,department_short_name
,reports_to_level_6_employee_login
)


SELECT DISTINCT
job_id
,COALESCE(job_icims_id, NULL) AS job_icims_id_final
--,reqs.job_icims_id
,job_guid
,current_job_state
,MAX(TRUNC(enter_state_time)) as event_max_date_time
--,final_approval_date
,COALESCE(final_approval_date, NULL) AS final_approval_date_final
,job_level
,current_job_state
,job_tech_indicator
--,requisition_opened_time
,city
,country
,current_sourcer_employee_login
,current_recruiter_employee_login
,reports_to_level_6_employee_login
,generated_date


--,calendar_day
--,reporting_week_of_year
--,calendar_month_of_year
--,calendar_qtr
--,reporting_year

FROM TEST t
--LEFT JOIN weeks wks ON wks.calendar_day = t.event_max_date_time

GROUP BY
job_id
,job_icims_id
,job_guid
,current_job_state
--,MAX(TRUNC(reqs.enter_state_time)
,final_approval_date
,job_level
,current_job_state
,job_tech_indicator
,city
,country
,current_sourcer_employee_login
,current_recruiter_employee_login
,reports_to_level_6_employee_login
,generated_date
