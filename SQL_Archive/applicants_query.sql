select distinct icims_id 
from hrmetrics.dynamo_applicants 
where peoplesoft_employee_id in 
(select distinct employee_id from hrmetrics.employee_hierarchy_eu_ops_ta)
order by 1 asc
