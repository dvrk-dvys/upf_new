WITH CORE AS (    
        SELECT
    --ra.candidate_icims_id
    ra.job_icims_id as ra_job_icims_id 
    ,ra.source_system 
    --Actor employee details--
    ,actor_employee_id
    ,ACT.employee_login as Recruiter_Login
    ,ACT.employee_display_name AS Recruiter_Name
    ,ACT.employee_internal_email_address as Recruiter_email
    ,ACT.location_name AS Recruiter_Building
    ,ACT.geo_region_name as Recruiter_Region
    ,ACT.location_country_name as Recruiter_Country
    
    ,ACT.job_family_name as Recruiter_job_family
    --,TEMP.job_family_name as Addecco_job_family
    ,ACT.job_title_name as Recruiter_Title
    --,TEMP.job_title_name as Addecco_Title
    ,ACT.employee_business_title as Recruiter_business_title
    --,TEMP.employee_business_title as Addecco_business_title
    
    ,ACT.job_code as Recruiter_Job_Code
    ,ACT.regular_temporary_name as Recruiter_Reg_Temp
    ,ACT.department_ofa_cost_center_code as Recruiter_Cost_Center
    ,ACT.job_level_name as Recruiter_Job_Level
    ,ACT.employee_badge_type as Recruiter_badge_type
    
    ,ra.candidate_identifier_employee_id 
    ,ra.candidate_identifier_login
    ,ra.candidate_identifier_name
    ,ra.candidate_identifier_reports_to_level_6_employee_login
    ,ra.candidate_identifier_reports_to_level_7_employee_login    



    ,RA.recruiting_state
    ,PL.*

    ,application_date

    ,resume_review_completed_date

    ,phone_screen_scheduled_date
    --,phone_screen_occurred_date
    ,phone_screen_completed_date

    ,on_site_scheduled_date
    --,on_site_occurred_date
    ,on_site_completed_date

    ,offer_extended_date 
    ,offer_accepted_date

    ,employee_starts_date
    --,last_event_time
    --,COALESCE(TRUNC(reporting_date), TRUNC(application_date))
    ,COALESCE(COALESCE(resume_review_completed_date, phone_screen_scheduled_date, phone_screen_occurred_date, phone_screen_completed_date, 
               on_site_scheduled_date, on_site_occurred_date, on_site_completed_date, offer_extended_date, offer_accepted_date, employee_starts_date),  application_date) AS reporting_date


    ,ACT.reports_to_supervisor_employee_login as recruiter_reports_to_supervisor
    ,ACT.reports_to_level_2_employee_login as recruiter_reports_to_level_2_login
    ,ACT.reports_to_level_3_employee_login as recruiter_reports_to_level_3_login
    ,ACT.reports_to_level_4_employee_login as recruiter_reports_to_level_4_login
    ,ACT.reports_to_level_5_employee_login as recruiter_reports_to_level_5_login
    ,ACT.reports_to_level_6_employee_login as recruiter_reports_to_level_6_login
    ,ACT.reports_to_level_7_employee_login as recruiter_reports_to_level_7_login
    ,ACT.reports_to_level_8_employee_login as recruiter_reports_to_level_8_login

    FROM opstadw.masterhr.recruiting_activity ra
        INNER JOIN masterhr.employee_hc_current act 
                    ON ((nvl(ra.actor_employee_id,'99999999999') = act.emplid  
                        AND act.reports_to_level_6_employee_login = 'arendtg'
                        AND act.reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')
                        AND act.job_level_name = 99
                        AND act.employee_badge_type = 'Yellow')
                    OR (nvl(ra.candidate_identifier_employee_id,'99999999999') = act.emplid
                        AND ra.candidate_identifier_reports_to_level_6_employee_login = 'arendtg'
                        AND ra.candidate_identifier_reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')
                        AND act.reports_to_level_6_employee_login = 'arendtg'
                        AND act.reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')
                        AND act.job_level_name = 99
                        AND act.employee_badge_type = 'Yellow'))
         LEFT JOIN ops_insearch.pipeline pl ON pl.person_id = ra.candidate_icims_id AND  pl.job_id = ra.job_icims_id AND is_latest_step = 'true'
         
    WHERE 1=1
    --AND job_level_name = 99
    --AND employee_badge_type = 'Yellow'
    AND ra.is_funnel_count = 'Y'
    --AND (act.reports_to_level_6_employee_login = 'arendtg'
    --AND (act.reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))
    AND ra.actor_employee_id <> ''
    AND RA.recruiting_state IN ('Employee Starts', 'Applicant Tagged', 'Resume Review Completed', 'Phone Screen Scheduled', 'Phone Screen Completed', 'On-site Scheduled', 'On-site Completed', 'Offer Extended', 'Offer Accepted', 'Debrief Scheduled')
),

max_req AS (

    SELECT
    MAX(snapshot_begin_timestamp) as max_req_state
    ,reqs.job_icims_id
    ,core.ra_job_icims_id 
    FROM masterhr.requisition reqs
    INNER JOIN CORE ON reqs.job_icims_id = core.ra_job_icims_id 
    WHERE 1=1
    --AND job_state != 'POOLING'
    GROUP BY
    reqs.job_icims_id
    ,core.ra_job_icims_id 
)


SELECT DISTINCT
reqs.city as req_city   
,reqs.building as req_building
,reqs.country as req_country
,reqs.job_classification_title
,reqs.internal_job_title as business_title
,reqs.job_code AS req_job_code
,reqs.ofa_cost_center_code as req_cost_center
,reqs.hiring_manager_reports_to_level_3_employee_login as hrng_mngr_reports_to_level3_login 
,reqs.job_level as req_job_level 
,reqs.job_state
,CORE.*
,DAYS.*
,TEMP.employee_login as Addecco_employee_login
,TEMP.job_level_name as Addecco_job_level
,TEMP.job_family_name as Addecco_job_family
,TEMP.job_title_name as Addecco_Title
,TEMP.job_action_code as Addecco_job_action_code
,TEMP.employee_badge_type as Addecco_employee_badge_type
,TEMP.emplid as Addecco_emplid
,TEMP.employee_business_title as Addecco_business_title


FROM CORE
INNER JOIN hrmetrics.o_reporting_days days ON TRUNC(calendar_day) = TRUNC(reporting_date) AND reporting_year = 2020
LEFT JOIN max_req ON max_req.job_icims_id = core.ra_job_icims_id
LEFT JOIN masterhr.requisition reqs ON reqs.job_icims_id = CORE.ra_job_icims_id AND reqs.snapshot_begin_timestamp = max_req.max_req_state --AND job_state != 'POOLING' 
LEFT JOIN masterhr.employee_hc_current TEMP ON TEMP.employee_login = CORE.Recruiter_Login
WHERE 1=1
--AND recruiter_reports_to_level_7_login NOT IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')
