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

  SELECT icims_id, person_id, job_id, status, dateadd(ms, ws.icims_updated_timestamp, '1970-01-01') AS icims_updated_timestamp, dateadd(ms, ws.updated_timestamp, '1970-01-01') AS status_date, dateadd(ms, ws.icims_created_timestamp, '1970-01-01') AS icims_created_timestamp 

  ,LEAD (ws.icims_id,1) OVER (ORDER BY  ws.icims_id DESC, ws.updated_timestamp ASC,
  (CASE WHEN ws.status LIKE 'Candidate - Offer - Requested' THEN 10
       WHEN ws.status LIKE 'Internal Transfer - Prepare Offer' THEN 20
       WHEN ws.status LIKE 'Internal Transfer - Offer Confirmation Request' THEN 30
       WHEN ws.status LIKE  'Candidate - Offer - Approved' THEN 40
       WHEN ws.status LIKE  'Candidate - Offer - Extended' THEN 50
     
  ELSE 1000 END )ASC ) AS next_icims_id_1

  ,LEAD (ws.status, 1) OVER (ORDER BY  ws.icims_id DESC, ws.updated_timestamp ASC,
  (CASE WHEN ws.status LIKE 'Candidate - Offer - Requested' THEN 10
       WHEN ws.status LIKE 'Internal Transfer - Prepare Offer' THEN 20
       WHEN ws.status LIKE 'Internal Transfer - Offer Confirmation Request' THEN 30
       WHEN ws.status LIKE  'Candidate - Offer - Approved' THEN 40
       WHEN ws.status LIKE  'Candidate - Offer - Extended' THEN 50
     
  ELSE 1000 END )ASC ) AS next_status_1

  ,LEAD (dateadd(ms, ws.updated_timestamp, '1970-01-01'), 1) OVER (ORDER BY  ws.icims_id DESC, ws.updated_timestamp ASC,
  (CASE WHEN ws.status LIKE 'Candidate - Offer - Requested' THEN 10
       WHEN ws.status LIKE 'Internal Transfer - Prepare Offer' THEN 20
       WHEN ws.status LIKE 'Internal Transfer - Offer Confirmation Request' THEN 30
       WHEN ws.status LIKE  'Candidate - Offer - Approved' THEN 40
       WHEN ws.status LIKE  'Candidate - Offer - Extended' THEN 50
     
  else 1000 END )ASC ) AS next_time_1

  FROM ads.worksteps ws
  WHERE  1=1 
  AND dateadd(ms, ws.updated_timestamp, '1970-01-01') > '2017-01-01 00:00:00'
),

hireraw AS (

  SELECT job_amzr_req_id, cand_icims_id, step, enter_state_time, job_art_job_id

  ,LEAD (step, 1) OVER (ORDER BY  cand_icims_id DESC, enter_state_time ASC,
  (CASE WHEN step LIKE 'OFFER_CREATED' THEN 15 
       WHEN step LIKE 'OFFER_ACCEPTED' THEN 25 

    ELSE 1000 END )ASC ) AS next_step_2

  ,LEAD (enter_state_time,1) OVER (ORDER BY  cand_icims_id DESC, enter_state_time ASC,
  (CASE WHEN step LIKE 'OFFER_CREATED' THEN 15 
       WHEN step LIKE 'OFFER_ACCEPTED' THEN 25 

    ELSE 1000 END )ASC ) AS next_time_2
  
  FROM hrmetrics.art_full
  WHERE internal = 'INTERNAL'
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
  ir.person_id
  ,ir.job_id::varchar AS req_icims_id
  ,ir.icims_created_timestamp
  ,ir.icims_updated_timestamp
  ,CASE WHEN ir.icims_id = ir.next_icims_id_1 THEN 1 END AS matchingreqcandidate
  ,wks.reporting_week_of_year
  ,wks.reporting_year
  ,wks.calendar_day AS weekstart
  ,icims_id
  ,person_id
  ,job_id
  ,status
  ,ir.status_date
  ,next_icims_id_1
  ,next_status_1
  ,next_time_1
  ,cand_icims_id 
  ,step
  ,enter_state_time
  ,next_step_2
  ,next_time_2
  ,req_status.req_status
  ,hireraw.job_amzr_req_id
  ,hireraw.job_art_job_id
  ,req_status.sourcer_login
  ,reporting_line.reports_to_level_6_employee_login
  ,reporting_line.reports_to_level_6_employee_name


  FROM icims_raw ir
  

  FULL OUTER JOIN hireraw ON hireraw.cand_icims_id = ir.person_id 
  LEFT JOIN req_status ON req_status.job_art_job_id = hireraw.job_art_job_id
  INNER JOIN weeks wks ON wks.calendar_day BETWEEN ir.status_date AND ir.next_time_1
  INNER JOIN reporting_line ON reporting_line.employee_login = req_status.sourcer_login

  WHERE step IN ('OFFER_CREATED', 'OFFER_EXTENDED')
  AND status_date > '2019-01-01' 
  AND enter_state_time > '2019-01-01' 
  AND ( CASE WHEN ir.icims_id = ir.next_icims_id_1 THEN 1 END) = 1
  AND status IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request')
  AND req_status != 'POOLING'
)

SELECT 

  ip.cand_icims_id,
  req_icims_id,
  icims_created_timestamp,
  icims_updated_timestamp,
  reporting_week_of_year,
  reporting_year,
  weekstart,
  icims_id,
  job_art_job_id,
  req_status,
  sourcer_login,
  reports_to_level_6_employee_login,
  reports_to_level_6_employee_name,
  status,
  status_date,
  next_icims_id_1,
  next_status_1,
  next_time_1,
  step,
  enter_state_time,
  next_step_2,
  next_time_2,

  (CASE 
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
   END) AS first_offer_creation,
 
   (CASE 
      WHEN next_time_1 > next_time_2 THEN next_time_2
      WHEN next_time_1 < next_time_2 THEN next_time_1
    END) AS next_state_time,
 
   (CASE 
      WHEN enter_state_time > status_date THEN 'ICIMS'
      WHEN enter_state_time < status_date THEN 'HIRE'
    END) AS originating_system,
   
 DATEDIFF(day, status_date, next_state_time) AS dwelling_time

FROM icimsprep ip
WHERE DATEDIFF(day, status_date, next_state_time) > 10 
AND next_state IN ( 'Candidate - Offer - Requested', 'Candidate - Offer - Approved', 'Candidate - Offer - Extended', 'Internal Transfer - Prepare Offer', 'Internal Transfer - Offer Confirmation Request', 'OFFER_CREATED', 'OFFER_EXTENDED')
