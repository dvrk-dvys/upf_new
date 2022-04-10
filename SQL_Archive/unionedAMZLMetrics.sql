WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year

    FROM hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = DATEPART(year, sysdate)
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
),

current_data AS (
    SELECT 
    max(reporting_week_of_year) AS current_week
    ,max(calendar_month_of_year) AS current_month
    ,max(calendar_qtr) AS current_quarter
    ,reporting_year AS current_year

    FROM hrmetrics.o_reporting_days

    WHERE 1=1
    AND calendar_day_of_week = 1 
    AND reporting_year = DATEPART(year, sysdate)
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
    AND calendar_month_of_year <= DATEPART(month, sysdate)

    GROUP BY
    reporting_year
    
),



reporting_line AS (

    SELECT DISTINCT 
    employee_login, employee_full_name,
    employee_internal_email_address,
  --  department_name, employee_business_title,
  --  reports_to_supervisor_employee_login, reports_to_supervisor_employee_name,
    reports_to_level_3_employee_login, reports_to_level_3_employee_name, 
    reports_to_level_4_employee_login, reports_to_level_4_employee_name, 
    reports_to_level_5_employee_login, reports_to_level_5_employee_name, 
    reports_to_level_6_employee_login, reports_to_level_6_employee_name
    FROM masterhr.employee_hc
    WHERE 1=1
    AND reports_to_level_3_employee_login = 'darcie' 
    AND reports_to_level_4_employee_login = 'kelleyse'
    AND reports_to_level_5_employee_login = 'chaluleu' 
    AND reports_to_level_6_employee_login = 'kevrodge'
    AND reports_to_level_7_employee_login = 'wllmm'

),

reporting_line_hm AS (

    SELECT DISTINCT employee_login FROM masterhr.employee_hc 
    WHERE 1=1
    AND reports_to_level_5_employee_login = 'lacall' 

),



dwell_min_max AS (

    SELECT DISTINCT
    
    reqs.job_id
    ,reqs.job_icims_id
    ,reqs.job_guid
    ,reqs.current_job_state
    ,MIN(TRUNC(reqs.enter_state_time)) as event_min_date_time
    ,MAX(TRUNC(reqs.enter_state_time)) as event_max_date_time


    FROM masterhr.requisition reqs
    INNER JOIN reporting_line ON reporting_line.employee_login = reqs.current_recruiter_employee_login
    INNER JOIN reporting_line_hm ON reporting_line_hm.employee_login = reqs.current_hiring_manager_employee_login        

    WHERE 1=1 
    AND reqs.job_state IN ('SUSPENDED', 'APPROVED', 'OPEN')    
    AND reqs.requisition_opened_time >= '2019-01-01 00:00:00'
    AND ofa_cost_center_code IN ('1153', '1153HR')

    GROUP BY
    reqs.job_id
    ,reqs.job_icims_id
    ,reqs.job_guid
    ,reqs.current_job_state


),

