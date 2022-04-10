SELECT DISTINCT
    lgn.*,
     CASE WHEN (reports_to_level_5_employee_login = 'chaluleu' OR reports_to_level_6_employee_login = 'chaluleu') THEN 'NA Ops TA'
         WHEN (reports_to_level_5_employee_login = 'ninasj' OR reports_to_level_6_employee_login = 'ninasj') THEN 'EMEA Ops TA'
         WHEN (reports_to_level_5_employee_login = 'barresi' OR reports_to_level_6_employee_login = 'barresi') THEN 'Ops Tech'
         ELSE 'Other' END AS Leader,
    hc.job_title_name,
    hc.job_level_name,
    hc.reports_to_supervisor_employee_login,
    hc.reports_to_supervisor_employee_name,
    calendar_day,
    reporting_week_of_year,
    calendar_month_of_year,
    calendar_qtr,
    reporting_year
    

 
FROM opsdw.beamery_csv_logins lgn
    LEFT JOIN masterhr.employee_hc hc ON hc.employee_login = lgn.aliase
    LEFT JOIN opstadw.hrmetrics.o_reporting_days wks ON wks.calendar_day = lgn.last_login
    
WHERE 1=1
--AND(reports_to_level_6_employee_login IN ('chaluleu', 'ninasj', 'barresi')
--or reports_to_level_5_employee_login IN ('chaluleu', 'ninasj', 'barresi'))
