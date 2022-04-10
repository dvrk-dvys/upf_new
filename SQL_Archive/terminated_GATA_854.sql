SELECT DISTINCT
hc.job_code
--,hc.job_candidate_icims_id
,hc.job_icims_id
,hc.employee_first_name
,hc.employee_last_name
,hc.employee_login
,hc.hr_end_dt
,hc.employee_status_description
,hc.job_termination_date
,employee_display_name
--,*
,reportingdays.reporting_week_of_year
,reportingdays.reporting_year
,reportingdays.calendar_month_of_year
,reportingdays.calendar_qtr
,hc.job_title_name
,hc.location_country_name
,hc.department_id
,hc.department_ofa_cost_center_code

--,hc.*

FROM masterhr.employee_hc hc
--INNER JOIN accepts a ON hc.job_candidate_icims_id = a.candidate_icims_id
INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = hc.job_termination_date AND reportingdays.reporting_year = DATEPART(year, sysdate)

WHERE 1=1
AND employee_status_description = 'Terminated'
--AND job_candidate_icims_id <> ''
AND (LOWER(reports_to_level_4_employee_login) = 'feitzing'
OR LOWER(reports_to_level_5_employee_login) = 'feitzing'
OR LOWER(reports_to_level_6_employee_login) = 'feitzing'
OR LOWER(reports_to_level_7_employee_login) = 'feitzing')

