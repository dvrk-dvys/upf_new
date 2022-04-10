 SELECT DISTINCT
     d.calendar_year AS offer_year,
     hc.job_code,
     hc.job_level_name,
     offer.job_icims_id,
     offer.candidate_icims_id,
     offer.candidate_full_name,
     starts.job_action_desc,
     ct.candidate_type AS prev_candidate_type,
     offer.offer_accepted_count,
     offer.offer_accepted_date,
     starts.employee_start_date,
     starts.emplid,
     starts.reports_to_level_3_employee_login,
     HIST.*


       
    FROM masterhr.offer_accepts offer
      INNER JOIN opsdw.employer_history hist ON hist.candidate_icims_id = offer.candidate_icims_id
      LEFT JOIN hrmetrics.o_reporting_days AS d ON TRUNC (offer.offer_accepted_date) = TRUNC (d.calendar_day)
      LEFT JOIN masterhr.candidate_type ct ON ct.candidate_icims_id = offer.candidate_icims_id AND ct.job_icims_id = offer.job_icims_id AND ct.candidate_type = 'EXTERNAL'
      LEFT JOIN masterhr.employee_starts starts ON offer.candidate_icims_id = starts.job_candidate_icims_id AND starts.job_icims_id = offer.job_icims_id
      LEFT JOIN masterhr.employee_hc_current hc ON starts.emplid = hc.emplid

    WHERE 1 = 1
    AND offer.offer_accepted_count = 1
    AND DATEPART(year, employee_start_date)IN (2019, 2020)
    AND offer.country = 'USA' 

    AND job_action_desc IN ('Rehire', 'New Hire') 
    AND starts.reports_to_level_3_employee_login = 'davecl'
    AND (professional_experience_1_employer IS NOT NULL
    OR professional_experience_2_employer IS NOT NULL
    OR professional_experience_3_employer IS NOT NULL
    OR professional_experience_4_employer IS NOT NULL
    OR professional_experience_5_employer IS NOT NULL  
    OR professional_experience_6_employer IS NOT NULL
    OR professional_experience_7_employer IS NOT NULL
    OR professional_experience_8_employer IS NOT NULL 
    OR professional_experience_9_employer IS NOT NULL)  
