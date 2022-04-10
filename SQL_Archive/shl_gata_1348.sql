WITH snapshots AS (
SELECT DISTINCT
    emplid
    ,job_candidate_icims_id
    ,MAX(event_date) as max_date

FROM masterhr.employee_hc

GROUP BY
emplid
,job_candidate_icims_id
)



SELECT DISTINCT
c.candidate_employee_id,
hc.employee_full_name,
shl.forename,
shl.surname,
shl.email_address,
shl.candidate_id,
time_stamp,
vatmpnr_sten_score,
vatmpnr_percentile_score,
c.candidate_icims_id,
hc.location_building_name,
hc.location_country_name,
hc.department_ofa_cost_center_code,
hc.job_level_name as final_job_level_name,
hc.job_title_name as final_job_title_name,
ep.prior_job_level_name,
ep.prior_job_title_name,
ep.post_job_level_name,
ep.post_job_title_name,
hc.reports_to_level_4_employee_login,
hc.reports_to_level_5_employee_login

FROM opsdw.shl_scores shl
INNER JOIN masterhr.candidate c ON LOWER(c.email_address) = LOWER(shl.email_address) AND (shl.time_stamp between c.snapshot_begin_timestamp and c.snapshot_end_timestamp)
left JOIN snapshots s ON s.emplid = c.candidate_employee_id or s.job_candidate_icims_id = c.candidate_icims_id
LEFT JOIN masterhr.employee_hc hc ON s.emplid = c.candidate_employee_id and hc.job_candidate_icims_id = c.candidate_icims_id and hc.event_date = s.max_date
LEFT JOIN masterhr.employee_promotions ep on  hc.emplid = ep.emplid



WHERE 1=1

and( hc.reports_to_level_4_employee_login = 'roypert'
or hc.reports_to_level_5_employee_login = 'roypert')
--AND hc.job_level_name = 3

--AND hc.job_code = 'P03231'
AND ep.prior_job_code = 'P03231'
AND ep.prior_job_level_name = 3
AND ep.post_job_level_name = 4
AND ep.post_job_code = 'P03171'
AND DATEPART(year, time_stamp) = '2018'

