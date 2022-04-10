Select distinct 
'W'||days.reporting_week_of_year Reporting_week 
,days.reporting_year Reporting_year
,'W'||days.calendar_week calendar_week
,cast(EXTRACT(week from offer_accepted_date) as char(10)) wk_number
,offer.offer_accepted_Date
,days.calendar_day
,team.wk_begin_dt
,team.wk_end_dt
,concat(offer.job_icims_id,offer.candidate_icims_id)  unique_key
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
,offer.current_job_state current_requisition_status
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
= '' then offer.hiring_manager_employee_login end)"Leader"
 ,offer.department_id "Cost center"
from masterhr.offer_accepts offer
inner join opsdw.ops_ta_team_wk team on team.emplid = offer.recruiter_employee_id and offer.offer_accepted_date::date between team.wk_begin_dt AND team.wk_end_dt
inner join opstadw.hrmetrics.o_reporting_days days on cast(offer.offer_accepted_date as date)= days.calendar_day -- inlcuded to get the reporting week
where offer.offer_accepted_count = 1
AND (offer.department_id like '1065%' OR offer.department_id like '1057%')
--P03171-Manager I,ops , P03131-Manager II,ops , P03091-Mananger III,ops, 
--P02093 -Pathways Ops mgr, P03135 -Manager I,Training,P03095 -Manager III,Training
and offer.job_code in ('P03231','P03240','P03131','P03171','P03237','P03211','A01231','M06051','M06151','P03091','P03218','M06111','M06201','P03032','P03214',
                        'P03239','P03051','P03054','A01211','P03238','M06130','A05151','P02093','A05202','M06030','M05151','P03235','M06112','P03031','P03231',
                        'P03240','P03131','P03171','P03237','P03211','A01231','M06051','M06151','P03091','P03218','M06111','M06201','P03032','P03214','P03239',
                        'P03051','P03054','A01211','P03238','M06130','A05151','P02093',' A05202','M06030','M05151','P03235','M06112','P03031')


and  offer.offer_accepted_date >= '01/01/2019'
and (upper(offer.recruiter_reports_to_level_5_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu'))
or   upper(offer.recruiter_reports_to_level_6_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu'))
or   upper(offer.recruiter_reports_to_level_7_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu'))
or   upper(offer.recruiter_reports_to_level_8_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu')))
