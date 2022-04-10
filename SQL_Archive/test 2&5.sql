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

counts AS (

    SELECT 
    sla_defect
    ,clock_still_running
    ,last_updated_dt
    ,interview_summary_id
    ,clock_stop_goal
    , COUNT(DISTINCT (CASE WHEN clock_still_running = 'Yes' AND clock_stop_goal >= last_updated_dt THEN interview_summary_id ELSE NULL END)) AS future_goal
    , COUNT(DISTINCT (CASE WHEN sla_defect = 'No' AND clock_still_running = 'No' THEN interview_summary_id ELSE NULL END)) AS head_success
    , COUNT(DISTINCT (CASE WHEN calc_cycle_time > 15 THEN interview_summary_id ELSE NULL END)) AS tail_failure
    --,reporting_week_of_year
    --,calendar_month_of_year
  --  ,calendar_qtr
--    ,reporting_year
    

    ,interview_year
    ,interview_quarter
    ,interview_month
    ,interview_week


    ,interview_stage
    ,candidate_type


    FROM hrmetrics.rad_two_five_promise
   -- INNER JOIN weeks wks ON wks.calendar_day BETWEEN clock_start_time AND clock_stop_time
   -- INNER JOIN weeks wks ON (TRUNC(interview_date) BETWEEN TRUNC(wks.calendar_day) AND (TRUNC(wks.calendar_day) + INTERVAL '6 DAY'))    

    WHERE 1=1
    AND(  (interview_week < 8 AND (rectr_reports_to_level6_id IN ( 'LOSCOTT') OR rectr_reports_to_level7_id IN ( 'LOSCOTT') )) 
    or (rectr_reports_to_level6_id IN ( 'AMANDAM') OR rectr_reports_to_level7_id IN ( 'AMANDAM') ))


    AND candidate_type = 'Internal'
    AND interview_year = 2019


    GROUP BY 
     sla_defect
    ,clock_still_running
    ,last_updated_dt
    ,interview_summary_id
    ,clock_stop_goal
    --,reporting_week_of_year
    --,calendar_month_of_year
    --,calendar_qtr
    --,reporting_year

    
    ,interview_year
    ,interview_quarter
    ,interview_month
    ,interview_week
    
    ,interview_stage
    ,candidate_type

),

sums AS (

    SELECT DISTINCT
    
    SUM(future_goal) AS future_goal_sum
    ,SUM(head_success) AS head_success_sum
    ,COUNT(interview_summary_id) AS total_sum
    ,SUM(tail_failure) AS tail_failure
   -- ,reporting_week_of_year
   -- ,calendar_month_of_year
   -- ,calendar_qtr
   -- ,reporting_year
    ,interview_stage
    ,candidate_type
    
    ,interview_year
    ,interview_quarter
    ,interview_month
    ,interview_week
    
    FROM counts
    WHERE 1=1
   -- AND sourcer_reports_to_level6_id = 'AMANDAM' OR cur_rectr_reports_to_level6_id = 'AMANDAM'
   -- AND reporting_week_of_year = 37
    
    GROUP BY
   -- reporting_week_of_year
   -- ,calendar_month_of_year
   -- ,calendar_qtr
   -- ,reporting_year
    interview_stage
    ,candidate_type
    
    ,interview_year
    ,interview_quarter
    ,interview_month
    ,interview_week

)

SELECT
interview_stage
,(CAST(head_success_sum AS decimal(10,3))/CAST((total_sum - future_goal_sum) AS decimal(10,3))) AS head_success_rate
,(CAST(head_success_sum + (((total_sum - future_goal_sum) - head_success_sum)- tail_failure) AS decimal(10,3))/CAST((total_sum - future_goal_sum) AS decimal(10,3))) AS tail_success_rate
,(total_sum - future_goal_sum) AS  #ofinterviews
,head_success_sum
,(((total_sum - future_goal_sum) - head_success_sum)- tail_failure) AS tail_success
,future_goal_sum
,tail_failure
--,reporting_week_of_year
--,calendar_month_of_year
--,calendar_qtr
--,reporting_year

,interview_year
,interview_quarter
,interview_month
,interview_week


,candidate_type
,(#ofinterviews - head_success_sum) AS head_failure
,total_sum
,TRUNC(SYSDATE) AS generated_date


FROM sums
WHERE 1=1
--AND sourcer_reports_to_level6_id = 'AMANDAM' OR cur_rectr_reports_to_level6_id = 'AMANDAM'
--AND reporting_week_of_year = 38
--AND interview_week = 38
