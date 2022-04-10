WITH CORE AS (
    SELECT DISTINCT


    ra.candidate_icims_id
    ,ra.job_icims_id



    ,ra.source_system  
    --Actor employee details--
    ,actor_employee_id
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
    ,ACT.reports_to_supervisor_employee_login as Actor_reports_to_supervisor
    ,ACT.reports_to_level_2_employee_login as Actor_reports_to_level_2_login
    ,ACT.reports_to_level_3_employee_login as Actor_reports_to_level_3_login
    ,ACT.reports_to_level_4_employee_login as Actor_reports_to_level_4_login
    ,ACT.reports_to_level_5_employee_login as Actor_reports_to_level_5_login
    ,ACT.reports_to_level_6_employee_login as Actor_reports_to_level_6_login
    ,ACT.reports_to_level_7_employee_login as Actor_reports_to_level_7_login
    ,ACT.reports_to_level_8_employee_login as Actor_reports_to_level_8_login

    ,application_date

    ,resume_review_completed_date

    ,phone_screen_scheduled_date
    ,phone_screen_occurred_date
    ,phone_screen_completed_date

    ,on_site_scheduled_date
    ,on_site_occurred_date
    ,on_site_completed_date

    ,offer_date
    ,offer_extended_date 
    ,offer_accepted_date

    ,employee_starts_date


    FROM opstadw.masterhr.recruiting_activity ra
        INNER JOIN  masterhr.employee_hc_current act ON nvl(ra.actor_employee_id,'99999999999') = act.emplid AND DATEPART(year, hr_begin_dt) >= 2020
        --INNER JOIN ops_insearch.pipeline pl ON pl.person_id = ra.candidate_icims_id AND  pl.job_id = ra.job_icims_id AND is_internal = 'true' AND is_latest_step = 'true'
    WHERE 1=1
    AND DATEPART(year, application_date) = 2020
    AND ACT.reports_to_level_3_employee_login = 'darcie'
    --AND DATEPART(year, hr_begin_dt) >= 2020
    AND lower(ACT.job_title_name) NOT LIKE '%director%'
    AND lower(ACT.job_title_name) NOT LIKE '%manager%'
    AND lower(ACT.job_title_name) NOT LIKE '%principal%'
    AND lower(ACT.job_title_name) NOT LIKE '%mgr%'
    AND actor_employee_id <> ''
    AND actor_region = 'EMEA'
),

TEST as (

      SELECT DISTINCT 
      source_system

      FROM opstadw.masterhr.recruiting_activity ra
      --INNER JOIN  masterhr.employee_hc_current act ON nvl(ra.actor_employee_id,'99999999999') = act.emplid AND DATEPART(year, hr_begin_dt) >= 2020
      --INNER JOIN ops_insearch.pipeline pl ON pl.person_id = ra.candidate_icims_id AND  pl.job_id = ra.job_icims_id AND is_internal = 'true' AND is_latest_step = 'true'
      WHERE 1=1
      AND ra.is_funnel_count = 'Y'
          AND DATEPART(year, application_date) = 2020
      --      AND ACT.reports_to_level_3_employee_login = 'darcie'
      --AND DATEPART(year, hr_begin_dt) >= 2020
      --AND lower(ACT.job_title_name) NOT LIKE '%director%'
      --AND lower(ACT.job_title_name) NOT LIKE '%manager%'
      --AND lower(ACT.job_title_name) NOT LIKE '%principal%'
      --AND lower(ACT.job_title_name) NOT LIKE '%mgr%'
      --AND actor_employee_id <> ''

      
),

