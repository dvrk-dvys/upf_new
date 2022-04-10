WITH ap AS (

      SELECT 
      job_id,
      icims_id,
      person_id,
     -- MIN(icims_created_timestamp) AS application_date
      MIN(convert_timezone ('US/Pacific',CAST((TIMESTAMP 'epoch' + CAST(icims_updated_timestamp AS BIGINT) / 1000*INTERVAL '1 Second') AS TIMESTAMP))) AS application_date
      
      FROM ads.worksteps
      GROUP BY job_id,
      icims_id,
      person_id
),

status AS (

      SELECT 
      job_id,
      icims_id,
      person_id,
      status      
      
      FROM ads.worksteps
      GROUP BY job_id,
      icims_id,
      person_id,
      status
),

latest as (

    SELECT 
      job_id,
      icims_id,
      person_id,
      icims_updated_timestamp,
      status
      
    FROM ads.worksteps_latest
) ,


-- Accepts & Declines --
accepts_declines AS (

    SELECT DISTINCT 
      DATEDIFF (d , offer.requisition_final_approval_date::timestamp,offer_accepted_date::timestamp) as TTF,
      DATEDIFF (d , TRUNC(ap.application_date), TRUNC(offer_accepted_date)) as TTH,
      reqs.job_id,
      reqs.job_icims_id,
      reqs.ofa_cost_center_code,
      --reqs.snapshot_begin_timestamp,
      --reqs.snapshot_end_timestamp,
      offer.icims_status,
      offer.enter_state_time,
      offer.candidate_full_name,
      offer.job_icims_id AS offer_job_icims_id,
      offer.candidate_icims_id,
      offer.offer_accepted_count,
      offer.offer_accepted_date,
      offer.offer_declined_count,
      offer.offer_declined_date,
      offer.candidate_type,
      offer.job_id as offer_job_id,
      offer.candidate_guid,
      offer.job_level,
      offer.job_code,
      offer.job_classification_title,
      offer.country,
      offer.building,
     -- offer.recruiter_employee_login,
      reqs.recruiter_employee_login,
      reqs.recruiter_employee_full_name,
      reqs.sourcer_employee_login,
      reqs.sourcer_employee_full_name,
      offer.current_recruiter_employee_full_name,
      reqs.current_job_state as reqscurrentjobstate,
      reqs.internal_job_title,
      reportingdays.calendar_day,
      reportingdays.reporting_week_of_year,
      reportingdays.calendar_month_of_year,
      reportingdays.calendar_qtr,
      reportingdays.reporting_year,
      TRUNC(SYSDATE) AS generated_date,
      --reqs.hiring_manager_reports_to_level_4_employee_login,
      --reqs.hiring_manager_reports_to_level_5_employee_login,
      offer.hiring_manager_reports_to_level_4_employee_login,
      offer.hiring_manager_reports_to_level_5_employee_login,
      ap.application_date



      FROM masterhr.offer_accepts offer
      INNER JOIN ap ON ap.job_id = offer.job_icims_id AND ap.person_id = offer.candidate_icims_id
      INNER JOIN opsdw.ops_ta_team_wk team ON team.emplid = offer.recruiter_employee_id
      INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = offer.job_icims_id AND ((TRUNC(offer.offer_accepted_date) BETWEEN TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(reqs.snapshot_end_timestamp)) OR (TRUNC(offer.offer_declined_date) BETWEEN TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(reqs.snapshot_end_timestamp)))
      INNER JOIN hrmetrics.o_reporting_days reportingdays ON ((reportingdays.calendar_day = TRUNC(offer.offer_accepted_date)) OR (reportingdays.calendar_day = TRUNC(offer.offer_declined_date))) AND reportingdays.reporting_year IN (DATEPART(year, sysdate), DATEPART(year, sysdate) - 1)
      WHERE 1=1
      AND( reqs.hiring_manager_reports_to_level_4_employee_login = 'feitzing'
      OR reqs.hiring_manager_reports_to_level_5_employee_login = 'feitzing'
      OR offer.hiring_manager_reports_to_level_4_employee_login = 'feitzing'
      OR offer.hiring_manager_reports_to_level_5_employee_login = 'feitzing')
      OR (LOWER(offer.sourcer_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike')
      OR LOWER(reqs.sourcer_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike')
      OR LOWER(offer.recruiter_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike') 
      OR LOWER(reqs.recruiter_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike'))

),

-- Pending Starts --
pending AS (

     SELECT DISTINCT 
        ap.application_date,
        TTF,
        TTH,
        offer.job_icims_id,
        offer.candidate_icims_id AS person_id,
        reqscurrentjobstate,
        l.icims_updated_timestamp AS current_icims_status,
        l.status,
        calendar_day,
        reporting_week_of_year,
        reporting_year,
        calendar_month_of_year,
        calendar_qtr,
        offer.enter_state_time,
        TRUNC(offer.offer_accepted_date),
        --offer.current_recruiter_employee_login,
       -- offer.current_recruiter_name,
        offer.sourcer_employee_login,
        offer.sourcer_employee_full_name,
        --offer.department_id,
        offer.candidate_type,
        offer.job_level,
        offer.job_code,
        offer.job_classification_title,
        offer.country,
        offer.building,
        offer.candidate_full_name,
        --empl.emplid,
        TRUNC(SYSDATE) AS generated_date,
        ofa_cost_center_code


        FROM accepts_declines offer

        INNER JOIN ap ON ap.job_id = offer.job_icims_id AND ap.person_id = offer.candidate_icims_id
        LEFT JOIN status ON status.job_id = ap.job_id AND status.person_id = ap.person_id
        LEFT JOIN lookup.icims_recruiting_states s ON status.status = s.icims_status
        LEFT JOIN latest l ON l.job_id = ap.job_id AND l.icims_id = ap.icims_id AND l.person_id = ap.person_id

        WHERE 1=1
        AND offer.offer_accepted_count = 1
        AND offer_accepted_date >= (CAST((DATEPART(year, offer_accepted_date)) AS VARCHAR) + '-01-01')
        --AND offer_accepted_date >= '2019-01-01'
        AND s.ra_column_name = 'pending_start_count'
      --  AND reqs.ofa_cost_center_code in ('1023', '1092', '1145', '1158', '1160', '1171', '1172', '1173', '1174', '1263', '1290', '1299', '1917', '2157', '7024', '7709')
        AND (LOWER(offer.sourcer_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike')
        OR LOWER(offer.recruiter_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike') 
        OR(LOWER(offer.hiring_manager_reports_to_level_4_employee_login) = 'feitzing'
        OR LOWER(offer.hiring_manager_reports_to_level_5_employee_login) = 'feitzing'))
    
),


-- Promotions --
promotions AS (

        select distinct

        promo_effective_date,
        ep.emplid,
        ep.employee_login,
        ep.employee_full_name,
        reportingdays.calendar_day,
        reportingdays.reporting_week_of_year,
        reportingdays.reporting_year,
        reportingdays.calendar_month_of_year,
        reportingdays.calendar_qtr,
        ep.prior_job_level_name,
        ep.post_job_level_name,
        ep.job_level_diff,
        ep.prior_employee_business_title,
        ep.prior_department_ofa_cost_center_code,
        ep.prior_job_title_name,
        ep.post_employee_business_title,
        ep.post_department_ofa_cost_center_code,
        ep.post_job_title_name,
        prior_regulatory_region_country_name AS prior_country,
        post_regulatory_region_country_name AS post_country,
        TRUNC(SYSDATE) AS generated_date

        FROM masterhr.employee_promotions ep
        INNER JOIN masterhr.employee_hc hc ON hc.employee_login = ep.employee_login
        --INNER JOIN accepts_declines a ON hc.job_candidate_icims_id = a.candidate_icims_id AND a.offer_accepted_count = 1
        INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = ep.promo_effective_date::DATE AND reportingdays.reporting_year IN (DATEPART(year, sysdate), DATEPART(year, sysdate) - 1)
        WHERE 1=1
        AND (prior_reports_to_level_4_employee_login = 'feitzing'
        OR prior_reports_to_level_5_employee_login = 'feitzing')
),

-- Transfers --
transfers AS (

        select distinct
        
        et.transfer_effective_date,
        et.emplid,
        et.employee_login,
        et.employee_full_name,
        reportingdays.calendar_day,
        reportingdays.reporting_week_of_year,
        reportingdays.reporting_year,
        reportingdays.calendar_month_of_year,
        reportingdays.calendar_qtr,
        et.prior_job_level_name,
        et.post_job_level_name,
        et.prior_employee_business_title,
        et.prior_department_ofa_cost_center_code,
        et.prior_job_title_name,
        et.post_employee_business_title,
        et.post_department_ofa_cost_center_code,
        et.post_job_title_name,
        prior_regulatory_region_country_name as prior_country,
        post_regulatory_region_country_name as post_country,
        TRUNC(SYSDATE) AS generated_date

        FROM masterhr.employee_transfers et
        INNER JOIN masterhr.employee_hc hc ON hc.employee_login = et.employee_login
        --INNER JOIN accepts_declines a ON hc.job_candidate_icims_id = a.candidate_icims_id AND a.offer_accepted_count = 1
        INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = et.transfer_effective_date::DATE AND reportingdays.reporting_year IN (DATEPART(year, sysdate), DATEPART(year, sysdate) - 1)
        WHERE 1=1
        AND (prior_reports_to_level_4_employee_login = 'feitzing'
        OR prior_reports_to_level_5_employee_login = 'feitzing')

),


-- Terminated --
terminated AS (

      SELECT DISTINCT
      hc.job_code
      --,hc.job_candidate_icims_id
      ,hc.job_level_name AS job_level
      ,hc.job_icims_id
      ,hc.employee_login
      ,hc.employee_status_description
      ,hc.job_termination_date
      ,employee_display_name AS candidate_full_name
      ,reportingdays.calendar_day
      ,reportingdays.reporting_week_of_year
      ,reportingdays.reporting_year
      ,reportingdays.calendar_month_of_year
      ,reportingdays.calendar_qtr
      ,hc.job_title_name AS job_classification_title
      ,hc.location_country_name AS country
      ,hc.department_id
      ,hc.department_ofa_cost_center_code
      ,TRUNC(SYSDATE) AS generated_date

      FROM masterhr.employee_hc hc
      --INNER JOIN accepts_declines a ON hc.job_candidate_icims_id = a.candidate_icims_id AND a.offer_accepted_count = 1
      INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = hc.job_termination_date AND reportingdays.reporting_year IN (DATEPART(year, sysdate), DATEPART(year, sysdate) - 1)

      WHERE 1=1
      AND employee_status_description = 'Terminated'
      AND (LOWER(reports_to_level_4_employee_login) = 'feitzing'
      OR LOWER(reports_to_level_5_employee_login) = 'feitzing'
      OR LOWER(reports_to_level_6_employee_login) = 'feitzing'
      OR LOWER(reports_to_level_7_employee_login) = 'feitzing')

),

rhmd AS (

      SELECT       
      current_recruiter_login, survey_question, survey_response_translated, initial_language, days_since_interview,main_sentiment_labeled,main_sentiment_value,interview_summary_id,
      icims_id AS job_icims_id, candidate_icims_id AS person_id, interview_date, interview_type,survey_start_date,survey_end_date,survey_status,hire_link,hire_type,job_code,job_title_int AS internal_job_title,
      job_title_ext,job_level,req_status,rc_owner,rc_owner_id,rc_owner_mgr_id,cost_center AS ofa_cost_center_code,recruiter_id,recruiter_name,recruiter_dept_id,recruiter_dept_name,sourcer_id,debrief_decision,
      rectr_reports_to_level2_id,recruiter_reports_to_2,rectr_reports_to_level3_id,recruiter_reports_to_3,rectr_reports_to_level4_id, recruiter_reports_to_4,rectr_reports_to_level5_id,
      recruiter_reports_to_5,rectr_reports_to_level6_id,recruiter_reports_to_6,rectr_reports_to_level7_id,recruiter_reports_to_7,rectr_reports_to_level8_id,recruiter_reports_to_8
      ,reportingdays.calendar_day
      ,reportingdays.reporting_week_of_year
      ,reportingdays.calendar_month_of_year
      ,reportingdays.calendar_qtr
      ,reportingdays.reporting_year
      ,TRUNC(SYSDATE) AS generated_date

      FROM opstadw.ops_insearch.rhmd_consolidated rhmd
      INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = TRUNC(rhmd.interview_date)
      WHERE 1=1

)

----Union of all the AGL metrics-------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
,unionedAGLMetrics as (
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    SELECT 'Accepts & Declines'::VARCHAR(200) AS metric_name
            ,application_date::VARCHAR(200)      
            ,TTF::VARCHAR(200)
            ,TTH::VARCHAR(200)
            ,job_id::VARCHAR(200)
            ,job_icims_id::VARCHAR(200)
            ,candidate_guid::VARCHAR(200)
            ,NULL AS person_id
            ,ofa_cost_center_code::VARCHAR(200)
            ,icims_status::VARCHAR(200)
            ,NULL AS status
            ,enter_state_time::VARCHAR(200)
            ,candidate_full_name::VARCHAR(200)
            ,candidate_icims_id::VARCHAR(200)
            ,offer_accepted_count::VARCHAR(200)
            ,offer_accepted_date::VARCHAR(200)
            ,offer_declined_count::VARCHAR(200)
            ,offer_declined_date::VARCHAR(200)
            ,candidate_type::VARCHAR(200)
            ,job_level::VARCHAR(200)
            ,job_code::VARCHAR(200)
            ,job_classification_title::VARCHAR(200)
            ,country::VARCHAR(200)
            ,NULL AS prior_country
            ,NULL AS post_country
            ,building::VARCHAR(200)
            ,recruiter_employee_login::VARCHAR(200)
            ,recruiter_employee_full_name::VARCHAR(200)
            ,sourcer_employee_login::VARCHAR(200)
            ,sourcer_employee_full_name::VARCHAR(200)
            ,current_recruiter_employee_full_name::VARCHAR(200)
            ,reqscurrentjobstate::VARCHAR(200)
            ,internal_job_title::VARCHAR(200)
            ,NULL AS promo_effective_date
            ,NULL AS transfer_effective_date
            ,NULL AS job_termination_date
            ,NULL AS emplid
            ,NULL AS employee_login
            ,NULL AS employee_full_name
            ,NULL AS prior_job_level_name
            ,NULL AS post_job_level_name
            ,NULL AS job_level_diff
            ,NULL AS prior_employee_business_title
            ,NULL AS prior_department_ofa_cost_center_code
            ,NULL AS prior_job_title_name
            ,NULL AS post_employee_business_title
            ,NULL AS post_department_ofa_cost_center_code
            ,NULL AS post_job_title_name         
            ,NULL AS current_recruiter_login  
            ,NULL AS survey_question   
            ,NULL AS survey_response_translated   
            ,NULL AS initial_language 
            ,NULL AS days_since_interview 
            ,NULL AS main_sentiment_labeled  
            ,NULL AS main_sentiment_value
            ,NULL AS debrief_decision
            ,NULL AS interview_summary_id 
            ,NULL AS interview_date
            ,NULL AS interview_type
            ,NULL AS survey_start_date
            ,NULL AS survey_end_date
            ,NULL AS survey_status
            ,NULL AS hire_link
            ,NULL AS hire_type
            ,NULL AS req_status
            ,NULL AS rc_owner
            ,NULL AS rc_owner_id
            ,NULL AS rc_owner_mgr_id
            ,NULL AS recruiter_id
            ,NULL AS recruiter_name
            ,NULL AS recruiter_dept_id
            ,NULL AS recruiter_dept_name
            ,NULL AS sourcer_id                        
            ,calendar_day::VARCHAR(200)
            ,reporting_week_of_year::VARCHAR(200)
            ,calendar_month_of_year::VARCHAR(200)
            ,calendar_qtr::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,generated_date::VARCHAR(200)                                     

    FROM accepts_declines

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 'Pending Starts'::VARCHAR(200) AS metric_name
            ,application_date::VARCHAR(200)
            ,TTF::VARCHAR(200)
            ,TTH::VARCHAR(200)
            ,NULL AS job_id
            ,job_icims_id::VARCHAR(200)
            ,NULL AS candidate_guid
            ,person_id::VARCHAR(200)
            ,ofa_cost_center_code::VARCHAR(200)
            ,NULL AS icims_status
            ,status::VARCHAR(200)
            ,enter_state_time::VARCHAR(200)
            ,candidate_full_name::VARCHAR(200)
            ,NULL AS candidate_icims_id
            ,NULL AS offer_accepted_count
            ,NULL AS offer_accepted_date
            ,NULL AS offer_declined_count
            ,NULL AS offer_declined_date
            ,candidate_type::VARCHAR(200)
            ,job_level::VARCHAR(200)
            ,job_code::VARCHAR(200)
            ,job_classification_title::VARCHAR(200)
            ,country::VARCHAR(200)
            ,NULL AS prior_country
            ,NULL AS post_country
            ,building::VARCHAR(200)
            ,NULL AS recruiter_employee_login
            ,NULL AS recruiter_employee_full_name
            ,sourcer_employee_login::VARCHAR(200)
            ,sourcer_employee_full_name::VARCHAR(200)
            ,NULL AS current_recruiter_employee_full_name
            ,reqscurrentjobstate::VARCHAR(200)
            ,NULL AS internal_job_title
            ,NULL AS promo_effective_date
            ,NULL AS transfer_effective_date
            ,NULL AS job_termination_date
            ,NULL AS emplid
            ,NULL AS employee_login
            ,NULL AS employee_full_name
            ,NULL AS prior_job_level_name
            ,NULL AS post_job_level_name
            ,NULL AS job_level_diff
            ,NULL AS prior_employee_business_title
            ,NULL AS prior_department_ofa_cost_center_code
            ,NULL AS prior_job_title_name
            ,NULL AS post_employee_business_title
            ,NULL AS post_department_ofa_cost_center_code
            ,NULL AS post_job_title_name
            ,NULL AS current_recruiter_login  
            ,NULL AS survey_question   
            ,NULL AS survey_response_translated   
            ,NULL AS initial_language 
            ,NULL AS days_since_interview 
            ,NULL AS main_sentiment_labeled  
            ,NULL AS main_sentiment_value
            ,NULL AS debrief_decision
            ,NULL AS interview_summary_id 
            ,NULL AS interview_date
            ,NULL AS interview_type
            ,NULL AS survey_start_date
            ,NULL AS survey_end_date
            ,NULL AS survey_status
            ,NULL AS hire_link
            ,NULL AS hire_type
            ,NULL AS req_status
            ,NULL AS rc_owner
            ,NULL AS rc_owner_id
            ,NULL AS rc_owner_mgr_id
            ,NULL AS recruiter_id
            ,NULL AS recruiter_name
            ,NULL AS recruiter_dept_id
            ,NULL AS recruiter_dept_name
            ,NULL AS sourcer_id
            ,calendar_day::VARCHAR(200)
            ,reporting_week_of_year::VARCHAR(200)
            ,calendar_month_of_year::VARCHAR(200)
            ,calendar_qtr::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,generated_date::VARCHAR(200)                               
    FROM pending



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 'Promotions'::VARCHAR(200) AS metric_name
            ,NULL AS application_date
            ,NULL AS TTF
            ,NULL AS TTH
            ,NULL AS job_id
            ,NULL AS job_icims_id
            ,NULL AS candidate_guid
            ,NULL AS person_id
            ,NULL AS ofa_cost_center_code
            ,NULL AS icims_status
            ,NULL AS status
            ,NULL AS enter_state_time
            ,NULL AS candidate_full_name
            ,NULL AS candidate_icims_id
            ,NULL AS offer_accepted_count
            ,NULL AS offer_accepted_date
            ,NULL AS offer_declined_count
            ,NULL AS offer_declined_date
            ,NULL AS candidate_type
            ,NULL AS job_level
            ,NULL AS job_code
            ,NULL AS job_classification_title
            ,NULL AS country
            ,prior_country::VARCHAR(200)
            ,post_country::VARCHAR(200)
            ,NULL AS building
            ,NULL AS recruiter_employee_login
            ,NULL AS recruiter_employee_full_name
            ,NULL AS sourcer_employee_login
            ,NULL AS sourcer_employee_full_name
            ,NULL AS current_recruiter_employee_full_name
            ,NULL AS reqscurrentjobstate
            ,NULL AS internal_job_title      
            ,promo_effective_date::VARCHAR(200)
            ,NULL AS transfer_effective_date
            ,NULL AS job_termination_date
            ,emplid::VARCHAR(200)
            ,employee_login::VARCHAR(200)
            ,employee_full_name::VARCHAR(200)
            ,prior_job_level_name::VARCHAR(200)
            ,post_job_level_name::VARCHAR(200)
            ,job_level_diff::VARCHAR(200)
            ,prior_employee_business_title::VARCHAR(200)
            ,prior_department_ofa_cost_center_code::VARCHAR(200)
            ,prior_job_title_name::VARCHAR(200)
            ,post_employee_business_title::VARCHAR(200)
            ,post_department_ofa_cost_center_code::VARCHAR(200)
            ,post_job_title_name::VARCHAR(200)
            ,NULL AS current_recruiter_login  
            ,NULL AS survey_question   
            ,NULL AS survey_response_translated   
            ,NULL AS initial_language 
            ,NULL AS days_since_interview 
            ,NULL AS main_sentiment_labeled  
            ,NULL AS main_sentiment_value
            ,NULL AS debrief_decision
            ,NULL AS interview_summary_id 
            ,NULL AS interview_date
            ,NULL AS interview_type
            ,NULL AS survey_start_date
            ,NULL AS survey_end_date
            ,NULL AS survey_status
            ,NULL AS hire_link
            ,NULL AS hire_type
            ,NULL AS req_status
            ,NULL AS rc_owner
            ,NULL AS rc_owner_id
            ,NULL AS rc_owner_mgr_id
            ,NULL AS recruiter_id
            ,NULL AS recruiter_name
            ,NULL AS recruiter_dept_id
            ,NULL AS recruiter_dept_name
            ,NULL AS sourcer_id         
            ,calendar_day::VARCHAR(200)
            ,reporting_week_of_year::VARCHAR(200)
            ,calendar_month_of_year::VARCHAR(200)
            ,calendar_qtr::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,generated_date::VARCHAR(200)                               
    FROM promotions

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 'Transfers'::VARCHAR(200) AS metric_name
            ,NULL AS application_date
            ,NULL AS TTF
            ,NULL AS TTH
            ,NULL AS job_id
            ,NULL AS job_icims_id
            ,NULL AS candidate_guid
            ,NULL AS person_id
            ,NULL AS ofa_cost_center_code
            ,NULL AS icims_status
            ,NULL AS status
            ,NULL AS enter_state_time
            ,NULL AS candidate_full_name
            ,NULL AS candidate_icims_id
            ,NULL AS offer_accepted_count
            ,NULL AS offer_accepted_date
            ,NULL AS offer_declined_count
            ,NULL AS offer_declined_date
            ,NULL AS candidate_type
            ,NULL AS job_level
            ,NULL AS job_code
            ,NULL AS job_classification_title
            ,NULL AS country
            ,prior_country::VARCHAR(200)
            ,post_country::VARCHAR(200)
            ,NULL AS building
            ,NULL AS recruiter_employee_login
            ,NULL AS recruiter_employee_full_name
            ,NULL AS sourcer_employee_login
            ,NULL AS sourcer_employee_full_name
            ,NULL AS current_recruiter_employee_full_name
            ,NULL AS reqscurrentjobstate
            ,NULL AS internal_job_title      
            ,NULL AS promo_effective_date
            ,transfer_effective_date::VARCHAR(200)
            ,NULL AS job_termination_date
            ,emplid::VARCHAR(200)
            ,employee_login::VARCHAR(200)
            ,employee_full_name::VARCHAR(200)
            ,prior_job_level_name::VARCHAR(200)
            ,post_job_level_name::VARCHAR(200)
            ,NULL AS job_level_diff
            ,prior_employee_business_title::VARCHAR(200)
            ,prior_department_ofa_cost_center_code::VARCHAR(200)
            ,prior_job_title_name::VARCHAR(200)
            ,post_employee_business_title::VARCHAR(200)
            ,post_department_ofa_cost_center_code::VARCHAR(200)
            ,post_job_title_name::VARCHAR(200)
            ,NULL AS current_recruiter_login  
            ,NULL AS survey_question   
            ,NULL AS survey_response_translated   
            ,NULL AS initial_language 
            ,NULL AS days_since_interview 
            ,NULL AS main_sentiment_labeled  
            ,NULL AS main_sentiment_value
            ,NULL AS debrief_decision
            ,NULL AS interview_summary_id 
            ,NULL AS interview_date
            ,NULL AS interview_type
            ,NULL AS survey_start_date
            ,NULL AS survey_end_date
            ,NULL AS survey_status
            ,NULL AS hire_link
            ,NULL AS hire_type
            ,NULL AS req_status
            ,NULL AS rc_owner
            ,NULL AS rc_owner_id
            ,NULL AS rc_owner_mgr_id
            ,NULL AS recruiter_id
            ,NULL AS recruiter_name
            ,NULL AS recruiter_dept_id
            ,NULL AS recruiter_dept_name
            ,NULL AS sourcer_id         
            ,calendar_day::VARCHAR(200)
            ,reporting_week_of_year::VARCHAR(200)
            ,calendar_month_of_year::VARCHAR(200)
            ,calendar_qtr::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,generated_date::VARCHAR(200)                               
    FROM transfers
    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



SELECT 'Terminated'::VARCHAR(200) AS metric_name
            ,NULL AS application_date
            ,NULL AS TTF
            ,NULL AS TTH
            ,NULL AS job_id
            ,job_icims_id::VARCHAR(200)
            ,NULL AS candidate_guid
            ,NULL AS person_id
            ,NULL AS ofa_cost_center_code
            ,NULL AS icims_status
            ,NULL AS status
            ,NULL AS enter_state_time
            ,candidate_full_name::VARCHAR(200)
            ,NULL AS candidate_icims_id
            ,NULL AS offer_accepted_count
            ,NULL AS offer_accepted_date
            ,NULL AS offer_declined_count
            ,NULL AS offer_declined_date
            ,NULL AS candidate_type
            ,job_level::VARCHAR(200)
            ,job_code::VARCHAR(200)
            ,job_classification_title::VARCHAR(200)
            ,country::VARCHAR(200)
            ,NULL AS prior_country
            ,NULL AS post_country
            ,NULL AS building
            ,NULL AS recruiter_employee_login
            ,NULL AS recruiter_employee_full_name
            ,NULL AS sourcer_employee_login
            ,NULL AS sourcer_employee_full_name
            ,NULL AS current_recruiter_employee_full_name
            ,NULL AS reqscurrentjobstate
            ,NULL AS internal_job_title      
            ,NULL AS promo_effective_date
            ,NULL AS transfer_effective_date
            ,job_termination_date::VARCHAR(200)
            ,NULL AS emplid
            ,employee_login::VARCHAR(200)
            ,NULL AS employee_full_name
            ,NULL AS prior_job_level_name
            ,NULL AS post_job_level_name
            ,NULL AS job_level_diff
            ,NULL AS prior_employee_business_title
            ,NULL AS prior_department_ofa_cost_center_code
            ,NULL AS prior_job_title_name
            ,NULL AS post_employee_business_title
            ,NULL AS post_department_ofa_cost_center_code
            ,NULL AS post_job_title_name
            ,NULL AS current_recruiter_login  
            ,NULL AS survey_question   
            ,NULL AS survey_response_translated   
            ,NULL AS initial_language 
            ,NULL AS days_since_interview 
            ,NULL AS main_sentiment_labeled  
            ,NULL AS main_sentiment_value
            ,NULL AS debrief_decision
            ,NULL AS interview_summary_id 
            ,NULL AS interview_date
            ,NULL AS interview_type
            ,NULL AS survey_start_date
            ,NULL AS survey_end_date
            ,NULL AS survey_status
            ,NULL AS hire_link
            ,NULL AS hire_type
            ,NULL AS req_status
            ,NULL AS rc_owner
            ,NULL AS rc_owner_id
            ,NULL AS rc_owner_mgr_id
            ,NULL AS recruiter_id
            ,NULL AS recruiter_name
            ,NULL AS recruiter_dept_id
            ,NULL AS recruiter_dept_name
            ,NULL AS sourcer_id  
            ,calendar_day::VARCHAR(200)
            ,reporting_week_of_year::VARCHAR(200)
            ,calendar_month_of_year::VARCHAR(200)
            ,calendar_qtr::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,generated_date::VARCHAR(200)     
    FROM terminated


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 'rhmd'::VARCHAR(200) AS metric_name
            ,NULL AS application_date
            ,NULL AS TTF
            ,NULL AS TTH
            ,NULL AS job_id
            ,job_icims_id::VARCHAR(200)
            ,NULL AS candidate_guid
            ,person_id::VARCHAR(200)
            ,ofa_cost_center_code::VARCHAR(200)
            ,NULL AS icims_status
            ,NULL AS status
            ,NULL AS enter_state_time
            ,NULL AS candidate_full_name
            ,NULL AS candidate_icims_id
            ,NULL AS offer_accepted_count
            ,NULL AS offer_accepted_date
            ,NULL AS offer_declined_count
            ,NULL AS offer_declined_date
            ,NULL AS candidate_type
            ,job_level::VARCHAR(200)
            ,job_code::VARCHAR(200)
            ,NULL AS job_classification_title
            ,NULL AS country
            ,NULL AS prior_country
            ,NULL AS post_country
            ,NULL AS building
            ,NULL AS recruiter_employee_login
            ,NULL AS recruiter_employee_full_name
            ,NULL AS sourcer_employee_login
            ,NULL AS sourcer_employee_full_name
            ,NULL AS current_recruiter_employee_full_name
            ,NULL AS reqscurrentjobstate
            ,internal_job_title::VARCHAR(200)     
            ,NULL AS promo_effective_date
            ,NULL AS transfer_effective_date
            ,NULL AS job_termination_date
            ,NULL AS emplid
            ,NULL AS employee_login
            ,NULL AS employee_full_name
            ,NULL AS prior_job_level_name
            ,NULL AS post_job_level_name
            ,NULL AS job_level_diff
            ,NULL AS prior_employee_business_title
            ,NULL AS prior_department_ofa_cost_center_code
            ,NULL AS prior_job_title_name
            ,NULL AS post_employee_business_title
            ,NULL AS post_department_ofa_cost_center_code
            ,NULL AS post_job_title_name
            ,current_recruiter_login::VARCHAR(200)   
            ,survey_question::VARCHAR(200)   
            ,survey_response_translated::VARCHAR(200)   
            ,initial_language::VARCHAR(200)   
            ,days_since_interview::VARCHAR(200)   
            ,main_sentiment_labeled::VARCHAR(200)   
            ,main_sentiment_value::VARCHAR(200)
            ,debrief_decision::VARCHAR(200)
            ,interview_summary_id::VARCHAR(200)    
            ,interview_date::VARCHAR(200)
            ,interview_type::VARCHAR(200)
            ,survey_start_date::VARCHAR(200)
            ,survey_end_date::VARCHAR(200)
            ,survey_status::VARCHAR(200)
            ,hire_link::VARCHAR(200)
            ,hire_type::VARCHAR(200)
            ,req_status::VARCHAR(200)
            ,rc_owner::VARCHAR(200)
            ,rc_owner_id::VARCHAR(200)
            ,rc_owner_mgr_id::VARCHAR(200)
            ,recruiter_id::VARCHAR(200)
            ,recruiter_name::VARCHAR(200)
            ,recruiter_dept_id::VARCHAR(200)
            ,recruiter_dept_name::VARCHAR(200)
            ,sourcer_id::VARCHAR(200)  
            ,calendar_day::VARCHAR(200)
            ,reporting_week_of_year::VARCHAR(200)
            ,calendar_month_of_year::VARCHAR(200)
            ,calendar_qtr::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,generated_date::VARCHAR(200)     
    FROM rhmd




)


SELECT metric_name
,application_date::VARCHAR(200)
,TTF::VARCHAR(200)
,TTH::VARCHAR(200)
,job_id::VARCHAR(200)
,job_icims_id::VARCHAR(200)
,candidate_guid::VARCHAR(200)
,person_id::VARCHAR(200)
,ofa_cost_center_code::VARCHAR(200)
,icims_status::VARCHAR(200)
,status::VARCHAR(200)
,enter_state_time::VARCHAR(200)
,candidate_full_name::VARCHAR(200)
,candidate_icims_id::VARCHAR(200)
,offer_accepted_count::VARCHAR(200)
,offer_accepted_date::VARCHAR(200)
,offer_declined_count::VARCHAR(200)
,offer_declined_date::VARCHAR(200)
,candidate_type::VARCHAR(200)
,job_level::VARCHAR(200)
,job_code::VARCHAR(200)
,job_classification_title::VARCHAR(200)
,country::VARCHAR(200)
,prior_country::VARCHAR(200)
,post_country::VARCHAR(200)
,building::VARCHAR(200)
,recruiter_employee_login::VARCHAR(200)
,recruiter_employee_full_name::VARCHAR(200)
,sourcer_employee_login::VARCHAR(200)
,sourcer_employee_full_name::VARCHAR(200)
,current_recruiter_employee_full_name::VARCHAR(200)
,reqscurrentjobstate::VARCHAR(200)
,internal_job_title::VARCHAR(200)
,promo_effective_date::VARCHAR(200)
,transfer_effective_date::VARCHAR(200)
,job_termination_date::VARCHAR(200)
,emplid::VARCHAR(200)
,employee_login::VARCHAR(200)
,employee_full_name::VARCHAR(200)
,prior_job_level_name::VARCHAR(200)
,post_job_level_name::VARCHAR(200)
,job_level_diff::VARCHAR(200)
,prior_employee_business_title::VARCHAR(200)
,prior_department_ofa_cost_center_code::VARCHAR(200)
,prior_job_title_name::VARCHAR(200)
,post_employee_business_title::VARCHAR(200)
,post_department_ofa_cost_center_code::VARCHAR(200)
,post_job_title_name::VARCHAR(200)
,current_recruiter_login::VARCHAR(200)   
,survey_question::VARCHAR(200)   
,survey_response_translated::VARCHAR(200)   
,initial_language::VARCHAR(200)   
,days_since_interview::VARCHAR(200)   
,main_sentiment_labeled::VARCHAR(200)   
,main_sentiment_value::VARCHAR(200)
,debrief_decision::VARCHAR(200)
,interview_summary_id::VARCHAR(200)    
,interview_date::VARCHAR(200)
,interview_type::VARCHAR(200)
,survey_start_date::VARCHAR(200)
,survey_end_date::VARCHAR(200)
,survey_status::VARCHAR(200)
,hire_link::VARCHAR(200)
,hire_type::VARCHAR(200)
,req_status::VARCHAR(200)
,rc_owner::VARCHAR(200)
,rc_owner_id::VARCHAR(200)
,rc_owner_mgr_id::VARCHAR(200)
,recruiter_id::VARCHAR(200)
,recruiter_name::VARCHAR(200)
,recruiter_dept_id::VARCHAR(200)
,recruiter_dept_name::VARCHAR(200)
,sourcer_id::VARCHAR(200)
,calendar_day::VARCHAR(200)
,reporting_week_of_year::VARCHAR(200)
,calendar_month_of_year::VARCHAR(200)
,calendar_qtr::VARCHAR(200)
,reporting_year::VARCHAR(200)
,generated_date::VARCHAR(200)  
FROM unionedAGLMetrics
WHERE 1=1
--AND reporting_week_of_year = 43
--AND job_guid = '0537c363-d3d5-4d86-944c-de4227320836'
--AND job_icims_id = '902554'
--AND metric_name = 'Promotions'
--AND prior_country != post_country
--AND (TRUNC(sysdate) - INTERVAL '35 DAY') < TRUNC(calendar_day)
AND reporting_year = 2018

--Accepts & Declines, PENDING STARTS, 
--TRANSFER, TERMINATED, PROMOTIONS
