WITH CORE AS (    
    SELECT
    --ra.candidate_icims_id
    --,ra.job_icims_id
    ra.source_system 
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
        INNER JOIN masterhr.employee_hc_current act ON nvl(ra.actor_employee_id,'99999999999') = act.emplid --AND DATEPART(year, ACT.hr_begin_dt) >= 2020
        LEFT JOIN ops_insearch.pipeline pl ON pl.person_id = ra.candidate_icims_id AND  pl.job_id = ra.job_icims_id AND is_latest_step = 'true'
    WHERE 1=1
    --AND job_level_name = 99
    --AND employee_badge_type = 'Yellow'
    AND ra.is_funnel_count = 'Y'
    AND (act.reports_to_level_6_employee_login = 'arendtg'
    AND (act.reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))
    AND actor_employee_id <> ''
    AND RA.recruiting_state IN ('Employee Starts', 'Applicant Tagged', 'Resume Review Completed', 'Phone Screen Scheduled', 'Phone Screen Completed', 'On-site Scheduled', 'On-site Completed', 'Offer Extended', 'Offer Accepted', 'Debrief Scheduled')        
),

max_req AS (

    SELECT
    MAX(snapshot_begin_timestamp) as max_req_state
    ,reqs.job_icims_id
    FROM masterhr.requisition reqs
    INNER JOIN CORE ON reqs.job_icims_id = core.job_id
    WHERE 1=1
    AND job_state != 'POOLING'
    GROUP BY
    reqs.job_icims_id

),

BASE AS (
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
    ,CORE.*
    ,DAYS.*


    FROM CORE
    INNER JOIN hrmetrics.o_reporting_days days ON TRUNC(calendar_day) = TRUNC(reporting_date) AND reporting_year = 2020
    LEFT JOIN max_req ON max_req.job_icims_id = core.job_id
    LEFT JOIN masterhr.requisition reqs ON reqs.job_icims_id = CORE.job_id AND job_state != 'POOLING' AND reqs.snapshot_begin_timestamp = max_req.max_req_state
    WHERE 1=1    
),

TEMP AS (
    SELECT DISTINCT
    TEMP.employee_login as Addecco_employee_login
    ,TEMP.job_level_name as Addecco_job_level
    ,TEMP.job_family_name as Addecco_job_family
    ,TEMP.job_title_name as Addecco_Title
    ,TEMP.job_action_code as Addecco_job_action_code
    ,TEMP.employee_badge_type as Addecco_employee_badge_type
    ,TEMP.emplid as Addecco_emplid
    ,TEMP.employee_business_title as Addecco_business_title

    FROM masterhr.employee_hc_current TEMP           
    WHERE 1=1
        AND TEMP.reports_to_level_6_employee_login = 'arendtg'
        AND TEMP.reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')
        AND job_level_name = 99
        AND employee_badge_type = 'Yellow'
)   


