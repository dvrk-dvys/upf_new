WITH X AS (
    SELECT DISTINCT
    --S.candidate_id 
    LOWER(S.email_address) AS email_address
    --,vatmpnr_percentile_score
    --,s.time_stamp
    --,pl.enter_state_time
    --,pl.*
    ,MAX(s.vatmpnr_percentile_score) AS vatmpnr_percentile_score
    --,pl.person_job_id
    FROM opsdw.shl_scores s
    INNER JOIN masterhr.candidate c ON lower(s.email_address) = lower(c.email_address)
    INNER JOIN ops_insearch.pipeline pl ON pl.person_id = c.candidate_icims_id AND is_internal = 'true' AND TRUNC(s.time_stamp) <= TRUNC(PL.enter_state_time) AND is_latest_step = 'true'    
    
    WHERE 1=1
    AND DATEPART(YEAR, time_stamp) in (2019, 2020)
    AND time_stamp < '2020-04-01 00:00:00'
    AND (concat_steps LIKE '%REJECTION%'
        AND concat_steps LIKE '%ASSESSMENT%'
        AND pl.concat_steps NOT LIKE '%OFFER%')
    and (pl.concat_steps LIKE '%OFFER%'
        AND concat_steps LIKE '%ASSESSMENT%')
    GROUP BY
    --S.candidate_id 
    lower(S.email_address)
    --,s.time_stamp
    --,pl.enter_state_time
    --,pl.person_job_id
    
)

SELECT DISTINCT

shl.*

FROM opsdw.shl_scores SHL
INNER JOIN X ON lower(shl.email_address) = lower(X.email_address) AND X.vatmpnr_percentile_score = SHL.vatmpnr_percentile_score
INNER JOIN masterhr.candidate c ON lower(shl.email_address) = lower(c.email_address)
INNER JOIN masterhr.employee_hc HC ON c.candidate_employee_id = hc.emplid AND job_level_name = 4 AND job_title_name = 'Manager I, Operations' AND job_code = 'P03171'
INNER JOIN ops_insearch.pipeline pl ON pl.person_id = c.candidate_icims_id AND is_internal = 'true' --AND is_latest_step = 'true'    
WHERE 1=1

AND DATEPART(YEAR, time_stamp) in (2019, 2020)
AND time_stamp < '2020-04-01 00:00:00'
    OR (pl.concat_steps LIKE '%OFFER%'
        AND concat_steps LIKE '%ASSESSMENT%')

