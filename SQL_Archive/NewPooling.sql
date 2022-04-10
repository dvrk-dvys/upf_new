WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,reporting_year

    FROM hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = 2019
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
)



SELECT calendar_day, reporting_week_of_year, reporting_year, updated_date, snapshot_begin_timestamp, insert_time, snapshot_end_timestamp, department_effective_date, final_approval_date, job_state, enter_state_time, requisition_age, requisition_opened_time, 
requisition_accepted_offer_time, requisition_pooling_time, sourcer_employee_login, desired_start_date, *
FROM phoenix_tier2.requisition_conf rc

INNER JOIN weeks wks ON wks.calendar_day BETWEEN rc.enter_state_time  AND rc.updated_date
WHERE sourcer_reports_to_level_6_employee_login = 'amandam' AND job_state != 'POOLING' AND requisition_age > 100 AND reporting_week_of_year = 17 --AND TRUNC(sysdate) BETWEEN snapshot_begin_timestamp AND snapshot_end_timestamp


--NOTE: The requisition age is to current date. So would take brute force calculation to back fill this report. But for the current week, it could work 
