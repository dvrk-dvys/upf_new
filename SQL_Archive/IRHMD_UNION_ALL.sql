--------old code-------------

WITH oldone AS (

    select * from 
    (
    Select distinct


    hc.employee_display_name AS full_name,
    candidate.candidate_icims_id as candidate_id,
    candidate_employee_id as empl_id,
    convert_timezone('US/Pacific',cast((TIMESTAMP 'epoch' + CAST(w.icims_updated_timestamp AS BIGINT)/1000 * INTERVAL '1 Second') as timestamp)) application_date, 
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
    interview.interview_summary_id as intrvw_summary_id
    row_number() over (partition by interview.job_icims_id || candidate.candidate_id order by rad.clock_stop_time desc ) rnum

    from masterhr.interview_activity interview

    inner join masterhr.candidate candidate on candidate.candidate_icims_id = interview.candidate_icims_id 
    inner join ads.worksteps w on w.job_id = interview.job_icims_id and w.person_id = interview.candidate_icims_id 
    left join masterhr.offer_accepts offer on offer.candidate_icims_id = interview.candidate_icims_id 
    inner join masterhr.requisition reqs on reqs.job_icims_id = interview.job_icims_id
    inner join opsdw.ops_ta_team_wk team on team.emplid = reqs.current_recruiter_employee_id
    inner join masterhr.employee_hc_current hc on hc.emplid = candidate.candidate_employee_id
    left join hrmetrics.rad_two_five_promise rad on rad.interview_summary_id = interview.interview_summary_id 


    where 1=1
    AND (reqs.recruiter_reports_to_level_4_employee_login = 'kelleyse'
    OR (reqs.recruiter_reports_to_level_3_employee_login = 'darcie'
    AND reqs.recruiter_reports_to_level_4_employee_login IN ('barresi','jsserran','jquintas','chaluleu','ninasj')))
    and reqs.current_transaction_flag = 'Y'
    and interview.applicant_type = 'INTERNAL'
    and interview.event_type = 'On-site'
    and interview.event_status = 'Occurred'
    and rad.clock_stop_time::date >= dateadd(day,-7,sysdate)
    and hc.emplid IS NOT Null )
     where 1=1
),


-----------new code-----------------

stop_states AS (
      SELECT 
      job_icims_id,
      candidate_icims_id,
      min(enter_state_time) AS min_time
      from masterhr.recruiting_activity

      WHERE 1=1
      AND recruiting_state in('Assessment Scheduled',
                               'Offer Prepared',
                               'On-site Scheduled',
                               'Phone Screen Scheduled',
                               'Rejection Confirmed')

      GROUP BY
      job_icims_id,
      candidate_icims_id
),


clock_stop AS (

      SELECT DISTINCT
          rn.job_icims_id,
          rn.candidate_icims_id,
          Case
          WHEN (af.contact_attempts IS NOT NULL) AND min_time > first_contact_attempt_date THEN first_contact_attempt_date
          WHEN (af.contact_attempts IS NOT NULL) AND min_time < first_contact_attempt_date THEN min_time
          ELSE min_time END AS clock_stop_time


      FROM masterhr.recruiting_activity rn
      INNER JOIN stop_states s ON s.candidate_icims_id = rn.candidate_icims_id AND s.job_icims_id = rn.job_icims_id AND s.min_time = rn.enter_state_time
      LEFT JOIN hrmetrics.art_full af ON af.cand_icims_id = rn.candidate_icims_id AND af.job_amzr_req_id = rn.job_icims_id AND af.contact_attempts = 1

),

current_step AS (

      SELECT DISTINCT
          application_date,
          candidate_icims_id,
          job_icims_id,
          MAX(enter_state_time_pst) as max_date

      FROM opstadw.masterhr.recruiting_activity

      WHERE 1=1

      GROUP BY
      application_date,
      candidate_icims_id,
      job_icims_id
      
),

