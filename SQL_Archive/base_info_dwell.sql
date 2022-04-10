WITH reporting_line AS (
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
        job_id
        ,job_icims_id
        ,job_guid
       -- ,DATEDIFF(day, start_dwell, end_dwell) AS total_dwelling_time
       -- ,DATEDIFF(day, start_dwell, CASE WHEN (TRUNC(calendar_day) + INTERVAL '6 DAY') > end_dwell THEN end_dwell ELSE (TRUNC(calendar_day) + INTERVAL '6 DAY') END) AS dwelling_time
        --,dr.requisition_age
       -- ,reporting_week_of_year
       -- ,calendar_month_of_year
       -- ,calendar_qtr
       -- ,reporting_year
        --,start_dwell
        --,end_dwell
        ,job_level
        ,job_state
        ,current_job_state
        ,job_tech_indicator
        --,sourcer_employee_login
        ,enter_state_time
        ,requisition_opened_time
        ,final_approval_date
        ,city
        ,country
        ,current_sourcer_employee_login
        ,current_recruiter_employee_login
        ,department_short_name
        ,reports_to_level_6_employee_login
        ,TRUNC(SYSDATE) AS generated_date
      --  ,*


FROM masterhr.requisition reqs
INNER JOIN reporting_line ON reporting_line.employee_login = reqs.current_recruiter_employee_login

WHERE 1=1
--AND current_job_state = 'OPEN'
--AND reqs.final_approval_date >= '2019-01-01 00:00:00'
--AND reqs.requisition_opened_time >= '2019-01-01 00:00:00'
--AND reqs.job_guid = 'bbb32b08-5d7c-4ec3-8a0c-04225f4161f4'
--and reqs.job_id = 719894