----Union of all the WBR metrics-------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
,unionedSlingshot as (
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    SELECT DISTINCT 'CORE'::VARCHAR(200) AS metric_name,
    req_city::VARCHAR(200),
    req_building::VARCHAR(200),
    req_country::VARCHAR(200),
    job_classification_title::VARCHAR(200),
    business_title::VARCHAR(200),
    req_job_code::VARCHAR(200),
    req_cost_center::VARCHAR(200),
    hrng_mngr_reports_to_level3_login::VARCHAR(200),
    req_job_level::VARCHAR(200),
    source_system::VARCHAR(200),
    actor_employee_id::VARCHAR(200),
    recruiter_login::VARCHAR(200),
    recruiter_name::VARCHAR(200),
    recruiter_email::VARCHAR(200),
    recruiter_building::VARCHAR(200),
    recruiter_region::VARCHAR(200),
    recruiter_country::VARCHAR(200),
    recruiter_job_family::VARCHAR(200),
    recruiter_title::VARCHAR(200),
    recruiter_business_title::VARCHAR(200),
    recruiter_job_code::VARCHAR(200),
    recruiter_reg_temp::VARCHAR(200),
    recruiter_cost_center::VARCHAR(200),
    recruiter_job_level::VARCHAR(200),
    recruiter_badge_type::VARCHAR(200),
    recruiting_state::VARCHAR(200),
    person_job_id::VARCHAR(200),
    person_id::VARCHAR(200),
    job_id::VARCHAR(200),
    step::VARCHAR(200),
    source_status::VARCHAR(200),
    enter_state_time::VARCHAR(200),
    source::VARCHAR(200),
    NULL AS is_latest_step,
    NULL AS is_mapped,
    NULL AS is_internal,
    NULL AS is_recyclable,
    concat_steps::VARCHAR(200),
    application_date::VARCHAR(200),
    resume_review_completed_date::VARCHAR(200),
    phone_screen_scheduled_date::VARCHAR(200),
    phone_screen_completed_date::VARCHAR(200),
    on_site_scheduled_date::VARCHAR(200),
    on_site_completed_date::VARCHAR(200),
    offer_extended_date::VARCHAR(200),
    offer_accepted_date::VARCHAR(200),
    employee_starts_date::VARCHAR(200),
    reporting_date::TIMESTAMP,
    recruiter_reports_to_supervisor::VARCHAR(200),
    recruiter_reports_to_level_2_login::VARCHAR(200),
    recruiter_reports_to_level_3_login::VARCHAR(200),
    recruiter_reports_to_level_4_login::VARCHAR(200),
    recruiter_reports_to_level_5_login::VARCHAR(200),
    recruiter_reports_to_level_6_login::VARCHAR(200),
    recruiter_reports_to_level_7_login::VARCHAR(200),
    recruiter_reports_to_level_8_login::VARCHAR(200),
    calendar_day::TIMESTAMP,
    calendar_year::SMALLINT,
    calendar_month_of_year::SMALLINT,
    calendar_day_of_month::SMALLINT,
    calendar_day_of_week::SMALLINT,
    calendar_week::SMALLINT,
    calendar_day_of_year::SMALLINT,
    calendar_qtr::SMALLINT,
    reporting_year::SMALLINT,
    reporting_week_of_year::SMALLINT,
    reporting_week_offset::SMALLINT,
    reporting_year_offset::SMALLINT,
    iso_reporting_week_of_year::numeric(38,10),
    NULL AS addecco_employee_login, 
    NULL AS addecco_job_level,
    NULL AS addecco_job_family,
    NULL AS addecco_title,
    NULL AS addecco_job_action_code,
    NULL AS addecco_employee_badge_type,
    NULL AS addecco_emplid,
    NULL AS addecco_business_title

    FROM BASE


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    SELECT DISTINCT 'TEMP'::VARCHAR(200) AS metric_name,
    NULL AS req_city,
    NULL AS req_building,
    NULL AS req_country,
    NULL AS job_classification_title,
    NULL AS business_title,
    NULL AS req_job_code,
    NULL AS req_cost_center,
    NULL AS hrng_mngr_reports_to_level3_login,
    NULL AS req_job_level,
    NULL AS source_system,
    NULL AS actor_employee_id,
    NULL AS recruiter_login,
    NULL AS recruiter_name,
    NULL AS recruiter_email,
    NULL AS recruiter_building,
    NULL AS recruiter_region,
    NULL AS recruiter_country,
    NULL AS recruiter_job_family,
    NULL AS recruiter_title,
    NULL AS recruiter_business_title,
    NULL AS recruiter_job_code,
    NULL AS recruiter_reg_temp,
    NULL AS recruiter_cost_center,
    NULL AS recruiter_job_level,
    NULL AS recruiter_badge_type,
    NULL AS recruiting_state,
    NULL AS person_job_id,
    NULL AS person_id,
    NULL AS job_id,
    NULL AS step,
    NULL AS source_status,
    NULL AS enter_state_time,
    NULL AS source,
    NULL AS is_latest_step,
    NULL AS is_mapped,
    NULL AS is_internal,
    NULL AS is_recyclable,
    NULL AS concat_steps,
    NULL AS application_date,
    NULL AS resume_review_completed_date,
    NULL AS phone_screen_scheduled_date,
    NULL AS phone_screen_completed_date,
    NULL AS on_site_scheduled_date,
    NULL AS on_site_completed_date,
    NULL AS offer_extended_date,
    NULL AS offer_accepted_date,
    NULL AS employee_starts_date,
    NULL::TIMESTAMP AS reporting_date,
    NULL AS recruiter_reports_to_supervisor,
    NULL AS recruiter_reports_to_level_2_login,
    NULL AS recruiter_reports_to_level_3_login,
    NULL AS recruiter_reports_to_level_4_login,
    NULL AS recruiter_reports_to_level_5_login,
    NULL AS recruiter_reports_to_level_6_login,
    NULL AS recruiter_reports_to_level_7_login,
    NULL AS recruiter_reports_to_level_8_login,
    NULL::TIMESTAMP AS calendar_day,
    NULL::int4 AS calendar_year,
    NULL::int4 AS calendar_month_of_year,
    NULL::int4 AS calendar_day_of_month,
    NULL::int4 AS calendar_day_of_week,
    NULL::int4 AS calendar_week,
    NULL::int4 AS calendar_day_of_year,
    NULL::int4 AS calendar_qtr,
    NULL::int4 AS reporting_year,
    NULL::int4 AS reporting_week_of_year,
    NULL::int4 AS reporting_week_offset,
    NULL::int4 AS reporting_year_offset,
    NULL::int4 AS iso_reporting_week_of_year,
    addecco_employee_login::VARCHAR(200), 
    addecco_job_level::VARCHAR(200),
    addecco_job_family::VARCHAR(200),
    addecco_title::VARCHAR(200),
    addecco_job_action_code::VARCHAR(200),
    addecco_employee_badge_type::VARCHAR(200),
    addecco_emplid::VARCHAR(200),
    addecco_business_title::VARCHAR(200)

        FROM TEMP

)


