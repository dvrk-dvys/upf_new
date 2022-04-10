 WITH declines as(
 
        SELECT DISTINCT 
        DATEDIFF (d , offer.requisition_final_approval_date::timestamp,offer_accepted_date::timestamp) as TTF,
        reqs.job_id,
        reqs.job_icims_id,
        reqs.ofa_cost_center_code,
        --reqs.snapshot_begin_timestamp,
        --reqs.snapshot_end_timestamp,
        offer.icims_status,
        offer.enter_state_time,
        offer.candidate_full_name,
        offer.job_icims_id,
        offer.candidate_icims_id,
        offer.offer_accepted_count,
        offer.offer_accepted_date,
        offer.offer_declined_count,
        offer.offer_declined_date,
        offer.job_id,
        offer.candidate_guid,
        offer.recruiter_employee_login,
        offer.current_recruiter_employee_full_name,
        reqs.current_job_state as reqscurrentjobstate,
        reqs.internal_job_title,
        reportingdays.calendar_day,
        reportingdays.reporting_week_of_year,
        reportingdays.calendar_month_of_year,
        reportingdays.calendar_qtr,
        reportingdays.reporting_year



        FROM masterhr.offer_accepts offer
        INNER JOIN opsdw.ops_ta_team_wk team ON team.emplid = offer.recruiter_employee_id
        INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = offer.job_icims_id AND ((TRUNC(offer.offer_accepted_date) BETWEEN TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(reqs.snapshot_end_timestamp)) OR (TRUNC(offer.offer_declined_date) BETWEEN TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(reqs.snapshot_end_timestamp)))
        INNER JOIN hrmetrics.o_reporting_days reportingdays ON ((reportingdays.calendar_day = TRUNC(offer.offer_accepted_date)) OR (reportingdays.calendar_day = TRUNC(offer.offer_declined_date))) AND  reportingdays.reporting_year = DATEPART(year, sysdate)
        WHERE 1=1
        AND reqs.ofa_cost_center_code in ('1023', '1092', '1145', '1158', '1160', '1171', '1172', '1173', '1174', '1263', '1290', '1299', '1917', '2157', '7024', '7709')
        AND offer.enter_state_time::date between team.wk_begin_dt AND team.wk_end_dt
        --AND offer.offer_accepted_count = 1
        AND offer.offer_declined_count = 1

)


SELECT DISTINCT
  a.job_id,
  a.icims_id,
  a.person_id,
  a.icims_updated_timestamp,
  a.status,
  rd.calendar_day,
  rd.reporting_week_of_year,
  rd.reporting_year,
  rd.calendar_month_of_year,
  rd.calendar_qtr
    

      
FROM ads.worksteps_latest A
INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = a.job_id
INNER JOIN test ON a.job_id = test.job_id AND a.icims_id = test.icims_id AND a.person_id = test.person_id
INNER JOIN hrmetrics.o_reporting_days rd ON rd.calendar_day_of_week = 1 AND rd.calendar_day >= reqs.snapshot_begin_timestamp AND rd.calendar_day < snapshot_end_timestamp AND rd.calendar_day_of_week = 1 AND rd.reporting_year IN (2019) 

WHERE 1=1
AND icims_updated_timestamp > '2019-01-01 12:00:00'
AND a.status NOT IN ('Candidate - Offer - Accepted', 'Employee - Hire Confirmed', 'Candidate - Interview Process - Move candidate to Amazon Hire', 'Candidate - Offer - Extended', 'Candidate - Pre-hire - Error - Prepare for Hire', 'Candidate - Pre-hire - Prepare for Hire', 'Candidate - Interview Process - ART - Tagged', 'Candidate - Offer - Cancelled')
AND reqs.ofa_cost_center_code in ('1023', '1092', '1145', '1158', '1160', '1171', '1172', '1173', '1174', '1263', '1290', '1299', '1917', '2157', '7024', '7709')
