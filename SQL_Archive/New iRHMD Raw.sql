WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year

    FROM opstadw.hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = 2019
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM opstadw.hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
),

reporting_line AS (
    SELECT DISTINCT reports_to_level_6_employee_login, reports_to_level_6_employee_name, employee_login, emplid, employee_business_title
    FROM masterhr.employee_hc
    WHERE 1=1
    AND company_country_code IN ('AUT', 'BEL', 'CHE', 'CZE', 'DEU', 'DNK', 'ESP', 'FIN', 'FRA', 'GBR', 'IRL', 'ITA', 'LUX', 'NLD', 'NOR', 'POL', 'PRT', 'ROU', 'SVK', 'SWE', 'TUR')
    --AND reports_to_level_6_employee_login IN ('amandam', 'loscott', 'kallea')
)




SELECT *    
FROM opstadw.opsdw.irhmd_xfm

--INNER JOIN weeks wks ON (TRUNC(response_interviewstart) BETWEEN TRUNC(wks.calendar_day) AND (TRUNC(wks.calendar_day) + INTERVAL '6 DAY'))
INNER JOIN reporting_line ON reporting_line.emplid = irhmd_xfm.empl_id
WHERE 1=1
