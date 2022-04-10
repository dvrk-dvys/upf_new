WITH CORE AS (    
    SELECT DISTINCT
    --pipeline data--
    ra.recruiting_state
    ,pl.person_job_id
    ,pl.person_id
    ,pl.job_id
    ,ra.candidate_full_name
    ,pl.source
    ,pl.is_latest_step
    ,pl.is_mapped
    ,pl.is_internal
    ,pl.is_recyclable
    ,pl.concat_steps    


    --ra.candidate_icims_id--
    ,ra.job_icims_id as ra_job_icims_id 
    ,ra.source_system 


    --Actor employee details--
    ,ra.actor_employee_id as actor_employee_id
    ,ra.actor_employee_login as actor_employee_login
    ,ra.actor_employee_full_name  as actor_employee_display_name
    ,actor.location_name AS Actor_Building
    ,actor.geo_region_name as Actor_Region
    ,actor.location_country_name as Actor_Country
    ,actor.job_family_name as Actor_job_family
    ,actor.job_title_name as Actor_Title
    ,actor.employee_business_title as Actor_business_title
    ,actor.job_code as Actor_Job_Code
    ,actor.regular_temporary_name as Actor_Reg_Temp
    ,actor.department_ofa_cost_center_code as Actor_Cost_Center
    ,actor.job_level_name as Actor_Job_level
    ,ra.actor_reports_to_supervisor_employee_login
    ,ra.actor_reports_to_login_hierarchy
    ,super.employee_business_title as actor_supervisor_title

    --Recruiter employee details--
    ,ra.recruiter_employee_id
    ,ra.recruiter_employee_login as Recruiter_Login
    ,ra.recruiter_employee_full_name AS Recruiter_Name
    ,rec.employee_internal_email_address as Recruiter_email
    ,rec.location_name AS Recruiter_Building
    ,rec.geo_region_name as Recruiter_Region
    ,rec.location_country_name as Recruiter_Country
    ,rec.job_family_name as Recruiter_job_family
    ,rec.job_title_name as Recruiter_Title
    ,rec.employee_business_title as Recruiter_business_title
    ,rec.job_code as Recruiter_Job_Code
    ,rec.regular_temporary_name as Recruiter_Reg_Temp
    ,rec.department_ofa_cost_center_code as Recruiter_Cost_Center
    ,rec.job_level_name as Recruiter_Job_Level
    ,rec.employee_badge_type as Recruiter_badge_type
    ,rec.reports_to_supervisor_employee_login as Recruiter_reports_to_supervisor_employee_login
    ,ra.recruiter_reports_to_login_hierarchy



    --Current Recruiter employee details--
    ,ra.current_recruiter_employee_id    
    ,ra.current_recruiter_employee_login
    ,ra.current_recruiter_employee_full_name AS Current_Recruiter_Name
    ,curr.employee_internal_email_address as Current_Recruiter_email
    ,curr.location_name AS Current_Recruiter_Building
    ,curr.geo_region_name as Current_Recruiter_Region
    ,curr.location_country_name as Current_Recruiter_Country
    ,curr.job_family_name as Current_Recruiter_job_family
    ,curr.job_title_name as Current_Recruiter_Title
    ,curr.employee_business_title as Current_Recruiter_business_title
    ,curr.job_code as Current_Recruiter_Job_Code
    ,curr.regular_temporary_name as Current_Recruiter_Reg_Temp
    ,curr.department_ofa_cost_center_code as Current_Recruiter_Cost_Center
    ,curr.job_level_name as Current_Recruiter_Job_Level
    ,curr.employee_badge_type as Current_Recruiter_badge_type
    ,curr.reports_to_supervisor_employee_login as Current_Recruiter_reports_to_supervisor_employee_login
    ,curr.reports_to_level_2_employee_login::text || '.' || curr.reports_to_level_3_employee_login::text || '.' || curr.reports_to_level_4_employee_login::text || '.' || curr.reports_to_level_5_employee_login::text || '.' || curr.reports_to_level_6_employee_login::text || '.'|| curr.reports_to_level_7_employee_login::text || '.' || curr.reports_to_level_8_employee_login::text AS current_recruiter_reports_to_login_hierarchy
    
    
    --Candidate Identifier employee details--
    ,ra.candidate_identifier_employee_id 
    ,ra.candidate_identifier_login
    ,ra.candidate_identifier_name
    ,can.location_name AS candidate_identifier_Building
    ,can.geo_region_name as candidate_identifier_Region
    ,can.location_country_name as candidate_identifier_Country
    ,can.job_family_name as candidate_identifier_job_family
    ,can.job_title_name as candidate_identifier_Title
    ,can.employee_business_title as candidate_identifier_business_title
    ,can.job_code as candidate_identifier_Job_Code
    ,can.regular_temporary_name as candidate_identifier_Reg_Temp
    ,can.department_ofa_cost_center_code as candidate_identifier_Cost_Center
    ,can.job_level_name as candidate_identifier_Job_level
    ,can.reports_to_supervisor_employee_login as candidate_identifier_reports_to_supervisor_employee_login
    ,ra.candidate_recruiter_reports_to_login_hierarchy
    ,can.reports_to_level_2_employee_login::text || '.' || can.reports_to_level_3_employee_login::text || '.' || can.reports_to_level_4_employee_login::text || '.' || can.reports_to_level_5_employee_login::text || '.' || can.reports_to_level_6_employee_login::text || '.'|| can.reports_to_level_7_employee_login::text || '.' || can.reports_to_level_8_employee_login::text AS candidate_identifier_reports_to_login_hierarchy


    ,application_date
    
    ,resume_review_completed_date

    ,phone_screen_scheduled_date
    ,phone_screen_completed_date

    ,on_site_scheduled_date
    ,on_site_completed_date

    ,offer_extended_date 
    ,offer_accepted_date

    ,employee_starts_date

    ,COALESCE(COALESCE(resume_review_completed_date, phone_screen_scheduled_date, phone_screen_occurred_date, phone_screen_completed_date, 
               on_site_scheduled_date, on_site_occurred_date, on_site_completed_date, offer_extended_date, offer_accepted_date, employee_starts_date),  application_date) AS reporting_date

    ,1 AS join_me
    



    FROM opstadw.masterhr.recruiting_activity ra
       INNER JOIN opsdw.ops_ta_team_wk team ON team.team_flag IN ('ADECCO RC', 'ADECCO Recruiters') AND (team.emplid = ra.recruiter_employee_id or team.emplid = ra.actor_employee_id OR team.emplid = ra.candidate_identifier_employee_id or team.emplid = ra.current_recruiter_employee_id)	 
            --LEFT JOIN opsdw.ops_ta_team_wk team_rec ON team_rec.emplid = ra.recruiter_employee_id	AND team_rec.team_flag IN ('NA', 'EU', 'EU - PRIOR TO SEAN', 'ADECCO Recruiters', 'GLOBAL', 'OPS TECH')
            --LEFT JOIN opsdw.ops_ta_team_wk team_act ON team_act.emplid = ra.actor_employee_id AND team_rec.team_flag IN ('NA', 'EU', 'EU - PRIOR TO SEAN', 'ADECCO Recruiters', 'GLOBAL', 'OPS TECH')
            --LEFT JOIN opsdw.ops_ta_team_wk team_can ON team_can.emplid = ra.candidate_identifier_employee_id AND team_rec.team_flag IN ('NA', 'EU', 'EU - PRIOR TO SEAN', 'ADECCO Recruiters', 'GLOBAL', 'OPS TECH')
            --LEFT JOIN opsdw.ops_ta_team_wk team_curr ON team_curr.emplid = ra.current_recruiter_employee_id AND team_rec.team_flag IN ('NA', 'EU', 'EU - PRIOR TO SEAN', 'ADECCO Recruiters', 'GLOBAL', 'OPS TECH')
       LEFT JOIN masterhr.employee_hc_current actor ON (actor.emplid = nvl(ra.actor_employee_id,'99999999999'))
                                                     -- AND (actor.reports_to_level_4_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                     -- OR actor.reports_to_level_5_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                     -- OR actor.reports_to_level_6_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                     -- OR actor.reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                     -- OR actor.reports_to_level_8_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                     -- OR actor.reports_to_level_9_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))
       LEFT JOIN masterhr.employee_hc_current super ON (ra.actor_reports_to_supervisor_employee_login = super.employee_login)
       LEFT JOIN masterhr.employee_hc_current rec ON (rec.emplid = nvl(ra.recruiter_employee_id,'99999999999')
                                                      AND (rec.reports_to_level_4_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR rec.reports_to_level_5_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR rec.reports_to_level_6_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR rec.reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR rec.reports_to_level_8_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR rec.reports_to_level_9_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))                                                     
       LEFT JOIN masterhr.employee_hc_current can ON (can.emplid = nvl(ra.candidate_identifier_employee_id,'99999999999')
                                                      AND (can.reports_to_level_4_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR can.reports_to_level_5_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR can.reports_to_level_6_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR can.reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR can.reports_to_level_8_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR can.reports_to_level_9_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))  
       LEFT JOIN masterhr.employee_hc_current curr ON (curr.emplid = nvl(ra.current_recruiter_employee_id,'99999999999')
                                                      AND (curr.reports_to_level_4_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR curr.reports_to_level_5_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR curr.reports_to_level_6_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR curr.reports_to_level_7_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR curr.reports_to_level_8_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr') 
                                                      OR curr.reports_to_level_9_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))      
       LEFT JOIN ops_insearch.pipeline pl ON pl.person_id = ra.candidate_icims_id AND  pl.job_id = ra.job_icims_id AND is_latest_step = 'true'
         
    WHERE 1
    =1
    AND ra.is_funnel_count = 'Y'
    AND ra.actor_employee_id <> ''
    AND RA.recruiting_state IN ('Employee Starts', 'Applicant Tagged', 'Resume Review Completed', 'Phone Screen Scheduled', 'Phone Screen Completed', 'On-site Scheduled', 'On-site Completed', 'Offer Extended', 'Offer Accepted', 'Debrief Scheduled')
),


