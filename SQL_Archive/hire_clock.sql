SELECT
cand_icims_id,
job_amzr_req_id,
candidate_name,
step,
enter_state_time,
contact_attempts,
first_contact_attempt_date,
*

FROM hrmetrics.art_full
WHERE 1=1
and cand_icims_id = 9278233
AND job_amzr_req_id = 1048176
--AND candidate_icims_id = 9278233
--AND icims_id = 1048176

