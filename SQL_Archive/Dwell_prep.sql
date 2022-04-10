WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,reporting_year

    FROM hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = 2019
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
),

icims_raw AS (

  SELECT icims_id, person_id, job_id, status, updated_timestamp, dateadd(ms, ws.icims_updated_timestamp, '1970-01-01') AS icims_updated_timestamp, dateadd(ms, ws.updated_timestamp, '1970-01-01') AS status_date, dateadd(ms, ws.icims_created_timestamp, '1970-01-01') AS icims_created_timestamp 
    ,source_channel
    
    , count(*) OVER (PARTITION BY person_id, job_id ORDER BY ws.updated_timestamp ROWS UNBOUNDED PRECEDING) AS select_1 

    FROM ads.worksteps ws
    WHERE  1=1 
    AND dateadd(ms, ws.updated_timestamp, '1970-01-01') > '2017-01-01 00:00:00'
    --AND person_id = 17621531
    --AND job_id = 773272
    AND person_id = 6659102
    AND job_id = 898203
    
    AND TRUNC(status_date) >= '2019-01-01' 
),

hireraw AS (

  SELECT job_amzr_req_id, cand_icims_id, step, enter_state_time, job_art_job_id

    , count(*) OVER (PARTITION BY job_amzr_req_id, cand_icims_id ORDER BY enter_state_time ROWS UNBOUNDED PRECEDING) AS select_2
  
  FROM hrmetrics.art_full
  WHERE internal = 'INTERNAL'
  --AND cand_icims_id = 17621531
  --AND job_amzr_req_id = 773272
  AND cand_icims_id = 6659102
  AND job_amzr_req_id = 898203

  AND TRUNC(enter_state_time) >= '2019-01-01'
),  

personal_data AS (
  SELECT first_name, last_name, email, icims_id
  FROM ads.applicants
),
 
req_status AS (
  SELECT req_status, job_amzr_req_id, job_art_job_id, sourcer_login
  FROM hrmetrics.art_jobs
  WHERE sourcer_id <> ''
),

reporting_line AS (
  SELECT DISTINCT reports_to_level_6_employee_login, reports_to_level_6_employee_name,  employee_login
  FROM masterhr.employee_hc
  WHERE reports_to_level_6_employee_login = 'amandam'
),