adecco_all AS (

    SELECT DISTINCT
    
        employee_login
        ,employee_internal_email_address
        ,team.team_flag
        ,act.employee_business_title
        ,act.reports_to_level_4_employee_login
        ,act.reports_to_level_5_employee_login
        ,act.reports_to_level_6_employee_login
        ,act.reports_to_level_7_employee_login
        ,act.reports_to_level_8_employee_login
        ,act.reports_to_level_9_employee_login

    FROM masterhr.employee_hc_current act
           inner join opsdw.ops_ta_team_wk team ON team.team_flag IN ('ADECCO Recruiters', 'ADECCO RC') AND team.emplid = act.emplid
),


adecco_counts AS (
    SELECT COUNT(*) as adecco_all_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'balla' 
                                                OR reports_to_level_5_employee_login = 'balla' 
                                                OR reports_to_level_6_employee_login = 'balla' 
                                                OR reports_to_level_7_employee_login = 'balla' 
                                                OR reports_to_level_8_employee_login = 'balla' 
                                                OR reports_to_level_9_employee_login = 'balla')) as balla_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'cathlinh' 
                                                OR reports_to_level_5_employee_login = 'cathlinh' 
                                                OR reports_to_level_6_employee_login = 'cathlinh'
                                                OR reports_to_level_7_employee_login = 'cathlinh'
                                                OR reports_to_level_8_employee_login = 'cathlinh'
                                                OR reports_to_level_9_employee_login = 'cathlinh')) as cathlinh_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'lynsd'
                                                OR reports_to_level_5_employee_login = 'lynsd' 
                                                OR reports_to_level_6_employee_login = 'lynsd' 
                                                OR reports_to_level_7_employee_login = 'lynsd' 
                                                OR reports_to_level_8_employee_login = 'lynsd' 
                                                OR reports_to_level_9_employee_login = 'lynsd')) as lynsd_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'haywmart' 
                                                OR reports_to_level_5_employee_login = 'haywmart' 
                                                OR reports_to_level_6_employee_login = 'haywmart'
                                                OR reports_to_level_7_employee_login = 'haywmart'
                                                OR reports_to_level_8_employee_login = 'haywmart' 
                                                OR reports_to_level_9_employee_login = 'haywmart')) as haywmart_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'chilverr' 
                                                OR reports_to_level_5_employee_login = 'chilverr' 
                                                OR reports_to_level_6_employee_login = 'chilverr' 
                                                OR reports_to_level_7_employee_login = 'chilverr' 
                                                OR reports_to_level_8_employee_login = 'chilverr' 
                                                OR reports_to_level_9_employee_login = 'chilverr')) as chilverr_hc,
     1 AS join_me

