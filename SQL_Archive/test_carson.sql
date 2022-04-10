WITH current_data AS
( SELECT reporting_year, reporting_week_of_year, calendar_year, calendar_month_of_year, calendar_qtr FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))

SELECT 

CASE WHEN TRUNC(snapshot_end_timestamp) > (TRUNC(rd_week.calendar_day) + INTERVAL '6 DAY') THEN DATEDIFF(d,snapshot_begin_timestamp, (rd_week.calendar_day + INTERVAL '6 DAY'))
     ELSE DATEDIFF(d,snapshot_begin_timestamp, snapshot_end_timestamp) END AS deltadays


,DATEDIFF(d,snapshot_begin_timestamp, snapshot_end_timestamp) AS deltadays_1

,TRUNC(rd_week.calendar_day) AS daycal_week
,TRUNC(snapshot_begin_timestamp) AS beginday
,TRUNC(snapshot_end_timestamp) AS endday
,rd_week.reporting_week_of_year
,rd_week.reporting_year
,reqs.enter_state_time
,reqs.sourcer_employee_login
,reqs.sourcer_employee_id
,reqs.job_guid
,reqs.job_state
,final_approval_date
,snapshot_begin_timestamp
,snapshot_end_timestamp
,current_job_state
,job_icims_id
,job_level
,job_tech_indicator

FROM masterhr.requisition reqs 

INNER JOIN hrmetrics.o_reporting_days rd_week ON TRUNC(rd_week.calendar_day) >= TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(rd_week.calendar_day) < TRUNC(snapshot_end_timestamp) AND rd_week.calendar_day_of_week = 1 AND rd_week.reporting_year IN (2019) 

WHERE 
1=1 
AND DATEDIFF(d,snapshot_begin_timestamp, snapshot_end_timestamp) > 0 
--AND (recruiter_reports_to_level_5_employee_login = 'chaluleu' OR recruiter_reports_to_level_4_employee_login = 'chaluleu' OR recruiter_reports_to_level_6_employee_login = 'chaluleu')
AND job_state NOT IN ('POOLING','ELIMINATED')
AND recruiter_reports_to_level_6_employee_login = 'amandam' --and job_guid = '5a1f4499-fced-40cc-9dd4-767b5148f666'
AND reporting_week_of_year = 17 

