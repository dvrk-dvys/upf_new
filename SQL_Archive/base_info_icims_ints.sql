SELECT 
icims_id,
 person_id,
status,
cast((TIMESTAMP 'epoch' + CAST(updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ') as date) AS updated_date,
cast((TIMESTAMP 'epoch' + CAST(icims_created_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ')as date) AS icims_created_timestamp

FROM ads.worksteps
WHERE 1=1
--hired
AND icims_id = 55537713
AND person_id = 672828
--rejected
--AND icims_id = 54034017
--AND person_id = 5553271

--AND status = 'Candidate - Interview Process - Phone Screen Pending'
AND cast((TIMESTAMP 'epoch' + CAST(icims_created_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ')as date) >= '2019-01-01'

--GROUP BY
-- icims_id,
-- status,
-- updated_timestamp