dwellraw AS (

        SELECT DISTINCT

        reqs.job_icims_id
        ,reqs.job_id
        ,reqs.job_guid
        ,reqs.current_job_state
        ,dmm.event_min_date_time AS start_dwell
        ,dmm.event_max_date_time AS check_of_max_offer
        ,MIN(TRUNC(reqs.enter_state_time)) AS end_dwell
        ,(CASE WHEN reqs.current_job_state IN ( 'OPEN', 'APPROVED') THEN SYSDATE ELSE MIN(TRUNC(reqs.enter_state_time)) END) AS test_end
        ,final_approval_date
        ,reqs.requisition_opened_time
        
        ,reporting_line.employee_login
        ,employee_internal_email_address
        ,reports_to_level_3_employee_login, reports_to_level_3_employee_name 
        ,reports_to_level_4_employee_login, reports_to_level_4_employee_name 
        ,reports_to_level_5_employee_login, reports_to_level_5_employee_name 
        ,reports_to_level_6_employee_login, reports_to_level_6_employee_name

        FROM dwell_min_max dmm
        LEFT JOIN masterhr.requisition reqs ON dmm.job_icims_id = reqs.job_icims_id AND dmm.job_guid = reqs.job_guid AND TRUNC(reqs.enter_state_time) >= TRUNC(dmm.event_max_date_time)
        INNER JOIN reporting_line ON reporting_line.employee_login = reqs.current_recruiter_employee_login
        INNER JOIN reporting_line_hm ON reporting_line_hm.employee_login = reqs.current_hiring_manager_employee_login        

        WHERE 1=1
        AND reqs.job_icims_id IS NOT NULL
        AND reqs.job_id IS NOT NULL
        AND reqs.current_job_state != 'POOLING'
        AND reqs.requisition_opened_time >= '2019-01-01 00:00:00'
        AND ofa_cost_center_code IN ('1153', '1153HR')

        GROUP BY
        reqs.job_id
        ,reqs.job_icims_id
        ,reqs.job_guid
        ,reqs.final_approval_date
        ,reqs.requisition_opened_time
        ,dmm.event_min_date_time
        ,dmm.event_max_date_time
        ,reqs.current_job_state
        ,reporting_line.employee_login
        ,employee_internal_email_address
        ,reports_to_level_3_employee_login, reports_to_level_3_employee_name 
        ,reports_to_level_4_employee_login, reports_to_level_4_employee_name 
        ,reports_to_level_5_employee_login, reports_to_level_5_employee_name 
        ,reports_to_level_6_employee_login, reports_to_level_6_employee_name

),

prep_open AS (

SELECT DISTINCT
        dr.job_icims_id
        ,dr.job_id
        ,dr.job_guid
        ,DATEDIFF(day, start_dwell, CASE WHEN (test_end > SYSDATE or current_job_state IN ('FILLED', 'OFFER ACCEPTED')) THEN SYSDATE ELSE test_end END) AS total_dwelling_time
        ,DATEDIFF(day, start_dwell, CASE WHEN ((TRUNC(calendar_day) + INTERVAL '6 DAY') > SYSDATE OR current_job_state IN ('FILLED', 'OFFER ACCEPTED')) THEN SYSDATE ELSE (TRUNC(calendar_day) + INTERVAL '6 DAY') END) AS dwelling_time
        ,wks.calendar_day 
        ,reporting_week_of_year
        ,calendar_month_of_year
        ,calendar_qtr
        ,reporting_year
        ,start_dwell
        ,test_end
        ,current_job_state
        ,dr.requisition_opened_time
        ,TRUNC(SYSDATE) AS generated_date
        
        ,employee_login
        ,employee_internal_email_address
        ,reports_to_level_3_employee_login, reports_to_level_3_employee_name 
        ,reports_to_level_4_employee_login, reports_to_level_4_employee_name 
        ,reports_to_level_5_employee_login, reports_to_level_5_employee_name 
        ,reports_to_level_6_employee_login, reports_to_level_6_employee_name


FROM dwellraw dr
    INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND test_end

WHERE 1=1
        
),

--Open Reqs Week over Week-
open_reqs_change AS (

    select
        p.job_id
        ,p.job_icims_id
        ,p.job_guid
        ,p.current_job_state
        ,p.total_dwelling_time
        ,p.dwelling_time
        ,calendar_day
        ,reporting_week_of_year
        ,calendar_month_of_year
        ,calendar_qtr
        ,reporting_year
        ,p.start_dwell
        ,p.test_end

        ,p.requisition_opened_time
        ,current_week
        ,current_month
        ,current_quarter
        ,p.generated_date    
        ,p.employee_login
        ,p.employee_internal_email_address
        ,p.reports_to_level_3_employee_login, p.reports_to_level_3_employee_name 
        ,p.reports_to_level_4_employee_login, p.reports_to_level_4_employee_name 
        ,p.reports_to_level_5_employee_login, p.reports_to_level_5_employee_name 
        ,p.reports_to_level_6_employee_login, p.reports_to_level_6_employee_name
        ,reqs.job_classification_title
        ,reqs.job_level
        ,building


    FROM prep_open p
    LEFT JOIN current_data cd on p.reporting_year = cd.current_year
    LEFT JOIN masterhr.requisition reqs ON p.job_icims_id = reqs.job_icims_id AND p.job_guid = reqs.job_guid AND (TRUNC(p.calendar_day) BETWEEN TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(reqs.snapshot_end_timestamp))
    WHERE 1=1
    AND ofa_cost_center_code IN ('1153', '1153HR')

),

