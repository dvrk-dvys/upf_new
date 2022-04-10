WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,reporting_year

    FROM opstadw.hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = 2019
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM opstadw.hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
)


Select responsevalue_value, codes_label,  ((Count(responsevalue_value)* 100.0 / 

(WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,reporting_year

    FROM opstadw.hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = 2019
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM opstadw.hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
)

Select Count(*)  

From opstadw.opsdw.irhmd_xfm

  INNER JOIN weeks wks ON (TRUNC(response_interviewstart) BETWEEN TRUNC(wks.calendar_day) AND (TRUNC(wks.calendar_day) + INTERVAL '6 DAY'))

where 1=1
and surveyvariable_label = 'Overall my internal transfer experience was frustration free.' 
AND codes_label != '' 
AND reporting_week_of_year = 32
))) as Percentage, reporting_week_of_year
--Select responsevalue_value, codes_label,  ((Count(responsevalue_value)* 100.0 / (Select Count(*)  From opstadw.opsdw.irhmd_xfm  where surveyvariable_label = 'Overall my internal transfer experience was frustration free.' AND codes_label != ''))) as Percentage

--SELECT * 
 From opstadw.opsdw.irhmd_xfm
  
  INNER JOIN weeks wks ON (TRUNC(response_interviewstart) BETWEEN TRUNC(wks.calendar_day) AND (TRUNC(wks.calendar_day) + INTERVAL '6 DAY'))

  WHERE survey_surveyname = 'Global iRMHD Survey' 
    AND codes_label != '' 
    AND surveyvariable_label= 'Overall my internal transfer experience was frustration free.' 
    AND reporting_week_of_year = 32
    --AND TRUNC(survey_enddate) >= '2019-01-01'
    --AND DATEPART(WEEK, survey_enddate) = 32
Group By codes_label
,responsevalue_value
,reporting_week_of_year
