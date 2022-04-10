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

personal_data AS (
  SELECT first_name, last_name, email, icims_id, address_country, peoplesoft_employee_id
  FROM ads.applicants
),
 
req_data AS (
  SELECT req_status, job_amzr_req_id, job_art_job_id, sourcer_login, relocations
  FROM hrmetrics.art_jobs
  WHERE sourcer_id <> '' AND req_status != 'POOLING'
),

reporting_line AS (
  SELECT DISTINCT reports_to_level_6_employee_login, reports_to_level_6_employee_name, employee_login
  FROM masterhr.employee_hc
  WHERE reports_to_level_6_employee_login IN ('amandam', 'loscott')
),

employee_class AS (
  SELECT employee_class_name, employee_login, employee_internal_email_address, event_date
  FROM masterhr.employee_hc
  WHERE 1=1
  AND event_date > '2019-01-01 00:00:00'
  AND employee_class_name IN ('Regular Flex Time - < 20 Hrs', 'Regular Full Time', 'Regular Part Time - 20 + Hours', 'Regular Reduced Time  30 + Hrs', 'Field Regular Part Time 20-29', 'Fixed Term Contractor - EU')
),

offer_accepts AS (
  SELECT job_icims_id, candidate_icims_id, icims_status, enter_state_time, recruiting_state, candidate_source_category, candidate_source_specific
  from masterhr.offer_accepts
  WHERE 1=1
  AND lower(candidate_source_category) LIKE '%internal transfer%'
),

hireraw_min_max AS (

  SELECT 
  artf.job_amzr_req_id
  ,artf.cand_icims_id
  ,w2.step
  ,artf.job_art_job_id
  ,CASE WHEN w2.step IN ( 'OFFER_CREATED', 'OFFER_EXTENDED') THEN 'YES' ELSE 'NO' END as check_field
  ,MIN(TRUNC(artf.enter_state_time)) as event_min_date_time
  ,MAX(TRUNC(artf.enter_state_time)) as event_max_date_time

  
  FROM hrmetrics.art_full artf

  LEFT JOIN hrmetrics.art_full_latest w2 ON artf.job_amzr_req_id = w2.job_amzr_req_id AND artf.cand_icims_id = w2.cand_icims_id   

  WHERE 1=1
  AND artf.step IN ('OFFER_CREATED', 'OFFER_EXTENDED')
  AND w2.internal = 'INTERNAL'
  AND TRUNC(artf.enter_state_time) > CAST(DATEPART(year, sysdate) - 1 AS TEXT) + '-12-19'
  
  GROUP BY
    artf.job_amzr_req_id
    ,artf.cand_icims_id
    ,w2.step
    ,artf.job_art_job_id
    ,CASE WHEN w2.step IN ( 'OFFER_CREATED', 'OFFER_EXTENDED') THEN 'IN OFFER STEP' ELSE 'OTHER STEP' END
),