closed_min AS (

    SELECT DISTINCT
    reqs.job_id
    ,reqs.job_icims_id
    ,reqs.job_guid
    ,reqs.current_job_state
    ,MIN(TRUNC(reqs.enter_state_time)) as event_min_date_time
    ,MAX(TRUNC(reqs.enter_state_time)) as event_max_date_time


    FROM masterhr.requisition reqs
    INNER JOIN reporting_line ON reporting_line.employee_login = reqs.current_recruiter_employee_login
    INNER JOIN reporting_line_hm ON reporting_line_hm.employee_login = reqs.current_hiring_manager_employee_login        

    WHERE 1=1 
    AND reqs.job_state IN ('FILLED', 'ELIMINATED', 'OFFER ACCEPTED')    
    AND reqs.requisition_opened_time >= '2019-01-01 00:00:00'
    AND ofa_cost_center_code IN ('1153', '1153HR')

    GROUP BY
    reqs.job_id
    ,reqs.job_icims_id
    ,reqs.job_guid
    ,reqs.current_job_state


),

closedraw AS (

        SELECT DISTINCT
        reqs.job_id
        ,reqs.job_icims_id
        ,reqs.job_guid
        ,reqs.current_job_state
        ,dmm.event_min_date_time AS closed_date
        ,dmm.event_max_date_time AS check_of_max_close
        ,final_approval_date
        ,reqs.requisition_opened_time
        
        ,reporting_line.employee_login
        ,employee_internal_email_address
        ,reports_to_level_3_employee_login, reports_to_level_3_employee_name 
        ,reports_to_level_4_employee_login, reports_to_level_4_employee_name 
        ,reports_to_level_5_employee_login, reports_to_level_5_employee_name 
        ,reports_to_level_6_employee_login, reports_to_level_6_employee_name


        FROM closed_min dmm
        LEFT JOIN masterhr.requisition reqs ON dmm.job_icims_id = reqs.job_icims_id AND dmm.job_guid = reqs.job_guid AND TRUNC(reqs.enter_state_time) >= TRUNC(dmm.event_max_date_time)
        INNER JOIN reporting_line ON reporting_line.employee_login = reqs.current_recruiter_employee_login
        INNER JOIN reporting_line_hm ON reporting_line_hm.employee_login = reqs.current_hiring_manager_employee_login        

        WHERE 1=1
        AND reqs.job_icims_id IS NOT NULL
        AND reqs.job_id IS NOT NULL
        AND reqs.current_job_state != 'POOLING'
        AND reqs.requisition_opened_time >= '2019-01-01 00:00:00'
        AND ofa_cost_center_code IN ('1153', '1153HR')

        GROUP BY
        reqs.job_id
        ,reqs.job_icims_id
        ,reqs.job_guid
        ,reqs.final_approval_date
        ,reqs.requisition_opened_time
        ,dmm.event_min_date_time
        ,dmm.event_max_date_time
        ,reqs.current_job_state
        ,reporting_line.employee_login
        ,employee_internal_email_address
        ,reports_to_level_3_employee_login, reports_to_level_3_employee_name 
        ,reports_to_level_4_employee_login, reports_to_level_4_employee_name 
        ,reports_to_level_5_employee_login, reports_to_level_5_employee_name 
        ,reports_to_level_6_employee_login, reports_to_level_6_employee_name

),

