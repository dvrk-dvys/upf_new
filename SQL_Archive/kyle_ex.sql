--with a AS (select '20190101'::date AS clock_start
--, '20190201'::date AS clock_stop
--)
 select * 
 , count(*) OVER (PARTITION BY person_id, job_id ORDER BY icims_updated_timestamp ROWS UNBOUNDED PRECEDING) AS select_1 
 from ads.worksteps ws
 where person_id = '19334464'
--select operations.f_weekday_minutes_between(clock_start, null)/1440 from a
--
limit 100
