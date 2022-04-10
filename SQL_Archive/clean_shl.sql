WITH X AS(

    SELECT 
    EMAIL
    ,MAX(s.vatmpnr_percentile_score) AS vatmpnr_percentile_score
    FROM ads.shl s
    GROUP BY
    EMAIL

)


SELECT DISTINCT

candidate_icims_id AS SystemID
--,shl.email
,LTRIM(CAST(extract(MONTH from shl.time_stamp) AS varchar)) + '/' + LTRIM(CAST(extract(DAY from shl.time_stamp) AS varchar)) + '/' + CAST(extract(year from shl.time_stamp) AS varchar) AS rcf2702
,shl.vatmpnr_percentile_score AS rcf2700

FROM ads.shl SHL
INNER JOIN masterhr.candidate c ON lower(shl.email) = lower(c.email_address)
INNER JOIN X ON lower(shl.email) = lower(X.email) AND X.vatmpnr_percentile_score = SHL.vatmpnr_percentile_score

WHERE 1=1
--AND candidate_icims_id = 25787677
--and source_status IN ('Candidate - Interview Process - Move candidate to Amazon Hire (HM review)', 'Candidate - Interview Process - Assessment Complete', 'Rejected - Rejected Applicant', 'Rejected - Rejected Candidate')
