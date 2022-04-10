WITH current_week as
( SELECT reporting_year, reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate) AND reporting_year = DATEPART(year, sysdate)),


prep AS (

Select distinct 
cast(EXTRACT(week from offer_accepted_date) as char(10)) AS wk_number
,offer.offer_accepted_Date
,team.wk_begin_dt
,team.wk_end_dt
,concat(offer.job_icims_id,offer.candidate_icims_id) AS unique_key
,offer.job_icims_id
,offer.candidate_icims_id
,offer.candidate_full_name
,offer.candidate_identifier_login
,offer.candidate_identifier_name
,offer.candidate_recruiter_login
,offer.recruiter_employee_login
,offer.candidate_type
,offer.job_code
,offer.job_level
,offer.job_title
,offer.country
,offer.location_building_name
,offer.job_id
,offer.hire_type
,offer.department_id
,offer.current_job_state AS current_requisition_status
,team.team_flag
--recruiter hierarchy--
,offer.recruiter_reports_to_level_2_employee_login
,offer.recruiter_reports_to_level_3_employee_login
,offer.recruiter_reports_to_level_4_employee_login
,offer.recruiter_reports_to_level_5_employee_login
,offer.recruiter_reports_to_level_6_employee_login
,offer.recruiter_reports_to_level_7_employee_login
,offer.recruiter_reports_to_level_8_employee_login
--hiring manager hierarchy--
,offer.hiring_manager_employee_id 
,offer.hiring_manager_employee_login
,offer.hiring_manager_reports_to_level_2_employee_login
,offer.hiring_manager_reports_to_level_3_employee_login
,offer.hiring_manager_reports_to_level_4_employee_login
,offer.hiring_manager_reports_to_level_5_employee_login
,offer.hiring_manager_reports_to_level_6_employee_login
,offer.hiring_manager_reports_to_level_7_employee_login
,offer.hiring_manager_reports_to_level_8_employee_login
,offer.hiring_manager_reports_to_level_2_employee_name
,offer.hiring_manager_reports_to_level_3_employee_name
,offer.hiring_manager_reports_to_level_4_employee_name
,offer.hiring_manager_reports_to_level_5_employee_name
,offer.hiring_manager_reports_to_level_6_employee_name
,offer.hiring_manager_reports_to_level_7_employee_name
,offer.hiring_manager_reports_to_level_8_employee_name
-- leader login from hiring hierarchy--
,(Case when offer.hiring_manager_reports_to_level_3_employee_login||offer.hiring_manager_reports_to_level_4_employee_login||offer.hiring_manager_reports_to_level_5_employee_login||offer.hiring_manager_reports_to_level_6_employee_login||offer.hiring_manager_reports_to_level_7_employee_login
like '%patsean%' then 'PATSEAN-Patterson, Sean' 
when  offer.hiring_manager_reports_to_level_3_employee_login||offer.hiring_manager_reports_to_level_4_employee_login||offer.hiring_manager_reports_to_level_5_employee_login||offer.hiring_manager_reports_to_level_6_employee_login||offer.hiring_manager_reports_to_level_7_employee_login
= '' then offer.hiring_manager_employee_login end) AS "Leader"
 ,offer.department_id AS "Cost center"
 ,1 AS join_me
from masterhr.offer_accepts as offer
inner join opsdw.ops_ta_team_wk team on team.emplid = offer.recruiter_employee_id and offer.offer_accepted_date::date between team.wk_begin_dt AND team.wk_end_dt
where offer.offer_accepted_count = 1
AND "Leader" = 'PATSEAN-Patterson, Sean'
AND (offer.department_id like '1065%' OR offer.department_id like '1057%')

),

ytd AS (
SELECT
COUNT(*) as total_ytd_count,
(SELECT COUNT(*) FROM prep WHERE job_level = 3) as lvl_3_count,
(SELECT COUNT(*) FROM prep WHERE job_level = 4) as lvl_4_count,
(SELECT COUNT(*) FROM prep WHERE job_level = 5) as lvl_5_count,
(SELECT COUNT(*) FROM prep WHERE job_level = 6) as lvl_6_count,
(SELECT COUNT(*) FROM prep WHERE job_level = 7) as lvl_7_count,
1 AS join_me
FROM prep
)


Select
'Offer Accepts'::VARCHAR(200) AS metric_name 
,'W'||days.reporting_week_of_year AS Reporting_week 
,days.reporting_year AS Reporting_year
,'W'||days.calendar_week AS calendar_week
,wk_number
,offer_accepted_Date
,days.calendar_day
,wk_begin_dt
,wk_end_dt
,unique_key
,job_icims_id
,candidate_icims_id
,candidate_full_name
,candidate_identifier_login
,candidate_identifier_name
,candidate_recruiter_login
,recruiter_employee_login
,candidate_type
,job_code
,job_level
,job_title
,country
,location_building_name
,job_id
,hire_type
,department_id
,current_requisition_status
,team_flag
,"Leader"
,"Cost center"
,total_ytd_count
,lvl_3_count
,lvl_4_count
,lvl_5_count
,lvl_6_count
,lvl_7_count

FROM PREP
INNER JOIN opstadw.hrmetrics.o_reporting_days days on cast(offer_accepted_date as date)= days.calendar_day -- inlcuded to get the reporting week
INNER JOIN current_week cw ON  cw.reporting_year  >= days.reporting_year AND  cw.reporting_week_of_year >= days.reporting_week_of_year
LEFT JOIN ytd ON prep.join_me = ytd.join_me 

WHERE 1=1
AND days.reporting_week_of_year >= (cw.reporting_week_of_year - 10)

