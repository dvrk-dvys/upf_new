select 
full_name,
candidate_id,
empl_id,
application_date,
icims_id,
ofr_extndd_dt,
step,
ofr_accepted_dt,
loc_cty_nm,
loc_bldg_cd,
business_title,
external_job_title,
hrng_mngr_reports_to_level3_login, 
co_nm, 
req_dept_nm, 
job_function_desc,
job_type, 
req_job_level, 
rgltry_rgn_cd,
email_address,
job_title, 
job_level,
loc_nm,
reports_to_level3_login, 
reports_to_suprvsr_login, 
dept_nm, 
interview_date, 
recruiter_login,
recruiter_nm,
Business_Lane, 
team_flag, 
intrvw_summary_id,
rnum


from opstadw.ops_insearch.irhmd_email
WHERE 1=1
and status = 'New'
