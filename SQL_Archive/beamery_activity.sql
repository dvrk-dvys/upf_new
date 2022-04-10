WITH prep as (

      SELECT DISTINCT
      
      CAST(LEFT(TRIM(RIGHT(TRIM(LEFT(month,ABS(LEN(month)-CHARINDEX('-',month)))),ABS(LEN(TRIM(LEFT(month,ABS(LEN(month)-CHARINDEX('-',month)))))-CHARINDEX(' ',TRIM(LEFT(month,ABS(LEN(month)-CHARINDEX('-',month)))))))), 2) AS INT) as day_num,
      cast(EXTRACT(MONTH FROM to_date(TRIM(LEFT(TRIM(LEFT(month,LEN(month)-CHARINDEX('-',month))), CHARINDEX(' ',TRIM(LEFT(month,LEN(month)-CHARINDEX('-',month)))))), 'Mon')) AS INT) as month_num,
      month AS week_inter,
      ac.*

      FROM opsdw.beamery_csv_activity ac
)

Select
    calendar_day,
    reporting_week_of_year,
    calendar_month_of_year,
    calendar_qtr,
    reporting_year,
    wks.calendar_year,
    --prep.*
    day_num,
    month_num,
    week_inter,
    aliase,
    user_name,
    week,
    month,
    CAST(contacts_added AS INT),
    CAST(contacts_updated AS INT),
    CAST(tasks_created AS INT),
    CAST(tasks_assigned AS INT),
    CAST(tasks_completed AS INT),
    CAST(notes_logged AS INT),
    CAST(phone_calls_logged AS INT),
    CAST(meetings_logged AS INT),
    CAST(inmail_logged AS INT),
    CAST(direct_messages_sent AS INT),
    CAST(email_conversations AS INT),
    organization_name,
    level_3_leader,
    level_4_leader,
    level_5_leader,
    level_6_leader,
    level_7_leader,
    cost_center,
    company,
    country,
    hc.job_title_name,
    hc.job_level_name,
    hc.reports_to_supervisor_employee_login,
    hc.reports_to_supervisor_employee_name

from prep 

              
    LEFT JOIN masterhr.employee_hc_current hc ON hc.employee_login = prep.aliase
    LEFT JOIN opstadw.hrmetrics.o_reporting_days wks ON (CASE WHEN CAST(prep.week AS INT) >= 24 AND month_num != 12 THEN wks.calendar_year = 2020
                                                         ELSE wks.calendar_year = 2019
                                                         END)
                                                     AND wks.calendar_month_of_year = month_num 
                                                     AND wks.calendar_day_of_month = day_num

            


