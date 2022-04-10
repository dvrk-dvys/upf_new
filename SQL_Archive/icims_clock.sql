SELECT DISTINCT 
*,
convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(icims_updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp))
        
FROM ads.worksteps
where 1=1
--AND  LOWER(status) LIKE '%attempt%'
--group by status
--and cand_icims_id = 9278233
--AND job_amzr_req_id = 1048176

AND person_id = 9278233
AND job_id =1048176
--person_id