SELECT DISTINCT      
    req_city::VARCHAR(200),
    req_building::VARCHAR(200),
    req_country::VARCHAR(200),
    job_classification_title::VARCHAR(200),
    business_title::VARCHAR(200),
    req_job_code::VARCHAR(200),
    req_cost_center::VARCHAR(200),
    hrng_mngr_reports_to_level3_login::VARCHAR(200),
    req_job_level::VARCHAR(200),
    source_system::VARCHAR(200),
    actor_employee_id::VARCHAR(200),
    recruiter_login::VARCHAR(200),
    recruiter_name::VARCHAR(200),
    recruiter_email::VARCHAR(200),
    recruiter_building::VARCHAR(200),
    recruiter_region::VARCHAR(200),
    recruiter_country::VARCHAR(200),
    recruiter_job_family::VARCHAR(200),
    recruiter_title::VARCHAR(200),
    recruiter_business_title::VARCHAR(200),
    recruiter_job_code::VARCHAR(200),
    recruiter_reg_temp::VARCHAR(200),
    recruiter_cost_center::VARCHAR(200),
    recruiter_job_level::VARCHAR(200),
    recruiter_badge_type::VARCHAR(200),
    recruiting_state::VARCHAR(200),
    person_job_id::VARCHAR(200),
    person_id::VARCHAR(200),
    job_id::VARCHAR(200),
    step::VARCHAR(200),
    source_status::VARCHAR(200),
    enter_state_time::VARCHAR(200),
    source::VARCHAR(200),
    is_latest_step::VARCHAR(200),
    is_mapped::VARCHAR(200),
    is_internal::VARCHAR(200),
    is_recyclable::VARCHAR(200),
    concat_steps::VARCHAR(200),
    application_date::VARCHAR(200),
    resume_review_completed_date::VARCHAR(200),
    phone_screen_scheduled_date::VARCHAR(200),
    phone_screen_completed_date::VARCHAR(200),
    on_site_scheduled_date::VARCHAR(200),
    on_site_completed_date::VARCHAR(200),
    offer_extended_date::VARCHAR(200),
    offer_accepted_date::VARCHAR(200),
    employee_starts_date::VARCHAR(200),
    reporting_date::TIMESTAMP,
    recruiter_reports_to_supervisor::VARCHAR(200),
    recruiter_reports_to_level_2_login::VARCHAR(200),
    recruiter_reports_to_level_3_login::VARCHAR(200),
    recruiter_reports_to_level_4_login::VARCHAR(200),
    recruiter_reports_to_level_5_login::VARCHAR(200),
    recruiter_reports_to_level_6_login::VARCHAR(200),
    recruiter_reports_to_level_7_login::VARCHAR(200),
    recruiter_reports_to_level_8_login::VARCHAR(200),
    calendar_day::TIMESTAMP,
    calendar_year::SMALLINT,
    calendar_month_of_year::SMALLINT,
    calendar_day_of_month::SMALLINT,
    calendar_day_of_week::SMALLINT,
    calendar_week::SMALLINT,
    calendar_day_of_year::SMALLINT,
    calendar_qtr::SMALLINT,
    reporting_year::SMALLINT,
    reporting_week_of_year::SMALLINT,
    reporting_week_offset::SMALLINT,
    reporting_year_offset::SMALLINT,
    iso_reporting_week_of_year::numeric(38,10),
    addecco_employee_login::VARCHAR(200), 
    addecco_job_level::VARCHAR(200),
    addecco_job_family::VARCHAR(200),
    addecco_title::VARCHAR(200),
    addecco_job_action_code::VARCHAR(200),
    addecco_employee_badge_type::VARCHAR(200),
    addecco_emplid::VARCHAR(200),
    addecco_business_title::VARCHAR(200)
FROM unionedSlingshot


WHERE 1=1
AND addecco_title IS NOT NULL

