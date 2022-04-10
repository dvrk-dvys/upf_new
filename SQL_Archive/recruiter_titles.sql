WITH A AS 
(
      SELECT
      --Recruiter details--
      ia.recruiter_employee_login  as  Recruiter_login
      ,ia.recruiter_employee_login +'@amazon.com' as Recruiter_email
      ,ia.recruiter_employee_full_name as  Recruiter_full_name
      ,ia.job_icims_id
      ,rec.geo_region_name as Recruiter_Region
      ,rec.location_country_name as Recruiter_Country
      ,rec.job_title_name as Recruiter_current_title
      ,rec.regular_temporary_name as Recruiter_Reg_Temp
      ,rec.reports_to_supervisor_employee_login as Recruiter_reports_to_current_supervisor_login
      ,rec.reports_to_level_2_employee_login    as Recruiter_reports_to_current_level2_login
      ,rec.reports_to_level_3_employee_login    as Recruiter_reports_to_current_level3_login
      ,rec.reports_to_level_4_employee_login    as Recruiter_reports_to_current_level4_login
      ,rec.reports_to_level_5_employee_login    as Recruiter_reports_to_current_level5_login
      ,rec.reports_to_level_6_employee_login    as Recruiter_reports_to_current_level6_login
      ,rec.reports_to_level_7_employee_login    as Recruiter_reports_to_current_level7_login
      ,rec.reports_to_level_8_employee_login    as Recruiter_reports_to_current_level8_login
      --RC details--
      ,(CASE WHEN RC.EMPLOYEE_LOGIN ='' OR  RC.EMPLOYEE_LOGIN IS NULL THEN 'NA' ELSE RC.EMPLOYEE_LOGIN  END) RC_LOGIN
      ,(CASE WHEN RC.EMPLOYEE_LOGIN ='' OR  RC.EMPLOYEE_LOGIN IS NULL THEN 'NA' ELSE RC.EMPLOYEE_LOGIN  END) +'@amazon.com' as RC_email
      ,rc.geo_region_name as RC_Region
      ,rc.location_country_name as RC_Country
      ,rc.job_title_name as RC_title
      ,rc.regular_temporary_name as RC_Reg_Temp
      ,rc.reports_to_supervisor_employee_login  as RC_reports_to_supervisor
      ,rc.reports_to_level_2_employee_login as RC_reports_to_level_2_login
      ,rc.reports_to_level_3_employee_login  as RC_reports_to_level_3_login
      ,rc.reports_to_level_4_employee_login  as RC_reports_to_level_4_login
      ,rc.reports_to_level_5_employee_login  as RC_reports_to_level_5_login
      ,rc.reports_to_level_6_employee_login as RC_reports_to_level_6_login
      ,rc.reports_to_level_7_employee_login as RC_reports_to_level_7_login
      ,rc.reports_to_level_8_employee_login as RC_reports_to_level_8_login
      --Actor employee details--
      ,(CASE WHEN ACT.EMPLOYEE_LOGIN ='' OR  ACT.EMPLOYEE_LOGIN IS NULL THEN 'NA' ELSE ACT.EMPLOYEE_LOGIN  END) Actor_LOGIN
      ,(CASE WHEN ACT.EMPLOYEE_LOGIN ='' OR  ACT.EMPLOYEE_LOGIN IS NULL THEN 'NA' ELSE ACT.EMPLOYEE_LOGIN  END) +'@amazon.com' as Actor_email
      ,ACT.geo_region_name as Actor_Region
      ,ACT.location_country_name as Actor_Country
      ,ACT.job_title_name as Actor_title
      ,ACT.regular_temporary_name as Actor_Reg_Temp
      ,ACT.reports_to_supervisor_employee_login  as Actor_reports_to_supervisor
      ,ACT.reports_to_level_2_employee_login as Actor_reports_to_level_2_login
      ,ACT.reports_to_level_3_employee_login  as Actor_reports_to_level_3_login
      ,ACT.reports_to_level_4_employee_login  as Actor_reports_to_level_4_login
      ,ACT.reports_to_level_5_employee_login  as Actor_reports_to_level_5_login
      ,ACT.reports_to_level_6_employee_login as Actor_reports_to_level_6_login
      ,ACT.reports_to_level_7_employee_login as Actor_reports_to_level_7_login
      ,ACT.reports_to_level_8_employee_login as Actor_reports_to_level_8_login
      --Metrics--
      ,is_funnel_count 
      ,SUM(applicant_count) AS applicant_count

      ,SUM(resume_review_scheduled_count) AS resume_review_scheduled_count
      ,SUM(resume_review_completed_count) AS resume_review_completed_count
      ,SUM(resume_review_by_hiring_manager_count) AS resume_review_by_hiring_manager_count

      ,SUM(resume_review_by_recruiter_count) AS resume_review_by_recruiter_count

      ,SUM(phone_screen_requested_count) AS phone_screen_requested_count
      ,SUM(phone_screen_scheduled_count) AS phone_screen_scheduled_count
      ,SUM(phone_screen_occurred_count) AS phone_screen_occurred_count
      ,SUM(phone_screen_did_not_occur_count) AS phone_screen_did_not_occur_count
      ,SUM(phone_screen_not_started_yet_count) AS phone_screen_not_started_yet_count
      ,SUM(phone_screen_completed_count) AS phone_screen_completed_count
      ,SUM(phone_screen_canceled_count) AS phone_screen_canceled_count
      ,SUM(phone_screen_requested_contact_attempts_count) AS phone_screen_requested_contact_attempts_count

      ,SUM(on_site_requested_count) AS on_site_requested_count
      ,SUM(on_site_scheduled_count) AS on_site_scheduled_count
      ,SUM(on_site_occurred_count) AS on_site_occurred_count
      ,SUM(on_site_did_not_occur_count) AS on_site_did_not_occur_count
      ,SUM(on_site_not_started_yet_count) AS on_site_not_started_yet_count
      ,SUM(on_site_completed_count) AS on_site_completed_count
      ,SUM(on_site_canceled_count) AS on_site_canceled_count
      ,SUM(on_site_requested_contact_attempts_count) AS on_site_requested_contact_attempts_count

      ,SUM(assessment_requested_count) AS assessment_requested_count
      ,SUM(assessment_scheduled_count) AS assessment_scheduled_count
      ,SUM(assessment_occurred_count) AS assessment_occurred_count
      ,SUM(assessment_did_not_occur_count) AS assessment_did_not_occur_count
      ,SUM(assessment_not_started_yet_count) AS assessment_not_started_yet_count
      ,SUM(assessment_completed_count) AS assessment_completed_count
      ,SUM(assessment_canceled_count) AS assessment_canceled_count
      ,SUM(assessment_requested_contact_attempts_count) AS assessment_requested_contact_attempts_count

      ,SUM(prebrief_scheduled_count) AS prebrief_scheduled_count
      ,SUM(prebrief_occurred_count) AS prebrief_occurred_count
      ,SUM(prebrief_did_not_occur_count) AS prebrief_did_not_occur_count
      ,SUM(prebrief_not_started_yet_count) AS prebrief_not_started_yet_count

      ,SUM(debrief_scheduled_count) AS debrief_scheduled_count
      ,SUM(debrief_occurred_count) AS debrief_occurred_count
      ,SUM(debrief_did_not_occur_count) AS debrief_did_not_occur_count
      ,SUM(debrief_not_started_yet_count) AS debrief_not_started_yet_count

       ,SUM(offer_count) AS offer_count
       ,SUM(offer_prepared_count) AS offer_prepared_count
       ,SUM(offer_drafted_count)  AS offer_drafted_count
       ,SUM(offer_auto_approved_count) AS offer_auto_approved_count
       ,SUM(offer_pending_compensation_approval_count) AS offer_pending_compensation_approval_count
       ,SUM(offer_approved_count) AS offer_approved_count
       ,SUM(offer_rejected_count) AS offer_rejected_count
       ,SUM(offer_extended_count) AS offer_extended_count
       ,SUM(offer_accepted_count) AS offer_accepted_count
       ,SUM(offer_canceled_count) AS offer_canceled_count
       ,SUM(offer_rescinded_count) AS offer_rescinded_count
       ,SUM(offer_declined_count) AS offer_declined_count 
       ,SUM(offer_signed_count) AS offer_signed_count
       ,SUM(offer_expired_count) AS offer_expired_count

       ,SUM(rejection_requested_count) AS rejection_requested_count
       ,SUM(rejection_confirmed_count) AS rejection_confirmed_count
       ,SUM(rejection_canceled_count) AS rejection_canceled_count
       ,SUM(rejection_requested_contact_attempts_count) AS rejection_requested_contact_attempts_count

       ,SUM(pending_start_count) AS pending_start_count
       ,SUM(pending_start_internal_count) AS pending_start_internal_count
       ,SUM(pending_start_external_count) AS pending_start_external_count
       ,SUM(employee_starts_count) AS employee_starts_count
       ,SUM(employee_start_internal_count) AS employee_start_internal_count
       ,SUM(employee_start_external_count) AS employee_start_external_count

      --Others--
      ,ia.source_system
      ,date_part('year',enter_state_time_pst) as Year
      ,ia.recruiting_State
      ,ia.icims_status


      FROM opstadw.masterhr.recruiting_activity ia


      LEFT JOIN  masterhr.employee_hc_current rec ON nvl(ia.recruiter_employee_id,'99999999999') = rec.emplid
      LEFT JOIN  masterhr.employee_hc_current rc ON nvl(ia.rc_employee_id,'99999999999') = rc.emplid
      LEFT JOIN  masterhr.employee_hc_current act ON nvl(ia.actor_employee_id,'99999999999') = act.emplid
      
      WHERE 1=1
      AND ia.actor_employee_id <> ''
      AND ia.is_funnel_count = 'Y'
      AND ia.recruiter_reports_to_level_3_employee_login = 'darcie'
      AND trunc(ia.enter_state_time_pst) >='01/07/2019' 
      AND ia.recruiter_employee_login != ''
      AND recruiting_state IN (
      'On-site Scheduled'
      ,'Phone Screen Scheduled'
      ,'Assessment Scheduled')
      AND lower(actor_title) NOT LIKE '%director%'
      AND lower(actor_title) NOT LIKE '%manager%'
      AND lower(actor_title) NOT LIKE '%principal%'
      AND lower(actor_title) NOT LIKE '%mgr%'
      AND (applicant_count > 0
           OR resume_review_scheduled_count > 0
           OR resume_review_completed_count > 0 
           OR resume_review_by_hiring_manager_count  > 0
           OR resume_review_by_recruiter_count > 0

           OR phone_screen_requested_count  > 0
           OR phone_screen_scheduled_count  > 0
           OR phone_screen_occurred_count  > 0
           OR phone_screen_did_not_occur_count > 0 
           OR phone_screen_not_started_yet_count > 0
           OR phone_screen_completed_count  > 0
           OR phone_screen_canceled_count  > 0
           OR phone_screen_requested_contact_attempts_count > 0

           OR on_site_requested_count  > 0
           OR on_site_scheduled_count  > 0
           OR on_site_occurred_count  > 0
           OR on_site_did_not_occur_count > 0 
           OR on_site_not_started_yet_count  > 0
           OR on_site_completed_count  > 0
           OR on_site_canceled_count  > 0
           OR on_site_requested_contact_attempts_count > 0

           OR assessment_requested_count  > 0
           OR assessment_scheduled_count  > 0
           OR assessment_occurred_count  > 0
           OR assessment_did_not_occur_count > 0 
           OR assessment_not_started_yet_count  > 0
           OR assessment_completed_count  > 0
           OR assessment_canceled_count  > 0
           OR assessment_requested_contact_attempts_count > 0

           OR prebrief_scheduled_count  > 0
           OR prebrief_occurred_count  > 0
           OR prebrief_did_not_occur_count > 0 
           OR prebrief_not_started_yet_count > 0

           OR debrief_scheduled_count  > 0
           OR debrief_occurred_count  > 0
           OR debrief_did_not_occur_count > 0 
           OR debrief_not_started_yet_count > 0

           OR offer_count  > 0
           OR offer_prepared_count > 0 
           OR offer_drafted_count  > 0
           OR offer_auto_approved_count > 0 
           OR offer_pending_compensation_approval_count  > 0
           OR offer_approved_count  > 0
           OR offer_rejected_count  > 0
           OR offer_extended_count  > 0
           OR offer_accepted_count  > 0
           OR offer_canceled_count  > 0
           OR offer_rescinded_count > 0
           OR offer_declined_count  > 0
           OR offer_signed_count  > 0
           OR offer_expired_count > 0

           OR rejection_requested_count > 0 
           OR rejection_confirmed_count  > 0
           OR rejection_canceled_count  > 0
           OR rejection_requested_contact_attempts_count > 0
     
           OR pending_start_count  > 0
           OR pending_start_internal_count > 0 
           OR pending_start_external_count  > 0
           OR employee_starts_count  > 0
           OR employee_start_internal_count > 0 
           OR employee_start_external_count > 0
)
      

      GROUP BY  
      --Recruiter details--
      ia.recruiter_employee_login  
      ,ia.recruiter_employee_full_name
      ,rec.geo_region_name 
      ,rec.location_country_name
      ,rec.job_title_name
      ,rec.regular_temporary_name
      ,rec.reports_to_supervisor_employee_login 
      ,rec.reports_to_level_2_employee_login 
      ,rec.reports_to_level_3_employee_login
      ,rec.reports_to_level_4_employee_login 
      ,rec.reports_to_level_5_employee_login
      ,rec.reports_to_level_6_employee_login 
      ,rec.reports_to_level_7_employee_login
      ,rec.reports_to_level_8_employee_login 
      --Rc details--
      ,rc.geo_region_name 
      ,rc.location_country_name 
      ,rc.job_title_name 
      ,RC.EMPLOYEE_LOGIN
      ,rc.regular_temporary_name
      ,rc.reports_to_supervisor_employee_login 
      ,rc.reports_to_level_2_employee_login 
      ,rc.reports_to_level_3_employee_login 
      ,rc.reports_to_level_4_employee_login 
      ,rc.reports_to_level_5_employee_login 
      ,rc.reports_to_level_6_employee_login
      ,rc.reports_to_level_7_employee_login 
      ,rc.reports_to_level_8_employee_login 
      --Actor details--
      ,act.geo_region_name 
      ,act.location_country_name 
      ,act.job_title_name 
      ,act.EMPLOYEE_LOGIN
      ,act.regular_temporary_name
      ,act.reports_to_supervisor_employee_login 
      ,act.reports_to_level_2_employee_login 
      ,act.reports_to_level_3_employee_login
      ,act.reports_to_level_4_employee_login
      ,act.reports_to_level_5_employee_login
      ,act.reports_to_level_6_employee_login
      ,act.reports_to_level_7_employee_login
      ,act.reports_to_level_8_employee_login
      --others--
      ,is_funnel_count 
      ,ia.source_system 
      ,ia.job_icims_id
      ,date_part('year',enter_state_time_pst)
      ,ia.recruiting_State
      ,ia.icims_status

             
)


SELECT DISTINCT

       aa.*,
       mr.building,
       CASE WHEN mr.building IN ('BER1','BER3','BER17','CGN1','DTM1','DTM2','DUS2','FRA1','FRA3','FRA7','HAM2','LEJ1','MUC3','STR1','REG','VCC') THEN 'GWC sites'
            ELSE 'Non GWC sites'
       END AS site_type
FROM a aa
  LEFT JOIN masterhr.requisition mr ON mr.job_icims_id = aa.job_icims_Id AND mr.current_transaction_flag = 'Y'
  

--
