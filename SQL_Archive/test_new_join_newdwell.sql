WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,calendar_month_of_year
    ,calendar_qtr
    ,reporting_year

    FROM hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = 2019
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
),

personal_data AS (
  SELECT first_name, last_name, email, icims_id, address_country
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
  WHERE reports_to_level_6_employee_login = 'amandam'
),

latest_state AS (
  SELECT w2.step, wl.status, wl.job_id, wl.person_id
  FROM hrmetrics.art_full_latest w2    
  FULL OUTER JOIN ads.worksteps_latest wl ON w2.job_amzr_req_id = wl.job_id AND  w2.cand_icims_id = wl.person_id 
),


prep_min_max AS (

  SELECT 
  artf.job_amzr_req_id
  ,artf.cand_icims_id
  ,w2.step
  ,artf.job_art_job_id
  ,CASE WHEN w2.step IN ( 'OFFER_CREATED', 'OFFER_EXTENDED') THEN 'YES' ELSE 'NO' END as check_field_h
  ,MIN(TRUNC(artf.enter_state_time)) as event_min_date_time_h
  ,MAX(TRUNC(artf.enter_state_time)) as event_max_date_time_h


  ,wst.job_id
  ,wst.person_id
  ,wl.status
  ,CASE WHEN wl.status IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request') THEN 'YES' ELSE 'NO' END as check_field_i
  ,MIN(TRUNC(wst.updated_timestamp)) as event_min_date_time_i
  ,MAX(TRUNC(wst.updated_timestamp)) as event_max_date_time_i




  FROM hrmetrics.art_full artf
      FULL OUTER JOIN ads.worksteps wst ON artf.job_amzr_req_id = wst.job_id AND artf.cand_icims_id = wst.person_id 
  LEFT JOIN hrmetrics.art_full_latest w2 ON artf.job_amzr_req_id = w2.job_amzr_req_id AND artf.cand_icims_id = w2.cand_icims_id   
  LEFT JOIN ads.worksteps_latest wl ON wst.job_id = wl.job_id AND wst.person_id = wl.person_id 

  WHERE 1=1
  AND (( artf.step IN ('OFFER_CREATED', 'OFFER_EXTENDED') AND w2.internal = 'INTERNAL')
  OR (wst.status IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request')))

 -- WHERE 
    --AND artf.step IN ('OFFER_CREATED', 'OFFER_EXTENDED')
    --AND w2.internal = 'INTERNAL'
    --AND wst.status IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request')
  
  GROUP BY
    artf.job_amzr_req_id
    ,artf.cand_icims_id
    ,w2.step
    ,artf.job_art_job_id
    ,CASE WHEN w2.step IN ( 'OFFER_CREATED', 'OFFER_EXTENDED') THEN 'IN OFFER STEP' ELSE 'OTHER STEP' END
    
    ,wst.job_id
    ,wst.person_id
    ,wl.status
    ,CASE WHEN wl.status IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request') THEN 'IN OFFER STEP' ELSE 'OTHER STEP' END    
),

prepraw AS (

      SELECT 
      pmm.job_amzr_req_id
      ,pmm.cand_icims_id
      ,pmm.step AS current_status_hire
      ,pmm.job_art_job_id
      ,pmm.check_field_h AS dwelling_now_hire
      
      ,pmm.event_min_date_time_h AS start_dwell_hire
      ,pmm.event_max_date_time_h AS check_of_max_offer_hire
      ,MIN(TRUNC(artf.enter_state_time)) AS end_dwell_hire_1
      ,MAX(TRUNC(artf.enter_state_time)) AS event_max_date_time_hire_1
      ,first_name AS first_name_hire
      ,last_name AS last_name_hire
      ,email AS email_hire
      ,address_country AS address_country_hire
      ,pd.icims_id AS icims_id
      ,req_status AS req_status_hire
      ,sourcer_login AS sourcer_login_hire
      ,relocations AS relocations_hire
      ,reports_to_level_6_employee_login AS reports_to_level_6_employee_login_hire
      ,reports_to_level_6_employee_name AS reports_to_level_6_employee_name_hire
      ,employee_login AS employee_login_hire
       


      ,pmm.job_id
      ,pmm.person_id
      ,pmm.status AS current_status_icims
      ,pmm.check_field_i AS dwelling_now_icims
      ,cast((TIMESTAMP 'epoch' + CAST(pmm.event_min_date_time_i AS BIGINT)/1000 * INTERVAL '1 Second ') as date) as start_dwell_icims
      ,cast((TIMESTAMP 'epoch' + CAST(pmm.event_max_date_time_i AS BIGINT)/1000 * INTERVAL '1 Second ') as date) as check_of_max_offer_icims
      ,MIN(cast((TIMESTAMP 'epoch' + CAST(wst.updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ') as date)) AS end_dwell_icims_1
      ,MAX(cast((TIMESTAMP 'epoch' + CAST(wst.updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second ') as date)) AS event_max_date_time_icims_1
      ,first_name AS first_name_icims
      ,last_name AS last_name_icims
      ,email AS email_icims
      ,address_country AS address_country_icims
      ,req_status AS req_status_icims
      ,sourcer_login AS sourcer_login_icims
      ,relocations AS relocations_icims
      ,reports_to_level_6_employee_login AS reports_to_level_6_employee_login_icims
      ,reports_to_level_6_employee_name AS reports_to_level_6_employee_name_icims
      ,employee_login AS employee_login_icims

      FROM prep_min_max pmm
      

      LEFT JOIN hrmetrics.art_full artf ON artf.job_amzr_req_id = pmm.job_amzr_req_id AND artf.cand_icims_id = pmm.cand_icims_id AND TRUNC(artf.enter_state_time) > TRUNC(pmm.event_max_date_time_h)
      LEFT JOIN ads.worksteps  wst ON wst.job_id = pmm.job_id AND wst.person_id = pmm.person_id AND TRUNC(wst.updated_timestamp) > TRUNC(pmm.event_max_date_time_i)


      INNER JOIN req_data rd ON rd.job_art_job_id = pmm.job_art_job_id AND pmm.job_amzr_req_id = rd.job_amzr_req_id AND pmm.job_id = rd.job_amzr_req_id
      INNER JOIN reporting_line ON reporting_line.employee_login = rd.sourcer_login
      INNER JOIN personal_data pd ON pmm.cand_icims_id = pd.icims_id
     

      GROUP BY
      pmm.job_id
      ,pmm.person_id
      ,pmm.status
      ,pmm.check_field_i
      ,cast((TIMESTAMP 'epoch' + CAST(pmm.event_min_date_time_i AS BIGINT)/1000 * INTERVAL '1 Second ') as date)
      ,cast((TIMESTAMP 'epoch' + CAST(pmm.event_max_date_time_i AS BIGINT)/1000 * INTERVAL '1 Second ') as date)


      ,pmm.job_amzr_req_id
      ,pmm.cand_icims_id
      ,pmm.step
      ,pmm.job_art_job_id
      ,pmm.check_field_h
      ,pmm.event_min_date_time_h
      ,pmm.event_max_date_time_h
      ,pd.icims_id

      ,first_name, last_name, email, address_country, req_status, sourcer_login, reports_to_level_6_employee_login, reports_to_level_6_employee_name, employee_login, relocations
      
),

prep AS (

  SELECT *, coalesce(end_dwell_hire_1, sysdate) as end_dwell_hire, coalesce(event_max_date_time_hire_1, sysdate) as event_max_date_time_hire, DATEDIFF(day, start_dwell_hire, coalesce(end_dwell_hire_1, sysdate)) AS dwelling_time_hire,
            coalesce(end_dwell_icims_1, sysdate) as end_dwell_icims, coalesce(event_max_date_time_icims_1, sysdate) as event_max_date_time_icims, DATEDIFF(day, start_dwell_icims, coalesce(end_dwell_icims_1, sysdate)) AS dwelling_time_icims
            ,pr.job_amzr_req_id as job_amzr_req_id_final
            ,pr.cand_icims_id AS cand_icims_id_final

    FROM prepraw pr
  
),

allraw AS (

  SELECT DISTINCT *
  ,COALESCE(CAST(job_amzr_req_id_final AS int), job_id) AS job_id_final
  ,COALESCE(CAST(cand_icims_id_final AS int), person_id) AS person_id_final
  ,COALESCE(first_name_hire, first_name_icims) AS first_name
  ,COALESCE(last_name_hire, last_name_icims) AS last_name
  ,COALESCE(email_hire, email_icims) AS email
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
          WHEN end_dwell_hire IS NULL THEN end_dwell_icims
          WHEN end_dwell_hire < end_dwell_icims THEN end_dwell_hire
          WHEN end_dwell_icims IS NULL THEN end_dwell_hire
       END) AS end_dwell
 
       ,(CASE 
          WHEN start_dwell_hire >= start_dwell_icims THEN 'ICIMS'
          WHEN start_dwell_hire IS NULL THEN 'ICIMS'
          WHEN start_dwell_hire < start_dwell_icims THEN 'HIRE'
          WHEN start_dwell_icims IS NULL THEN 'HIRE'
        END) AS originating_system
        ---Not sure if dwelling_now correcteif
       ,(CASE
          WHEN dwelling_now_hire = 'YES' AND dwelling_now_icims = 'YES' AND req_status != 'FILLED' THEN 'YES'
          WHEN dwelling_now_hire IS NULL AND dwelling_now_icims = 'YES' AND req_status != 'FILLED' THEN 'YES'
          WHEN dwelling_now_hire = 'YES' AND dwelling_now_icims IS NULL AND req_status != 'FILLED' THEN 'YES'
          ELSE 'NO'
        END) AS dwelling_now

    FROM prep pr  
)


SELECT DATEDIFF(day, start_dwell, end_dwell) AS dwelling_time
,calendar_day
,calendar_month_of_year
,calendar_qtr
,reporting_week_of_year
,reporting_year
,start_dwell
,end_dwell
,originating_system
,dwelling_now
,job_id_final
,person_id_final
,first_name
,last_name
,email
,req_status
,sourcer_login
,reports_to_level_6_employee_login
,reports_to_level_6_employee_name
,employee_login
,relocations
,address_country
,is_cross_country
,current_status_hire
,current_status_icims



FROM allraw ar
    INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND end_dwell
    LEFT JOIN latest_state ls ON ls.job_id = ar.job_id AND ls.person_id = ar.person_id
WHERE 1=1
AND job_id_final = 771064
AND person_id_final = 12407718
AND first_name = 'Murad'
AND last_name = 'Hyasat'
--AND current_status_hire IN ('OFFER_CREATED', 'OFFER_EXTENDED')
--AND current_status_icims IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request')
--AND reporting_week_of_year IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ,13, 14, 15, 16)
--AND reporting_week_of_year = 32
--AND dwelling_time BETWEEN 11 AND 50
--AND job_id = 856550
--AND dwelling_now = 'YES'
--AND req_status_hire != req_status_icims






