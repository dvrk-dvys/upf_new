WITH max_req AS (
      
        SELECT 
        job_icims_id,
        MAX(updated_date) AS updated_date
        --job_level,
        --job_classification_title    
        FROM masterhr.requisition reqs
        GROUP BY 
        job_icims_id
        --job_level,
        --job_classification_title
        
),


 REQS AS(
      
        SELECT 
        reqs.job_icims_id,
        max_req.updated_date,
        reqs.job_level,
        reqs.job_classification_title,
        reqs.ofa_cost_center_code   
        FROM masterhr.requisition reqs
        INNER JOIN max_req ON reqs.job_icims_id = max_req.job_icims_id AND reqs.updated_date = max_req.updated_date
        
) 


SELECT DISTINCT 
--ra.job_id,
ra.job_icims_id,
ra.candidate_icims_id,
ra.candidate_employee_id,
ra.candidate_type,
ra.current_funnel_state,
ps.candidate_start_date,

reqs.job_level AS req_job_level,
reqs.job_classification_title AS req_job_title,

ra.job_code AS new_job_code,
hc.job_code AS current_job_code,


hc.company_country_code,
ra.department_id,

hc.department_ofa_cost_center_code AS old_cost_center,
reqs.ofa_cost_center_code AS new_cost_center,

hc.employee_status,
hc.job_level_name,
hc.employee_login,
hc.employee_display_name,
hc.employee_internal_email_address,
pl.person_job_id,
pl.person_id,
pl.job_id,
pl.step,
pl.source_status,
pl.enter_state_time,
pl.source,
pl.is_latest_step,
pl.is_mapped,
pl.is_internal,
pl.is_recyclable,
pl.concat_steps,

CASE WHEN ra.current_recruiter_employee_full_name IS NULL THEN ra.recruiter_employee_full_name
     ELSE ra.current_recruiter_employee_full_name END AS recruiter_full_name,
CASE WHEN ra.current_sourcer_employee_full_name IS NULL THEN ra.sourcer_employee_full_name
     ELSE ra.current_sourcer_employee_full_name END AS sourcer_full_name,
     
hc.reports_to_supervisor_employee_name as recruiter_reports_to_supervisor_employee_name,

ra.sourcer_reports_to_supervisor_employee_login,
ra.sourcer_reports_to_supervisor_employee_name,


hc.reports_to_level_1_employee_login,
hc.reports_to_level_2_employee_login,
hc.reports_to_level_3_employee_login,
hc.reports_to_level_4_employee_login,
hc.reports_to_level_5_employee_login,
hc.reports_to_level_6_employee_login,
hc.reports_to_level_7_employee_login,
hc.reports_to_level_8_employee_login,
hc.reports_to_level_9_employee_login,
hc.reports_to_level_10_employee_login

FROM masterhr.recruiting_activity ra
INNER JOIN masterhr.employee_hc_current hc ON hc.emplid = ra.candidate_employee_id
INNER JOIN ops_insearch.pipeline pl ON pl.person_id = ra.candidate_icims_id AND  pl.job_id = ra.job_icims_id
LEFT JOIN reqs ON reqs.job_icims_id = ra.job_icims_id
LEFT JOIN masterhr.offer_accepts offer on pl.job_id = offer.job_icims_id and pl.person_id = offer.candidate_icims_id 
LEFT JOIN masterhr.employee_pending_starts ps ON ra.candidate_icims_id = ps.candidate_icims_id AND ra.job_icims_id = ps.job_icims_id
LEFT JOIN masterhr.employee_hc_current hc2 ON hc2.employee_login = ra.sourcer_reports_to_supervisor_employee_login

WHERE 1=1
AND ra.candidate_type = 'INTERNAL'
AND current_funnel_state NOT IN  ('Rejection Confirmed', 'Employee Starts', 'Offer Declined', 'Offer Canceled', 'Offer Rescinded', 'Offer Expired')
AND hc.reports_to_level_4_employee_login = 'rgansert'
AND hc.department_ofa_cost_center_code IN ('1262','1005','1062','1213','1264','1203','1299010','1299030','1234','1299040','1031','5617','1192','1012','1004','1299070',
'1290','1204','1167','1214','1061','1060','1064','1058','1201','1008','1299','1067','1147','1063','1701', '1043','1235','1194','5624','1126','1017','1242','1014')
AND ra.department_id NOT IN ('1262','1005','1062','1213','1264','1203','1299010','1299030','1234','1299040','1031','5617','1192','1012','1004','1299070',
'1290','1204','1167','1214','1061','1060','1064','1058','1201','1008','1299','1067','1147','1063','1701', '1043','1235','1194','5624','1126','1017','1242','1014')
AND datepart(year, pl.enter_state_time) IN (2019, 2020)
AND ra.current_transaction_flag = 'Y'
AND is_latest_step = 'true'
