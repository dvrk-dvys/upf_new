SELECT DISTINCT
pl.person_job_id,
pl.person_id,
pl.job_id,
activity.requisition_region,
activity.country,
pl.step,
pl.source_status,
pl.enter_state_time,
pl.source,
pl.is_latest_step,
pl.is_mapped,
pl.is_internal,
pl.is_recyclable,
pl.concat_steps


FROM ops_insearch.pipeline pl
INNER JOIN masterhr.recruiting_activity activity ON pl.person_id = activity.candidate_icims_id AND  pl.job_id = activity.job_icims_id

WHERE 1=1
AND activity.candidate_type = 'EXTERNAL'
AND activity.requisition_region = 'EMEA' 
AND activity.country != 'DEU'
AND( job_level >= 4 and job_level <= 8)
AND DATEPART(year, pl.enter_state_time) IN (2019)
AND pl.step = 'PHONE_SCREEN_2'
AND pl.concat_steps LIKE '%PHONE_SCREEN_2%' 


--HIRING MANAGER or proxy (non recruiting role) PARTICIPATING A (2ND) PHONE SCREEN 
--first screen immediately followed by a rejection removed from the origianl data
--remove 2018 was a nice to have 
