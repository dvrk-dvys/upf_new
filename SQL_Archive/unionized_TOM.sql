WITH current_week as
( SELECT reporting_year, reporting_week_of_year, calendar_month_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate) AND reporting_year = DATEPART(year, sysdate)),


prep_offer AS (

    Select distinct 
    cast(EXTRACT(week from offer_accepted_date) as char(10)) AS wk_number
    ,offer.offer_accepted_Date
    ,team.wk_begin_dt
    ,team.wk_end_dt
    ,concat(offer.job_icims_id,offer.candidate_icims_id) AS unique_key
    ,offer.job_icims_id
    ,offer.candidate_icims_id
    ,offer.candidate_full_name
    ,offer.candidate_identifier_login
    ,offer.candidate_identifier_name
    ,offer.candidate_recruiter_login
    ,offer.recruiter_employee_login
    ,offer.candidate_type
    ,offer.job_code
    ,offer.job_level
    ,offer.job_title
    ,offer.country
    ,offer.location_building_name
    ,offer.job_id
    ,offer.hire_type
    ,offer.department_id
    ,offer.current_job_state AS current_requisition_status
    ,team.team_flag
    --recruiter hierarchy--
    ,offer.recruiter_reports_to_level_2_employee_login
    ,offer.recruiter_reports_to_level_3_employee_login
    ,offer.recruiter_reports_to_level_4_employee_login
    ,offer.recruiter_reports_to_level_5_employee_login
    ,offer.recruiter_reports_to_level_6_employee_login
    ,offer.recruiter_reports_to_level_7_employee_login
    ,offer.recruiter_reports_to_level_8_employee_login
    --hiring manager hierarchy--
    ,offer.hiring_manager_employee_id 
    ,offer.hiring_manager_employee_login
    ,offer.hiring_manager_reports_to_level_2_employee_login
    ,offer.hiring_manager_reports_to_level_3_employee_login
    ,offer.hiring_manager_reports_to_level_4_employee_login
    ,offer.hiring_manager_reports_to_level_5_employee_login
    ,offer.hiring_manager_reports_to_level_6_employee_login
    ,offer.hiring_manager_reports_to_level_7_employee_login
    ,offer.hiring_manager_reports_to_level_8_employee_login
    ,offer.hiring_manager_reports_to_level_2_employee_name
    ,offer.hiring_manager_reports_to_level_3_employee_name
    ,offer.hiring_manager_reports_to_level_4_employee_name
    ,offer.hiring_manager_reports_to_level_5_employee_name
    ,offer.hiring_manager_reports_to_level_6_employee_name
    ,offer.hiring_manager_reports_to_level_7_employee_name
    ,offer.hiring_manager_reports_to_level_8_employee_name
    -- leader login from hiring hierarchy--
    ,(Case when offer.hiring_manager_reports_to_level_3_employee_login||offer.hiring_manager_reports_to_level_4_employee_login||offer.hiring_manager_reports_to_level_5_employee_login||offer.hiring_manager_reports_to_level_6_employee_login||offer.hiring_manager_reports_to_level_7_employee_login
    like '%patsean%' then 'PATSEAN-Patterson, Sean' 
    when  offer.hiring_manager_reports_to_level_3_employee_login||offer.hiring_manager_reports_to_level_4_employee_login||offer.hiring_manager_reports_to_level_5_employee_login||offer.hiring_manager_reports_to_level_6_employee_login||offer.hiring_manager_reports_to_level_7_employee_login
    = '' then offer.hiring_manager_employee_login end) AS "Leader"
     ,offer.department_id AS "Cost center"
     ,1 AS join_me
    from masterhr.offer_accepts as offer
    inner join opsdw.ops_ta_team_wk team on team.emplid = offer.recruiter_employee_id and offer.offer_accepted_date::date between team.wk_begin_dt AND team.wk_end_dt
    where offer.offer_accepted_count = 1
    AND "Leader" = 'PATSEAN-Patterson, Sean'
    AND (offer.department_id like '1065%' OR offer.department_id like '1057%')

),

ytd_offer AS (
    SELECT
    COUNT(*) as total_ytd_count,
    (SELECT COUNT(*) FROM prep_offer WHERE job_level = 3) as lvl_3_count,
    (SELECT COUNT(*) FROM prep_offer WHERE job_level = 4) as lvl_4_count,
    (SELECT COUNT(*) FROM prep_offer WHERE job_level = 5) as lvl_5_count,
    (SELECT COUNT(*) FROM prep_offer WHERE job_level = 6) as lvl_6_count,
    (SELECT COUNT(*) FROM prep_offer WHERE job_level = 7) as lvl_7_count,
    1 AS join_me
    FROM prep_offer
),