hireraw AS (

      SELECT 
      hmm.job_amzr_req_id
      ,hmm.cand_icims_id
      ,hmm.job_art_job_id
      ,hmm.check_field AS dwelling_now_hire
      
      ,hmm.event_min_date_time AS start_dwell_hire
      ,hmm.event_max_date_time AS check_of_max_offer_hire
      ,MIN(TRUNC(artf.enter_state_time)) AS end_dwell_hire_1
      ,MAX(TRUNC(artf.enter_state_time)) AS event_max_date_time_hire_1
      ,first_name AS first_name_hire
      ,last_name AS last_name_hire
      ,email AS email_hire
      ,peoplesoft_employee_id AS peoplesoft_employee_id_hire
      ,address_country AS address_country_hire
      ,icims_id AS icims_id
      ,req_status AS req_status_hire
      ,sourcer_login AS sourcer_login_hire
      ,relocations AS relocations_hire
      ,reports_to_level_6_employee_login AS reports_to_level_6_employee_login_hire
      ,reports_to_level_6_employee_name AS reports_to_level_6_employee_name_hire
      ,employee_login AS employee_login_hire
       
      FROM hireraw_min_max hmm

      LEFT JOIN hrmetrics.art_full artf ON artf.job_amzr_req_id = hmm.job_amzr_req_id AND artf.cand_icims_id = hmm.cand_icims_id AND TRUNC(artf.enter_state_time) > TRUNC(hmm.event_max_date_time)
      INNER JOIN req_data rd ON rd.job_art_job_id = hmm.job_art_job_id AND hmm.job_amzr_req_id = rd.job_amzr_req_id
      INNER JOIN reporting_line ON reporting_line.employee_login = rd.sourcer_login
      INNER JOIN personal_data pd ON hmm.cand_icims_id = pd.icims_id

      WHERE 1=1
      AND reports_to_level_6_employee_login = (CASE WHEN start_dwell_hire < '2019-02-23' THEN 'loscott'
                                                    WHEN start_dwell_hire >= '2019-02-23' THEN 'amandam' END )

      GROUP BY
      hmm.job_amzr_req_id
      ,hmm.cand_icims_id
      ,hmm.step
      ,hmm.job_art_job_id
      ,hmm.check_field
      ,hmm.event_min_date_time
      ,hmm.event_max_date_time
      ,first_name, last_name, email, peoplesoft_employee_id, address_country, icims_id, req_status, sourcer_login, reports_to_level_6_employee_login, reports_to_level_6_employee_name, employee_login, relocations
),


