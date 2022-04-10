SELECT shl.forename,
shl.surname,
shl.email_address,
time_stamp,
vatmpnr_sten_score,
vatmpnr_percentile_score,
hc.candidate_id,
hc.candidate_icims_id,
oa.internal_job_title,
oa.building,
job_title,
job_classification_title


FROM opsdw.shl_scores_2019 shl
LEFT JOIN masterhr.candidate hc ON LOWER(hc.email_address) = LOWER(shl.email_address) AND (shl.time_stamp between hc.snapshot_begin_timestamp and hc.snapshot_end_timestamp)
INNER JOIN masterhr.offer_accepts oa ON hc.candidate_icims_id = oa.candidate_icims_id

WHERE 1=1
AND oa.building = 'LCY2'
AND job_level = 4
AND job_code = 'P03211'
