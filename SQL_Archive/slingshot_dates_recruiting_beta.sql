WITH CORE AS (
SELECT DISTINCT

      ia.source_system   
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


      ,SUM(applicant_count) AS applicant_count

      --,SUM(resume_review_scheduled_count) AS resume_review_scheduled_count
      ,SUM(resume_review_completed_count) AS resume_review_completed_count
      --,SUM(resume_review_by_hiring_manager_count) AS resume_review_by_hiring_manager_count
      --,SUM(resume_review_by_recruiter_count) AS resume_review_by_recruiter_count

      --,SUM(phone_screen_requested_count) AS phone_screen_requested_count
      ,SUM(phone_screen_scheduled_count) AS phone_screen_scheduled_count
      ,SUM(phone_screen_occurred_count) AS phone_screen_occurred_count
      --,SUM(phone_screen_did_not_occur_count) AS phone_screen_did_not_occur_count
      --,SUM(phone_screen_not_started_yet_count) AS phone_screen_not_started_yet_count
      ,SUM(phone_screen_completed_count) AS phone_screen_completed_count
      --,SUM(phone_screen_canceled_count) AS phone_screen_canceled_count
      --,SUM(phone_screen_requested_contact_attempts_count) AS phone_screen_requested_contact_attempts_count

      --,SUM(on_site_requested_count) AS on_site_requested_count
      ,SUM(on_site_scheduled_count) AS on_site_scheduled_count
      ,SUM(on_site_occurred_count) AS on_site_occurred_count
      --,SUM(on_site_did_not_occur_count) AS on_site_did_not_occur_count
      --,SUM(on_site_not_started_yet_count) AS on_site_not_started_yet_count
      ,SUM(on_site_completed_count) AS on_site_completed_count
      --,SUM(on_site_canceled_count) AS on_site_canceled_count
      --,SUM(on_site_requested_contact_attempts_count) AS on_site_requested_contact_attempts_count

      --,SUM(assessment_requested_count) AS assessment_requested_count
      --,SUM(assessment_scheduled_count) AS assessment_scheduled_count
      --,SUM(assessment_occurred_count) AS assessment_occurred_count
      --,SUM(assessment_did_not_occur_count) AS assessment_did_not_occur_count
      --,SUM(assessment_not_started_yet_count) AS assessment_not_started_yet_count
      --,SUM(assessment_completed_count) AS assessment_completed_count
      --,SUM(assessment_canceled_count) AS assessment_canceled_count
      --,SUM(assessment_requested_contact_attempts_count) AS assessment_requested_contact_attempts_count

      --,SUM(prebrief_scheduled_count) AS prebrief_scheduled_count
      --,SUM(prebrief_occurred_count) AS prebrief_occurred_count
      --,SUM(prebrief_did_not_occur_count) AS prebrief_did_not_occur_count
      --,SUM(prebrief_not_started_yet_count) AS prebrief_not_started_yet_count

      --,SUM(debrief_scheduled_count) AS debrief_scheduled_count
      --,SUM(debrief_occurred_count) AS debrief_occurred_count
      --,SUM(debrief_did_not_occur_count) AS debrief_did_not_occur_count
      --,SUM(debrief_not_started_yet_count) AS debrief_not_started_yet_count

      ,SUM(offer_count) AS offer_count
      --,SUM(offer_prepared_count) AS offer_prepared_count
      --,SUM(offer_drafted_count)  AS offer_drafted_count
      --,SUM(offer_auto_approved_count) AS offer_auto_approved_count
      --,SUM(offer_pending_compensation_approval_count) AS offer_pending_compensation_approval_count
      --,SUM(offer_approved_count) AS offer_approved_count
      --,SUM(offer_rejected_count) AS offer_rejected_count
      ,SUM(offer_extended_count) AS offer_extended_count
      ,SUM(offer_accepted_count) AS offer_accepted_count
      --,SUM(offer_canceled_count) AS offer_canceled_count
      --,SUM(offer_rescinded_count) AS offer_rescinded_count
      --,SUM(offer_declined_count) AS offer_declined_count 
      --,SUM(offer_signed_count) AS offer_signed_count
      --,SUM(offer_expired_count) AS offer_expired_count

      --,SUM(rejection_requested_count) AS rejection_requested_count
      --,SUM(rejection_confirmed_count) AS rejection_confirmed_count
      --,SUM(rejection_canceled_count) AS rejection_canceled_count
      --,SUM(rejection_requested_contact_attempts_count) AS rejection_requested_contact_attempts_count

      -- ,SUM(pending_start_count) AS pending_start_count
      -- ,SUM(pending_start_internal_count) AS pending_start_internal_count
      -- ,SUM(pending_start_external_count) AS pending_start_external_count
      ,SUM(employee_starts_count) AS employee_starts_count
      -- ,SUM(employee_start_internal_count) AS employee_start_internal_count
      -- ,SUM(employee_start_external_count) AS employee_start_external_count
      ,1 AS NUM



      FROM opstadw.masterhr.recruiting_activity ia
      LEFT JOIN  masterhr.employee_hc_current act ON nvl(ia.actor_employee_id,'99999999999') = act.emplid

      WHERE 1=1
      AND ia.is_funnel_count = 'Y'
      AND (act.reports_to_level_5_employee_login = 'arendtg'
      OR (act.reports_to_level_6_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))
      AND actor_employee_id <> ''

      GROUP BY
    

      --Actor details--
      actor_employee_id
      ,act.employee_internal_email_address
      ,act.employee_display_name
      ,act.location_name   
      ,act.geo_region_name 
      ,act.location_country_name 
      ,act.job_title_name
      ,act.job_code
      ,act.employee_login
      ,act.department_ofa_cost_center_code
      ,act.regular_temporary_name
      ,act.job_level_name
      ,act.reports_to_supervisor_employee_login 
      ,act.reports_to_level_2_employee_login 
      ,act.reports_to_level_3_employee_login
      ,act.reports_to_level_4_employee_login
      ,act.reports_to_level_5_employee_login
      ,act.reports_to_level_6_employee_login
      ,act.reports_to_level_7_employee_login
      ,act.reports_to_level_8_employee_login
      ,ia.source_system
      
),

