WITH A AS
(
  SELECT DISTINCT location_building_name, location_city_name, location_country_name, department_name, department_id, department_org_level2, emplid, employee_login, employee_full_name, job_entry_date,
    job_tech_indicator, job_level_name, job_title_name AS Interviewer_Title, job_last_hire_date, business_unit_name, business_unit_code,
    employee_class_name, employee_status_description, 
    reports_to_level_2_employee_name, reports_to_level_3_employee_name, reports_to_level_4_employee_name, reports_to_level_5_employee_name, reports_to_level_6_employee_name, reports_to_supervisor_employee_name,
    DATEDIFF(month, job_last_hire_date, GETDATE()) AS "tenure_in_months",
    
    CASE WHEN employee_bar_raiser_flag = 'Y' THEN 'YES'
         ELSE 'NO' END AS active_br_flag,
    
    CASE WHEN employee_bar_raiser_status_code = 'I' THEN 'YES'
         ELSE 'NO' END AS active_brit_flag
    
    FROM masterhr.employee_hc_current
  WHERE employee_hc_current.job_title_short_name IN ('MgrIII,SDE', 'SDE III', 'MgrIIIP/A', 'Princ,SDE', 'SrMgr,Soft', 'Front-End') AND employee_hc_current.reports_to_level_3_employee_name = 'Clark,David H.'
),

B AS
(
  SELECT MAX(event_finish) AS last_interview_date,
      interviewer_employee_id,
      sum(case when event_role = 'SHADOW' then 1 else 0 end) AS shadow_count_excluded,
      sum(case when event_role = 'LUNCH_BUDDY' then 1 else 0 end) AS lunch_buddy_count_excluded,
      sum(case when event_role = 'BAR_RAISER' then 1 else 0 end) AS br_onsite_interviews_total,
      sum(case when event_role = 'BAR_RAISER_IN_TRAINING' then 1 else 0 end) AS brit_onsite_interviews_total,
     (COUNT(*) - shadow_count_excluded - lunch_buddy_count_excluded) AS adjusted_interviews_total,
      event_role,
      job_icims_id

  FROM masterhr.interview_activity
  WHERE  interview_activity.work_step = 'Interview Event' AND interview_activity.event_status = 'Occurred' 
  GROUP BY interview_activity.interviewer_employee_id, job_icims_id, event_role
),

C AS 
(
  SELECT DISTINCT job_id, snapshot_begin_timestamp, snapshot_end_timestamp, job_state, job_classification_title AS Open_Rec_Title
    FROM masterhr.requisition
  WHERE job_classification_title IN ('Manager III, Software Dev', 'Software Dev Engineer III', 'Mgr III, Programmer/Analyst', 'Front-End Engineer III')
)



SELECT * FROM A

INNER JOIN B ON A.emplid = B.interviewer_employee_id

INNER JOIN C ON B.job_icims_id = c.job_id


ORDER BY B.adjusted_interviews_total DESC;