FROM adecco_all

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
),

FINAL AS (

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
    ,reqs.job_state as job_state_dupes

        --Team Flags by Recruiter Types--   
    ,team_rec.team_flag as rec_team_flag
    ,team_can.team_flag as can_team_flag
    ,team_act.team_flag as act_team_flag
    ,team_curr.team_flag as curr_team_flag

    ,CORE.*
    ,DAYS.*

        --Adecco employee details--
    --,adecco.employee_login as Adecco_employee_login
    --,adecco.job_level_name as Adecco_job_level
    --,adecco.job_family_name as Adecco_job_family
    --,adecco.job_title_name as Adecco_Title
    --,adecco.job_action_code as Adecco_job_action_code
    --,adecco.employee_badge_type as Adecco_employee_badge_type
    --,adecco.emplid as Adecco_emplid
    --,adecco.employee_business_title as Adecco_business_title

    --,team_act.*


    --,adecco.reports_to_supervisor_employee_login as adecco_reports_to_supervisor
    --,adecco.reports_to_level_2_employee_login as adecco_reports_to_level_2_login
    --,adecco.reports_to_level_3_employee_login as adecco_reports_to_level_3_login
    --,adecco.reports_to_level_4_employee_login as adecco_reports_to_level_4_login
    --,adecco.reports_to_level_5_employee_login as adecco_reports_to_level_5_login
    --,adecco.reports_to_level_6_employee_login as adecco_reports_to_level_6_login
    --,adecco.reports_to_level_7_employee_login as adecco_reports_to_level_7_login
    --,adecco.reports_to_level_8_employee_login as adecco_reports_to_level_8_login

        --Adecco Head Counts by Leader--
    ,balla_hc
    ,cathlinh_hc
    ,lynsd_hc
    ,haywmart_hc
    ,chilverr_hc


    FROM CORE
    INNER JOIN hrmetrics.o_reporting_days days ON TRUNC(calendar_day) = TRUNC(reporting_date) AND reporting_year = 2020
    LEFT JOIN max_req ON max_req.job_icims_id = core.ra_job_icims_id
    LEFT JOIN masterhr.requisition reqs ON reqs.job_icims_id = CORE.ra_job_icims_id AND reqs.snapshot_begin_timestamp = max_req.max_req_state --AND job_state != 'POOLING' 
    LEFT JOIN masterhr.employee_hc_current adecco ON adecco.employee_login = CORE.Recruiter_Login AND adecco.job_title_name = 'Staffing Agency Rep (OSP)'
    LEFT JOIN adecco_counts ac ON CORE.join_me = ac.join_me

    LEFT JOIN opsdw.ops_ta_team_wk team_rec ON team_rec.emplid = core.recruiter_employee_id AND (TRUNC(reporting_date) BETWEEN team_rec.wk_begin_dt AND team_rec.wk_end_dt) AND team_rec.team_flag IN ('NA', 'EU', 'EU - PRIOR TO SEAN', 'ADECCO Recruiters', 'ADECCO RC', 'GLOBAL', 'OPS TECH')
    LEFT JOIN opsdw.ops_ta_team_wk team_act ON team_act.emplid = core.actor_employee_id AND (TRUNC(reporting_date) BETWEEN team_act.wk_begin_dt AND team_act.wk_end_dt) AND team_act.team_flag IN ('NA', 'EU', 'EU - PRIOR TO SEAN', 'ADECCO Recruiters', 'ADECCO RC', 'GLOBAL', 'OPS TECH')
    LEFT JOIN opsdw.ops_ta_team_wk team_can ON team_can.emplid = core.candidate_identifier_employee_id AND (TRUNC(reporting_date) BETWEEN team_can.wk_begin_dt AND team_can.wk_end_dt) AND team_can.team_flag IN ('NA', 'EU', 'EU - PRIOR TO SEAN', 'ADECCO Recruiters', 'ADECCO RC', 'GLOBAL', 'OPS TECH')
    LEFT JOIN opsdw.ops_ta_team_wk team_curr ON team_curr.emplid = core.current_recruiter_employee_id AND (TRUNC(reporting_date) BETWEEN team_curr.wk_begin_dt AND team_curr.wk_end_dt) AND team_curr.team_flag IN ('NA', 'EU', 'EU - PRIOR TO SEAN', 'ADECCO Recruiters', 'ADECCO RC', 'GLOBAL', 'OPS TECH')
       
 
    WHERE 1=1
    --AND offer_accepted_date IS NOT NULL
    AND (('ADECCO Recruiters') IN (team_rec.team_flag, team_act.team_flag, team_can.team_flag, team_curr.team_flag)
    OR ('ADECCO RC') IN (team_rec.team_flag, team_act.team_flag, team_can.team_flag, team_curr.team_flag))


    
                                --REGULAR POOLING--              ||          --POOLING DUPES--
  --  AND person_job_id IN ('23457466_1139883', '23722911_1097150', '10315169_1138761', '23457466_1139925')

    



),

no_dupes AS (


    SELECT 
    A.job_state_dupes as job_state
    ,A.person_job_id 
    ,A.reporting_date 
    ,A.recruiting_state

    FROM FINAL A
    LEFT OUTER JOIN

        (SELECT B.job_state_dupes as job_state
               ,B.person_job_id 
               ,B.reporting_date
               ,B.recruiting_state
         FROM FINAL AS B
         WHERE job_state_dupes != 'POOLING') AS C ON A.job_state_dupes != C.job_state AND A.recruiting_state = C.recruiting_state AND A.person_job_id = C.person_job_id AND A.reporting_date = C.reporting_date
    WHERE 1=1
    AND A.job_state_dupes IS NULL
    OR C.job_state IS NULL

)

SELECT DISTINCT
no.job_state
,FINAL.*
FROM FINAL
LEFT JOIN no_dupes no ON no.person_job_id = final.person_job_id AND no.reporting_date = final.reporting_date AND no.recruiting_state = final.recruiting_state
WHERE 1=1
--AND act_team_flag IN ('ADECCO RC', 'ADECCO Recruiters')
    --AND offer_accepted_date IS NOT NULL


