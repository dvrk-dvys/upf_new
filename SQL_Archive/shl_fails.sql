WITH X AS(



    SELECT DISTINCT
    LOWER(S.email_address) AS email_address
    ,MAX(s.vatmpnr_percentile_score) AS vatmpnr_percentile_score
    FROM opsdw.shl_scores s
    INNER JOIN masterhr.candidate c ON lower(s.email_address) = lower(c.email_address)
    INNER JOIN ops_insearch.pipeline pl ON pl.person_id = c.candidate_icims_id AND is_internal = 'true' AND TRUNC(s.time_stamp) <= TRUNC(PL.enter_state_time)  
    
    WHERE 1=1
    AND DATEPART(YEAR, time_stamp) in (2019, 2020)
    AND time_stamp < '2020-04-01 00:00:00'
    AND is_internal = 'true'
    AND is_latest_step = 'true'
--    AND (( concat_steps LIKE '%REJECTION%'
--          AND concat_steps LIKE '%ASSESSMENT%'
 --         AND pl.concat_steps NOT LIKE '%OFFER%')       
--         OR ( pl.concat_steps LIKE '%OFFER%'
             --AND concat_steps LIKE '%ASSESSMENT%'
 --            AND pl.concat_steps NOT LIKE '%REJECTION%'))
    
    
    --    ~Rejections~   --
AND pl.concat_steps LIKE '%REJECTION%'
AND pl.concat_steps LIKE '%ASSESSMENT%'
AND pl.concat_steps NOT LIKE '%OFFER%'

--    ~Pass~    --
--AND pl.concat_steps LIKE '%OFFER%'
--AND pl.concat_steps LIKE '%ASSESSMENT%'
--AND pl.concat_steps NOT LIKE '%REJECTION%'
      

    GROUP BY
    lower(S.email_address)

)


SELECT DISTINCT

shl.forename
,shl.surname
,shl.email_address
,shl.time_stamp
,shl.vatmpnr_percentile_score
,reqs.job_classification_title AS req_job_title
,reqs.job_code
,reqs.job_level
--,hc.employee_business_title
,c.candidate_icims_id
,c.candidate_employee_id
,PL.*



FROM opsdw.shl_scores SHL
INNER JOIN X ON lower(shl.email_address) = lower(X.email_address) AND X.vatmpnr_percentile_score = SHL.vatmpnr_percentile_score
INNER JOIN masterhr.candidate c ON lower(shl.email_address) = lower(c.email_address)
INNER JOIN masterhr.employee_hc HC ON c.candidate_employee_id = hc.emplid --AND job_level_name = 4 AND job_title_name = 'Manager I, Operations' AND job_code = 'P03171'
INNER JOIN ops_insearch.pipeline pl ON pl.person_id = c.candidate_icims_id AND is_latest_step = 'true' AND is_internal = 'true' 
INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = pl.job_id AND reqs.job_level = 4 AND reqs.job_classification_title = 'Manager I, Operations' AND reqs.job_code = 'P03171'




WHERE 1=1
AND reqs.job_level = 4 
AND reqs.job_classification_title = 'Manager I, Operations' 
AND reqs.job_code = 'P03171'

--AND DATEPART(YEAR, PL.enter_state_time) in (2019, 2020)
AND DATEPART(YEAR, shl.time_stamp) in (2019, 2020)
AND shl.time_stamp < '2020-04-01 00:00:00'
--    ~Rejections~   --
AND pl.concat_steps LIKE '%REJECTION%'
AND pl.concat_steps LIKE '%ASSESSMENT%'
AND pl.concat_steps NOT LIKE '%OFFER%'

--    ~Pass~    --
--AND pl.concat_steps LIKE '%OFFER%'
--AND pl.concat_steps LIKE '%ASSESSMENT%'
--AND pl.concat_steps NOT LIKE '%REJECTION%'


-- all --

--    AND (( concat_steps LIKE '%REJECTION%'
--          AND concat_steps LIKE '%ASSESSMENT%'
 --         AND pl.concat_steps NOT LIKE '%OFFER%')       
 --        OR (  pl.concat_steps LIKE '%OFFER%'
--             AND concat_steps LIKE '%ASSESSMENT%'
 --            AND pl.concat_steps NOT LIKE '%REJECTION%'))
    