-- Offers --
offer_accepts AS (

    Select 
    'Offer Accepts'::VARCHAR(200) AS metric_name 
    ,'W'||days.reporting_week_of_year AS reporting_week  
    ,days.calendar_month_of_year AS calendar_month
    ,days.reporting_year AS Reporting_year
    ,'W'||days.calendar_week AS calendar_week
    ,wk_number
    ,offer_accepted_Date
    ,days.calendar_day
    ,wk_begin_dt
    ,wk_end_dt
    ,unique_key
    ,job_icims_id
    ,candidate_icims_id
    ,candidate_full_name
    ,candidate_identifier_login
    ,candidate_identifier_name
    ,candidate_recruiter_login
    ,recruiter_employee_login
    ,candidate_type
    ,job_code
    ,job_level
    ,job_title
    ,country
    ,location_building_name
    ,job_id
    ,hire_type
    ,department_id
    ,current_requisition_status
    ,team_flag
    ,"Leader" as leader
    ,"Cost center" as cost_center
    ,total_ytd_count
    ,lvl_3_count
    ,lvl_4_count
    ,lvl_5_count
    ,lvl_6_count
    ,lvl_7_count

    FROM prep_offer prep
    INNER JOIN opstadw.hrmetrics.o_reporting_days days on cast(offer_accepted_date as date)= days.calendar_day -- inlcuded to get the reporting week
    INNER JOIN current_week cw ON  cw.reporting_year  >= days.reporting_year AND  cw.reporting_week_of_year >= days.reporting_week_of_year
    LEFT JOIN ytd_offer ytd ON prep.join_me = ytd.join_me 

    WHERE 1=1
    AND days.reporting_year IN (DATEPART(year, sysdate), DATEPART(year, sysdate)-1)
),


raw_data_reqs as
( 
    select 
    DATEDIFF(d,snapshot_begin_timestamp, snapshot_end_timestamp) as deltadays
    ,reqs.snapshot_begin_timestamp
    ,TRUNC(rd.calendar_day) as daycal
    ,TRUNC(snapshot_begin_timestamp) beginday
    ,TRUNC(snapshot_end_timestamp) endnday
    ,rd.reporting_week_of_year
    ,rd.calendar_month_of_year
    ,rd.reporting_year
    ,rd.calendar_week
    ,CASE WHEN reqs.approved = 0 THEN 'PENDING APPROVAL' ELSE 'APPROVED' END as job_approval_status ,TRUNC(reqs.final_approval_date) as approval_date
    ,TRUNC(reqs.requisition_opened_time) as creation_date
    ,CASE WHEN job_state IN('FILLED','OFFER ACCEPTED') AND DATE_PART(y,TRUNC(enter_state_time)) < 2019 THEN 0 ELSE 1 END as filter
    ,reqs.* 

    from masterhr.requisition reqs 

    INNER JOIN hrmetrics.o_reporting_days rd ON rd.calendar_day_of_week = 1 AND rd.calendar_day >= reqs.snapshot_begin_timestamp AND rd.calendar_day < snapshot_end_timestamp AND rd.calendar_day_of_week = 1 AND rd.reporting_year IN (DATEPART(year, sysdate), DATEPART(year, sysdate)-1)

    WHERE 
    1=1 
    AND DATEDIFF(d,snapshot_begin_timestamp, snapshot_end_timestamp) > 0 
    AND job_state NOT IN ('POOLING','ELIMINATED')
),

