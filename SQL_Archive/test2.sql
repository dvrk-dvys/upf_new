WITH TEST AS (

SELECT  
interview_summary_guid, 
interviewer_vote, 
outcome_vote,
interviewer_employee_full_name,
CASE WHEN interviewer_vote IN ('INCLINED','STRONG_HIRE') THEN 'INCLINED'
     WHEN interviewer_vote IN ('NOT_INCLINED','STRONG_NO_HIRE') THEN 'NOT_INCLINED' END AS processed_vote



FROM masterhr.interview_activity ia
INNER JOIN (SELECT *
            FROM (SELECT *,
                        RANK() OVER (PARTITION BY job_icims_id ORDER BY snapshot_end_timestamp DESC) AS rnk
                  FROM masterhr.requisition)
            WHERE rnk = 1
            AND country IN ('USA', 'CAN')) r ON ia.job_icims_id = r.job_icims_id
LEFT JOIN ads.applicants metadata ON ia.candidate_icims_id = metadata.icims_id            

WHERE 1=1
AND ia.hire_type NOT IN ('Campus Intern','Campus Fte')
AND ia.event_type = 'On-site'
AND ia.event_start_dt BETWEEN '2016-01-01' AND '2019-03-01'
AND ia.work_step = 'Interview Event'
AND ia.event_status = 'Occurred'
AND r.job_classification_title IN ('Manager I, Operations', 'Manager II, Operations', 'Manager III, Operations')
AND event_role != 'SHADOW'
AND applicant_type = 'EXTERNAL'
AND outcome_vote = 'NOT_INCLINED'
GROUP BY  interview_summary_guid, outcome_vote, processed_vote, interviewer_vote, interviewer_employee_full_name

)

SELECT interview_summary_guid, interviewer_employee_full_name, outcome_vote, processed_vote, interviewer_vote, COUNT(interview_summary_guid)
FROM TEST 
GROUP BY  interview_summary_guid, outcome_vote, processed_vote, interviewer_vote, interviewer_employee_full_name
--HAVING COUNT(interview_summary_guid) > 1
