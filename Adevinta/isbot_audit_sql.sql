With sessions as (
select distinct
client,
b.sessionid,
environment_id,
event_id,
publishedlocaltime
from subito_databox.insights_sessions_enrichment_365d b
where environment_id is not null
/*and b.sessionid in ('78099d22e7dda1daaafb05d99768e626')
'e7174a13b6aef115a45bb57bfd00292f')
/*and b.sessionid in ('f6c94919df580dec2166e9c116f9865d',
'e7174a13b6aef115a45bb57bfd00292f',
'000530c79a2b41bfc0f153bf36eb3ec3')*/
and b.publishedlocaltime between '2021-12-20 00:00:00' and '2021-12-21 00:00:00'),
prep as (
select distinct
a.deviceisbot,
a.screensize,
split(a.screensize, 'x') AS wxh,
a.published,
CAST(from_iso8601_timestamp(a.published) AS timestamp) as published_dt,
a.id,
b.sessionid,
a.environmentid,
a.eventname
/*CAST(from_iso8601_timestamp(b.publishedlocaltime ) AS timestamp) as published_local_dt*/
from subito_databox.yellow_pulse_simple_28d a 
inner join sessions b on a.environmentid = b.environment_id
where a.published between '2021-12-20 00:00:00' and '2021-12-21 00:00:00'
/*and a.environmentid in ('sdrn:schibsted:environment:00002c6a-b459-4e7a-b516-a0ee9d0af9ea')
and a.environmentid in ('sdrn:schibsted:environment:b795567b-bd7a-41e5-8578-89c20a62ac74',
'sdrn:schibsted:environment:00002c6a-b459-4e7a-b516-a0ee9d0af9ea',
'sdrn:schibsted:environment:253b14be-e911-488b-a1bf-d61d86ca916d',
'sdrn:schibsted:environment:b677faec-c56e-4d1c-933e-ff88ecdbfae8',
'sdrn:schibsted:environment:c5c664e9-e491-4516-8ac8-4e5c38d0c68e'
)*/
and a.deviceisbot = false 
and a.eventname is not null
and a.eventname not like 'Trust%'
ORDER by a.published asc),
rank_prep as (
select 
*,
ROW_NUMBER() OVER ( PARTITION BY sessionid ORDER BY published ASC) AS rnk_evi
from prep
ORDER by sessionid, published asc)
select distinct
a.deviceisbot,
/*a.wxh[1] as width,
a.wxh[2] as height,*/
a.screensize,
date_diff('second', a.published_dt, b.published_dt) as diff,
a.eventname as event_a,
b.eventname as event_b,
a.environmentid,
b.sessionid,
a.published_dt as published_dt_A,
b.published_dt as published_dt_B,
a.rnk_evi as rnk_evi_a,
b.rnk_evi as rnk_evi_b
from rank_prep a inner join rank_prep b on a.environmentid=b.environmentid
WHERE b.rnk_evi = (a.rnk_evi + 1)
and date_diff('second', a.published_dt, b.published_dt) between 1 and 4
 and a.eventname like 'Recommendation%'
and b.eventname like 'Recommendation%'
group by
a.deviceisbot,
a.wxh,
a.screensize,
b.sessionid,
a.eventname,
b.eventname,
a.environmentid,
a.published_dt,
b.published_dt,
a.rnk_evi,
b.rnk_evi
ORDER by b.sessionid desc, a.rnk_evi, b.rnk_evi asc
;


/*,
ROW_NUMBER() OVER ( PARTITION BY b.sessionid ORDER BY a.published ASC) AS rnk_evi
/*a.devicetype,
a.locationaccuracy,
a.isloggedin,
a.providerproducttype,
a.objectname,
a.objecttype,
a.useragent,
b.client,
b.event_id
sdrn:schibsted:environment:00002c6a-b459-4e7a-b516-a0ee9d0af9ea
78099d22e7dda1daaafb05d99768e626
*
*
*0005e6cd2bbe6db8e4101d156d3346a1
**/




