WITH accepts AS (

      SELECT DISTINCT 
      DATEDIFF (d , offer.requisition_final_approval_date::timestamp,offer_accepted_date::timestamp) as TTF,
      reqs.job_id,
      reqs.job_icims_id,
      reqs.ofa_cost_center_code,
      --reqs.snapshot_begin_timestamp,
      --reqs.snapshot_end_timestamp,
      offer.icims_status,
      offer.enter_state_time,
      offer.candidate_full_name,
      offer.job_icims_id,
      offer.candidate_icims_id,
      offer.offer_accepted_count,
      offer.offer_accepted_date,
      offer.offer_declined_count,
      offer.offer_declined_date,
      offer.job_id,
      offer.candidate_guid,
      offer.candidate_type,
      offer.recruiter_employee_login,
      offer.current_recruiter_employee_full_name,
      reqs.current_job_state as reqscurrentjobstate,
      reqs.internal_job_title,
      reportingdays.calendar_day,
      reportingdays.reporting_week_of_year,
      reportingdays.calendar_month_of_year,
      reportingdays.calendar_qtr,
      reportingdays.reporting_year



      FROM masterhr.offer_accepts offer
      INNER JOIN opsdw.ops_ta_team_wk team ON team.emplid = offer.recruiter_employee_id
      INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = offer.job_icims_id AND ((TRUNC(offer.offer_accepted_date) BETWEEN TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(reqs.snapshot_end_timestamp)) OR (TRUNC(offer.offer_declined_date) BETWEEN TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(reqs.snapshot_end_timestamp)))
      INNER JOIN hrmetrics.o_reporting_days reportingdays ON ((reportingdays.calendar_day = TRUNC(offer.offer_accepted_date)) OR (reportingdays.calendar_day = TRUNC(offer.offer_declined_date))) AND  reportingdays.reporting_year = DATEPART(year, sysdate)
      WHERE 1=1
      --AND reqs.ofa_cost_center_code in ('1023', '1092', '1145', '1158', '1160', '1171', '1172', '1173', '1174', '1263', '1290', '1299', '1917', '2157', '7024', '7709')
      AND offer.enter_state_time::date between team.wk_begin_dt AND team.wk_end_dt
      AND offer.offer_accepted_count = 1
      AND (LOWER(offer.sourcer_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike')
      OR LOWER(reqs.sourcer_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike')
      OR LOWER(offer.recruiter_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike') 
      OR LOWER(reqs.recruiter_employee_login) IN ('lizjam', 'landeb' , 'rpprker' , 'raghushw', 'liuyul', 'osupike'))

--AND( --reqs.recruiter_reports_to_level_6_employee_login IN ('wiljohnn', 'cathlinh', 'paulinma', 'balla', 'mjwheble', 'jonethad')
--OR offer.recruiter_reports_to_level_6_employee_login IN ('wiljohnn', 'cathlinh', 'paulinma', 'balla', 'mjwheble', 'jonethad')

      OR( LOWER(reqs.hiring_manager_reports_to_level_4_employee_login) = 'feitzing'
      OR LOWER(reqs.hiring_manager_reports_to_level_5_employee_login) = 'feitzing'
      OR LOWER(offer.hiring_manager_reports_to_level_4_employee_login) = 'feitzing'
      OR LOWER(offer.hiring_manager_reports_to_level_5_employee_login) = 'feitzing')
)


select distinct

promo_effective_date,
ep.emplid,
ep.employee_login,
ep.employee_full_name,
reportingdays.calendar_day,
reportingdays.reporting_week_of_year,
reportingdays.reporting_year,
reportingdays.calendar_month_of_year,
reportingdays.calendar_qtr,
prior_regulatory_region_country_name AS prior_country,
post_regulatory_region_country_name AS post_country,
ep.*


from masterhr.employee_promotions ep
INNER JOIN masterhr.employee_hc hc ON hc.employee_login = ep.employee_login
--INNER JOIN accepts a ON hc.job_candidate_icims_id = a.candidate_icims_id
INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = ep.promo_effective_date::DATE AND reportingdays.reporting_year = DATEPART(year, sysdate)


WHERE 1=1
AND (prior_reports_to_level_4_employee_login = 'feitzing'
OR prior_reports_to_level_5_employee_login = 'feitzing')
