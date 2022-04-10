  SELECT DISTINCT 
  employee_login, employee_full_name,
  employee_internal_email_address,
  department_name, employee_business_title,
--  reports_to_supervisor_employee_login, reports_to_supervisor_employee_name,
  reports_to_level_3_employee_login, reports_to_level_3_employee_name, 
  reports_to_level_4_employee_login, reports_to_level_4_employee_name, 
  reports_to_level_4_employee_login, reports_to_level_5_employee_name, 
  reports_to_level_6_employee_login, reports_to_level_6_employee_name
  FROM masterhr.employee_hc
  WHERE 1=1
  AND reports_to_level_3_employee_login = 'darcie' 
  AND reports_to_level_4_employee_login = 'kelleyse'
  AND reports_to_level_5_employee_login = 'chaluleu' 
  AND reports_to_level_6_employee_login = 'kevrodge'
