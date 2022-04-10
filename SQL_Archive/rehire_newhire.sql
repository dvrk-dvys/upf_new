WITH REHIRE AS (

    SELECT DISTINCT
     d.calendar_year AS YEAR,
     offer.job_code,
     offer.job_level,
     offer.job_icims_id,
     offer.candidate_icims_id,
     offer.candidate_full_name,
     offer.offer_accepted_count,
     offer.offer_accepted_date,
     starts.employee_start_date,
     starts.job_action_desc,
     prev.offer_accepted_date AS prev_offer_accepted_date,
     prev.job_code AS prev_job_code,
     prev.job_level AS prev_job_level,
     prev.job_icims_id AS prev_job_icims_id,
     prev.candidate_icims_id AS prev_candidate_icims_id,
     prev.candidate_full_name AS prev_candidate_full_name,
     ct.candidate_type AS prev_candidate_type

       
    FROM masterhr.offer_accepts offer
      LEFT JOIN hrmetrics.o_reporting_days AS d ON TRUNC (offer.offer_accepted_date) = TRUNC (d.calendar_day)
      INNER JOIN masterhr.candidate_type ct ON ct.candidate_icims_id = offer.candidate_icims_id AND ct.job_icims_id = offer.job_icims_id AND ct.candidate_type = 'EXTERNAL'
      INNER JOIN masterhr.offer_accepts prev ON offer.candidate_icims_id = prev.candidate_icims_id AND offer.offer_accepted_date != prev.offer_accepted_date
      LEFT JOIN masterhr.employee_starts starts ON offer.candidate_icims_id = starts.job_candidate_icims_id AND starts.job_icims_id = offer.job_icims_id

    WHERE 1 = 1
    AND offer.offer_accepted_count = 1
    AND YEAR IN (2019, 2020)
    AND offer.country = 'USA' 
    AND employee_start_date IS NOT NULL  

),

NEWHIRE AS (

    SELECT DISTINCT
    d.calendar_year AS YEAR,
    offers.job_code,
    offers.job_level,
    offers.job_icims_id,
    offers.candidate_icims_id,
    offers.candidate_full_name,
    offers.offer_accepted_count,
    offers.offer_accepted_date,
    starts.employee_start_date,
    starts.job_action_desc

    FROM masterhr.offer_accepts offers
    LEFT JOIN hrmetrics.o_reporting_days AS d ON TRUNC (offers.offer_accepted_date) = TRUNC (d.calendar_day)
    LEFT JOIN masterhr.employee_starts starts ON offers.candidate_icims_id = starts.job_candidate_icims_id AND starts.job_icims_id = offers.job_icims_id

    WHERE 1 = 1
    AND offers.candidate_icims_id NOT IN (SELECT candidate_icims_id FROM REHIRE)
    AND offers.offer_accepted_count = 1
    AND YEAR IN (2019, 2020)
    AND offers.country = 'USA'
    AND employee_start_date IS NOT NULL

)

(SELECT DISTINCT 
    YEAR,
    job_code,
    job_level,
    job_icims_id,
    candidate_icims_id,
    candidate_full_name,
    offer_accepted_count,
    offer_accepted_date,
    employee_start_date,
    job_action_desc,
    'REHIRE' AS rehire
 FROM REHIRE)
 
 UNION
 
 (SELECT DISTINCT 
    YEAR,
    job_code,
    job_level,
    job_icims_id,
    candidate_icims_id,
    candidate_full_name,
    offer_accepted_count,
    offer_accepted_date,
    employee_start_date,
    job_action_desc,
    'NEWHIRE' AS newhire
 FROM NEWHIRE)

order by 3,1 asc
