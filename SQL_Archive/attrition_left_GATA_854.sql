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

hired AS (

    SELECT employee_first_name, employee_last_name,  employee_emplid, candidate_guid, job_code, job_title_name, job_candidate_icims_id, job_icims_id
    FROM opstadw.masterhr.employee_starts
    WHERE 1=1
    --AND employee_login = 'jorharj'
),

terminated AS (

SELECT DISTINCT *
FROM masterhr.employee_termination
WHERE job_level_name != 99 

)



select distinct 
ap.application_date, 
DATEDIFF (d , offer.requisition_final_approval_date::timestamp,offer_accepted_date::timestamp) as TTF,
h.employee_emplid,

offer.*,
reqs.current_job_state as reqscurrentjobstate,
reportingdays.calendar_day,
team.team_flag


FROM masterhr.offer_accepts offer
INNER JOIN opsdw.ops_ta_team_wk team ON team.emplid = offer.recruiter_employee_id
INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = offer.job_icims_id
LEFT JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = offer.offer_accepted_date

INNER JOIN ap ON ap.job_id = offer.job_icims_id AND ap.person_id = offer.candidate_icims_id 
LEFT JOIN status on status.job_id = ap.job_id AND status.person_id = ap.person_id
LEFT JOIN lookup.icims_recruiting_states s ON status.status=s.icims_status 
INNER JOIN hired h ON h.job_candidate_icims_id = ap.person_id AND h.job_icims_id = ap.job_id
INNER JOIN terminated t ON t.employee_emplid = h.employee_emplid



WHERE 1=1
AND offer.enter_state_time::date between team.wk_begin_dt AND team.wk_end_dt
AND offer.offer_accepted_count = 1
AND reqs.current_transaction_flag = 'Y'
--AND offer.candidate_recruiter_login = 'osupike'
--AND CAST(lower(candidate_full_name) AS varchar) LIKE '%harris%'
--AND lower(candidate_full_name) LIKE '%jordan%'

--candidate_guid
--job_icims_id
--candidate_icims_id