newish AS (


    SELECT DISTINCT
    hc.employee_display_name AS full_name,
    candidate.candidate_icims_id AS candidate_id,
    candidate.candidate_employee_id AS empl_id,
    activity.application_date,
    interview.job_icims_id AS icims_id,
    offer.enter_state_time AS ofr_extndd_dt,
    activity.current_funnel_state AS step,
    offer.offer_accepted_date AS ofr_accepted_dt,
    reqs.city AS loc_cty_nm, 
    reqs.building AS loc_bldg_cd,
    reqs.internal_job_title AS business_title,
    reqs.job_title AS external_job_title,
    reqs.hiring_manager_reports_to_level_3_employee_login AS hrng_mngr_reports_to_level3_login, 
    reqs.company_name AS req_co_nm, 
    reqs.department_name AS dept_nm, 
    reqs.job_function AS req_job_function_desc,
    reqs.job_type, 
    reqs.job_level, 
    reqs.country as req_rgltry_rgn_cd,
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
    NVL(team.team_flag, team2.team_flag, team3.team_flag) AS team_flag, 
    interview.interview_summary_id as intrvw_summary_id,
    1 AS rnum

    from masterhr.recruiting_activity activity


    LEFT JOIN current_step cs on cs.job_icims_id = activity.job_icims_id and cs.candidate_icims_id = activity.candidate_icims_id  
    INNER JOIN masterhr.interview_activity interview on activity.job_icims_id = interview.job_icims_id and activity.candidate_icims_id = interview.candidate_icims_id AND cs.max_date = activity.enter_state_time_pst 
    INNER JOIN masterhr.candidate candidate on candidate.candidate_icims_id = interview.candidate_icims_id 

    LEFT JOIN masterhr.offer_accepts offer on offer.candidate_icims_id = interview.candidate_icims_id AND offer.job_icims_id = interview.job_icims_id
    INNER JOIN masterhr.requisition reqs on reqs.job_icims_id = interview.job_icims_id AND reqs.current_transaction_flag = 'Y'
    LEFT JOIN opsdw.ops_ta_team_wk team on team.emplid = reqs.recruiter_employee_id AND reqs.requisition_opened_time BETWEEN team.wk_begin_dt and team.wk_end_dt
     LEFT JOIN opsdw.ops_ta_team_wk team2 on team2.emplid = reqs.current_recruiter_employee_id AND activity.application_date BETWEEN team2.wk_begin_dt and team2.wk_end_dt
     LEFT JOIN opsdw.ops_ta_team_wk team3 on team3.emplid = reqs.current_recruiter_employee_id AND CURRENT_DATE BETWEEN team3.wk_begin_dt and team3.wk_end_dt
    LEFT JOIN masterhr.employee_hc_current hc on hc.emplid = candidate.candidate_employee_id
    INNER JOIN clock_stop clock ON clock.candidate_icims_id = interview.candidate_icims_id AND clock.job_icims_id =interview.job_icims_id

    where 1=1
    AND (reqs.recruiter_reports_to_level_4_employee_login = 'kelleyse'
    OR (reqs.recruiter_reports_to_level_3_employee_login = 'darcie'
    AND reqs.recruiter_reports_to_level_4_employee_login IN ('barresi','jsserran','jquintas','chaluleu','ninasj')))
    and interview.applicant_type = 'INTERNAL'
    and interview.event_type = 'On-site'
    and interview.event_status = 'Occurred'
    and hc.emplid IS NOT Null 
    --AND clock.clock_stop_time BETWEEN '2020-03-13 00:00:00' AND '2020-03-21 00:00:00'
    and clock.clock_stop_time::date >= dateadd(day,-100,sysdate)


)

----Union of all the WBR metrics-------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
,unionediRHMD_ETL as (
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    SELECT DISTINCT
        full_name::VARCHAR(200),
        candidate_id::VARCHAR(200),
        empl_id::VARCHAR(200),
        application_date::VARCHAR(200),
        icims_id::VARCHAR(200),
        ofr_extndd_dt::VARCHAR(200),
        step::VARCHAR(200),
        ofr_accepted_dt::VARCHAR(200),
        loc_cty_nm::VARCHAR(200),
        loc_bldg_cd::VARCHAR(200),
        business_title::VARCHAR(200),
        external_job_title::VARCHAR(200),
        hrng_mngr_reports_to_level3_login::VARCHAR(200), 
        co_nm::VARCHAR(200), 
        dept_nm::VARCHAR(200), 
        job_function_desc::VARCHAR(200),
        job_type::VARCHAR(200), 
        job_level::VARCHAR(200), 
        rgltry_rgn_cd::VARCHAR(200),
        email_address::VARCHAR(200),
        job_title::VARCHAR(200), 
        job_level::VARCHAR(200),
        loc_nm::VARCHAR(200),
        reports_to_level3_login::VARCHAR(200), 
        reports_to_suprvsr_login::VARCHAR(200), 
        dept_nm::VARCHAR(200), 
        interview_date::VARCHAR(200), 
        recruiter_login::VARCHAR(200),
        recruiter_nm::VARCHAR(200),
        Business_Lane::VARCHAR(200), 
        team_flag::VARCHAR(200), 
        intrvw_summary_id::VARCHAR(200),
        rnum::VARCHAR(200)

    FROM newish


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UNION ALL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    SELECT         
        full_name::VARCHAR(200),
        candidate_id::VARCHAR(200),
        empl_id::VARCHAR(200),
        application_date::VARCHAR(200),
        icims_id::VARCHAR(200),
        ofr_extndd_dt::VARCHAR(200),
        step::VARCHAR(200),
        ofr_accepted_dt::VARCHAR(200),
        loc_cty_nm::VARCHAR(200),
        loc_bldg_cd::VARCHAR(200),
        business_title::VARCHAR(200),
        external_job_title::VARCHAR(200),
        hrng_mngr_reports_to_level3_login::VARCHAR(200), 
        co_nm::VARCHAR(200), 
        dept_nm::VARCHAR(200), 
        job_function_desc::VARCHAR(200),
        job_type::VARCHAR(200), 
        job_level::VARCHAR(200), 
        rgltry_rgn_cd::VARCHAR(200),
        email_address::VARCHAR(200),
        job_title::VARCHAR(200), 
        job_level::VARCHAR(200),
        loc_nm::VARCHAR(200),
        reports_to_level3_login::VARCHAR(200), 
        reports_to_suprvsr_login::VARCHAR(200), 
        dept_nm::VARCHAR(200), 
        interview_date::VARCHAR(200), 
        recruiter_login::VARCHAR(200),
        recruiter_nm::VARCHAR(200),
        Business_Lane::VARCHAR(200), 
        team_flag::VARCHAR(200), 
        intrvw_summary_id::VARCHAR(200),
        rnum::VARCHAR(200)
FROM unionediRHMD_ETL
