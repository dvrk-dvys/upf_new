WITH weeks AS (
  SELECT *
  FROM hrmetrics.o_reporting_days WHERE calendar_year  = 2019
),

interviews AS (

  SELECT job_id, job_icims_id, candidate_id, candidate_icims_id, recruiter_employee_id, recruiter_employee_login, current_recruiter_employee_id, current_recruiter_employee_login, sourcer_employee_id, sourcer_employee_login, work_step, event_type, event_status,
  event_start, event_start_dt, interviewer_feedback_time, interviewer_feedback_dt, interview_completed_time, interview_completed_dt, source_system
  FROM masterhr.interview_activity
  WHERE event_type IN ('Phone Screen', 'On-site') AND work_step = 'Interview Event' AND event_start_dt >= '2019-01-01'
  
 ),
 
 dataprep AS (
 
  SELECT DISTINCT job_id, candidate_id, candidate_icims_id, sourcer_employee_id, sourcer_employee_login, work_step, event_type, event_status,
  reporting_week_of_year, event_start, event_start_dt, interviewer_feedback_time, interviewer_feedback_dt, interview_completed_time, interview_completed_dt,
  source_system, emplid, employee_login, employee_full_name,  job_title_name, employee_status_description, 
  reports_to_level_2_employee_name, reports_to_level_3_employee_name, reports_to_level_4_employee_name, reports_to_level_5_employee_name, reports_to_level_6_employee_name, reports_to_supervisor_employee_name
  
  FROM masterhr.employee_hc_current hc  
  INNER JOIN interviews ON interviews.sourcer_employee_id = hc.emplid 
  LEFT JOIN weeks ON event_start_dt = TRUNC(weeks.calendar_day)
  WHERE reports_to_level_6_employee_login = 'amandam' AND event_status != 'Did Not Occur'
  
)

SELECT DISTINCT  
CASE 
     WHEN DATEDIFF(d, event_start_dt, TRUNC(sysdate)) > 2 AND interviewer_feedback_dt IS NULL AND event_type = 'Phone Screen' THEN 'Y' 
     WHEN DATEDIFF(d, event_start_dt, interviewer_feedback_dt) > 2 AND interviewer_feedback_dt IS NOT NULL AND event_type = 'Phone Screen' THEN 'Y'
     ELSE 'N' 
 END AS PROMISE_BROKEN_PS
 
,CASE 
     WHEN DATEDIFF(d, event_start_dt, TRUNC(sysdate)) > 5 AND interviewer_feedback_dt IS NULL AND event_type = 'On-site' THEN 'Y'
     WHEN DATEDIFF(d, event_start_dt, interviewer_feedback_dt) > 5 AND interviewer_feedback_dt IS NOT NULL AND event_type = 'On-site' THEN 'Y'
     ELSE 'N' 
 END AS PROMISE_BROKEN_OS
 
,dp.*

FROM dataprep dp

WHERE reporting_week_of_year = 22 AND (promise_broken_ps = 'Y' OR promise_broken_os = 'Y') AND job_id = 746452 and candidate_id = 5162862
AND NOT EXISTS (select 1 
         from dataprep a
         where dp.job_id = a.job_id and
               dp.candidate_id = a.candidate_id and
               a.interviewer_feedback_dt >= dp.interviewer_feedback_dt)


--WHERE reporting_week_of_year = 22 AND (promise_broken_ps = 'Y' OR promise_broken_os = 'Y') AND job_id = 746452 and candidate_id = 5162862
