WITH ap AS (

    SELECT 

    job_id,
    icims_id,
    person_id,
    --status,
    MIN(convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(icims_updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp))) as application_date

    FROM

    ads.worksteps
    GROUP BY job_id, icims_id, person_id
),

status as(
 
    SELECT 

    job_id,
    icims_id,
    person_id,
    status

    FROM

    ads.worksteps
    GROUP BY job_id, icims_id, person_id, status
),

HC AS (

    SELECT *    
    FROM masterhr.employee_hc_current
    WHERE 1=1
    AND employee_hc_current.job_title_short_name IN ('MgrIII,SDE', 'SDE III', 'SDEIII', 'MgrIIIP/A', 'Princ,SDE', 'SrMgr,Soft', 'Front-End', 'MgrII,SDE', 'SDE II', 'SDEII', 'Front-End', 'SDE I', 'SDEI')

)



SELECT DISTINCT 
    ap.application_date, 
    DATEDIFF (d , offer.requisition_final_approval_date::timestamp,offer_accepted_date::timestamp) as TTF,
    offer.job_icims_id,
    offer.candidate_icims_id,
    offer.enter_state_time,
    offer.offer_accepted_date,
    offer.candidate_full_name,    
    offer.job_id,
    offer.hire_type,
    offer.department_id,
    offer.location_id,
    offer.current_job_state,
    offer.candidate_type,
    hc.employee_display_name,
    hc.emplid,
    hc.employee_login,
    hc.job_title_name,
    hc.job_title_short_name,
    
    offer.job_title,
    offer.internal_job_title,
    offer.employee_class,
    offer.cost_type,
    offer.job_code,
    offer.job_level,
    offer.job_tech_indicator,
    offer.job_tech_non_tech_sde_code,
    
    offer.country,
    offer.state,
    offer.city,
    offer.building,
    offer.location_building_name,
    offer.business_unit_code,
    offer.business_unit_name,
    offer.job_family_name,
    offer.job_family_code,
    offer.job_classification_title,
    
    offer.current_recruiter_employee_id,
    offer.current_recruiter_employee_login,
    offer.current_sourcer_employee_id,
    offer.current_sourcer_employee_login,
    
    offer.candidate_identifier_employee_id,
    offer.candidate_identifier_login,
    offer.candidate_identifier_name,
    offer.candidate_recruiter_employee_id,
    offer.candidate_recruiter_login,
    offer.candidate_recruiter_name,
    offer.candidate_source_category,
    offer.recruiting_state


from masterhr.offer_accepts offer
inner join opsdw.ops_ta_team_wk team on team.emplid = offer.recruiter_employee_id
--inner join masterhr.requisition reqs on reqs.job_icims_id = offer.job_icims_id
--left join hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = offer.offer_accepted_date

inner join ap on ap.job_id = offer.job_icims_id and ap.person_id = offer.candidate_icims_id 
--left join status on status.job_id = ap.job_id and status.person_id = ap.person_id
--left join lookup.icims_recruiting_states s on status.status=s.icims_status 
left join hc ON hc.job_candidate_icims_id = offer.candidate_icims_id AND hc.job_icims_id = offer.job_icims_id


WHERE 1=1    
--AND offer.enter_state_time::date between team.wk_begin_dt AND team.wk_end_dt
AND offer.offer_accepted_count = 1
AND DATEPART(year, offer_accepted_date) = '2019'
AND( offer.recruiter_reports_to_level_4_employee_login = 'kelleyse'
OR offer.recruiter_reports_to_level_3_employee_login = 'kelleyse'
OR offer.sourcer_reports_to_level_4_employee_login= 'kelleyse'
OR offer.sourcer_reports_to_level_3_employee_login = 'kelleyse'
OR offer.sourcer_reports_to_level_5_employee_login= 'taravan'
OR offer.sourcer_reports_to_level_5_employee_login = 'taravan')
AND (offer.job_classification_title IN ('Software Dev Engineer III', 'Software Dev Engineer - Test III', 'Software Dev Engineer II', 'Software Dev Engineer II-TEST', 'Software Dev Engineer I', 'Software Dev Engineer I-TEST')
OR hc.job_title_short_name IN ('MgrIII,SDE', 'SDE III', 'SDEIII', 'MgrIIIP/A', 'Princ,SDE', 'SrMgr,Soft', 'Front-End', 'MgrII,SDE', 'SDE II', 'SDEII', 'Front-End', 'SDE I', 'SDEI'))
--AND hc.employee_login = 'mackieg'
--AND hc.employee_display_name IS NOT NULL
