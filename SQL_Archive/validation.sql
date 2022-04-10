WITH old_one AS (

    select * from 
    (
    Select distinct 
    --candidate.first_name	|| ' ' || candidate.last_name as Full_Name,
    hc.employee_display_name AS full_name,
    candidate.candidate_icims_id as candidate_id,
    candidate_employee_id as empl_id,
    convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(w.icims_updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp)) application_date, 

    team.wk_begin_dt,
    team.wk_end_dt,    

    interview.job_icims_id as icims_id, 
    offer.enter_state_time as ofr_extndd_dt,
    w.status as Step,
    offer.offer_accepted_date as ofr_accepted_dt,
    reqs.city as loc_cty_nm, 
    reqs.building as loc_bldg_cd,
    reqs.internal_job_title as business_title,
    reqs.job_title as external_job_title,
    reqs.hiring_manager_reports_to_level_3_employee_login as hrng_mngr_reports_to_level3_login, 
    reqs.company_name as co_nm, 
    reqs.department_name as dept_nm, 
    reqs.job_function as job_function_desc,
    reqs.job_type, 
    reqs.job_level, 
    reqs.country as rgltry_rgn_cd,
    Case
    WHEN reqs.job_level >=5 THEN hc.employee_internal_email_address
    WHEN hc.employee_personal_email_address = '' THEN hc.employee_internal_email_address
    ELSE hc.employee_personal_email_address END as email_address,
    hc.job_title_name as job_title, 
    hc.job_level_name as job_level, 
    hc.location_short_name as  loc_nm,
    hc.reports_to_level_3_employee_login as reports_to_level3_login, 
    hc.reports_to_supervisor_employee_login as reports_to_suprvsr_login, 
    hc.department_name as dept_nm, 
    interview.interview_completed_dt as interview_date, 
    reqs.current_recruiter_employee_login  as recruiter_login,
    reqs.current_recruiter_employee_full_name as recruiter_nm,
    reqs.opex_id || ' - ' || reqs.department_name || ' - '  || reqs.business_unit_code|| ' - '  ||  hc.reports_to_level_3_employee_login as Business_Lane, 
    team.team_flag, 
    interview.interview_summary_id as intrvw_summary_id,
    row_number() over (partition by interview.job_icims_id || candidate.candidate_id order by rad.clock_stop_time desc ) rnum

    from masterhr.interview_activity interview

    inner join masterhr.candidate candidate on candidate.candidate_icims_id = interview.candidate_icims_id 
    inner join ads.worksteps w on w.job_id = interview.job_icims_id and w.person_id = interview.candidate_icims_id 
    left join masterhr.offer_accepts offer on offer.candidate_icims_id = interview.candidate_icims_id AND offer.job_icims_id = interview.job_icims_id
    inner join masterhr.requisition reqs on reqs.job_icims_id = interview.job_icims_id
    inner join opsdw.ops_ta_team_wk team on team.emplid = reqs.current_recruiter_employee_id
    inner join masterhr.employee_hc_current hc on hc.emplid = candidate.candidate_employee_id
    inner join hrmetrics.rad_two_five_promise rad on rad.interview_summary_id = interview.interview_summary_id 


    where reqs.recruiter_reports_to_level_4_employee_login = 'kelleyse'
    and reqs.current_transaction_flag = 'Y'
    and interview.applicant_type = 'INTERNAL'
    and interview.event_type = 'On-site'
    and interview.event_status = 'Occurred'
    and rad.clock_stop_time::date >= dateadd(day,-7,sysdate)
    and hc.emplid IS NOT Null )
     where rnum=1
     --AND full_name = 'GABE NIEVES' 
     --AND full_name = 'Victoria Arana'
     --AND( full_name = 'Caitlyn Edler'
     --or full_name = 'Andrew Liggon'
     --OR full_name = 'Adam Waligorski')


),

