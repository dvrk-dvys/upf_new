SELECT DISTINCT 
PL.*

FROM OPS_INSEARCH.PIPELINE PL
INNER JOIN masterhr.candidate c ON c.candidate_icims_id = pl.person_id
INNER JOIN masterhr.employee_hc HC ON c.candidate_employee_id = hc.emplid AND job_level_name = 4 AND job_title_name = 'Manager I, Operations' AND job_code = 'P03171'
INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = pl.job_id AND reqs.job_level = 4 AND reqs.job_classification_title = 'Manager I, Operations' AND reqs.job_code = 'P03171'

WHERE 1=1
--AND source_status IN ('Candidate - Interview Process - Assessment Complete') 
--and source_status IN ('Candidate - Interview Process - Move candidate to Amazon Hire (HM review)', 'Candidate - Interview Process - Assessment Complete', 'Rejected - Rejected Applicant', 'Rejected - Rejected Candidate')
AND is_internal = 'true'
AND DATEPART(YEAR, pl.enter_state_time) in (2019, 2020)
AND is_latest_step = 'true'
    AND (( concat_steps LIKE '%REJECTION%'
          AND concat_steps LIKE '%ASSESSMENT%'
          AND pl.concat_steps NOT LIKE '%OFFER%')       
         OR (  pl.concat_steps LIKE '%OFFER%'
             AND concat_steps LIKE '%ASSESSMENT%'
             AND pl.concat_steps NOT LIKE '%REJECTION%'))

--AND person_job_id = '10138282_564354'