icims_min_max AS (

    SELECT 
    wst.job_id
    ,wst.person_id
    ,wl.status
    ,CASE WHEN wl.status IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request') THEN 'YES' ELSE 'NO' END as check_field
    ,MIN(TRUNC(wst.updated_timestamp)) as event_min_date_time
    ,MAX(TRUNC(wst.updated_timestamp)) as event_max_date_time

    FROM ads.worksteps wst
        LEFT JOIN ads.worksteps_latest wl ON wst.job_id = wl.job_id AND wst.person_id = wl.person_id 
    WHERE  wst.status IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request')    
    AND cast((TIMESTAMP 'epoch' + CAST(wst.updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ') as date) > CAST(DATEPART(year, sysdate) - 1 AS TEXT) + '-12-19'

    GROUP BY
    wst.job_id
    ,wst.person_id
    ,wl.status
    ,CASE WHEN wl.status IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request') THEN 'IN OFFER STEP' ELSE 'OTHER STEP' END
),

icimsraw AS (

      SELECT 
      fst.job_id
      ,fst.person_id
      ,fst.check_field AS dwelling_now_icims
      ,cast((TIMESTAMP 'epoch' + CAST(fst.event_min_date_time AS BIGINT)/1000 * INTERVAL '1 Second ') as date) as start_dwell_icims
      ,cast((TIMESTAMP 'epoch' + CAST(fst.event_max_date_time AS BIGINT)/1000 * INTERVAL '1 Second ') as date) as check_of_max_offer_icims
      ,MIN(cast((TIMESTAMP 'epoch' + CAST(wst.updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ') as date)) AS end_dwell_icims_1
      ,MAX(cast((TIMESTAMP 'epoch' + CAST(wst.updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ') as date)) AS event_max_date_time_icims_1
      ,first_name AS first_name_icims
      ,last_name AS last_name_icims
      ,email AS email_icims
      ,peoplesoft_employee_id AS peoplesoft_employee_id_icims
      ,address_country AS address_country_icims
      ,req_status AS req_status_icims
      ,sourcer_login AS sourcer_login_icims
      ,relocations AS relocations_icims
      ,reports_to_level_6_employee_login AS reports_to_level_6_employee_login_icims
      ,reports_to_level_6_employee_name AS reports_to_level_6_employee_name_icims
      ,employee_login AS employee_login_icims

      FROM icims_min_max fst 

      LEFT JOIN ads.worksteps  wst ON wst.job_id = fst.job_id AND wst.person_id = fst.person_id AND TRUNC(wst.updated_timestamp) > TRUNC(fst.event_max_date_time)
      INNER JOIN req_data rd ON fst.job_id = rd.job_amzr_req_id
      INNER JOIN reporting_line ON reporting_line.employee_login = rd.sourcer_login
      INNER JOIN personal_data pd ON fst.person_id = pd.icims_id
      
      WHERE 1=1
      AND reports_to_level_6_employee_login = (CASE WHEN start_dwell_icims < '2019-02-23' THEN 'loscott'
                                                    WHEN start_dwell_icims >= '2019-02-23' THEN 'amandam' END )

      GROUP BY
      fst.job_id
      ,fst.person_id
      ,fst.status
      ,fst.check_field
      ,cast((TIMESTAMP 'epoch' + CAST(fst.event_min_date_time AS BIGINT)/1000 * INTERVAL '1 Second ') as date)
      ,cast((TIMESTAMP 'epoch' + CAST(fst.event_max_date_time AS BIGINT)/1000 * INTERVAL '1 Second ') as date)
      ,first_name, last_name, email, peoplesoft_employee_id, address_country, req_status, sourcer_login, reports_to_level_6_employee_login, reports_to_level_6_employee_name, employee_login, relocations
),


prep AS (

  SELECT *
         ,end_dwell_hire_1 as end_dwell_hire
         ,event_max_date_time_hire_1 as event_max_date_time_hire
         ,DATEDIFF(day, start_dwell_hire, end_dwell_hire_1) AS dwelling_time_hire
         ,end_dwell_icims_1 as end_dwell_icims
         ,event_max_date_time_icims_1 as event_max_date_time_icims
         ,DATEDIFF(day, start_dwell_icims, end_dwell_icims_1) AS dwelling_time_icims
         ,hr.job_amzr_req_id as job_amzr_req_id_final
         ,hr.cand_icims_id AS cand_icims_id_final
         ,ir.job_id as job_id_test
         ,ir.person_id as person_id_test
          
    FROM hireraw hr 
          FULL OUTER JOIN icimsraw ir ON ir.person_id = hr.cand_icims_id AND ir.job_id = hr.job_amzr_req_id
          INNER JOIN offer_accepts oa ON oa.candidate_icims_id = hr.cand_icims_id AND  oa.job_icims_id = hr.job_amzr_req_id
),

allraw AS (

  SELECT DISTINCT *
  ,COALESCE(CAST(job_amzr_req_id_final AS int), job_id_test) AS job_id_final
  ,COALESCE(CAST(cand_icims_id_final AS int), person_id_test) AS person_id_final
  ,COALESCE(first_name_hire, first_name_icims) AS first_name
  ,COALESCE(last_name_hire, last_name_icims) AS last_name
  ,COALESCE(email_hire, email_icims) AS email
  ,COALESCE(peoplesoft_employee_id_hire, peoplesoft_employee_id_icims) AS peoplesoft_employee_id
  ,COALESCE(req_status_hire, req_status_icims)AS req_status
  ,COALESCE(sourcer_login_hire, sourcer_login_icims) AS sourcer_login
  ,COALESCE(reports_to_level_6_employee_login_icims, reports_to_level_6_employee_login_hire) AS reports_to_level_6_employee_login
  ,COALESCE(reports_to_level_6_employee_name_icims, reports_to_level_6_employee_name_hire) AS reports_to_level_6_employee_name
  ,COALESCE(employee_login_hire, employee_login_icims) AS employee_login
  ,COALESCE(relocations_hire, relocations_icims) AS relocations
  ,COALESCE(address_country_hire, address_country_icims) AS address_country
  ,(CASE WHEN relocations <> '' THEN 'YES' ELSE 'NO' END) AS is_cross_country
  
       ,(CASE 
          WHEN start_dwell_hire >= start_dwell_icims THEN start_dwell_icims
          WHEN start_dwell_hire IS NULL THEN start_dwell_icims
          WHEN start_dwell_hire < start_dwell_icims THEN start_dwell_hire
          WHEN start_dwell_icims IS NULL THEN start_dwell_hire
       END) AS start_dwell
 
      ,(CASE 
          WHEN end_dwell_hire >= end_dwell_icims THEN end_dwell_icims
          WHEN end_dwell_hire IS NULL AND end_dwell_icims IS NOT NULL THEN end_dwell_icims
          WHEN end_dwell_hire < end_dwell_icims THEN end_dwell_hire
          WHEN end_dwell_icims IS NULL AND end_dwell_hire IS NOT NULL THEN end_dwell_hire

       END) AS end_dwell

       ,(CASE 
          WHEN start_dwell_hire >= start_dwell_icims THEN 'ICIMS'
          WHEN start_dwell_hire IS NULL THEN 'ICIMS'
          WHEN start_dwell_hire < start_dwell_icims THEN 'HIRE'
          WHEN start_dwell_icims IS NULL THEN 'HIRE'
        END) AS originating_system

       ,(CASE
          WHEN dwelling_now_hire = 'YES' AND dwelling_now_icims = 'YES' AND req_status != 'FILLED' THEN 'YES'
          WHEN dwelling_now_hire IS NULL AND dwelling_now_icims = 'YES' AND req_status != 'FILLED' THEN 'YES'
          WHEN dwelling_now_hire = 'YES' AND dwelling_now_icims IS NULL AND req_status != 'FILLED' THEN 'YES'
          ELSE 'NO'
        END) AS dwelling_now

    FROM prep pr  
),

latest_state AS (
  SELECT w2.step AS current_status_hire, wl.status AS current_status_icims, wl.job_id, wl.person_id, w2.job_amzr_req_id, w2.cand_icims_id , enter_state_time, updated_timestamp
  FROM hrmetrics.art_full_latest w2    
  FULL OUTER JOIN ads.worksteps_latest wl ON w2.job_amzr_req_id = wl.job_id AND  w2.cand_icims_id = wl.person_id 
),

final AS (

SELECT DISTINCT

start_dwell
,COALESCE(end_dwell, (CASE WHEN ls.enter_state_time >= ls.updated_timestamp THEN TRUNC(ls.updated_timestamp) ELSE TRUNC(ls.enter_state_time) END)) AS end_dwelling
,DATEDIFF(day, start_dwell, end_dwelling) AS total_dwelling_time
,DATEDIFF(day, start_dwell, CASE WHEN (TRUNC(calendar_day) + INTERVAL '6 DAY') > end_dwell THEN end_dwell ELSE (TRUNC(calendar_day) + INTERVAL '6 DAY') END) AS dwelling_time
,calendar_day
,calendar_month_of_year
,calendar_qtr
,reporting_week_of_year
,reporting_year
,originating_system
,dwelling_now
,job_id_final
,person_id_final
,first_name
,last_name
,email
,ec.employee_internal_email_address
,ec.event_date
,peoplesoft_employee_id
,employee_class_name
,req_status
,sourcer_login
,reports_to_level_6_employee_login
,reports_to_level_6_employee_name
,relocations
,address_country
,is_cross_country
,current_status_hire
,current_status_icims
,TRUNC(SYSDATE) AS generated_date

FROM allraw ar
    LEFT JOIN latest_state ls ON (ls.job_id = ar.job_id AND ls.person_id = ar.person_id) OR (ar.job_amzr_req_id = ls.job_amzr_req_id AND ar.cand_icims_id = ls.cand_icims_id)
    INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND COALESCE(end_dwell, (CASE WHEN ls.enter_state_time >= ls.updated_timestamp THEN TRUNC(ls.updated_timestamp) ELSE TRUNC(ls.enter_state_time) END))
    LEFT JOIN employee_class ec ON ec.employee_internal_email_address = ar.email 
)

SELECT a.*
FROM final a
INNER JOIN (
      SELECT job_id_final, person_id_final, MAX(event_date) AS max_date
      FROM final
      GROUP BY job_id_final, person_id_final
) latest ON latest.job_id_final = a.job_id_final AND latest.person_id_final = a.person_id_final AND a.event_date = latest.max_date
WHERE 1=1

AND dwelling_time > 10
AND total_dwelling_time > 10
--AND reporting_week_of_year = 37
--AND a.job_id_final = 871718
--AND a.person_id_final = 5317133
