SELECT DISTINCT employee_display_name, steam_leader, employee_login, employee_business_title, business_unit_code, business_unit_short_name, comp_frequency_descr, department_id, 
department_name, department_short_name, employee_class_name, employee_type_short_name, job_title_name, 
reports_to_level_2_employee_name, reports_to_level_3_employee_name, reports_to_level_4_employee_name, reports_to_level_5_employee_name, reports_to_level_6_employee_name, job_action_date, DATEPART(year, job_action_date)

FROM masterhr.employee_hc department_owner_employee_name
WHERE 1=1


AND employee_class_name = 'Regular Full Time'
--AND employee_login IN ('llandeb', 'helgblak', 'chloejac', 'korthm', 'marybetc', 'celescas', 'osupike') -- not in
AND (DATEPART(year, job_action_date) = 2018
OR DATEPART(year, job_action_date) = 2019)

AND reports_to_level_2_employee_name = 'Galetti,Elizabeth A'
AND reports_to_level_3_employee_name = 'Cakaric,Darcie'
AND reports_to_level_4_employee_name = 'Kelley,Sean Patrick'
AND reports_to_level_5_employee_name = 'Chaluleu,Maria Lourdes'
AND reports_to_level_6_employee_name = 'Wilson,Johnny'
