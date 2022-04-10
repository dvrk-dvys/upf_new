WITH stop_states AS
(
  SELECT job_icims_id,
         candidate_icims_id,
         MIN(enter_state_time) AS min_time
  FROM masterhr.recruiting_activity
  WHERE 1 = 1
  AND   recruiting_state IN ('Assessment Scheduled','Offer Prepared','On-site Scheduled','Phone Screen Scheduled','Rejection Confirmed')
  GROUP BY job_icims_id,
           candidate_icims_id
),
clock_stop AS
(
  SELECT DISTINCT rn.job_icims_id,
         rn.candidate_icims_id,
         CASE
           WHEN (af.contact_attempts IS NOT NULL) AND min_time > first_contact_attempt_date THEN first_contact_attempt_date
           WHEN (af.contact_attempts IS NOT NULL) AND min_time < first_contact_attempt_date THEN min_time
           ELSE min_time
         END AS clock_stop_time
  FROM masterhr.recruiting_activity rn
    INNER JOIN stop_states s
            ON s.candidate_icims_id = rn.candidate_icims_id
           AND s.job_icims_id = rn.job_icims_id
           AND s.min_time = rn.enter_state_time
    LEFT JOIN hrmetrics.art_full af
           ON af.cand_icims_id = rn.candidate_icims_id
          AND af.job_amzr_req_id = rn.job_icims_id
          AND af.contact_attempts = 1
),
current_step AS
(
  SELECT DISTINCT application_date,
         candidate_icims_id,
         job_icims_id,
         MAX(enter_state_time_pst) AS max_date
  FROM opstadw.masterhr.recruiting_activity
  WHERE 1 = 1
  GROUP BY application_date,
           candidate_icims_id,
           job_icims_id
)
SELECT DISTINCT CASE
         WHEN clock.clock_stop_time >= dateadd (DAY,-7,sysdate) THEN 'New'
         ELSE 'Historical'
       END AS status,
       hc.employee_display_name AS full_name,
       candidate.candidate_icims_id AS candidate_id,
       candidate.candidate_employee_id AS empl_id,
       activity.application_date,
       interview.job_icims_id AS icims_id,
       offer.enter_state_time AS ofr_extndd_dt,
       activity.current_funnel_state AS step,
       offer.offer_accepted_date AS ofr_accepted_dt,
       reqs.city AS loc_cty_nm,
       reqs.building AS loc_bldg_cd,
       reqs.internal_job_title AS business_title,
       reqs.job_title AS external_job_title,
       reqs.hiring_manager_reports_to_level_3_employee_login AS hrng_mngr_reports_to_level3_login,
       reqs.company_name AS co_nm,
       reqs.department_name AS req_dept_nm,
       reqs.job_function AS job_function_desc,
       reqs.job_type,
       reqs.job_level AS req_job_level,
       reqs.country AS rgltry_rgn_cd,
       CASE
         WHEN reqs.job_level >= 5 THEN hc.employee_internal_email_address
         WHEN hc.employee_personal_email_address = '' THEN hc.employee_internal_email_address
         ELSE hc.employee_personal_email_address
       END AS email_address,
       hc.job_title_name AS job_title,
       hc.job_level_name AS job_level,
       hc.location_short_name AS loc_nm,
       hc.reports_to_level_3_employee_login AS reports_to_level3_login,
       hc.reports_to_supervisor_employee_login AS reports_to_suprvsr_login,
       hc.department_name AS dept_nm,
       interview.interview_completed_dt AS interview_date,
       reqs.current_recruiter_employee_login AS recruiter_login,
       reqs.current_recruiter_employee_full_name AS recruiter_nm,
       reqs.opex_id || ' - ' || reqs.department_name || ' - ' || reqs.business_unit_code|| ' - ' || hc.reports_to_level_3_employee_login AS Business_Lane,
       team.team_flag,
       interview.interview_summary_id AS intrvw_summary_id,
       1 AS rnum
FROM masterhr.recruiting_activity activity
  LEFT JOIN current_step cs
         ON cs.job_icims_id = activity.job_icims_id
        AND cs.candidate_icims_id = activity.candidate_icims_id
  INNER JOIN masterhr.interview_activity interview
          ON activity.job_icims_id = interview.job_icims_id
         AND activity.candidate_icims_id = interview.candidate_icims_id
         AND cs.max_date = activity.enter_state_time_pst
         AND interview.applicant_type = 'INTERNAL'
         AND interview.event_type = 'On-site'
         AND interview.event_status = 'Occurred'
  INNER JOIN masterhr.candidate candidate ON candidate.candidate_icims_id = interview.candidate_icims_id
  LEFT JOIN masterhr.offer_accepts offer
         ON offer.candidate_icims_id = interview.candidate_icims_id
        AND offer.job_icims_id = interview.job_icims_id
  INNER JOIN masterhr.requisition reqs
          ON reqs.job_icims_id = interview.job_icims_id
         AND activity.application_date BETWEEN reqs.snapshot_begin_timestamp
         AND reqs.snapshot_end_timestamp
  INNER JOIN opsdw.ops_ta_team_wk team
          ON team.emplid = reqs.recruiter_employee_id
         AND activity.application_date BETWEEN team.wk_begin_dt
         AND team.wk_end_dt
  LEFT JOIN masterhr.employee_hc_current hc
         ON hc.emplid = candidate.candidate_employee_id
        AND hc.emplid IS NOT NULL
  INNER JOIN clock_stop clock
          ON clock.candidate_icims_id = interview.candidate_icims_id
         AND clock.job_icims_id = interview.job_icims_id
         AND clock.clock_stop_time::DATE>= '2019-09-15'

