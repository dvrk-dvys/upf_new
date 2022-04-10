WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year

    FROM opstadw.hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = DATEPART(year, sysdate)
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

    ,reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year
     ,rectr_reports_to_level3_id
     ,rectr_reports_to_level4_id
     ,rectr_reports_to_level5_id
     ,rectr_reports_to_level6_id   
     ,rectr_reports_to_level7_id
     ,rectr_supervisor_id
     ,recruiter_id
     ,sourcer_reports_to_level3_id
     ,sourcer_reports_to_level4_id
     ,sourcer_reports_to_level5_id
     ,sourcer_reports_to_level6_id
     ,sourcer_reports_to_level7_id
     ,sourcer_supervisor_id
     ,sourcer_id

    
    ,interview_week
    ,interview_month
    ,interview_quarter
    ,interview_year
    
    ,interview_stage
    ,candidate_type


    FROM hrmetrics.rad_two_five_promise

     --INNER JOIN weeks wks ON wks.calendar_day BETWEEN clock_start_time AND clock_stop_time
      INNER JOIN weeks wks ON (TRUNC(interview_date) BETWEEN TRUNC(wks.calendar_day) AND (TRUNC(wks.calendar_day) + INTERVAL '6 DAY'))    

    WHERE 1=1
    AND( hm_reports_to_level4_id = 'FEITZING'
    OR hm_reports_to_level5_id = 'FEITZING')
    AND candidate_type IN ('External', 'Internal')

    GROUP BY 
     sla_defect
    ,clock_still_running
    ,last_updated_dt
    ,interview_summary_id
    ,clock_stop_goal
    ,reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year
    
    ,interview_week
    ,interview_month
    ,interview_quarter
    ,interview_year
    ,interview_stage
    ,candidate_type
    ,rectr_reports_to_level3_id
     ,rectr_reports_to_level4_id
     ,rectr_reports_to_level5_id
     ,rectr_reports_to_level6_id   
     ,rectr_reports_to_level7_id
     ,rectr_supervisor_id
     ,recruiter_id
     ,sourcer_reports_to_level3_id
     ,sourcer_reports_to_level4_id
     ,sourcer_reports_to_level5_id
     ,sourcer_reports_to_level6_id
     ,sourcer_reports_to_level7_id
     ,sourcer_supervisor_id
     ,sourcer_id
),

sums AS (

    SELECT DISTINCT
    
    SUM(future_goal) AS future_goal_sum
    ,SUM(head_success) AS head_success_sum
    ,COUNT(interview_summary_id) AS total_sum
    ,SUM(tail_failure) AS tail_failure
    ,reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year
    ,interview_stage
    ,candidate_type


    FROM counts
    WHERE 1=1
    
    GROUP BY
    reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year
    ,interview_stage
    ,candidate_type
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
,reporting_week_of_year
,calendar_month_of_year
,calendar_qtr
,reporting_year
,candidate_type
,(#ofinterviews - head_success_sum) AS head_failure
,total_sum
,TRUNC(SYSDATE) AS generated_date

FROM sums
WHERE 1=1

