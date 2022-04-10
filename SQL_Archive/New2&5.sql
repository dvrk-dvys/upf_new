 SELECT candidate_dim_ky, candidate_icims_id, first_name, last_name, candidate_src_category, candidate_src_channel, candidate_type, requisition_dim_ky, icims_id,
  interview_stage, interview_year, interview_quarter, interview_month, interview_week, interview_date, clock_start_time, feedback_entered_date, next_step_request_date, clock_stop_time, clock_stop_goal, next_step_request_event
  clock_stop_event, recruiting_org, in_rejection_state, clock_still_running, candidates_sourcer_name, candidates_sourcer_id, interview_detail_page, 
  total_cycle_time, avg_days_clock_still_running, calc_cycle_time, days_until_feedback_entered, days_until_feedback_entered_all, days_between_feedback_n_request, days_between_feedback_n_request_all,
   days_between_request_n_clock_stop, days_between_request_n_clock_stop_all, days_between_feedback_entered_n_clock_stop, days_between_feedback_entered_n_clock_stop_all, rejection_sla, rejection_sla_all, 
   total_loop_size, bar_raisers, brit, hiring_mgr, other_interviewers, interviewer_name
  next_stage, next_step, first_feedback_date, votes, total_cycle_time, calc_cycle_time, days_until_feedback_entered, days_until_feedback_entered_all, days_between_feedback_n_request, 
  last_updated_dt, sourcer_id, sourcer_emp_id, sourcer_supervisor_id, sourcer_reports_to_level6_id, cur_sourcer_id, cur_sourcer_emp_id
  FROM hrmetrics.rad_two_five_promise
  WHERE interview_year = 2019 AND interview_week = 22 AND sourcer_reports_to_level6_id = 'AMANDAM'  AND candidate_type = 'Internal' AND interview_stage = 'Phone Screen'
  
  
