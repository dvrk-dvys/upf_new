WITH A AS (

  SELECT 
   job_id
   ,job_classification_title AS open_rec_title
   ,reqs.location_building_name as req_building 
   ,reqs.country as req_country
   ,reqs.internal_job_title as req_business_title
   ,reqs.job_code AS req_job_code
   ,reqs.ofa_cost_center_code as req_cost_center
   ,reqs.job_level as req_job_level 
   ,reqs.job_state
   ,reqs.job_tech_indicator as reqs_job_tech_indicator
   ,hiring_manager_employee_id 
   ,hiring_manager_employee_full_name 
   ,hiring_manager_employee_login
  FROM masterhr.requisition reqs
  WHERE 1=1
  AND current_transaction_flag = 'Y'
  AND job_classification_title IN ('Software Dev Engineer III', 'Software Dev Engineer - Test III', 'Software Dev Engineer II', 'Software Dev Engineer II-TEST', 'Software Dev Engineer I', 'Software Dev Engineer I-TEST')

)
  SELECT DISTINCT 
  
    job_id
   ,open_rec_title
   ,req_building 
   ,req_country
   ,req_business_title
   ,req_job_code
   ,req_cost_center
   ,req_job_level 
   ,job_state
   ,reqs_job_tech_indicator
   ,hiring_manager_employee_id 
   ,hiring_manager_employee_full_name 
   ,hiring_manager_employee_login
   ,hc.department_name 
   ,department_id 
   ,hc.emplid
   ,hc.employee_login
   ,hc.employee_display_name
   ,job_entry_date
   ,job_tech_indicator
   ,hc.job_level_name AS HM_job_level
   ,hc.job_title_name AS HM_job_Title
   ,job_title_short_name as hm_job_title_short_name
   ,job_last_hire_date 
   ,business_unit_name AS HM_business_unit_name
   ,business_unit_code AS HM_business_unit_code
   ,department_ofa_cost_center_code AS HM_cost_center
   ,hc.job_tech_indicator as HM_job_tech_indicator
   ,reports_to_level_2_employee_name, hc.reports_to_level_3_employee_name, hc.reports_to_level_4_employee_name, hc.reports_to_level_5_employee_name, hc.reports_to_level_6_employee_name,
    reports_to_level_7_employee_name, reports_to_level_8_employee_name, reports_to_level_9_employee_name, reports_to_level_10_employee_name, reports_to_supervisor_employee_name,
   DATEDIFF(month, job_last_hire_date, GETDATE()) AS "tenure_in_months"
   ,hc.is_mghd
    
     
   ,CASE WHEN hc.is_sfi = 'Y' THEN 'Y'
       ELSE 'N' END AS is_sfi
       
    ,CASE WHEN  sde_oa.emplid IS NOT NULL THEN 'Y'
       ELSE 'N' END AS is_sde_oa   
    
    ,CASE WHEN employee_bar_raiser_derived_status = 'BAR_RAISER' THEN 'YES'
         ELSE 'NO' END AS active_br_flag
    
    ,CASE WHEN employee_bar_raiser_derived_status = 'BAR_RAISER_IN_TRAINING' THEN 'YES'
         ELSE 'NO' END AS active_brit_flag
          
    FROM masterhr.employee_hc_current hc
        INNER JOIN A ON HC.emplid = A.hiring_manager_employee_id
        LEFT JOIN opsdw.sde_oa_phonetool sde_oa ON hc.employee_login = sde_oa.employee_login

    WHERE 1=1
    --AND hc.job_title_short_name IN ('MgrIII,SDE', 'SDE III', 'SDEIII', 'MgrIIIP/A', 'Princ,SDE', 'SrMgr,Soft', 'Front-End', 'MgrII,SDE', 'SDE II', 'SDEII', 'Front-End', 'SDE I', 'SDEI')
    --AND hc.job_level_name IN (4, 5, 6, 7) 
    AND hc.reports_to_level_3_employee_login IN ('davecl', 'darcie', 'gcarpe')
    
