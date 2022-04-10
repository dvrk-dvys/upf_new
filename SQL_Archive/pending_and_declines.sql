WITH ap AS (

      SELECT 
      job_id,
      icims_id,
      person_id,
      --status,
      MIN(icims_created_timestamp) AS application_date
      --MIN(convert_timezone ('US/Pacific',CAST((TIMESTAMP 'epoch' + CAST(icims_updated_timestamp AS BIGINT) / 1000*INTERVAL '1 Second') AS TIMESTAMP))) AS application_date
      
      FROM ads.worksteps
      GROUP BY job_id,
      icims_id,
      person_id
),

status AS (

      SELECT 
      job_id,
      icims_id,
      person_id,
      status
      
      
      FROM ads.worksteps
      GROUP BY job_id,
      icims_id,
      person_id,
      status
)

    SELECT DISTINCT 
    ap.application_date,
    DATEDIFF(d,offer.requisition_final_approval_date::TIMESTAMP,offer_accepted_date::TIMESTAMP) AS TTF,
    reqs.current_job_state AS reqscurrentjobstate,
    reportingdays.calendar_day,
    reportingdays.reporting_week_of_year,
    reportingdays.reporting_year,
    reportingdays.calendar_month_of_year,
    reportingdays.calendar_qtr,
    offer.job_icims_id AS job_id,
    offer.candidate_icims_id AS person_id,
    offer.enter_state_time,
    offer.offer_accepted_date,
    offer.candidate_recruiter_login,
    offer.candidate_recruiter_name,
    offer.department_id,
    offer.sourcer_employee_login,
    offer.sourcer_employee_full_name,
    offer.candidate_type,
    offer.job_level,
    offer.job_code,
    offer.job_classification_title,
    offer.country,
    offer.building,
    offer.candidate_full_name,
    empl.emplid,
    TRUNC(SYSDATE) AS generated_date,
    status.status

    FROM masterhr.requisition reqs
    LEFT JOIN masterhr.offer_accepts offer ON reqs.job_icims_id = offer.job_icims_id
--    FROM masterhr.offer_accepts offer
    --INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = offer.job_icims_id
    LEFT JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = offer.offer_accepted_date::DATE
    --LEFT JOIN weeks reportingdays ON reportingdays.calendar_day = offer.offer_accepted_date::DATE
    INNER JOIN ap ON ap.job_id = offer.job_icims_id AND ap.person_id = offer.candidate_icims_id
    LEFT JOIN status ON status.job_id = ap.job_id AND status.person_id = ap.person_id
    LEFT JOIN lookup.icims_recruiting_states s ON status.status = s.icims_status
    LEFT JOIN masterhr.employee_hc_current empl ON empl.job_candidate_icims_id = offer.candidate_icims_id
    LEFT JOIN phoenix_tier2_uat.candidate_type ct ON ct.candidate_icims_id = offer.candidate_icims_id AND ct.job_icims_id = offer.job_icims_id


    WHERE true
    AND offer.offer_accepted_count = 1
    AND reqs.current_transaction_flag = 'Y'
    --AND (offer.recruiter_reports_to_level_6_employee_login IN ('amandam', 'loscott') OR offer.sourcer_reports_to_level_6_employee_login IN ('amandam', 'loscott'))
    AND offer_accepted_date >= '2019-01-01'
    --AND ct.candidate_type = 'INTERNAL'
   -- AND (s.ra_column_name = 'pending_start_count'
   -- OR s.recruiting_state = 'Offer Declined')
   AND s.recruiting_state = 'Offer Declined'
