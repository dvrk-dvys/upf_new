SELECT 
current_recruiter_login, survey_question, survey_response_translated, initial_language, days_since_interview,main_sentiment_labeled,main_sentiment_value,interview_summary_id,
icims_id,candidate_icims_id,interview_date, candidate_last_name, interview_type,survey_start_date,survey_end_date,survey_status,hire_link,hire_type,job_code,job_title_int,job_title_ext,
job_level,req_status,rc_owner,rc_owner_id,rc_owner_mgr_id,cost_center,recruiter_id,recruiter_name,recruiter_dept_id,recruiter_dept_name,sourcer_id,debrief_decision,
rectr_reports_to_level2_id,recruiter_reports_to_2,rectr_reports_to_level3_id,recruiter_reports_to_3,rectr_reports_to_level4_id, recruiter_reports_to_4,rectr_reports_to_level5_id,
recruiter_reports_to_5,rectr_reports_to_level6_id,recruiter_reports_to_6,rectr_reports_to_level7_id,recruiter_reports_to_7,rectr_reports_to_level8_id,recruiter_reports_to_8


FROM opstadw.ops_insearch.rhmd_consolidated rhmd
      --INNER JOIN hrmetrics.o_reporting_days reportingdays ON reportingdays.calendar_day = TRUNC(rhmd.interview_date)
WHERE 1=1
--AND lower(current_recruiter_login) = 'osupike'
