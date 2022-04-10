WITH ap AS (

    SELECT 

    job_id,
    icims_id,
    person_id,
    --status,
    MIN(convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(icims_updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp))) as application_date

    FROM  ads.worksteps
    GROUP BY job_id, icims_id, person_id
),

status as(
 
    SELECT 

    job_id,
    icims_id,
    person_id,
    status

    FROM ads.worksteps
    GROUP BY job_id, icims_id, person_id, status
),

accepts AS (

select distinct 
ap.application_date, 
DATEDIFF (d , offer.requisition_final_approval_date::timestamp,offer_accepted_date::timestamp) as TTF,

--offer.*,
offer.candidate_full_name,
offer.job_icims_id,
offer.candidate_icims_id,
offer.icims_status,
offer.enter_state_time,
offer.offer_accepted_date,
offer.candidate_recruiter_employee_id,
offer.candidate_recruiter_login,

reqs.current_job_state as reqscurrentjobstate,
reportingdays.calendar_day,
team.team_flag, 
reqs.ofa_cost_center_code,
--reqs.*
reportingdays.calendar_day,
reportingdays.reporting_week_of_year,
reportingdays.reporting_year,
reportingdays.calendar_month_of_year,
reportingdays.calendar_qtr

FROM masterhr.offer_accepts offer
INNER JOIN opsdw.ops_ta_team_wk team ON team.emplid = offer.recruiter_employee_id
INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = offer.job_icims_id
LEFT JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = offer.offer_accepted_date

INNER JOIN ap ON ap.job_id = offer.job_icims_id AND ap.person_id = offer.candidate_icims_id 
LEFT JOIN status on status.job_id = ap.job_id AND status.person_id = ap.person_id
LEFT JOIN lookup.icims_recruiting_states s ON status.status=s.icims_status 


WHERE 1=1
AND offer.enter_state_time::date between team.wk_begin_dt AND team.wk_end_dt
AND offer.offer_accepted_count = 1
AND reqs.current_transaction_flag = 'Y'
--AND offer.candidate_recruiter_login = 'osupike'
--AND lower(candidate_full_name) LIKE '%jordan%harris%'
AND reqs.ofa_cost_center_code in ('1023', '1092', '1145', '1158', '1160', '1171', '1172', '1173', '1174', '1263', '1290', '1299', '1917', '2157', '7024', '7709')


)


select distinct

transfer_effective_date,
et.emplid,
et.employee_login,
et.employee_full_name,
reportingdays.calendar_day,
reportingdays.reporting_week_of_year,
reportingdays.reporting_year,
reportingdays.calendar_month_of_year,
reportingdays.calendar_qtr,
et.*

FROM masterhr.employee_transfers et
INNER JOIN masterhr.employee_hc hc ON hc.employee_login = et.employee_login
INNER JOIN accepts a ON hc.job_candidate_icims_id = a.candidate_icims_id
INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = et.transfer_effective_date::DATE AND reportingdays.reporting_year = DATEPART(year, sysdate)
