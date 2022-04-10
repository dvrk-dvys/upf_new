with current_month as
( SELECT calendar_year, calendar_month_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
,

raw_data as
( 
select 
DATEDIFF(d,snapshot_begin_timestamp, snapshot_end_timestamp) as deltadays
,reqs.snapshot_begin_timestamp
,TRUNC(rd.calendar_day) as daycal
,TRUNC(snapshot_begin_timestamp) beginday
,TRUNC(snapshot_end_timestamp) endnday
,rd.calendar_month_of_year
,rd.calendar_year
,CASE WHEN reqs.approved = 0 THEN 'PENDING APPROVAL' ELSE 'APPROVED' END as job_approval_status ,TRUNC(reqs.final_approval_date) as approval_date
,TRUNC(reqs.requisition_opened_time) as creation_date
,CASE WHEN job_state IN('FILLED','OFFER ACCEPTED') AND DATE_PART(y,TRUNC(enter_state_time)) < 2019 THEN 0 ELSE 1 END as filter
,reqs.* 

from masterhr.requisition reqs 

INNER JOIN hrmetrics.o_reporting_days rd ON rd.calendar_day >= reqs.snapshot_begin_timestamp AND rd.calendar_day < snapshot_end_timestamp AND rd.calendar_day_of_month = 1 AND rd.calendar_year IN (2019) 

WHERE 
1=1 
AND DATEDIFF(d,snapshot_begin_timestamp, snapshot_end_timestamp) > 0 
--AND (recruiter_reports_to_level_5_employee_login = 'chaluleu' OR recruiter_reports_to_level_4_employee_login = 'chaluleu' OR recruiter_reports_to_level_6_employee_login = 'chaluleu')
AND job_state NOT IN ('POOLING','ELIMINATED')
),

DATAPREP AS (

SELECT
r.calendar_year
,r.calendar_month_of_year
,daycal as month_begin_day
,r.job_approval_status
,r.job_state
,DATEDIFF(d, r.final_approval_date, daycal) as deltadays

,CASE 

WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state = r.current_job_state AND r.current_job_state ='OFFER ACCEPTED' AND r.current_job_state != aj.req_status THEN aj.req_status

WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state != r.current_job_state AND r.current_job_state ='OFFER ACCEPTED' AND r.current_job_state != aj.req_status THEN aj.req_status

WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state != r.current_job_state AND r.current_job_state = aj.req_status THEN r.current_job_state 
WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state != r.current_job_state THEN r.current_job_state ELSE r.job_state END AS job_state_c

--ELSE r.job_state END AS job_state_c
,r.job_guid
,r.job_icims_id
,r.job_level
,r.job_tech_indicator
,r.job_tech_non_tech_sde_code
,r.flsa_name
,r.final_approval_date
,r.recruiter_employee_login
,r.operational_plan_budget_year
,r.opening
,r.filled_openings
,r.remaining_openings
,r.country
,r.building
,r.current_job_state
,TRUNC(r.enter_state_time) as enter_state_day
,rd.calendar_month_of_year as enter_state_month
,rd.calendar_year as enter_state_year
,hc.reports_to_level_4_employee_login
,hc.reports_to_level_5_employee_login
,hc.reports_to_level_6_employee_login
,cm.calendar_month_of_year as current_month


FROM raw_data r 

LEFT JOIN hrmetrics.o_reporting_days rd ON rd.calendar_day = TRUNC(enter_state_time)
INNER JOIN masterhr.employee_hc hc ON r.recruiter_employee_id = hc.emplid AND r.daycal between TRUNC(hc.hr_begin_dt) AND TRUNC(hc.hr_end_dt) 
AND (reports_to_level_5_employee_login = 'amandam' OR reports_to_level_4_employee_login = 'amandam' OR reports_to_level_6_employee_login = 'amandam')

INNER JOIN current_month cm ON  cm.calendar_year  >= r.calendar_year AND  cm.calendar_month_of_year >= r.calendar_month_of_year

LEFT JOIN (SELECT
reqs.job_art_job_id
,case when reqs.req_status like 'OPEN' and reqs_current_pipeline.accepts + reqs_current_pipeline.hires >= reqs.openings then 'OFFER ACCEPTED' else reqs.req_status end as req_status

FROM rds.reqs reqs LEFT JOIN rds.reqs_current_pipeline ON (reqs.job_amzr_req_id=reqs_current_pipeline.job_id)
WHERE req_status NOT IN ('ELIMINATED') ) aj ON aj.job_art_job_id = r.job_guid


WHERE filter = 1 AND job_approval_status NOT IN( 'PENDING APPROVAL') 
)

SELECT dp.*
,CASE WHEN deltadays > 100 THEN 'Y' ELSE 'N' END as over_100_days

FROM dataprep dp WHERE job_state_c NOT IN ('FILLED','OFFER ACCEPTED')
