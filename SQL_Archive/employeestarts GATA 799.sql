--# of Employee Starts--
select distinct
'W'||days.reporting_week_of_year Reporting_week 
,days.reporting_year Reporting_year
,'W'||days.calendar_week calendar_week
,cast(EXTRACT(week from employee_start_Date) as char(10)) starts_wk_number
,concat(starts.job_icims_id,starts.job_candidate_icims_id) unique_key
,starts.job_icims_id
,starts.job_candidate_icims_id
,starts.department_id
,starts.job_code
,starts.job_title_name
,starts.job_level_name
,starts.emplid
,starts.employee_login
,starts.employee_full_name
,starts.job_tech_indicator
,starts.job_flsa_name
,starts.location_country_name
,starts.location_city_name
,starts.location_building_name
,starts.hire_type
,team.wk_begin_dt
,team.wk_end_dt
,team.team_flag
--recruiter hierarchy--
,offer.recruiter_reports_to_level_2_employee_login "recruiter_reports_to_level_2_employee_login"
,offer.recruiter_reports_to_level_3_employee_login "recruiter_reports_to_level_3_employee_login"
,offer.recruiter_reports_to_level_4_employee_login "recruiter_reports_to_level_4_employee_login"
,offer.recruiter_reports_to_level_5_employee_login "recruiter_reports_to_level_5_employee_login"
,offer.recruiter_reports_to_level_6_employee_login "recruiter_reports_to_level_6_employee_login"
,offer.recruiter_reports_to_level_7_employee_login "recruiter_reports_to_level_7_employee_login"
,offer.recruiter_reports_to_level_8_employee_login "recruiter_reports_to_level_8_employee_login"
--hiring manager hierarchy--
,starts.reports_to_level_2_employee_login
,starts.reports_to_level_3_employee_login
,starts.reports_to_level_4_employee_login
,starts.reports_to_level_5_employee_login
,starts.reports_to_level_6_employee_login
,starts.reports_to_level_7_employee_login
,starts.reports_to_level_8_employee_login
,starts.reports_to_level_2_employee_name
,starts.reports_to_level_3_employee_name
,starts.reports_to_level_4_employee_name
,starts.reports_to_level_5_employee_name
,starts.reports_to_level_6_employee_name
,starts.reports_to_level_7_employee_name
,starts.reports_to_level_8_employee_name
-- leader login from reports to hierarchy--
,(Case when starts.reports_to_level_3_employee_login||starts.reports_to_level_4_employee_login||starts.reports_to_level_5_employee_login||starts.reports_to_level_6_employee_login||starts.reports_to_level_7_employee_login
like '%patsean%' then 'PATSEAN-Patterson, Sean' 
else 'NA' end)"Leader",
team.team_flag
from masterhr.offer_accepts offer
left join masterhr.employee_starts starts on starts.job_candidate_icims_id= offer.candidate_icims_id  and starts.job_icims_id = offer.job_icims_id
inner join opsdw.ops_ta_team_wk team on team.emplid = offer.recruiter_employee_id and offer.offer_accepted_date::date between team.wk_begin_dt AND team.wk_end_dt
inner join opstadw.hrmetrics.o_reporting_days days on cast(starts.employee_start_date as date)= days.calendar_day -- inlcuded to the the reporting week
where starts.emplid is not null
and starts.employee_start_date <= current_date

AND (starts.department_id like '1065%' OR starts.department_id like '1057%')
and starts.employee_start_date >= '01/01/2019'
--P03171-Manager I,ops , P03131-Manager II,ops , P03091-Mananger III,ops, 
--P02093 -Pathways Ops mgr, P03135 -Manager I,Training,P03095 -Manager III,Training
and starts.job_code in ('P03231','P03240','P03131','P03171','P03237','P03211','A01231','M06051','M06151','P03091','P03218','M06111','M06201','P03032','P03214',
                        'P03239','P03051','P03054','A01211','P03238','M06130','A05151','P02093','A05202','M06030','M05151','P03235','M06112','P03031','P03231',
                        'P03240','P03131','P03171','P03237','P03211','A01231','M06051','M06151','P03091','P03218','M06111','M06201','P03032','P03214','P03239',
                        'P03051','P03054','A01211','P03238','M06130','A05151','P02093',' A05202','M06030','M05151','P03235','M06112','P03031')

and (upper(offer.recruiter_reports_to_level_5_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu'))
or   upper(offer.recruiter_reports_to_level_6_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu'))
or   upper(offer.recruiter_reports_to_level_7_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu'))
or   upper(offer.recruiter_reports_to_level_8_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu')))


