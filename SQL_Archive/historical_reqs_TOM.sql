with current_week as
( SELECT reporting_year, reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate)),

raw_data as
( 
select 
DATEDIFF(d,snapshot_begin_timestamp, snapshot_end_timestamp) as deltadays
,reqs.snapshot_begin_timestamp
,TRUNC(rd.calendar_day) as daycal
,TRUNC(snapshot_begin_timestamp) beginday
,TRUNC(snapshot_end_timestamp) endnday
,rd.reporting_week_of_year
,rd.reporting_year
,CASE WHEN reqs.approved = 0 THEN 'PENDING APPROVAL' ELSE 'APPROVED' END as job_approval_status ,TRUNC(reqs.final_approval_date) as approval_date
,TRUNC(reqs.requisition_opened_time) as creation_date
,CASE WHEN job_state IN('FILLED','OFFER ACCEPTED') AND DATE_PART(y,TRUNC(enter_state_time)) < 2019 THEN 0 ELSE 1 END as filter
,reqs.* 

from masterhr.requisition reqs 

INNER JOIN hrmetrics.o_reporting_days rd ON rd.calendar_day_of_week = 1 AND rd.calendar_day >= reqs.snapshot_begin_timestamp AND rd.calendar_day < snapshot_end_timestamp AND rd.calendar_day_of_week = 1 AND rd.reporting_year IN (2019) 

WHERE 
1=1 
AND DATEDIFF(d,snapshot_begin_timestamp, snapshot_end_timestamp) > 0 
AND job_state NOT IN ('POOLING','ELIMINATED')
),

PREP AS ( 

SELECT DISTINCT
enter_state_time
,r.beginday
,r.endnday
,r.job_approval_status
,r.job_state
,CASE 

WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state = r.current_job_state AND r.current_job_state ='OFFER ACCEPTED' AND r.current_job_state != aj.req_status THEN aj.req_status

WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state != r.current_job_state AND r.current_job_state ='OFFER ACCEPTED' AND r.current_job_state != aj.req_status THEN aj.req_status

WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state != r.current_job_state AND r.current_job_state = aj.req_status THEN r.current_job_state 
WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state != r.current_job_state THEN r.current_job_state ELSE r.job_state END AS job_state_c


,r.job_guid
,r.job_icims_id
,r.job_level
,r.job_tech_indicator
,r.job_tech_non_tech_sde_code
,r.department_id as cost_center
,r.flsa_name
,r.final_approval_date
,r.recruiter_employee_login
,r.operational_plan_budget_year
,r.opening
,r.filled_openings
,r.remaining_openings
,r.country
,r.job_classification_title
,r.building
,r.current_job_state
,TRUNC(r.enter_state_time) as enter_state_day
,r.hiring_manager_employee_full_name
,hchmc.reports_to_level_7_employee_name as HM_current_level7
,hchmc.reports_to_level_6_employee_name as HM_current_level6
,hchmc.reports_to_level_5_employee_name as HM_current_level5
,(Case when hchmc.reports_to_level_3_employee_login||hchmc.reports_to_level_4_employee_login||hchmc.reports_to_level_5_employee_login||hchmc.reports_to_level_6_employee_login||hchmc.reports_to_level_7_employee_login
like '%patsean%' then 'PATSEAN-Patterson, Sean' 
when  hchmc.reports_to_level_4_employee_login||hchmc.reports_to_level_5_employee_login||hchmc.reports_to_level_6_employee_login||hchmc.reports_to_level_7_employee_login
='' then hchmc.employee_full_name end)"Leader"
,hcmp.reports_to_level_7_employee_name as HM_past_level7,hcmp.reports_to_level_6_employee_name as HM_past_level6
,hcmp.reports_to_level_5_employee_name as HM_past_level5
, hchmc.reports_to_level_7_employee_name || hchmc.reports_to_level_6_employee_name || hcmp.reports_to_level_6_employee_name || hcmp.reports_to_level_7_employee_name as HMCONCAT
,1 AS join_me
FROM raw_data r 
LEFT JOIN masterhr.employee_hc_current hchmc ON r.hiring_manager_employee_id = hchmc.emplid 
LEFT JOIN masterhr.employee_hc  hcmp ON r.hiring_manager_employee_id = hcmp.emplid AND r.daycal between TRUNC(hcmp.hr_begin_dt) AND TRUNC(hcmp.hr_end_dt) 
    LEFT JOIN (SELECT reqs.job_art_job_id,
    case when reqs.req_status like 'OPEN' and reqs_current_pipeline.accepts + reqs_current_pipeline.hires >= reqs.openings then 'OFFER ACCEPTED' else reqs.req_status end as req_status
    FROM rds.reqs reqs LEFT JOIN rds.reqs_current_pipeline ON (reqs.job_amzr_req_id=reqs_current_pipeline.job_id) WHERE req_status NOT IN ('ELIMINATED') ) aj ON aj.job_art_job_id = r.job_guid

WHERE filter = 1
AND (cost_center like '1065%' OR cost_center like '1057%')
AND job_state NOT IN ('FILLED','OFFER ACCEPTED')
AND "Leader" = 'PATSEAN-Patterson, Sean'
),