prep_closed AS (

        SELECT DISTINCT
        cr.job_id
        ,cr.job_icims_id
        ,cr.job_guid
        ,wks.calendar_day 
        ,reporting_week_of_year
        ,calendar_month_of_year
        ,calendar_qtr
        ,reporting_year
        ,closed_date
        ,current_job_state
        ,cr.requisition_opened_time
        ,TRUNC(SYSDATE) AS generated_date
        
        ,employee_login
        ,employee_internal_email_address
        ,reports_to_level_3_employee_login, reports_to_level_3_employee_name 
        ,reports_to_level_4_employee_login, reports_to_level_4_employee_name 
        ,reports_to_level_5_employee_login, reports_to_level_5_employee_name 
        ,reports_to_level_6_employee_login, reports_to_level_6_employee_name

        

        FROM closedraw cr
            INNER JOIN weeks wks ON closed_date BETWEEN wks.calendar_day AND (TRUNC(wks.calendar_day) + INTERVAL '6 DAY')
        WHERE 1=1
        
),

--Closed Reqs Week over Week
closed_requisitions AS (

    SELECT
    p.job_id,
    p.job_icims_id,
    p.job_guid,
    calendar_day,
    reporting_week_of_year,
    calendar_month_of_year,
    calendar_qtr,
    reporting_year,
    p.closed_date,
    p.current_job_state,
    p.requisition_opened_time,
    current_week,
    current_month,
    current_quarter,
    current_year,
    p.generated_date,
    
    p.employee_login,
    p.employee_internal_email_address,
    p.reports_to_level_3_employee_login, p.reports_to_level_3_employee_name,
    p.reports_to_level_4_employee_login, p.reports_to_level_4_employee_name, 
    p.reports_to_level_5_employee_login, p.reports_to_level_5_employee_name, 
    p.reports_to_level_6_employee_login, p.reports_to_level_6_employee_name,
    reqs.job_classification_title,
    reqs.job_level,
    building


    FROM prep_closed p
    LEFT JOIN current_data cd on p.reporting_year = cd.current_year
    LEFT JOIN masterhr.requisition reqs ON p.job_icims_id = reqs.job_icims_id AND p.job_guid = reqs.job_guid AND (TRUNC(calendar_day) BETWEEN reqs.snapshot_begin_timestamp AND reqs.snapshot_end_timestamp)
    WHERE 1=1
    
),

---Candidates Change Week Over Week

