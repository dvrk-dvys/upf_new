WITH weeks AS (

    SELECT 
    cast(calendar_day AS Timestamp) AS calendar_day
    ,reporting_week_of_year
    ,reporting_year

    FROM hrmetrics.o_reporting_days

    WHERE calendar_day_of_week = 1 AND reporting_year = 2019
    AND reporting_week_of_year < (SELECT  reporting_week_of_year FROM hrmetrics.o_reporting_days WHERE TRUNC(calendar_day) = TRUNC(sysdate))
),


hireraw_min_max AS (

  SELECT 
  artf.job_amzr_req_id
  ,artf.cand_icims_id
  ,w2.step
  ,artf.job_art_job_id
  ,CASE WHEN w2.step IN ( 'OFFER_CREATED', 'OFFER_EXTENDED') THEN 'YES' ELSE 'NO' END as check_field
  ,MIN(artf.enter_state_time) as event_min_date_time
  ,MAX(artf.enter_state_time) as event_max_date_time

  
  FROM hrmetrics.art_full artf

  LEFT JOIN hrmetrics.art_full_latest w2 ON artf.job_amzr_req_id = w2.job_amzr_req_id AND artf.cand_icims_id = w2.cand_icims_id   

  WHERE artf.step IN ( 'OFFER_CREATED', 'OFFER_EXTENDED')
  AND w2.internal = 'INTERNAL'
  --AND TRUNC(w2.enter_state_time) >= '2019-01-01'
  
  GROUP BY
    artf.job_amzr_req_id
    ,artf.cand_icims_id
    ,w2.step
    ,artf.job_art_job_id
    ,CASE WHEN w2.step IN ( 'OFFER_CREATED', 'OFFER_EXTENDED') THEN 'IN OFFER STEP' ELSE 'OTHER STEP' END

),

hireraw AS (

      SELECT 
      artf.job_amzr_req_id
      ,artf.cand_icims_id
      ,hmm.step AS current_status
      ,artf.job_art_job_id
      ,hmm.check_field AS dwelling_now
      
      ,hmm.event_min_date_time AS start_dwell
      ,hmm.event_max_date_time AS check_of_max_offer
      ,artf.enter_state_time AS end_dwell
      ,artf.enter_state_time AS event_max_date_time

      FROM hrmetrics.art_full artf

     INNER JOIN hireraw_min_max hmm ON artf.job_amzr_req_id = hmm.job_amzr_req_id AND artf.cand_icims_id = hmm.cand_icims_id   
     AND artf.enter_state_time > hmm.event_max_date_time

      GROUP BY
      artf.job_amzr_req_id
      ,artf.cand_icims_id
      ,hmm.step
      ,artf.job_art_job_id
      ,hmm.check_field
      ,artf.enter_state_time
      ,artf.enter_state_time
      ,hmm.event_min_date_time
      ,hmm.event_max_date_time
),

personal_data AS (
  SELECT first_name, last_name, email, icims_id
  FROM ads.applicants
),
 
req_data AS (
  SELECT job_amzr_req_id, job_art_job_id, sourcer_login
  FROM hrmetrics.art_jobs
  WHERE sourcer_id <> ''
  AND req_status != 'POOLING'
),

reporting_line AS (
  SELECT DISTINCT reports_to_level_6_employee_login, reports_to_level_6_employee_name,  employee_login
  FROM masterhr.employee_hc
  WHERE reports_to_level_6_employee_login = 'amandam'
)


SELECT *,
DATEDIFF(day, start_dwell, end_dwell) AS dwelling_time

FROM hireraw hr
    INNER JOIN weeks wks ON wks.calendar_day BETWEEN start_dwell AND end_dwell
    LEFT JOIN req_data ON req_data.job_art_job_id = hr.job_art_job_id
    INNER JOIN reporting_line ON reporting_line.employee_login = req_data.sourcer_login
    INNER JOIN personal_data pd ON hr.cand_icims_id = pd.icims_id

WHERE
1=1
--AND job_amzr_req_id = 321242 AND cand_icims_id = 60079
AND reporting_week_of_year = 34
AND dwelling_time > 10