new_one as (

    WITH current_step AS (
    SELECT 
    w.job_id
    ,w.person_id
    ,MAX(w.icims_updated_timestamp) as max_date
    FROM ads.worksteps w

    GROUP BY
    icims_created_timestamp, icims_id, person_id, job_id, referrer_id, source_category, source_channel, source_specific

    )




    select * from 
    (
    Select distinct 
    --candidate.first_name	|| ' ' || candidate.last_name as Full_Name,
    hc.employee_display_name AS full_name,

    candidate.candidate_icims_id as candidate_id,
    candidate_employee_id as empl_id,

    --convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(w.icims_updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp)) application_date,
    convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(w.icims_created_timestamp AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp)) application_date,
    
    team.wk_begin_dt,
    team.wk_end_dt,

    interview.job_icims_id as icims_id,
    offer.enter_state_time as ofr_extndd_dt,
    w.status as Step,
    offer.offer_accepted_date as ofr_accepted_dt,
    reqs.city as loc_cty_nm, 
    reqs.building as loc_bldg_cd,
    reqs.internal_job_title as business_title,
    reqs.job_title as external_job_title,
    reqs.hiring_manager_reports_to_level_3_employee_login as hrng_mngr_reports_to_level3_login, 
    reqs.company_name as co_nm, 
    reqs.department_name as dept_nm, 
    reqs.job_function as job_function_desc,
    reqs.job_type, 
    reqs.job_level as req_job_level, 
    reqs.country as rgltry_rgn_cd,
    Case
    WHEN reqs.job_level >=5 THEN hc.employee_internal_email_address
    WHEN hc.employee_personal_email_address = '' THEN hc.employee_internal_email_address
    ELSE hc.employee_personal_email_address END as email_address,

    hc.job_title_name as current_job_title, 
    hc.job_level_name as current_job_level,
 
    hc.location_short_name as  loc_nm,
    hc.reports_to_level_3_employee_login as reports_to_level3_login, 
    hc.reports_to_supervisor_employee_login as reports_to_suprvsr_login, 
    hc.department_name as dept_nm, 
    reqs.current_recruiter_employee_login  as recruiter_login,
    reqs.current_recruiter_employee_full_name as recruiter_nm,
    reqs.opex_id || ' - ' || reqs.department_name || ' - '  || reqs.business_unit_code|| ' - '  ||  hc.reports_to_level_3_employee_login as Business_Lane, 
    team.team_flag, 
    interview.interview_summary_id as intrvw_summary_id,
    --team.wk_begin_dt,
    --team.wk_end_dt,
    convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(cs.max_date AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp)) as max_date

    --row_number() over (partition by interview.job_icims_id || candidate.candidate_id order by rad.clock_stop_time desc ) rnum

    from masterhr.interview_activity interview

    inner join masterhr.candidate candidate on candidate.candidate_icims_id = interview.candidate_icims_id 
    inner join current_step cs on cs.job_id = interview.job_icims_id and cs.person_id = interview.candidate_icims_id 
    inner join ads.worksteps w on w.job_id = interview.job_icims_id and w.person_id = interview.candidate_icims_id AND cs.max_date = w.icims_updated_timestamp


    left join masterhr.offer_accepts offer on offer.candidate_icims_id = interview.candidate_icims_id AND offer.job_icims_id = interview.job_icims_id
    inner join masterhr.requisition reqs on reqs.job_icims_id = interview.job_icims_id
    inner join opsdw.ops_ta_team_wk team on (team.emplid = reqs.current_recruiter_employee_id AND (trunc(convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(w.icims_created_timestamp AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp))) BETWEEN team.wk_begin_dt and team.wk_end_dt))          
                                             OR (team.emplid = reqs.recruiter_employee_login  AND (trunc(convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(w.icims_created_timestamp AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp))) BETWEEN team.wk_begin_dt and team.wk_end_dt)) 
    inner join masterhr.employee_hc_current hc on hc.emplid = candidate.candidate_employee_id
    --inner join hrmetrics.rad_two_five_promise rad on rad.interview_summary_id = interview.interview_summary_id 


    where 1=1
    AND reqs.recruiter_reports_to_level_4_employee_login = 'kelleyse'
    --OR (reqs.recruiter_reports_to_level_3_employee_login = 'darcie'
    --AND reqs.recruiter_reports_to_level_4_employee_login IN ('barresi','jsserran','jquintas','chaluleu','ninasj'))
    and reqs.current_transaction_flag = 'Y'
    and interview.applicant_type = 'INTERNAL'
    and interview.event_type = 'On-site'
    and interview.event_status = 'Occurred'


    --and rad.clock_stop_time::date >= dateadd(day,-7,sysdate)
    and interview.event_finish_dt::date >= dateadd(day,-8,sysdate)
    --and interview.event_finish_dt::date >= dateadd(day,-7,sysdate)
    and hc.emplid IS NOT Null 
    )
    WHERE 1=1

)

Select 

old2.*,
1 as line,
new2.*


FROM old_one old2

LEFT JOIN new_one new2 on new2.candidate_id = old2.candidate_id and new2.icims_id = old2.icims_id

where 1=1
AND new2.full_name is null