SYSTEMS AS (

SELECT DISTINCT 

      test.source_system as source_all
      ,ra.actor_employee_id

FROM opstadw.masterhr.recruiting_activity ra   
      --INNER JOIN  masterhr.employee_hc_current act ON nvl(ra.actor_employee_id,'99999999999') = act.emplid AND DATEPART(year, hr_begin_dt) >= 2020
      --INNER JOIN ops_insearch.pipeline pl ON pl.person_id = ra.candidate_icims_id AND  pl.job_id = ra.job_icims_id AND is_internal = 'true' AND is_latest_step = 'true'

CROSS JOIN test

WHERE 1=1
      AND ra.is_funnel_count = 'Y'
          AND DATEPART(year, application_date) = 2020
          --  AND ACT.reports_to_level_3_employee_login = 'darcie'
     -- AND DATEPART(year, hr_begin_dt) >= 2020
     -- AND lower(ACT.job_title_name) NOT LIKE '%director%'
     -- AND lower(ACT.job_title_name) NOT LIKE '%manager%'
     -- AND lower(ACT.job_title_name) NOT LIKE '%principal%'
      --AND lower(ACT.job_title_name) NOT LIKE '%mgr%'
     -- AND actor_employee_id <> ''

      
)


SELECT DISTINCT

CORE.candidate_icims_id
,CORE.job_icims_id
--,PL.* 
,hc.employee_login AS Actor_Login
,SYSTEMS.SOURCE_ALL AS source_system
,hc.emplid AS Actor_employee_id
,hc.employee_display_name AS Actor_Name
,hc.employee_internal_email_address AS Actor_email
,hc.location_name AS Actor_Building
,hc.geo_region_name AS Actor_Region 
,hc.location_country_name AS Actor_Country
,HC.job_title_name AS Actor_Title
,HC.job_code AS Job_Code
,HC.regular_temporary_name AS Actor_Reg_Temp
,hc.department_ofa_cost_center_code AS Actor_Cost_Center
,hc.job_level_name AS Actor_Job_Level
,hc.reports_to_supervisor_employee_login AS Actor_reports_to_supervisor
,hc.reports_to_level_2_employee_login AS Actor_reports_to_level_2_login
,hc.reports_to_level_3_employee_login AS Actor_reports_to_level_3_login
,hc.reports_to_level_4_employee_login AS Actor_reports_to_level_4_login
,hc.reports_to_level_5_employee_login AS Actor_reports_to_level_5_login
,hc.reports_to_level_6_employee_login AS Actor_reports_to_level_6_login
,hc.reports_to_level_7_employee_login AS Actor_reports_to_level_7_login
,hc.reports_to_level_8_employee_login AS Actor_reports_to_level_8_login

--,CASE WHEN applicant_count IS NULL THEN 'Never Active' ELSE 'Active' END AS activity_metric

,CORE.application_date

,CORE.resume_review_completed_date

,CORE.phone_screen_scheduled_date
,CORE.phone_screen_occurred_date
,CORE.phone_screen_completed_date

,CORE.on_site_scheduled_date
,CORE.on_site_occurred_date
,CORE.on_site_completed_date

,CORE.offer_date
,CORE.offer_extended_date 
,CORE.offer_accepted_date

,CORE.employee_starts_date



FROM SYSTEMS
LEFT OUTER JOIN CORE ON CORE.actor_employee_id = SYSTEMS.actor_employee_id AND SYSTEMS.source_all = CORE.SOURCE_SYSTEM
FULL OUTER JOIN (
            SELECT DISTINCT *
            FROM masterhr.employee_hc_current hc
            WHERE 1=1
            AND hc.reports_to_level_3_employee_login = 'darcie'
            AND DATEPART(year, hr_begin_dt) >= 2020
            AND lower(job_title_name) NOT LIKE '%director%'
            AND lower(job_title_name) NOT LIKE '%manager%'
            AND lower(job_title_name) NOT LIKE '%principal%'
            AND lower(job_title_name) NOT LIKE '%mgr%'
            AND hc.employee_login <> ''
                 ) AS not_active ON CORE.actor_login = not_active.employee_login
LEFT JOIN masterhr.employee_hc_current hc ON CORE.actor_employee_id = hc.emplid OR NOT_ACTIVE.employee_login = hc.employee_login OR SYSTEMS.actor_employee_id = hc.emplid
--INNER JOIN ops_insearch.pipeline pl ON pl.person_id = CORE.candidate_icims_id AND  pl.job_id = CORE.job_icims_id
 WHERE 1=1

    AND actor_region = 'EMEA'
