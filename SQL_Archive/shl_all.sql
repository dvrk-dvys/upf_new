WITH X AS(

    SELECT 
    LOWER(email_address) AS email_address
    ,MAX(s.vatmpnr_percentile_score) AS vatmpnr_percentile_score
    FROM opsdw.shl_scores s
    GROUP BY
    LOWER(email_address)

)


SELECT DISTINCT

shl.*
,hc.job_title_name
,hc.job_code
--,hc.employee_business_title
,c.candidate_icims_id
,c.candidate_employee_id
,PL.*
,LEFT(concat_steps,LEN(concat_steps)-CHARINDEX('|',concat_steps))



FROM opsdw.shl_scores SHL
INNER JOIN masterhr.candidate c ON lower(shl.email_address) = lower(c.email_address)
INNER JOIN X ON lower(shl.email_address) = lower(X.email_address) AND X.vatmpnr_percentile_score = SHL.vatmpnr_percentile_score
INNER JOIN masterhr.employee_hc HC ON c.candidate_employee_id = hc.emplid AND job_level_name = 4 AND job_title_name = 'Manager I, Operations' AND job_code = 'P03171'
INNER JOIN ops_insearch.pipeline pl ON pl.person_id = c.candidate_icims_id AND is_internal = 'true' AND is_latest_step = 'true' AND SHL.time_stamp < PL.enter_state_time  
            --AND source_status IN ('Candidate - Interview Process - Assessment Complete') 
            --AND source_status IN ('Candidate - Interview Process - Move candidate to Amazon Hire (HM review)', 'Candidate - Interview Process - Assessment Complete', 'Rejected - Rejected Applicant', 'Rejected - Rejected Candidate') 

WHERE 1=1
--AND DATEPART(YEAR, PL.enter_state_time) in (2019, 2020)
AND DATEPART(YEAR, time_stamp) in (2019, 2020)
AND time_stamp < '2020-04-01 00:00:00'
