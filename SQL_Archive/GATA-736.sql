SELECT ia.job_icims_id,
ia.candidate_icims_id,
ia.job_icims_id || ia.candidate_icims_id AS concat_job_cand,
ia.hire_type,
r.department_id,
r.job_classification_title AS job_code,
r.recruiter_employee_full_name,
event_start_dt,
interviewer_vote,
interviewer_employee_full_name,
interviewer_feedback_time,
outcome_vote,
CASE
WHEN interviewer_vote IN ('INCLINED','STRONG_HIRE') THEN concat_job_cand
END AS inclined,
CASE
WHEN interviewer_vote IN ('NOT_INCLINED','STRONG_NO_HIRE') THEN concat_job_cand
END AS not_inclined,
inclined_vote_ct,
not_inclined_vote_ct,
inclined_result_ct,
not_inclined_result_ct,
CASE
WHEN r.recruiter_reports_to_level_5_employee_login = 'chaluleu' THEN 'Luli'
WHEN r.recruiter_reports_to_level_4_employee_login = 'kelleyse' THEN 'Sean'
ELSE 'Other'
END AS org
FROM masterhr.interview_activity ia
INNER JOIN (SELECT *
FROM (SELECT RANK() OVER (PARTITION BY job_icims_id ORDER BY snapshot_end_timestamp DESC) AS rnk,
*
FROM masterhr.requisition)
WHERE rnk = 1
AND country = 'USA') r ON ia.job_icims_id = r.job_icims_id
WHERE 1 = 1
AND ia.hire_type NOT IN ('Campus Intern','Campus Fte')
AND ia.event_type = 'On-site'
AND ia.event_start_dt >= '2019-01-01'
AND ia.work_step = 'Interview Event'
AND ia.event_status = 'Occurred'
AND r.job_classification_title IN ('Manager III, Operations', 'Manager II, Operations')
AND applicant_type = 'EXTERNAL'
--AND r.recruiter_reports_to_level_4_employee_login = 'kelleyse'
--AND interviewer_vote <> ''
AND outcome_vote <> ''
ORDER BY 1,
2,
12