prep_reqs AS ( 

    SELECT DISTINCT
    enter_state_time
    ,r.beginday
    ,r.endnday
    ,r.job_approval_status
    ,r.job_state
    ,CASE 

    WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state = r.current_job_state AND r.current_job_state ='OFFER ACCEPTED' AND r.current_job_state != aj.req_status THEN aj.req_status

    WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state != r.current_job_state AND r.current_job_state ='OFFER ACCEPTED' AND r.current_job_state != aj.req_status THEN aj.req_status

    WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state != r.current_job_state AND r.current_job_state = aj.req_status THEN r.current_job_state 
    WHEN DATE_PART(y,TRUNC(r.snapshot_end_timestamp)) = 9999 AND r.job_state != r.current_job_state THEN r.current_job_state ELSE r.job_state END AS job_state_c


    ,r.job_guid
    ,r.job_icims_id
    ,r.job_level
    ,r.job_tech_indicator
    ,r.job_tech_non_tech_sde_code
    ,r.department_id as cost_center
    ,r.flsa_name
    ,r.final_approval_date
    ,r.recruiter_employee_login
    ,r.operational_plan_budget_year
    ,r.opening
    ,r.filled_openings
    ,r.remaining_openings
    ,r.country
    ,r.job_classification_title
    ,r.building
    ,r.current_job_state
    ,TRUNC(r.enter_state_time) as enter_state_day
    ,r.hiring_manager_employee_full_name
    ,hchmc.reports_to_level_7_employee_name as HM_current_level7
    ,hchmc.reports_to_level_6_employee_name as HM_current_level6
    ,hchmc.reports_to_level_5_employee_name as HM_current_level5
    ,(Case when hchmc.reports_to_level_3_employee_login||hchmc.reports_to_level_4_employee_login||hchmc.reports_to_level_5_employee_login||hchmc.reports_to_level_6_employee_login||hchmc.reports_to_level_7_employee_login
    like '%patsean%' then 'PATSEAN-Patterson, Sean' 
    when  hchmc.reports_to_level_4_employee_login||hchmc.reports_to_level_5_employee_login||hchmc.reports_to_level_6_employee_login||hchmc.reports_to_level_7_employee_login
    ='' then hchmc.employee_full_name end)"Leader"
    ,hcmp.reports_to_level_7_employee_name as HM_past_level7,hcmp.reports_to_level_6_employee_name as HM_past_level6
    ,hcmp.reports_to_level_5_employee_name as HM_past_level5
    , hchmc.reports_to_level_7_employee_name || hchmc.reports_to_level_6_employee_name || hcmp.reports_to_level_6_employee_name || hcmp.reports_to_level_7_employee_name as HMCONCAT
    ,1 AS join_me
    FROM raw_data_reqs r 
    LEFT JOIN masterhr.employee_hc_current hchmc ON r.hiring_manager_employee_id = hchmc.emplid 
    LEFT JOIN masterhr.employee_hc  hcmp ON r.hiring_manager_employee_id = hcmp.emplid AND r.daycal between TRUNC(hcmp.hr_begin_dt) AND TRUNC(hcmp.hr_end_dt) 
        LEFT JOIN (SELECT reqs.job_art_job_id,
        case when reqs.req_status like 'OPEN' and reqs_current_pipeline.accepts + reqs_current_pipeline.hires >= reqs.openings then 'OFFER ACCEPTED' else reqs.req_status end as req_status
        FROM rds.reqs reqs LEFT JOIN rds.reqs_current_pipeline ON (reqs.job_amzr_req_id=reqs_current_pipeline.job_id) WHERE req_status NOT IN ('ELIMINATED') ) aj ON aj.job_art_job_id = r.job_guid

    WHERE filter = 1
    AND (cost_center like '1065%' OR cost_center like '1057%')
    AND job_state NOT IN ('FILLED','OFFER ACCEPTED')
    AND "Leader" = 'PATSEAN-Patterson, Sean'
),


ytd_reqs AS (
    SELECT 
    COUNT(*) as ytd_count,
    (SELECT COUNT(*) FROM prep_reqs WHERE job_state = 'OPEN') as unapproved_count,
    (SELECT COUNT(*) FROM prep_reqs WHERE job_state = 'APPROVED') as approved_count,

    1 AS join_me
       
    FROM prep_reqs prep

),