ytd AS (
SELECT 
COUNT(*) as ytd_count,
(SELECT COUNT(*) FROM prep WHERE job_state = 'OPEN') as unapproved_count,
(SELECT COUNT(*) FROM prep WHERE job_state = 'APPROVED') as approved_count,

1 AS join_me
       
FROM prep

)


SELECT DISTINCT
'Historical Reqs'::VARCHAR(200) AS metric_name 
,rd2.reporting_year
,rd2.reporting_week_of_year
,rd2.daycal as week_begin_day
,TRUNC(DATEADD(day,7,daycal)) as day_for_nextweek_SLA_alert
,CASE WHEN rd2.job_approval_status IN ('PENDING APPROVAL') THEN DATEDIFF(d,creation_date, daycal) END as pending_approval_days_gross
,CASE WHEN rd2.job_approval_status IN ('PENDING APPROVAL') THEN ((DATEDIFF('day',creation_date,daycal)) -(DATEDIFF ('week',creation_date,daycal)*2) -(CASE WHEN DATE_PART(dow,creation_date) = 0 THEN 1 ELSE 0 END) -(CASE WHEN DATE_PART(dow,daycal) = 6 THEN 1 ELSE 0 END)) END as pending_approval_days_net
,CASE WHEN rd2.job_state IN ('APPROVED') THEN DATEDIFF(d,approval_date, daycal) END as approved_req_age_days_gross
,CASE WHEN rd2.job_state IN ('APPROVED') THEN ((DATEDIFF('day',approval_date,daycal)) -(DATEDIFF ('week',approval_date,daycal)*2) -(CASE WHEN DATE_PART(dow,approval_date) = 0 THEN 1 ELSE 0 END) -(CASE WHEN DATE_PART(dow,daycal) = 6 THEN 1 ELSE 0 END)) END as approved_req_age_days_net
,r.job_approval_status
,r.job_state
,r.job_state_c
,r.job_guid
,r.job_icims_id
,r.job_level
,r.job_tech_indicator
,r.job_tech_non_tech_sde_code
,r.cost_center
,r.flsa_name
,r.final_approval_date
,rd2.recruiter_employee_login
,r.operational_plan_budget_year
,r.opening
,r.filled_openings
,r.remaining_openings
,r.country
,r.job_classification_title
,r.building
,r.current_job_state
,r.enter_state_day
,rd2.reporting_week_of_year as state_enter_reporting_year
,rd2.reporting_year as state_enter_reporting_week
,cw.reporting_week_of_year as current_reporting_week
,r.hiring_manager_employee_full_name
,r.HM_current_level7
,r.HM_current_level6
,r.HM_current_level5
,r."Leader"
,r.HM_past_level7
,r.HM_past_level6
,r.HM_past_level5
,r.HMCONCAT
,ytd.ytd_count
,ytd.unapproved_count
,ytd.approved_count


FROM PREP r
LEFT JOIN hrmetrics.o_reporting_days rd ON rd.calendar_day = TRUNC(enter_state_time)
LEFT JOIN raw_data rd2 ON rd2.job_guid = r.job_guid AND r.job_icims_id = rd2.job_icims_id AND r.beginday = rd2.beginday AND r.endnday = rd2.endnday
INNER JOIN current_week cw ON  cw.reporting_year  >= rd2.reporting_year AND  cw.reporting_week_of_year >= rd2.reporting_week_of_year
LEFT JOIN ytd ON r.join_me = ytd.join_me 

WHERE 1=1
AND CAST(rd2.reporting_week_of_year AS int) >= (CAST(cw.reporting_week_of_year AS int) - 10)
