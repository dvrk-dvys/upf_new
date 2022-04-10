WITH A AS
(
  SELECT interviewer_employee_id, interviewer_employee_login, event_role, event_type, job_id, candidate_id, event_finish, interview_summary_guid
  FROM masterhr.interview_activity
    WHERE 1=1
    AND event_type IN ('Phone Screen', 'On-site')
    AND event_status = 'Occurred'
), 

B AS 
(
  SELECT job_id, job_classification_title AS open_rec_title, job_guid
  FROM masterhr.requisition
  WHERE job_classification_title IN ('Software Dev Engineer III', 'Software Dev Engineer - Test III', 'Software Dev Engineer II', 'Software Dev Engineer II-TEST', 'Software Dev Engineer I', 'Software Dev Engineer I-TEST')
),

C AS
(
  SELECT DISTINCT location_building_name, location_city_name, location_country_name, hc.department_name, department_id, department_org_level2, hc.emplid, hc.employee_login, hc.employee_full_name, job_entry_date,
    job_tech_indicator, hc.job_level_name, hc.job_title_name AS Interviewer_Title, job_title_short_name, job_last_hire_date, business_unit_name, business_unit_code, employee_class_name, employee_status_description, 
    reports_to_level_2_employee_name, hc.reports_to_level_3_employee_name, hc.reports_to_level_4_employee_name, hc.reports_to_level_5_employee_name, hc.reports_to_level_6_employee_name,
    reports_to_level_7_employee_name, reports_to_level_8_employee_name, reports_to_level_9_employee_name, reports_to_level_10_employee_name, reports_to_supervisor_employee_name,
    DATEDIFF(month, job_last_hire_date, GETDATE()) AS "tenure_in_months", hc.is_mghd,
    
     
    CASE WHEN hc.is_sfi = 'Y' THEN 'Y'
       ELSE 'N' END AS is_sfi,
       
    CASE WHEN  sde_oa.emplid IS NOT NULL THEN 'Y'
       ELSE 'N' END AS is_sde_oa,      
    
    CASE WHEN employee_bar_raiser_derived_status = 'BAR_RAISER' THEN 'YES'
         ELSE 'NO' END AS active_br_flag,
    
    CASE WHEN employee_bar_raiser_derived_status = 'BAR_RAISER_IN_TRAINING' THEN 'YES'
         ELSE 'NO' END AS active_brit_flag
          
    FROM masterhr.employee_hc_current hc
    LEFT JOIN opsdw.sde_oa_phonetool sde_oa ON hc.employee_login = sde_oa.employee_login
    WHERE 1=1
    AND hc.job_title_short_name IN ('MgrIII,SDE', 'SDE III', 'SDEIII', 'MgrIIIP/A', 'Princ,SDE', 'SrMgr,Soft', 'Front-End', 'MgrII,SDE', 'SDE II', 'SDEII', 'Front-End', 'SDE I', 'SDEI')
    AND hc.job_level_name IN (4, 5, 6, 7) 
    --AND hc.reports_to_level_3_employee_login IN ('davecl', 'darcie', 'gcarpe')
    
),

