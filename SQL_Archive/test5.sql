SELECT 

    ia.job_icims_id,
    ia.candidate_icims_id,
    ia.job_icims_id || ia.candidate_icims_id AS concat_job_cand,
    ia.hire_type,
    r.department_id,
    r.job_classification_title AS job_code,
    r.recruiter_employee_full_name,
    event_start_dt,
    outcome_vote,
    event_type,
    work_step,
    event_status,
    event_role,
    outcome_submitter_employee_login,
    outcome_feedback_dt,
    interviewer_employee_full_name,
    interviewer_vote,
    interview_completed_dt,
    ia.interview_summary_guid,
    inclined_vote_ct,
    not_inclined_vote_ct
     
FROM masterhr.interview_activity ia
--INNER JOIN unanimous u ON u.interview_summary_guid = ia.interview_summary_guid
INNER JOIN (SELECT *
            FROM (SELECT *,
                        RANK() OVER (PARTITION BY job_icims_id ORDER BY snapshot_end_timestamp DESC) AS rnk
                  FROM masterhr.requisition)
            WHERE rnk = 1
            AND country IN ('USA', 'CAN')) r ON ia.job_icims_id = r.job_icims_id
LEFT JOIN ads.applicants metadata ON ia.candidate_icims_id = metadata.icims_id  


WHERE 1 = 1

AND ia.hire_type NOT IN ('Campus Intern','Campus Fte')
AND ia.event_type = 'On-site'
AND ia.event_start_dt BETWEEN '2016-01-01' AND '2019-03-01'
AND ia.work_step = 'Interview Event'
AND ia.event_status = 'Occurred'
AND r.job_classification_title IN ('Manager I, Operations', 'Manager II, Operations', 'Manager III, Operations')
AND event_role != 'SHADOW'
AND applicant_type = 'EXTERNAL'
--AND r.recruiter_reports_to_level_4_employee_login = 'kelleyse'
--AND interviewer_vote <> ''
AND outcome_vote <> ''   
AND interview_summary_guid = '91236c9b-58d8-4d89-b967-1413dfb9ed0b'   

GROUP BY   ia.job_icims_id,
    ia.candidate_icims_id,
    ia.job_icims_id || ia.candidate_icims_id,
    ia.hire_type,
    r.department_id,
    r.job_classification_title,
    r.recruiter_employee_full_name,
    event_start_dt,
    outcome_vote,
    event_type,
    event_role,
    work_step,
    event_status,
    outcome_submitter_employee_login,
    outcome_feedback_dt,
    interviewer_employee_full_name,
    interviewer_vote,
    interview_completed_dt,
    ia.interview_summary_guid,
    interview_summary_guid,
    inclined_vote_ct,
    not_inclined_vote_ct