candidates AS (


      SELECT 
         reqs.job_id,
         reqs.job_guid,
         reqs.job_icims_id,
         wst.icims_id,
         wst.person_id, 
         wst.status,
         reqs.current_job_state,
         reqs.calendar_day,
         reqs.reporting_week_of_year,
         reqs.calendar_month_of_year,
         reqs.calendar_qtr,
         reqs.reporting_year,
         reqs.job_classification_title,
         reqs.job_level,
         building,
 

         cast((TIMESTAMP 'epoch' + CAST(wst.updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ') as date) AS updated_date,
         cast((TIMESTAMP 'epoch' + CAST(wst.icims_created_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ')as date) AS icims_created_timestamp
   
      FROM open_reqs_change reqs
      LEFT JOIN ads.worksteps wst ON reqs.job_icims_id = wst.job_id AND (cast((TIMESTAMP 'epoch' + CAST(wst.updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ') as date) BETWEEN calendar_day AND (TRUNC(calendar_day) + INTERVAL '6 DAY'))

      WHERE 1=1
      AND reqs.job_icims_id IS NOT NULL
      AND reqs.job_id IS NOT NULL
      AND status IN ( 'Candidate - Interview Process - Schedule Interview',
                    'Candidate - Interview Process - Phone Screen Rescheduling',
                    'Candidate - Interview Process - Interview Rescheduling',
                    'Candidate - Interview Process - Phone Screen Pending',
                    'Candidate - Interview Process - Interview Pending',
                    'Candidate - Interview Process - On Hold',


                    'Candidate - Interview Process - Phone Screen',
                    'Candidate - Interview Process - Interview',
                    'Candidate - Interview Process - On-Campus Interview',
                    'Candidate - Interview Process - On-Campus Interview',


                    'Candidate - Interview Process - Debrief',
                    'Internal Transfer - Prepare Offer',
                    'Candidate - Interview Process - Phone Screen Complete - HM Action Required',
                    'Candidate - Offer - Accepted',
                    'Candidate - Offer - Approved',
                    'Candidate - Offer - Declined/Rejected',
                    'Candidate - Offer - Cancelled',
                    'Candidate - Offer - Extended',
                    'Candidate - Offer - Requested',
                    'Rejected - Recycle Candidate',
                    'Rejected - Rejected Applicant',
                    'Rejected - Rejected for Amazon',
                    'Rejected - Rejected for Internal Transfer')

)



----Union of all the WBR metrics-------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
,unionedAMZLMetrics as (
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    SELECT 'Open Reqs WoW'::VARCHAR(200) AS metric_name
            ,job_icims_id::VARCHAR(200)
            ,job_guid::VARCHAR(200)
            ,NULL AS icims_id
            ,NULL AS person_id
            ,NULL AS status
            ,current_job_state::VARCHAR(200)
            ,total_dwelling_time::VARCHAR(200)
            ,dwelling_time::VARCHAR(200)
            ,calendar_day::VARCHAR(200)
            ,reporting_week_of_year::VARCHAR(200)
            ,calendar_month_of_year::VARCHAR(200)
            ,calendar_qtr::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,start_dwell::VARCHAR(200)
            ,test_end::VARCHAR(200)
            ,NULL AS closed_date
            ,requisition_opened_time::VARCHAR(200)
            ,NULL AS updated_date
            ,NULL AS icims_created_timestamp
            ,current_week::VARCHAR(200)
            ,current_month::VARCHAR(200)
            ,current_quarter::VARCHAR(200)
            ,generated_date::VARCHAR(200)
            ,employee_login::VARCHAR(200)
            ,employee_internal_email_address::VARCHAR(200)
            ,reports_to_level_3_employee_login::VARCHAR(200), reports_to_level_3_employee_name::VARCHAR(200) 
            ,reports_to_level_4_employee_login::VARCHAR(200), reports_to_level_4_employee_name::VARCHAR(200) 
            ,reports_to_level_5_employee_login::VARCHAR(200), reports_to_level_5_employee_name::VARCHAR(200) 
            ,reports_to_level_6_employee_login::VARCHAR(200), reports_to_level_6_employee_name::VARCHAR(200) 
            ,job_classification_title::VARCHAR(200)
            ,job_level::VARCHAR(200)
            ,building::VARCHAR(200)
            ,job_id::VARCHAR(200)               
    FROM open_reqs_change

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 'Closed Reqs WoW'::VARCHAR(200) AS metric_name
            ,job_icims_id::VARCHAR(200)
            ,job_guid::VARCHAR(200)
            ,NULL AS icims_id
            ,NULL AS person_id
            ,NULL AS status
            ,current_job_state::VARCHAR(200)
            ,NULL AS total_dwelling_time
            ,NULL AS dwelling_time
            ,NULL AS calendar_day
            ,reporting_week_of_year::VARCHAR(200)
            ,calendar_month_of_year::VARCHAR(200)
            ,calendar_qtr::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,NULL AS start_dwell
            ,NULL AS test_end
            ,closed_date::VARCHAR(200)
            ,requisition_opened_time::VARCHAR(200)
            ,NULL AS updated_date
            ,NULL AS icims_created_timestamp
            ,current_week::VARCHAR(200)
            ,current_month::VARCHAR(200)
            ,current_quarter::VARCHAR(200)
            ,generated_date::VARCHAR(200)
            ,employee_login::VARCHAR(200)
            ,employee_internal_email_address::VARCHAR(200)
            ,reports_to_level_3_employee_login::VARCHAR(200), reports_to_level_3_employee_name::VARCHAR(200) 
            ,reports_to_level_4_employee_login::VARCHAR(200), reports_to_level_4_employee_name::VARCHAR(200) 
            ,reports_to_level_5_employee_login::VARCHAR(200), reports_to_level_5_employee_name::VARCHAR(200) 
            ,reports_to_level_6_employee_login::VARCHAR(200), reports_to_level_6_employee_name::VARCHAR(200) 
            ,job_classification_title::VARCHAR(200)
            ,job_level::VARCHAR(200)
            ,building::VARCHAR(200)
            ,job_id::VARCHAR(200)                                              
    FROM closed_requisitions



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 'Candidates WoW'::VARCHAR(200) AS metric_name
            ,job_icims_id::VARCHAR(200)
            ,job_guid::VARCHAR(200)
            ,icims_id::VARCHAR(200)
            ,person_id::VARCHAR(200)
            ,status::VARCHAR(200)
            ,current_job_state::VARCHAR(200)
            ,NULL AS total_dwelling_time
            ,NULL AS dwelling_time
            ,calendar_day::VARCHAR(200)
            ,reporting_week_of_year::VARCHAR(200)
            ,calendar_month_of_year::VARCHAR(200)
            ,calendar_qtr::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,NULL AS start_dwell
            ,NULL AS test_end
            ,NULL AS closed_date
            ,NULL AS requisition_opened_time
            ,updated_date
            ,icims_created_timestamp
            ,NULL AS current_week
            ,NULL AS current_month
            ,NULL AS current_quarter
            ,NULL AS generated_date
            ,NULL AS employee_login
            ,NULL AS employee_internal_email_address
            ,NULL AS reports_to_level_3_employee_login, NULL AS reports_to_level_3_employee_name 
            ,NULL AS reports_to_level_4_employee_login, NULL AS reports_to_level_4_employee_name 
            ,NULL AS reports_to_level_5_employee_login, NULL AS reports_to_level_5_employee_name 
            ,NULL AS reports_to_level_6_employee_login, NULL AS reports_to_level_6_employee_name 
            ,job_classification_title::VARCHAR(200)
            ,job_level::VARCHAR(200)               
            ,building::VARCHAR(200)
            ,job_id::VARCHAR(200)                                   
    FROM candidates
    

)


SELECT metric_name,
       job_icims_id::VARCHAR(200),
       job_guid::VARCHAR(200),
       icims_id::VARCHAR(200),
       person_id::VARCHAR(200),
       status::VARCHAR(200),
       current_job_state::VARCHAR(200),
       total_dwelling_time::VARCHAR(200),
       dwelling_time::VARCHAR(200),
       calendar_day::VARCHAR(200),
       reporting_week_of_year::VARCHAR(200),
       calendar_month_of_year::VARCHAR(200),
       calendar_qtr::VARCHAR(200),
       reporting_year::VARCHAR(200),
       start_dwell::VARCHAR(200),
       test_end::VARCHAR(200),
       closed_date::VARCHAR(200),
       requisition_opened_time::VARCHAR(200),
       updated_date::VARCHAR(200),
       icims_created_timestamp::VARCHAR(200),
       current_week::VARCHAR(200),
       current_month::VARCHAR(200),
       current_quarter::VARCHAR(200),
       generated_date::VARCHAR(200),
       employee_login::VARCHAR(200),
       employee_internal_email_address::VARCHAR(200),
       reports_to_level_3_employee_login::VARCHAR(200), reports_to_level_3_employee_name::VARCHAR(200), 
       reports_to_level_4_employee_login::VARCHAR(200), reports_to_level_4_employee_name::VARCHAR(200), 
       reports_to_level_5_employee_login::VARCHAR(200), reports_to_level_5_employee_name::VARCHAR(200), 
       reports_to_level_6_employee_login::VARCHAR(200), reports_to_level_6_employee_name::VARCHAR(200), 
       job_classification_title::VARCHAR(200),
       job_level::VARCHAR(200),
       building::VARCHAR(200),
       job_id::VARCHAR(200)                                         
FROM unionedAMZLMetrics
WHERE 1=1
AND reporting_week_of_year = 43
--AND job_guid = '0537c363-d3d5-4d86-944c-de4227320836'
--AND job_icims_id = '902554'