D AS
(
  SELECT location_building_name, location_city_name, location_country_name, department_name, department_id, department_org_level2, emplid, employee_login, employee_full_name, job_entry_date,
        job_tech_indicator, job_level_name,Interviewer_Title, job_title_short_name, open_rec_title,
        job_last_hire_date, business_unit_name, business_unit_code, employee_class_name, employee_status_description, 
        reports_to_level_2_employee_name, reports_to_level_3_employee_name, reports_to_level_4_employee_name, reports_to_level_5_employee_name, reports_to_level_6_employee_name,
        reports_to_level_7_employee_name, reports_to_level_8_employee_name, reports_to_level_9_employee_name, reports_to_level_10_employee_name, reports_to_supervisor_employee_name, is_mghd, is_sfi, is_sde_oa, tenure_in_months, active_br_flag, active_brit_flag,

        sum(case when (event_role IN ('BAR_RAISER', 'BAR_RAISER_IN_TRAINING', 'HIRING_MANAGER', 'INTERVIEWER') AND event_type = 'On-site')then 1 else 0 end) AS OS_count,
        sum(case when (event_role IN ('BAR_RAISER', 'BAR_RAISER_IN_TRAINING', 'HIRING_MANAGER', 'INTERVIEWER') AND event_type = 'Phone Screen')then 1 else 0 end) AS PS_count,
        sum(case when (event_role = 'SHADOW' AND event_type = 'On-site')then 1 else 0 end) AS OS_shadow_count,
        sum(case when (event_role = 'SHADOW' AND event_type = 'Phone Screen')then 1 else 0 end) AS ps_shadow_count,
        sum(case when event_role = 'SHADOW' then 1 else 0 end) AS shadow_count_excluded,
        sum(case when event_role = 'LUNCH_BUDDY' then 1 else 0 end) AS lunch_buddy_count_excluded,
        sum(case when event_role = 'BAR_RAISER' then 1 else 0 end) AS br_onsite_interviews_total,
        sum(case when event_role = 'BAR_RAISER_IN_TRAINING' then 1 else 0 end) AS brit_onsite_interviews_total,
      
       (COUNT(interviewer_employee_id) - shadow_count_excluded - lunch_buddy_count_excluded) AS adjusted_interviews_total

  FROM (
      SELECT interviewer_employee_id, interviewer_employee_login, event_role, event_type, a.job_id, b.job_id, candidate_id, open_rec_title,
       job_guid, interview_summary_guid
      FROM A
      INNER JOIN B ON B.job_id = A.job_id
      GROUP BY interviewer_employee_id, interviewer_employee_login, event_role, event_type, a.job_id, b.job_id, candidate_id, open_rec_title,
       job_guid, interview_summary_guid
  ) AS raw_data

  RIGHT JOIN C
  ON C.emplid = raw_data.interviewer_employee_id

  GROUP BY location_building_name, location_city_name, location_country_name, department_name, department_id, department_org_level2, emplid, employee_login, employee_full_name, job_entry_date,
           job_tech_indicator, job_level_name,Interviewer_Title, job_title_short_name, open_rec_title, job_last_hire_date, business_unit_name, business_unit_code, employee_class_name, employee_status_description, 
           reports_to_level_2_employee_name, reports_to_level_3_employee_name, reports_to_level_4_employee_name, reports_to_level_5_employee_name, reports_to_level_6_employee_name,
           reports_to_level_7_employee_name, reports_to_level_8_employee_name, reports_to_level_9_employee_name, reports_to_level_10_employee_name, reports_to_supervisor_employee_name, is_mghd, is_sfi, is_sde_oa, tenure_in_months, active_br_flag, active_brit_flag
)


  SELECT location_building_name, location_city_name, location_country_name, department_name, D.department_id, department_org_level2, emplid, employee_login, employee_full_name, job_entry_date,
        job_tech_indicator, job_level_name,Interviewer_Title, job_title_short_name, open_rec_title, job_last_hire_date, business_unit_name, business_unit_code, employee_class_name, employee_status_description, 
        reports_to_level_2_employee_name, reports_to_level_3_employee_name, reports_to_level_4_employee_name, reports_to_level_5_employee_name, reports_to_level_6_employee_name,
        reports_to_level_7_employee_name, reports_to_level_8_employee_name, reports_to_level_9_employee_name, reports_to_level_10_employee_name, reports_to_supervisor_employee_name, is_mghd, is_sfi, is_sde_oa,
        tenure_in_months, active_br_flag, active_brit_flag, OS_count, PS_count, OS_shadow_count, ps_shadow_count, shadow_count_excluded,
        lunch_buddy_count_excluded, br_onsite_interviews_total, brit_onsite_interviews_total, adjusted_interviews_total, MAX(event_finish) AS last_interview_date
        
  FROM masterhr.interview_activity
  LEFT JOIN D
  ON D.employee_login = interview_activity.interviewer_employee_login

  GROUP BY location_building_name, location_city_name, location_country_name, D.department_id, department_name, department_org_level2, emplid, employee_login, employee_full_name, job_entry_date,
           job_tech_indicator, job_level_name,Interviewer_Title, job_title_short_name, open_rec_title, job_last_hire_date, business_unit_name, business_unit_code, employee_class_name, employee_status_description, 
           reports_to_level_2_employee_name, reports_to_level_3_employee_name, reports_to_level_4_employee_name, reports_to_level_5_employee_name, reports_to_level_6_employee_name,
           reports_to_level_7_employee_name, reports_to_level_8_employee_name, reports_to_level_9_employee_name, reports_to_level_10_employee_name, reports_to_supervisor_employee_name, is_mghd, is_sfi, is_sde_oa,
           tenure_in_months, active_br_flag, active_brit_flag, OS_count, PS_count, OS_shadow_count, ps_shadow_count, shadow_count_excluded,
           lunch_buddy_count_excluded, br_onsite_interviews_total, brit_onsite_interviews_total, adjusted_interviews_total
