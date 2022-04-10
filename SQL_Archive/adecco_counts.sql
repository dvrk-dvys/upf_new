WITH adecco_all AS (

SELECT distinct
employee_login
,employee_internal_email_address
,team.team_flag
,act.employee_business_title
,act.reports_to_level_4_employee_login
,act.reports_to_level_5_employee_login
,act.reports_to_level_6_employee_login
,act.reports_to_level_7_employee_login
,act.reports_to_level_8_employee_login
,act.reports_to_level_9_employee_login

FROM masterhr.employee_hc_current act
       inner join opsdw.ops_ta_team_wk team ON team.team_flag = 'ADECCO Recruiters' AND team.emplid = act.emplid
)


SELECT
    COUNT(*) as adecco_all_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'balla' 
                                                OR reports_to_level_5_employee_login = 'balla' 
                                                OR reports_to_level_6_employee_login = 'balla' 
                                                OR reports_to_level_7_employee_login = 'balla' 
                                                OR reports_to_level_8_employee_login = 'balla' 
                                                OR reports_to_level_9_employee_login = 'balla')) as balla_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'cathlinh' 
                                                OR reports_to_level_5_employee_login = 'cathlinh' 
                                                OR reports_to_level_6_employee_login = 'cathlinh'
                                                OR reports_to_level_7_employee_login = 'cathlinh'
                                                OR reports_to_level_8_employee_login = 'cathlinh'
                                                OR reports_to_level_9_employee_login = 'cathlinh')) as cathlinh_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'lynsd'
                                                OR reports_to_level_5_employee_login = 'lynsd' 
                                                OR reports_to_level_6_employee_login = 'lynsd' 
                                                OR reports_to_level_7_employee_login = 'lynsd' 
                                                OR reports_to_level_8_employee_login = 'lynsd' 
                                                OR reports_to_level_9_employee_login = 'lynsd')) as lynsd_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'haywmart' 
                                                OR reports_to_level_5_employee_login = 'haywmart' 
                                                OR reports_to_level_6_employee_login = 'haywmart'
                                                OR reports_to_level_7_employee_login = 'haywmart'
                                                OR reports_to_level_8_employee_login = 'haywmart' 
                                                OR reports_to_level_9_employee_login = 'haywmart')) as haywmart_hc,
    (SELECT COUNT(employee_login) FROM adecco_all WHERE (reports_to_level_4_employee_login = 'chilverr' 
                                                OR reports_to_level_5_employee_login = 'chilverr' 
                                                OR reports_to_level_6_employee_login = 'chilverr' 
                                                OR reports_to_level_7_employee_login = 'chilverr' 
                                                OR reports_to_level_8_employee_login = 'chilverr' 
                                                OR reports_to_level_9_employee_login = 'chilverr')) as chilverr_hc

FROM adecco_all
WHERE 1=1