-- Historical -- 
historical AS (


    SELECT DISTINCT
    'Historical Reqs'::VARCHAR(200) AS metric_name 
    ,rd2.reporting_year
    ,'W'||rd2.reporting_week_of_year AS reporting_week    
    ,rd2.reporting_week_of_year AS wk_number  
    ,rd2.calendar_month_of_year AS calendar_month
    ,rd2.daycal as week_begin_day
    ,'W'||rd2.calendar_week AS calendar_week
    ,TRUNC(DATEADD(day,7,daycal)) as day_for_nextweek_SLA_alert
    ,CASE WHEN rd2.job_approval_status IN ('PENDING APPROVAL') THEN DATEDIFF(d,creation_date, daycal) END as pending_approval_days_gross
    ,CASE WHEN rd2.job_approval_status IN ('PENDING APPROVAL') THEN ((DATEDIFF('day',creation_date,daycal)) -(DATEDIFF ('week',creation_date,daycal)*2) -(CASE WHEN DATE_PART(dow,creation_date) = 0 THEN 1 ELSE 0 END) -(CASE WHEN DATE_PART(dow,daycal) = 6 THEN 1 ELSE 0 END)) END as pending_approval_days_net
    ,CASE WHEN rd2.job_state IN ('APPROVED') THEN DATEDIFF(d,approval_date, daycal) END as approved_req_age_days_gross
    ,CASE WHEN rd2.job_state IN ('APPROVED') THEN ((DATEDIFF('day',approval_date,daycal)) -(DATEDIFF ('week',approval_date,daycal)*2) -(CASE WHEN DATE_PART(dow,approval_date) = 0 THEN 1 ELSE 0 END) -(CASE WHEN DATE_PART(dow,daycal) = 6 THEN 1 ELSE 0 END)) END as approved_req_age_days_net
    ,concat(r.job_guid,r.job_icims_id) AS unique_key  
    ,r.job_approval_status
    ,r.job_state
    ,r.job_state_c
    ,r.job_guid
    ,r.job_icims_id
    ,r.job_level
    ,r.job_tech_indicator
    ,r.job_tech_non_tech_sde_code
    ,r.cost_center
    ,r.flsa_name
    ,r.final_approval_date
    ,rd2.recruiter_employee_login
    ,r.operational_plan_budget_year
    ,r.opening
    ,r.filled_openings
    ,r.remaining_openings
    ,r.country
    ,r.job_classification_title
    ,r.building
    ,r.current_job_state
    ,r.enter_state_day
    ,rd2.reporting_week_of_year as state_enter_reporting_year
    ,rd2.reporting_year as state_enter_reporting_week
    ,days.reporting_week_of_year as current_reporting_week
    ,r.hiring_manager_employee_full_name
    ,r.HM_current_level7
    ,r.HM_current_level6
    ,r.HM_current_level5
    ,r."Leader"
    ,r.HM_past_level7
    ,r.HM_past_level6
    ,r.HM_past_level5
    ,r.HMCONCAT
    ,ytd.ytd_count
    ,ytd.unapproved_count
    ,ytd.approved_count


    FROM prep_reqs r
    LEFT JOIN hrmetrics.o_reporting_days rd ON rd.calendar_day = TRUNC(enter_state_time)
    LEFT JOIN raw_data_reqs rd2 ON rd2.job_guid = r.job_guid AND r.job_icims_id = rd2.job_icims_id AND r.beginday = rd2.beginday AND r.endnday = rd2.endnday
    INNER JOIN current_week days ON  days.reporting_year  >= rd2.reporting_year AND  days.reporting_week_of_year >= rd2.reporting_week_of_year
    LEFT JOIN ytd_reqs ytd ON r.join_me = ytd.join_me 

    WHERE 1=1
    AND days.reporting_year IN (DATEPART(year, sysdate), DATEPART(year, sysdate)-1)

),


fulltime AS (

    SELECT  employee_login, employee_class_name, MAX(event_date)
    FROM masterhr.employee_hc
    WHERE 1=1
    AND employee_class_name = 'Regular Full Time'

    GROUP BY 
    employee_login,
    employee_class_name

),

