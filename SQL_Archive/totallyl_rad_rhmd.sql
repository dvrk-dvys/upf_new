SELECT 

  interview_summary_id
	,	icims_id
	,	candidate_icims_id
	,	interview_date
	,	candidate_first_name 
  ,	candidate_last_name
  , candidate_data_source
  ,	survey_start_date
	,	survey_end_date
	,	survey_status
  ,	candidate_type
  , survey_question
  , survey_dropout_question  
  ,	MAX(CASE WHEN survey_id IN(9,19) THEN survey_response_num ELSE CAST(NULL AS INTEGER) END) os_Q1
	,	MAX(CASE WHEN survey_id = 20 THEN survey_response_num ELSE CAST(NULL AS INTEGER) END) os_Q2
	,	MAX(CASE WHEN survey_id = 21 THEN survey_response_num ELSE CAST(NULL AS INTEGER) END) os_Q3
	,	MAX(CASE WHEN survey_id = 22 THEN survey_response_num ELSE CAST(NULL AS INTEGER) END) os_Q4
	,	MAX(CASE WHEN survey_id = 23 THEN survey_response_num ELSE CAST(NULL AS INTEGER) END) os_Q5
	,	MAX(CASE WHEN survey_id = 24 THEN survey_response     ELSE NULL                  END) os_Q5a
	,	MAX(CASE WHEN survey_id = 25 THEN survey_response     ELSE NULL                  END) os_Q5b
	,	MAX(CASE WHEN survey_id = 26 THEN survey_response_num ELSE CAST(NULL AS INTEGER) END) os_Q6
	,	MAX(CASE WHEN survey_id = 27 THEN survey_response     ELSE NULL                  END) os_Q6a
	,	MAX(CASE WHEN survey_id = 28 THEN survey_response     ELSE NULL                  END) os_Q6b
	,	MAX(CASE WHEN survey_id = 29 THEN survey_response ELSE NULL                END) os_Q7
	,	MAX(CASE WHEN survey_id IN (16,30) THEN survey_response ELSE NULL                END) os_Q7a
	,	MAX(CASE WHEN survey_id IN (17,31) THEN survey_response ELSE NULL                END) os_Q8
	,	MAX(CASE WHEN survey_id IN (18,32) THEN survey_response ELSE NULL                END) os_Q9
	,	MAX(CASE WHEN survey_id IN (33,42) THEN survey_response_num ELSE CAST(NULL AS INTEGER) END) ps_Q1
	,	MAX(CASE WHEN survey_id = 43 THEN survey_response       ELSE NULL                END) ps_Q1a
	,	MAX(CASE WHEN survey_id IN (41,44) THEN survey_response ELSE NULL                END) ps_Q1b
  ,	MAX(CASE WHEN ff = 'Y' AND survey_response_num > 3 THEN 'POSITIVE'
			     WHEN ff = 'Y' AND survey_response_num = 3 THEN 'PASSIVE'
			     WHEN ff = 'Y' AND survey_response_num < 3 THEN 'NEGATIVE'
			     ELSE NULL 
			     END) RESPONSE_SCORE
	,	MAX(CASE WHEN ff = 'Y' THEN survey_response_num 
			     ELSE CAST(NULL AS INTEGER) 
			     END) Frustration_Free
	,	SUM(sent_ct) sent_ct
	,	SUM(response_ct) response_ct
	,	SUM(response_pos_ct) response_pos_ct
	,	SUM(response_neg_ct) response_neg_ct
	,	candidate_src_category
	,	hire_link
	,	hire_type
	,	job_code
	,	job_title_int
	,	job_title_ext
	,	job_level
	,	position_type
	,	flsa
	,	req_status
	,	busn_unit_cd
	,	busn_unit_nm
	,	job_family
	,	rc_group
	,	rc_owner
	,	rc_owner_id
	,	rc_owner_mgr_id
	,	employee_class
	,	reg_region_name
	,	reg_region_cd
	,	location_region
	,	location_country
	,	location_state
	,	location_city
	,	recruiting_org
	,	recruiting_sub_org
	,	cost_center
	,	cost_center_name
	,	dept_org_level1
	,	dept_org_level2
	,	recruiter_id
	,	recruiter_name
	,	recruiter_dept_id
	,	recruiter_dept_name
	, reportingdays.calendar_day
  , reportingdays.reporting_week_of_year
  , reportingdays.calendar_month_of_year
  , reportingdays.calendar_qtr
  , reportingdays.reporting_year
  , TRUNC(SYSDATE) AS generated_date


FROM TOTALLY_RAD.RHMD_ALL_PHNX rhmd
      INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = TRUNC(rhmd.interview_date) AND reportingdays.reporting_year = DATEPART(year, sysdate)
WHERE 1=1
--AND recruiter_id = 'OSUPIKE'
--AND response_ct = 1
--AND survey_question IS not null
AND survey_question = 'Overall my interview experience was frustration-free'
AND survey_question <> ''
AND( LOWER(hm_reports_to_level4_id) = 'feitzing'
OR LOWER(hm_reports_to_level4_id) = 'feitzing'
OR LOWER(recruiter_id) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike')
OR LOWER(sourcer_id) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike'))
      
GROUP BY

interview_summary_id
	,	icims_id
	,	candidate_icims_id
	,	interview_date
	,	candidate_first_name 
  ,	candidate_last_name
  , candidate_data_source
  ,	survey_start_date
	,	survey_end_date
	,	survey_status
  ,	candidate_type
  , survey_question
  , survey_dropout_question  
	,	candidate_src_category
	,	hire_link
	,	hire_type
	,	job_code
	,	job_title_int
	,	job_title_ext
	,	job_level
	,	position_type
	,	flsa
	,	req_status
	,	busn_unit_cd
	,	busn_unit_nm
	,	job_family
	,	rc_group
	,	rc_owner
	,	rc_owner_id
	,	rc_owner_mgr_id
	,	employee_class
	,	reg_region_name
	,	reg_region_cd
	,	location_region
	,	location_country
	,	location_state
	,	location_city
	,	recruiting_org
	,	recruiting_sub_org
	,	cost_center
	,	cost_center_name
	,	dept_org_level1
	,	dept_org_level2
	,	recruiter_id
	,	recruiter_name
	,	recruiter_dept_id
	,	recruiter_dept_name
	, reportingdays.calendar_day
  , reportingdays.reporting_week_of_year
  , reportingdays.calendar_month_of_year
  , reportingdays.calendar_qtr
  , reportingdays.reporting_year
  , TRUNC(SYSDATE)
