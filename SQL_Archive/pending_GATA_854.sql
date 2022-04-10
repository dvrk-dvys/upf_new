WITH ap AS (

      SELECT 
      job_id,
      icims_id,
      person_id,
     -- MIN(icims_created_timestamp) AS application_date
      MIN(convert_timezone ('US/Pacific',CAST((TIMESTAMP 'epoch' + CAST(icims_updated_timestamp AS BIGINT) / 1000*INTERVAL '1 Second') AS TIMESTAMP))) AS application_date
      
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
),

latest as (

    SELECT 
      job_id,
      icims_id,
      person_id,
      icims_updated_timestamp,
      status
      
    FROM ads.worksteps_latest
)

    SELECT DISTINCT 
    ap.application_date,
    DATEDIFF(d,offer.requisition_final_approval_date::TIMESTAMP,offer_accepted_date::TIMESTAMP) AS TTF,
    reqs.current_job_state AS reqscurrentjobstate,
    l.icims_updated_timestamp AS current_icims_status,
    l.status,
    reportingdays.calendar_day,
    reportingdays.reporting_week_of_year,
    reportingdays.reporting_year,
    reportingdays.calendar_month_of_year,
    reportingdays.calendar_qtr,
    offer.job_icims_id AS job_id,
    offer.candidate_icims_id AS person_id,
    offer.enter_state_time,
    TRUNC(offer.offer_accepted_date),
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
    --empl.emplid,
    TRUNC(SYSDATE) AS generated_date,
    reqs.ofa_cost_center_code
    --status.status
   -- ,offer.*

    FROM masterhr.offer_accepts offer
    INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = offer.job_icims_id
    INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = TRUNC(offer.offer_accepted_date::DATE) AND reportingdays.reporting_year = DATEPART(year, sysdate)

    INNER JOIN ap ON ap.job_id = offer.job_icims_id AND ap.person_id = offer.candidate_icims_id
    LEFT JOIN status ON status.job_id = ap.job_id AND status.person_id = ap.person_id
    LEFT JOIN lookup.icims_recruiting_states s ON status.status = s.icims_status
    LEFT JOIN masterhr.employee_hc_current empl ON empl.job_candidate_icims_id = offer.candidate_icims_id
    LEFT JOIN phoenix_tier2_uat.candidate_type ct ON ct.candidate_icims_id = offer.candidate_icims_id AND ct.job_icims_id = offer.job_icims_id
    LEFT JOIN latest l ON l.job_id = ap.job_id AND l.icims_id = ap.icims_id AND l.person_id = ap.person_id

    WHERE 1=1
    AND offer.offer_accepted_count = 1
    --AND reqs.current_transaction_flag = 'Y'
    AND offer_accepted_date >= '2019-01-01'
    AND s.ra_column_name = 'pending_start_count'
    AND reporting_week_of_year = 46
   -- AND reqs.ofa_cost_center_code in ('1023', '1092', '1145', '1158', '1160', '1171', '1172', '1173', '1174', '1263', '1290', '1299', '1917', '2157', '7024', '7709')
   
    AND (LOWER(offer.sourcer_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike')
    OR LOWER(offer.recruiter_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike') 
    OR(LOWER(offer.hiring_manager_reports_to_level_4_employee_login) = 'feitzing'
    OR LOWER(offer.hiring_manager_reports_to_level_5_employee_login) = 'feitzing'))
    