prep_starts AS (

    --# of Employee Starts--
    select distinct
    --'W'||days.reporting_week_of_year Reporting_week 
    --,days.reporting_year Reporting_year
    --,'W'||days.calendar_week calendar_week
    employee_start_Date
    ,concat(starts.job_icims_id,starts.job_candidate_icims_id) unique_key
    ,starts.job_icims_id
    ,starts.job_candidate_icims_id
    ,starts.department_id
    ,starts.job_code
    ,starts.job_title_name
    ,starts.job_level_name
    ,starts.emplid
    ,starts.employee_login
    ,starts.employee_full_name
    ,starts.job_tech_indicator
    ,starts.job_flsa_name
    ,starts.location_country_name
    ,starts.location_city_name
    ,starts.location_building_name
    ,starts.hire_type
    ,starts.department_ofa_cost_center_code 
    ,team.wk_begin_dt
    ,team.wk_end_dt
    ,team.team_flag
    --recruiter hierarchy--
    ,offer.recruiter_reports_to_level_2_employee_login "recruiter_reports_to_level_2_employee_login"
    ,offer.recruiter_reports_to_level_3_employee_login "recruiter_reports_to_level_3_employee_login"
    ,offer.recruiter_reports_to_level_4_employee_login "recruiter_reports_to_level_4_employee_login"
    ,offer.recruiter_reports_to_level_5_employee_login "recruiter_reports_to_level_5_employee_login"
    ,offer.recruiter_reports_to_level_6_employee_login "recruiter_reports_to_level_6_employee_login"
    ,offer.recruiter_reports_to_level_7_employee_login "recruiter_reports_to_level_7_employee_login"
    ,offer.recruiter_reports_to_level_8_employee_login "recruiter_reports_to_level_8_employee_login"
    --hiring manager hierarchy--
    ,starts.reports_to_level_2_employee_login
    ,starts.reports_to_level_3_employee_login
    ,starts.reports_to_level_4_employee_login
    ,starts.reports_to_level_5_employee_login
    ,starts.reports_to_level_6_employee_login
    ,starts.reports_to_level_7_employee_login
    ,starts.reports_to_level_8_employee_login
    ,starts.reports_to_level_2_employee_name
    ,starts.reports_to_level_3_employee_name
    ,starts.reports_to_level_4_employee_name
    ,starts.reports_to_level_5_employee_name
    ,starts.reports_to_level_6_employee_name
    ,starts.reports_to_level_7_employee_name
    ,starts.reports_to_level_8_employee_name
    -- leader login from reports to hierarchy--
    ,(Case when starts.reports_to_level_3_employee_login||starts.reports_to_level_4_employee_login||starts.reports_to_level_5_employee_login||starts.reports_to_level_6_employee_login||starts.reports_to_level_7_employee_login
    like '%patsean%' then 'PATSEAN-Patterson, Sean' 
    else 'NA' end)"Leader"
    ,1 AS join_me

    from masterhr.offer_accepts offer
    left join masterhr.employee_starts starts on starts.job_candidate_icims_id= offer.candidate_icims_id  and starts.job_icims_id = offer.job_icims_id
    inner join opsdw.ops_ta_team_wk team on team.emplid = offer.recruiter_employee_id and offer.offer_accepted_date::date between team.wk_begin_dt AND team.wk_end_dt
    INNER JOIN masterhr.employee_hc_current ehc ON ehc.employee_login = starts.employee_login


    where starts.emplid is not null
    and starts.employee_start_date <= current_date
    AND (starts.department_id like '1065%' OR starts.department_id like '1057%')
    --AND (starts.department_id like '1065%' OR starts.department_id like '1057%' OR starts.department_id like '1217%' OR starts.department_id like '1227%')
    --and starts.employee_start_date >= '01/01/2019'
    AND DATEPART(year,starts.employee_start_date) = DATEPART(year, sysdate)

    AND "Leader" = 'PATSEAN-Patterson, Sean'
    --AND full_part_time_code = 'F'
    --P03171-Manager I,ops , P03131-Manager II,ops , P03091-Mananger III,ops, 
    --P02093 -Pathways Ops mgr, P03135 -Manager I,Training,P03095 -Manager III,Training
    --and starts.job_code in ('P03231','P03240','P03131','P03171','P03237','P03211','A01231','M06051','M06151','P03091','P03218','M06111','M06201','P03032','P03214',
    --                        'P03239','P03051','P03054','A01211','P03238','M06130','A05151','P02093','A05202','M06030','M05151','P03235','M06112','P03031','P03231',
    --                        'P03240','P03131','P03171','P03237','P03211','A01231','M06051','M06151','P03091','P03218','M06111','M06201','P03032','P03214','P03239',
    --                        'P03051','P03054','A01211','P03238','M06130','A05151','P02093', 'A05202','M06030','M05151','P03235','M06112','P03031')

    --and (upper(offer.recruiter_reports_to_level_5_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu'))
    --or   upper(offer.recruiter_reports_to_level_6_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu'))
    --or   upper(offer.recruiter_reports_to_level_7_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu'))
    --or   upper(offer.recruiter_reports_to_level_8_employee_login)  IN (upper('malizal'), upper('dckydd'), upper('chaluleu')))

),

ytd_starts AS (
    SELECT
    COUNT(*) as total_ytd_count,
    (SELECT COUNT(*) FROM prep_starts WHERE location_building_name IN  ('BNA13 - Corp Off (Nashville)', 'BNA14 - Corp Off (Nashville)')) as NashvilleCount,
    1 AS join_me
    FROM prep_starts

),

--Starts--
starts AS (

    Select 
    'Starts'::VARCHAR(200) AS metric_name 
    ,'W'||days.reporting_week_of_year AS reporting_week 
    ,days.calendar_month_of_year AS calendar_month
    ,days.reporting_year Reporting_year
    ,'W'||days.calendar_week calendar_week
    ,days.reporting_week_of_year AS wk_number 
    ,cast(EXTRACT(week from employee_start_Date) as char(10)) starts_wk_number
    ,unique_key
    ,job_icims_id
    ,job_candidate_icims_id
    ,department_id
    ,job_code
    ,job_title_name
    ,job_level_name AS job_level
    ,emplid
    ,employee_login
    ,employee_full_name
    ,job_tech_indicator
    ,job_flsa_name
    ,location_country_name
    ,location_city_name
    ,location_building_name
    ,hire_type
    ,wk_begin_dt
    ,wk_end_dt
    ,team_flag
    ,"recruiter_reports_to_level_2_employee_login"
    ,"recruiter_reports_to_level_3_employee_login"
    ,"recruiter_reports_to_level_4_employee_login"
    ,"recruiter_reports_to_level_5_employee_login"
    ,"recruiter_reports_to_level_6_employee_login"
    ,"recruiter_reports_to_level_7_employee_login"
    ,"recruiter_reports_to_level_8_employee_login"
    ,reports_to_level_2_employee_login
    ,reports_to_level_3_employee_login
    ,reports_to_level_4_employee_login
    ,reports_to_level_5_employee_login
    ,reports_to_level_6_employee_login
    ,reports_to_level_7_employee_login
    ,reports_to_level_8_employee_login
    ,reports_to_level_2_employee_name
    ,reports_to_level_3_employee_name
    ,reports_to_level_4_employee_name
    ,reports_to_level_5_employee_name
    ,reports_to_level_6_employee_name
    ,reports_to_level_7_employee_name
    ,reports_to_level_8_employee_name
    ,"Leader" as leader
    ,department_ofa_cost_center_code AS cost_center
    ,ytd.total_ytd_count
    ,NashvilleCount
    --,offer_accepted_date

    FROM prep_starts prep
    inner join opstadw.hrmetrics.o_reporting_days days on cast(employee_start_date as date)= days.calendar_day -- inlcuded to the the reporting week
    INNER JOIN current_week cw ON  cw.reporting_year  >= days.reporting_year AND  cw.reporting_week_of_year >= days.reporting_week_of_year
    LEFT JOIN ytd_starts ytd ON prep.join_me = ytd.join_me 

    WHERE 1=1
    AND days.reporting_year = DATEPART(year, sysdate)
)





----Union of all the TOM metrics-------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
,unionedTOMMetrics as (
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    SELECT 'Offers'::VARCHAR(200) AS metric_name
            ,reporting_week::VARCHAR(200)      
            ,calendar_month::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,calendar_week::VARCHAR(200)
            ,wk_number::VARCHAR(200)
            ,unique_key::VARCHAR(200)
            ,offer_accepted_date::VARCHAR(200)
            ,job_icims_id::VARCHAR(200)
            ,job_id::VARCHAR(200)
            ,candidate_icims_id::VARCHAR(200)            
            ,candidate_full_name::VARCHAR(200)
            ,candidate_identifier_login::VARCHAR(200)           
            ,candidate_recruiter_login::VARCHAR(200)
            ,recruiter_employee_login::VARCHAR(200)
            ,candidate_type::VARCHAR(200)
            ,hire_type::VARCHAR(200)
            ,job_code::VARCHAR(200)            
            ,job_level::VARCHAR(200)
            ,job_title::VARCHAR(200)
            ,country::VARCHAR(200)
            ,location_building_name::VARCHAR(200)          
            ,department_id::VARCHAR(200)           
            ,current_requisition_status::VARCHAR(200)            
            ,leader::VARCHAR(200)            
            ,cost_center::VARCHAR(200)            
            ,lvl_3_count::VARCHAR(200)
            ,lvl_4_count::VARCHAR(200)
            ,lvl_5_count::VARCHAR(200)
            ,lvl_6_count::VARCHAR(200)
            ,lvl_7_count::VARCHAR(200)           
            ,NULL AS pending_approval_days_gross      
            ,NULL AS pending_approval_days_net
            ,NULL AS approved_req_age_days_gross
            ,NULL AS approved_req_age_days_net
            ,NULL AS job_approval_status
            ,NULL AS job_state
            ,NULL AS job_guid
            ,NULL AS flsa_name
            ,NULL AS final_approval_date
            ,NULL AS operational_plan_budget_year
            ,NULL AS job_classification_title
            ,NULL AS building
            ,NULL AS current_job_state
            ,NULL AS enter_state_day
            ,NULL AS state_enter_reporting_year
            ,NULL AS state_enter_reporting_week
            ,NULL AS current_reporting_week
            ,NULL AS hiring_manager_employee_full_name
            ,NULL AS HM_current_level7
            ,NULL AS HM_current_level6
            ,NULL AS HM_current_level5
            ,NULL AS HMCONCAT
            ,NULL AS ytd_count
            ,NULL AS unapproved_count
            ,NULL AS approved_count            
            ,NULL AS job_candidate_icims_id
            ,NULL AS job_title_name
            ,NULL AS emplid
            ,NULL AS employee_login
            ,NULL AS employee_full_name
            ,NULL AS job_tech_indicator
            ,NULL AS job_flsa_name
            ,NULL AS location_country_name
            ,NULL AS location_city_name
            ,NULL AS total_ytd_count
            ,NULL AS NashvilleCount
            
            
    FROM offer_accepts

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 'Historical Reqs'::VARCHAR(200) AS metric_name
            ,reporting_week::VARCHAR(200)      
            ,calendar_month::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,calendar_week::VARCHAR(200)
            ,wk_number::VARCHAR(200)
            ,unique_key::VARCHAR(200) 
            ,NULL AS offer_accepted_date
            ,job_icims_id::VARCHAR(200)
            ,NULL AS job_id
            ,NULL AS candidate_icims_id          
            ,NULL AS candidate_full_name
            ,NULL AS candidate_identifier_login         
            ,NULL AS candidate_recruiter_login
            ,recruiter_employee_login::VARCHAR(200)
            ,NULL AS candidate_type
            ,NULL AS hire_type
            ,NULL AS job_code            
            ,job_level::VARCHAR(200)
            ,NULL AS job_title
            ,NULL AS country
            ,NULL AS location_building_name          
            ,NULL AS department_id          
            ,NULL AS current_requisition_status                       
            ,leader::VARCHAR(200)                        
            ,cost_center::VARCHAR(200)           
            ,NULL AS lvl_3_count
            ,NULL AS lvl_4_count
            ,NULL AS lvl_5_count
            ,NULL AS lvl_6_count
            ,NULL AS lvl_7_count            
            ,pending_approval_days_gross::VARCHAR(200)       
            ,pending_approval_days_net::VARCHAR(200)
            ,approved_req_age_days_gross::VARCHAR(200)
            ,approved_req_age_days_net::VARCHAR(200)
            ,job_approval_status::VARCHAR(200)
            ,job_state::VARCHAR(200)
            ,job_guid::VARCHAR(200)
            ,flsa_name::VARCHAR(200)
            ,final_approval_date::VARCHAR(200)
            ,operational_plan_budget_year::VARCHAR(200)
            ,job_classification_title::VARCHAR(200)
            ,building::VARCHAR(200)
            ,current_job_state::VARCHAR(200)
            ,enter_state_day::VARCHAR(200)
            ,state_enter_reporting_year::VARCHAR(200)
            ,state_enter_reporting_week::VARCHAR(200)
            ,current_reporting_week::VARCHAR(200)
            ,hiring_manager_employee_full_name::VARCHAR(200)
            ,HM_current_level7::VARCHAR(200)
            ,HM_current_level6::VARCHAR(200)
            ,HM_current_level5::VARCHAR(200)
            ,HMCONCAT::VARCHAR(200)
            ,ytd_count::VARCHAR(200)
            ,unapproved_count::VARCHAR(200)
            ,approved_count::VARCHAR(200)
            ,NULL AS job_candidate_icims_id
            ,NULL AS job_title_name
            ,NULL AS emplid
            ,NULL AS employee_login
            ,NULL AS employee_full_name
            ,NULL AS job_tech_indicator
            ,NULL AS job_flsa_name
            ,NULL AS location_country_name
            ,NULL AS location_city_name
            ,NULL AS total_ytd_count
            ,NULL AS NashvilleCount
                
    FROM historical



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 'Starts'::VARCHAR(200) AS metric_name
            ,reporting_week::VARCHAR(200)      
            ,calendar_month::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,calendar_week::VARCHAR(200)
            ,wk_number::VARCHAR(200)
            ,unique_key::VARCHAR(200)            
            ,NULL AS offer_accepted_date
            ,job_icims_id::VARCHAR(200)            
            ,NULL AS job_id
            ,NULL AS candidate_icims_id          
            ,NULL AS candidate_full_name
            ,NULL AS candidate_identifier_login         
            ,NULL AS candidate_recruiter_login
            ,NULL AS recruiter_employee_login
            ,NULL AS candidate_type            
            ,hire_type::VARCHAR(200)
            ,job_code::VARCHAR(200)  
            ,job_level::VARCHAR(200) 
            ,NULL AS job_title
            ,NULL AS country
            ,location_building_name::VARCHAR(200)                          
            ,department_id::VARCHAR(200)           
            ,NULL AS current_requisition_status                    
            ,leader::VARCHAR(200)                        
            ,cost_center::VARCHAR(200)            
            ,NULL AS lvl_3_count
            ,NULL AS lvl_4_count
            ,NULL AS lvl_5_count
            ,NULL AS lvl_6_count
            ,NULL AS lvl_7_count               
            ,NULL AS pending_approval_days_gross      
            ,NULL AS pending_approval_days_net
            ,NULL AS approved_req_age_days_gross
            ,NULL AS approved_req_age_days_net
            ,NULL AS job_approval_status
            ,NULL AS job_state
            ,NULL AS job_guid
            ,NULL AS flsa_name
            ,NULL AS final_approval_date
            ,NULL AS operational_plan_budget_year
            ,NULL AS job_classification_title
            ,NULL AS building
            ,NULL AS current_job_state
            ,NULL AS enter_state_day
            ,NULL AS state_enter_reporting_year
            ,NULL AS state_enter_reporting_week
            ,NULL AS current_reporting_week
            ,NULL AS hiring_manager_employee_full_name
            ,NULL AS HM_current_level7
            ,NULL AS HM_current_level6
            ,NULL AS HM_current_level5
            ,NULL AS HMCONCAT
            ,NULL AS ytd_count
            ,NULL AS unapproved_count
            ,NULL AS approved_count                      
            ,job_candidate_icims_id::VARCHAR(200)
            ,job_title_name::VARCHAR(200)
            ,emplid::VARCHAR(200)
            ,employee_login::VARCHAR(200)
            ,employee_full_name::VARCHAR(200)
            ,job_tech_indicator::VARCHAR(200)
            ,job_flsa_name::VARCHAR(200)
            ,location_country_name::VARCHAR(200)
            ,location_city_name::VARCHAR(200)
            ,total_ytd_count::VARCHAR(200)
            ,NashvilleCount::VARCHAR(200)

                                        
    FROM starts


)


SELECT metric_name
            ,reporting_week::VARCHAR(200)      
            ,calendar_month::VARCHAR(200)
            ,reporting_year::VARCHAR(200)
            ,calendar_week::VARCHAR(200)
            ,wk_number::VARCHAR(200)
            ,unique_key::VARCHAR(200) 
            ,offer_accepted_date::VARCHAR(200)
            ,job_icims_id::VARCHAR(200)
            ,job_id::VARCHAR(200)
            ,candidate_icims_id::VARCHAR(200)          
            ,candidate_full_name::VARCHAR(200)
            ,candidate_identifier_login::VARCHAR(200)         
            ,candidate_recruiter_login::VARCHAR(200)
            ,recruiter_employee_login::VARCHAR(200)
            ,candidate_type::VARCHAR(200)
            ,hire_type::VARCHAR(200)
            ,job_code::VARCHAR(200)            
            ,job_level::VARCHAR(200)
            ,job_title::VARCHAR(200)
            ,country::VARCHAR(200)
            ,location_building_name::VARCHAR(200)          
            ,department_id::VARCHAR(200)          
            ,current_requisition_status::VARCHAR(200)                       
            ,leader::VARCHAR(200)                        
            ,cost_center::VARCHAR(200)           
            ,lvl_3_count::VARCHAR(200)
            ,lvl_4_count::VARCHAR(200)
            ,lvl_5_count::VARCHAR(200)
            ,lvl_6_count::VARCHAR(200)
            ,lvl_7_count::VARCHAR(200)
            ,pending_approval_days_gross::VARCHAR(200)       
            ,pending_approval_days_net::VARCHAR(200)
            ,approved_req_age_days_gross::VARCHAR(200)
            ,approved_req_age_days_net::VARCHAR(200)
            ,job_approval_status::VARCHAR(200)
            ,job_state::VARCHAR(200)
            ,job_guid::VARCHAR(200)
            ,flsa_name::VARCHAR(200)
            ,final_approval_date::VARCHAR(200)
            ,operational_plan_budget_year::VARCHAR(200)
            ,job_classification_title::VARCHAR(200)
            ,building::VARCHAR(200)
            ,current_job_state::VARCHAR(200)
            ,enter_state_day::VARCHAR(200)
            ,state_enter_reporting_year::VARCHAR(200)
            ,state_enter_reporting_week::VARCHAR(200)
            ,current_reporting_week::VARCHAR(200)
            ,hiring_manager_employee_full_name::VARCHAR(200)
            ,HM_current_level7::VARCHAR(200)
            ,HM_current_level6::VARCHAR(200)
            ,HM_current_level5::VARCHAR(200)
            ,HMCONCAT::VARCHAR(200)
            ,ytd_count::VARCHAR(200)
            ,unapproved_count::VARCHAR(200)
            ,approved_count::VARCHAR(200)
            ,job_candidate_icims_id::VARCHAR(200)
            ,job_title_name::VARCHAR(200)
            ,emplid::VARCHAR(200)
            ,employee_login::VARCHAR(200)
            ,employee_full_name::VARCHAR(200)
            ,job_tech_indicator::VARCHAR(200)
            ,job_flsa_name::VARCHAR(200)
            ,location_country_name::VARCHAR(200)
            ,location_city_name::VARCHAR(200)
            ,total_ytd_count::VARCHAR(200)
            ,NashvilleCount::VARCHAR(200)
FROM unionedTOMMetrics
WHERE 1=1
