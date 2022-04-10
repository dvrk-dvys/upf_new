with a as
(
SELECT 
job_amzr_req_id
,recruiter_name
,recruiter_id

FROM hrmetrics.art_jobs
WHERE job_amzr_req_id NOT LIKE ''
AND   req_status <> 'ELIMINATED'
AND recruiter_id IN  (SELECT employee_id
                      FROM hrmetrics.or_employee_hier_hist
                      WHERE supervisor_login_name IN ('amandam', 'mjwheble', 'cathlinh', 'chilverr', 'cndale')
                      AND   is_active_record = 'Y'
                      AND   is_employed = 'Y'
                      GROUP BY 1
                      )
)

SELECT 
c.person_id,
c.job_id,
updated_date,
c.status,
c.outside_sla,
a.recruiter_name
,a.recruiter_id
,datediff (day,TRUNC(updated_date),sysdate) as dwell
,ca.full_name
,aj.req_status
,apps.is_internal
,CASE 
  WHEN apps.is_internal = TRUE and apps.country = apps.app_date_country AND apps.app_date_country IS NOT NULL THEN 'N'
  WHEN apps.is_internal = TRUE and apps.country <> apps.app_date_country AND apps.app_date_country IS NOT NULL THEN 'Y'
  ELSE 'EXT'
  END AS is_cross_country

FROM hrmetrics.rds_current_pipeline c

INNER JOIN a a 
ON a.job_amzr_req_id = c.job_id

Inner join hrmetrics.dynamo_applicants ca
ON c.person_id = ca.icims_id 
and ca.full_name IS NOT NULL
LEFT JOIN hrmetrics.art_jobs aj ON job_id = aj.job_amzr_req_id
LEFT JOIN hrmetrics.applications AS apps ON c.job_id = apps.job_id AND c.person_id = apps.person_id 

Where

c.status IN
('SCHEDULE_DEBRIEF',
'PREBRIEF_SCHEDULED',
'Candidate - Interview Process - Flyback',
'Candidate - Interview Process - Testing',
'Candidate - Interview Process - Schedule Flyback',
'Candidate - Interview Process - Schedule 2nd Phone Screen',
'Candidate - Interview Process - CSM - L4/5 ? SJO',
'Candidate - Interview Process - Schedule Event Interview',
'Internal Transfer - Offer Confirmed',
'Candidate - Interview Process - Exec Assistant Assessment - ACAEA2',
'Candidate - Interview Process - Schedule Campus Interview',
'Candidate - Interview Process - Executive Assistant Assessment - ACAEA1',
'Candidate - Interview Process - Intern Hiring Meeting',
'Candidate - Offer - Requested',
'SCHEDULE_EVALUATION',
'SCHEDULE_INFORMATIONAL',
'IN_HOUSE_SCHEDULED',
'Candidate - Interview Process - ER_Sourced_SeSu_India Assessment',
'Candidate - Offer - Approved',
'SCHEDULE_PREBRIEF',
'SCHEDULE_IN_HOUSE',
'Candidate - Interview Process - On Hold',
'Candidate - Interview Process - Schedule Video Screen',
'Candidate - Interview Process - Assessment Complete',
'Candidate - Interview Process - NAFC-AM1 Assessment',
'Candidate - Interview Process - Phone Screen Pending',
'PHONE_SCREEN_BLOCKED',
'Candidate - Interview Process - CSM ? L4/5 ? USA Assessment',
'Candidate - Interview Process - Phone Screen',
'Candidate - Offer - Background/Reference Check Initiated',
'IH_TOOK_PLACE',
'PS_TOOK_PLACE',
'PHONE_SCREEN_SCHEDULED',
'Candidate - Interview Process - Interview Pending',
'Candidate - Interview Process - Amazon Recruiter Assessment ? ACARA1',
'Candidate - Interview Process - Video Screen',
'Candidate - Interview Process - Interview',
'Candidate - Interview Process - On-Campus Interview',
'Candidate - Interview Process - Initiate Assessment',
'Candidate - Interview Process - HS3C ? L2/3 ? Rom Assessment',
'Candidate - Interview Process - Debrief',
'EVALUATION_SCHEDULED',
'Candidate - Interview Process - Phone Screen Complete - HM Action Required',
'ONGOING_AUTO_EVALUATION',
'IN_HOUSE_BLOCKED',
'Candidate - Interview Process - Retail VJT-CA Battery Assessment',
'Candidate - Interview Process - 2nd Phone Screen Pending',
'Candidate - Interview Process - Schedule Phone Screen',
'Candidate - Interview Process - ER_Sourced_SeSu_NA Assessment',
'Candidate - Interview Process - ER_Sourced_TRMS_EU',
'Candidate - Offer - Extended',
'OFFER_CREATED',
'Candidate - Interview Process - Schedule Assessment Center',
'Candidate - Interview Process - Review Work Sample',
'Candidate - Interview Process - ER_Sourced_TRMS_NA Assessment',
'Internal Transfer - Offer Sent',
'Internal Transfer - Immigration Check',
'Candidate - Interview Process - Administrative Detail Orientation - ACAADO1',
'Candidate - Interview Process - MBA OA FT ? EU Assessment',
'Candidate - Interview Process - Schedule Interview',
'SCHEDULE_PHONE_SCREEN',
'DEBRIEF_SCHEDULED',
'Candidate - Interview Process - Amazon Writing Exercise - ACAWE1',
'Candidate - Offer - Cancelled',
'Internal Transfer - Prepare Offer',
'Internal Transfer - Offer Confirmation Request',
'Candidate - Offer - Background Check In-Progress'
)

AND a.recruiter_name <> 'Georgina Yellowlees'
