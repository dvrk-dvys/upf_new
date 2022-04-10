WITH ap AS (

      SELECT 
      job_id,
      icims_id,
      person_id,
     -- MIN(icims_created_timestamp) AS application_date
      MIN(convert_timezone ('US/Pacific',CAST((TIMESTAMP 'epoch' + CAST(icims_updated_timestamp AS BIGINT) / 1000*INTERVAL '1 Second') AS TIMESTAMP))) AS application_date
      
      FROM ads.worksteps
      GROUP BY job_id,
      icims_id,
      person_id
)

SELECT DISTINCT 
DATEDIFF (d , offer.requisition_final_approval_date::timestamp, offer_accepted_date::timestamp) as TTF,
DATEDIFF (d , TRUNC(ap.application_date), TRUNC(offer_accepted_date)) as TTH,
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
offer.candidate_type,
offer.job_id,
offer.candidate_guid,
offer.recruiter_employee_login,
reqs.recruiter_employee_login,
reqs.recruiter_employee_full_name,
reqs.sourcer_employee_login,
reqs.sourcer_employee_full_name,
offer.current_recruiter_employee_full_name,
reqs.current_job_state as reqscurrentjobstate,
reqs.internal_job_title,
reportingdays.calendar_day,
reportingdays.reporting_week_of_year,
reportingdays.calendar_month_of_year,
reportingdays.calendar_qtr,
reportingdays.reporting_year,
reqs.hiring_manager_reports_to_level_4_employee_login,
reqs.hiring_manager_reports_to_level_5_employee_login,
offer.hiring_manager_reports_to_level_4_employee_login,
offer.hiring_manager_reports_to_level_5_employee_login,
ap.application_date
--reqs.*
--offer.*



FROM masterhr.offer_accepts offer
INNER JOIN ap ON ap.job_id = offer.job_icims_id AND ap.person_id = offer.candidate_icims_id
INNER JOIN opsdw.ops_ta_team_wk team ON team.emplid = offer.recruiter_employee_id
INNER JOIN masterhr.requisition reqs ON reqs.job_icims_id = offer.job_icims_id AND ((TRUNC(offer.offer_accepted_date) BETWEEN TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(reqs.snapshot_end_timestamp)) OR (TRUNC(offer.offer_declined_date) BETWEEN TRUNC(reqs.snapshot_begin_timestamp) AND TRUNC(reqs.snapshot_end_timestamp)))
INNER JOIN hrmetrics.o_reporting_days reportingdays ON ((reportingdays.calendar_day = TRUNC(offer.offer_accepted_date)) OR (reportingdays.calendar_day = TRUNC(offer.offer_declined_date))) AND  reportingdays.reporting_year = DATEPART(year, sysdate)
WHERE 1=1


AND reporting_week_of_year = 46
--AND reqs.ofa_cost_center_code IN ('1001', '7709', '1010','1021','1090','1023','1025','1065','1172','1092','1145','1227','1158','1160','1166','1168','1173','2157','1290',
--'1174','1175','1184', '1186','1917','1200','1260','1263','1299','7033','1916','5121','5382','5615','7024','7177','8413')


--AND offer.enter_state_time::date between team.wk_begin_dt AND team.wk_end_dt
--AND offer.offer_accepted_count = 1
--AND offer.offer_declined_count = 1
--AND DATEPART(year,offer.offer_declined_date) = DATEPART(year, sysdate)
--AND offer.candidate_recruiter_login = 'osupike'
--AND UPPER(offer.sourcer_employee_login) = 'OSUPIKE'
--AND UPPER(reqs.sourcer_employee_login) = 'OSUPIKE'


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

--recruiter_reports_to_level_6_employee_login
--AND (offer.sourcer_reports_to_level_4_employee_name = 'Kelley,Sean Patrick'
--OR offer.recuiter_reports_to_level_4_employee_name = 'Kelley,Sean Patrick'
--OR offer.hiring_manager_reports_to_level_4_employee_login = 'feitzing'
--OR offer.hiring_manager_reports_to_level_5_employee_login = 'feitzing'

--OR reqs.sourcer_reports_to_level_4_employee_name = 'Kelley,Sean Patrick'
--OR reqs.recuiter_reports_to_level_4_employee_name = 'Kelley,Sean Patrick'
--OR reqs.hiring_manager_reports_to_level_4_employee_login = 'feitzing'
--OR reqs.hiring_manager_reports_to_level_5_employee_login = 'feitzing')




--AND UPPER(reqs.current_recruiter_employee_login) = 'OSUPIKE'
--AND lower(candidate_full_name) LIKE '%jordan%harris%'

--current_sourcer_employee_login
--LEVEL 10
--sourcer_reports_to_level_4_employee_name = Kelley,Sean Patrick
--hiring_manager_reports_to_level_4_employee_login = 'feitzing'
--hiring_manager_reports_to_level_5_employee_login = 'feitzing'

