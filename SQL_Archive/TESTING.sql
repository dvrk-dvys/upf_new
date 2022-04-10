  SELECT interviewer_employee_id, interviewer_employee_login, event_role, event_type, job_id, candidate_id, event_finish, event_status, interview_summary_guid
  FROM masterhr.interview_activity
  WHERE 1=1
  AND event_type IN ('Phone Screen', 'On-site')
  AND event_status != 'Did Not Occur'
