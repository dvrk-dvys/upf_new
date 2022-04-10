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
    SELECT DISTINCT  employee_login, emplid, company_country_code
    FROM masterhr.employee_hc
    WHERE company_country_code IN ('AUT', 'BEL', 'CHE', 'CZE', 'DEU', 'DNK', 'ESP', 'FIN', 'FRA', 'GBR', 'IRL', 'ITA', 'LUX', 'NLD', 'NOR', 'POL', 'PRT', 'ROU', 'SVK', 'SWE', 'TUR')
)


Select surveyvariable_label, responsevalue_value, codes_label,  ((Count(responsevalue_value)* 100.0 / 

      (

      Select Count(*)  

      FROM opstadw.opsdw.irhmd_xfm

        INNER JOIN weeks wks ON (TRUNC(response_interviewstart) BETWEEN TRUNC(wks.calendar_day) AND (TRUNC(wks.calendar_day) + INTERVAL '6 DAY'))
        INNER JOIN reporting_line ON reporting_line.employee_login = irhmd_xfm.login_id
      WHERE 1=1
      AND codes_label != ''
      AND surveyvariable_label <> '' 
      --AND surveyvariable_label IN ('Overall my internal transfer experience was frustration free.', 'How did you receive feedback from your most recent interview?', 'How did you first learn about the role you most recently interviewed for?' )
      AND surveyvariable_label = 'Overall my internal transfer experience was frustration free.'
      --AND surveyvariable_label = 'How did you receive feedback from your most recent interview? ' 
      AND reporting_week_of_year = 32

      ))) as Percentage
,reporting_week_of_year
,calendar_month_of_year
,COUNT(surveyvariable_label) as totals
--,calendar_qtr



 From opstadw.opsdw.irhmd_xfm
  
  INNER JOIN weeks wks ON (TRUNC(response_interviewstart) BETWEEN TRUNC(wks.calendar_day) AND (TRUNC(wks.calendar_day) + INTERVAL '6 DAY'))
  INNER JOIN reporting_line ON reporting_line.employee_login = irhmd_xfm.login_id
  WHERE 1=1
    AND survey_surveyname = 'Global iRMHD Survey' 
    AND codes_label != '' 
    AND surveyvariable_label <> ''
 --   AND surveyvariable_label IN ('Overall my internal transfer experience was frustration free.', 'How did you receive feedback from your most recent interview?', 'How did you first learn about the role you most recently interviewed for?' )
    AND surveyvariable_label= 'Overall my internal transfer experience was frustration free.' 
    --AND surveyvariable_label = 'How did you receive feedback from your most recent interview? '
    AND reporting_week_of_year = 32
    --AND calendar_month_of_year = 1

Group By
surveyvariable_label 
,codes_label
,responsevalue_value
,reporting_week_of_year
,calendar_month_of_year
--,calendar_qtr

