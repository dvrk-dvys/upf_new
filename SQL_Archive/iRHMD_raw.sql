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
    WHERE company_country_code IN ('AUT', 'BEL', 'CHE', 'CZE', 'DEU', 'DNK', 'ESP', 'FIN', 'FRA', 'GBR', 'IRL', 'ITA', 'LUX', 'NLD', 'NOR', 'POL', 'PRT', 'ROU', 'SVK', 'SWE', 'TUR')
    --WHERE reports_to_level_6_employee_login IN ('amandam', 'loscott', 'kallea')
)


SELECT 
--irhmd_xfm.login_id
--,reporting_week_of_year
--response_interviewstart
--,employee_business_title
* 
FROM opstadw.opsdw.irhmd_xfm
  
--INNER JOIN weeks wks ON (TRUNC(response_interviewstart) BETWEEN TRUNC(wks.calendar_day) AND (TRUNC(wks.calendar_day) + INTERVAL '6 DAY'))
--INNER JOIN reporting_line ON reporting_line.employee_login = irhmd_xfm.login_id

WHERE 1=1
   -- AND survey_surveyname = 'Global iRMHD Survey' 
    --AND codes_label != '' 
    --AND surveyvariable_label <> ''
    --AND surveyvariable_label= 'Overall my internal transfer experience was frustration free.' 

    --AND calendar_month_of_year = 8
    --AND response_responseid = '14148'
    --AND TRUNC(response_interviewstart) >= '2019-01-01'
    --AND DATEPART(WEEK, survey_enddate) = 32
--Group By 
--response_interviewstart,
--login_id,
---reporting_week_of_year,
--employee_business_title