TEST as (

      SELECT DISTINCT 
      source_system

      FROM opstadw.masterhr.recruiting_activity ia
      LEFT JOIN  masterhr.employee_hc_current act ON nvl(ia.actor_employee_id,'99999999999') = act.emplid
      WHERE 1=1
      AND ia.is_funnel_count = 'Y'
      AND (act.reports_to_level_5_employee_login = 'arendtg'
      OR (act.reports_to_level_6_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))
      AND actor_employee_id <> ''

      
),

SYSTEMS AS (

SELECT DISTINCT 

      test.source_system as source_all
      ,ia.actor_employee_id

FROM opstadw.masterhr.recruiting_activity ia   
      LEFT JOIN  masterhr.employee_hc_current act ON nvl(ia.actor_employee_id,'99999999999') = act.emplid
CROSS JOIN test

WHERE 1=1
      AND ia.is_funnel_count = 'Y'
      AND (act.reports_to_level_5_employee_login = 'arendtg'
      OR (act.reports_to_level_6_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))
      AND actor_employee_id <> ''

      
)


SELECT DISTINCT

hc.employee_login AS Actor_Login
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

,CASE WHEN applicant_count IS NULL THEN 'Never Active' ELSE 'Active' END AS activity_metric

,CORE.applicant_count
--,CORE.resume_review_scheduled_count
,CORE.resume_review_completed_count
--,CORE.resume_review_by_hiring_manager_count
--,CORE.resume_review_by_recruiter_count

--,CORE.phone_screen_requested_count
,CORE.phone_screen_scheduled_count
,CORE.phone_screen_occurred_count
--,CORE.phone_screen_did_not_occur_count 
--,CORE.phone_screen_not_started_yet_count
,CORE.phone_screen_completed_count
--,CORE.phone_screen_canceled_count
--,CORE.phone_screen_requested_contact_attempts_count

--,CORE.on_site_requested_count
,CORE.on_site_scheduled_count
,CORE.on_site_occurred_count
--,CORE.on_site_did_not_occur_count
--,CORE.on_site_not_started_yet_count
,CORE.on_site_completed_count
--,CORE.on_site_canceled_count
--,CORE.on_site_requested_contact_attempts_count

--,CORE.assessment_requested_count
--,CORE.assessment_scheduled_count
--,CORE.assessment_occurred_count
--,CORE.assessment_did_not_occur_count 
--,CORE.assessment_not_started_yet_count
--,CORE.assessment_completed_count
--,CORE.assessment_canceled_count
--,CORE.assessment_requested_contact_attempts_count

--,CORE.prebrief_scheduled_count
--,CORE.prebrief_occurred_count
--,CORE.prebrief_did_not_occur_count 
--,CORE.prebrief_not_started_yet_count

--,CORE.debrief_scheduled_count
--,CORE.debrief_did_not_occur_count 
--,CORE.debrief_not_started_yet_count

,CORE.offer_count
--,CORE.offer_prepared_count
--,CORE.offer_drafted_count
--,CORE.offer_auto_approved_count
--,CORE.offer_pending_compensation_approval_count
--,CORE.offer_approved_count
--,CORE.offer_rejected_count
,CORE.offer_extended_count 
,CORE.offer_accepted_count
--,CORE.offer_canceled_count
--,CORE.offer_rescinded_count
--,CORE.offer_declined_count
--,CORE.offer_signed_count
--,CORE.offer_expired_count

--,CORE.rejection_requested_count 
--,CORE.rejection_confirmed_count
--,CORE.rejection_canceled_count
--,CORE.rejection_requested_contact_attempts_count

--,CORE.pending_start_count
--,CORE.pending_start_internal_count
--,CORE.pending_start_external_count
,CORE.employee_starts_count
--,CORE.employee_start_internal_count
--,CORE.employee_start_external_count


FROM SYSTEMS
LEFT OUTER JOIN CORE ON CORE.actor_employee_id = SYSTEMS.actor_employee_id AND SYSTEMS.source_all = CORE.SOURCE_SYSTEM
FULL OUTER JOIN (
            SELECT DISTINCT *
            FROM masterhr.employee_hc_current hc
            WHERE 1=1
            AND (HC.reports_to_level_5_employee_login = 'arendtg'
            OR (HC.reports_to_level_6_employee_login IN ('balla', 'cathlinh', 'lynsd', 'haywmart', 'chilverr')))
            AND hc.employee_login <> ''
                 ) AS not_active ON CORE.actor_login = not_active.employee_login
LEFT JOIN masterhr.employee_hc_current hc ON CORE.actor_employee_id = hc.emplid OR NOT_ACTIVE.employee_login = hc.employee_login OR SYSTEMS.actor_employee_id = hc.emplid AND DATEPART(year, HC.hr_begin_dt) >= 2020
--INNER JOIN ops_insearch.pipeline pl ON pl.person_id = ra.candidate_icims_id AND  pl.job_id = ra.job_icims_id AND is_internal = 'true' AND is_latest_step = 'true'
WHERE 1=1