icimsprep AS (

  SELECT
    ir.icims_id
    ,person_id
    ,job_id
    ,select_1
    ,select_2
    ,ir.icims_created_timestamp
    ,ir.icims_updated_timestamp
    ,ir.updated_timestamp
    --,CASE WHEN ir.icims_id = ir.next_icims_id_1 THEN 1 END AS matchingreqcandidate
    --,wks.reporting_week_of_year
    --,wks.reporting_year
    --,wks.calendar_day AS weekstart
    ,source_channel
    ,first_name
    ,last_name
    ,email  
    ,status
    ,ir.status_date
    ,cand_icims_id 
    ,step
    ,enter_state_time
    ,req_status.req_status
    ,hr.job_amzr_req_id
    ,hr.job_art_job_id
    ,req_status.sourcer_login
    ,reporting_line.reports_to_level_6_employee_login
    ,reporting_line.reports_to_level_6_employee_name
  
    ,LEAD (ir.icims_id,1) OVER (ORDER BY  ir.icims_id DESC, ir.updated_timestamp ASC,
      (CASE WHEN ir.status LIKE 'Candidate - Offer - Requested' THEN 10
           WHEN ir.status LIKE 'Internal Transfer - Prepare Offer' THEN 20
           WHEN ir.status LIKE 'Internal Transfer - Offer Confirmation Request' THEN 30
           WHEN ir.status LIKE  'Candidate - Offer - Approved' THEN 40
           WHEN ir.status LIKE  'Candidate - Offer - Extended' THEN 50
     
      ELSE 1000 END )ASC ) AS next_icims_id_1

      ,LEAD (ir.status, 1) OVER (ORDER BY  ir.icims_id DESC, ir.updated_timestamp ASC,
      (CASE WHEN ir.status LIKE 'Candidate - Offer - Requested' THEN 10
           WHEN ir.status LIKE 'Internal Transfer - Prepare Offer' THEN 20
           WHEN ir.status LIKE 'Internal Transfer - Offer Confirmation Request' THEN 30
           WHEN ir.status LIKE  'Candidate - Offer - Approved' THEN 40
           WHEN ir.status LIKE  'Candidate - Offer - Extended' THEN 50
     
      ELSE 1000 END )ASC ) AS next_status_1

      ,LEAD (dateadd(ms, ir.updated_timestamp, '1970-01-01'), 1) OVER (ORDER BY  ir.icims_id DESC, ir.updated_timestamp ASC,
      (CASE WHEN ir.status LIKE 'Candidate - Offer - Requested' THEN 10
           WHEN ir.status LIKE 'Internal Transfer - Prepare Offer' THEN 20
           WHEN ir.status LIKE 'Internal Transfer - Offer Confirmation Request' THEN 30
           WHEN ir.status LIKE  'Candidate - Offer - Approved' THEN 40
           WHEN ir.status LIKE  'Candidate - Offer - Extended' THEN 50
     
      else 1000 END )ASC ) AS next_time_1
    

      ,LEAD (step, 1) OVER (ORDER BY  cand_icims_id DESC, enter_state_time ASC,
    (CASE WHEN step LIKE 'OFFER_CREATED' THEN 15 
         WHEN step LIKE 'OFFER_ACCEPTED' THEN 25 

      ELSE 1000 END )ASC ) AS next_step_2

    ,LEAD (enter_state_time,1) OVER (ORDER BY  cand_icims_id DESC, enter_state_time ASC,
    (CASE WHEN step LIKE 'OFFER_CREATED' THEN 15 
         WHEN step LIKE 'OFFER_ACCEPTED' THEN 25 

      ELSE 1000 END )ASC ) AS next_time_2
    
      ,(CASE 
          WHEN enter_state_time > status_date THEN status
          WHEN enter_state_time < status_date THEN step
       END) AS first_state,
 
      (CASE 
          WHEN next_time_1 > next_time_2 THEN next_step_2
          WHEN next_time_1 < next_time_2 THEN next_status_1
       END) AS next_state,
 
      (CASE 
         WHEN enter_state_time > status_date THEN status_date
         WHEN enter_state_time < status_date THEN enter_state_time
       END) AS first_state_time,
 
       (CASE 
          WHEN next_time_1 > next_time_2 THEN next_time_2
          WHEN next_time_1 < next_time_2 THEN next_time_1
        END) AS next_state_time,
 
       (CASE 
          WHEN enter_state_time > status_date THEN 'ICIMS'
          WHEN enter_state_time < status_date THEN 'HIRE'
        END) AS originating_system
   
     --DATEDIFF(day, first_state_time, next_state_time) AS dwelling_time


    FROM hireraw hr
    --FROM icims_raw ir
  
    FULL OUTER JOIN icims_raw ir ON ir.person_id = hr.cand_icims_id AND ir.job_id = hr.job_amzr_req_id
    --LEFT JOIN hireraw ON  = ir.person_id AND hireraw.job_amzr_req_id = ir.job_id
    LEFT JOIN req_status ON req_status.job_art_job_id = hr.job_art_job_id
    INNER JOIN reporting_line ON reporting_line.employee_login = req_status.sourcer_login
    INNER JOIN personal_data pd ON ir.person_id = pd.icims_id



    WHERE step IN ('OFFER_CREATED', 'OFFER_EXTENDED') OR status IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request')
    --AND( CASE WHEN ir.icims_id = ir.next_icims_id_1 THEN 1 END) = 1
    AND req_status != 'POOLING'
    --AND select_1 = 1

)


  SELECT 
    count(*) OVER (PARTITION BY person_id, job_id ORDER BY next_state_time ROWS UNBOUNDED PRECEDING) AS selecting
    ,*
    ,wks.reporting_week_of_year
    ,wks.reporting_year
    ,wks.calendar_day AS weekstart
    ,DATEDIFF(day, TRUNC(first_state_time), TRUNC(wks.calendar_day) + INTERVAL '6 DAY') AS dwelling_time
 --operations.f_weekday_minutes_between(first_state_time, next_state_time)/1440
    

  FROM icimsprep ip
      --INNER JOIN weeks wks ON wks.calendar_day BETWEEN first_state_time AND next_state_time 
      INNER JOIN weeks wks ON (next_state_time BETWEEN TRUNC(wks.calendar_day) AND TRUNC(wks.calendar_day) + INTERVAL '6 DAY') OR next_state_time IS NULL
  --WHERE reporting_week_of_year = 32
  AND (first_state IN ('OFFER_CREATED', 'OFFER_EXTENDED', 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request'))
 -- AND (next_state NOT IN ('OFFER_CREATED', 'OFFER_EXTENDED', 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request') OR next_state IS NULL)





