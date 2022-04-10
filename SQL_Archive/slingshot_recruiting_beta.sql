WITH CORE AS 
(    
    SELECT DISTINCT
    

    --ra.candidate_icims_id
    --,ra.job_icims_iD
    --,ra.source_system 
    --Actor employee details--
    
    actor_employee_id
    ,ACT.employee_login as Actor_Login
    ,ACT.employee_display_name AS Actor_Name
    ,ACT.employee_internal_email_address as Actor_email
    ,ACT.location_name AS Actor_Building
    ,ACT.geo_region_name as Actor_Region
    ,ACT.location_country_name as Actor_Country
    ,ACT.job_title_name as Actor_Title
    ,ACT.job_code as Job_Code
    ,ACT.regular_temporary_name as Actor_Reg_Temp
    ,ACT.department_ofa_cost_center_code as Actor_Cost_Center
    ,ACT.job_level_name as Actor_Job_Level
    ,PL.*

    ,reqs.city as req_city   
    ,reqs.building as req_building
    ,reqs.country as req_country
    ,reqs.job_classification_title
    ,reqs.internal_job_title as business_title
    ,reqs.job_title as external_job_title
    ,reqs.job_code AS req_job_code
    ,reqs.ofa_cost_center_code as req_cost_center
    ,reqs.hiring_manager_reports_to_level_3_employee_login as hrng_mngr_reports_to_level3_login 
    ,reqs.company_name
    ,reqs.department_name
    ,reqs.job_function
    ,reqs.job_type 
    ,reqs.job_level as req_job_level 
    ,snapshot_begin_timestamp
    ,snapshot_end_timestamp

    ,application_date

    ,resume_review_completed_date

    ,phone_screen_scheduled_date
    ,phone_screen_occurred_date
    ,phone_screen_completed_date

    ,on_site_scheduled_date
    ,on_site_occurred_date
    ,on_site_completed_date

    ,offer_extended_date 
    ,offer_accepted_date

    ,employee_starts_date
    
    ,COALESCE(resume_review_completed_date, phone_screen_scheduled_date, phone_screen_occurred_date, phone_screen_completed_date, 
               on_site_scheduled_date, on_site_occurred_date, on_site_completed_date, offer_extended_date, offer_accepted_date, employee_starts_date) AS reporting_date

    ,ACT.reports_to_supervisor_employee_login as Actor_reports_to_supervisor
    ,ACT.reports_to_level_5_employee_login as Actor_reports_to_level_5_login
    ,ACT.reports_to_level_6_employee_login as Actor_reports_to_level_6_login
    ,ACT.reports_to_level_7_employee_login as Actor_reports_to_level_7_login
    ,ACT.reports_to_level_8_employee_login as Actor_reports_to_level_8_login

    FROM opstadw.masterhr.recruiting_activity ra
        INNER JOIN  masterhr.employee_hc_current act ON nvl(ra.actor_employee_id,'99999999999') = act.emplid AND DATEPART(year, hr_begin_dt) in (2020, 2019)
        INNER JOIN ops_insearch.pipeline pl ON pl.person_id = ra.candidate_icims_id AND  pl.job_id = ra.job_icims_id AND is_internal = 'true' AND is_latest_step = 'true'
        INNER JOIN masterhr.requisition reqs on reqs.job_icims_id = pl.job_id AND job_state != 'POOLING' AND pl.enter_state_time BETWEEN reqs.snapshot_begin_timestamp and reqs.snapshot_end_timestamp
    WHERE 1=1
    --AND DATEPART(year, application_date) = 2020.
    --AND ACT.job_level_name = 99
    AND (ACT.reports_to_level_5_employee_login = 'arendtg'
    OR (ACT.reports_to_level_6_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))
    --AND DATEPART(year, hr_begin_dt) >= 2020
    AND actor_employee_id <> ''
    AND NOT (
              resume_review_completed_date IS NULL 
              AND phone_screen_scheduled_date IS NULL 
              AND phone_screen_occurred_date IS NULL 
              AND phone_screen_completed_date IS NULL 
              AND on_site_scheduled_date IS NULL 
              AND on_site_occurred_date IS NULL 
              AND offer_date IS NULL 
              AND offer_extended_date IS NULL 
              AND offer_accepted_date IS NULL
              AND employee_starts_date IS NULL
            ) 
)

SELECT *
FROM CORE
LEFT JOIN hrmetrics.o_reporting_days days ON TRUNC(calendar_day) = COALESCE(TRUNC(reporting_date), TRUNC(application_date))
WHERE 1=1 
--AND person_job_id = '7786555_1075568'
--AND reporting_date is null
