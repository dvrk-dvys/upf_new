SELECT DISTINCT
shl.first_name
,shl.last_name
,shl.email
,shl.time_stamp
,shl.vatmpnr_percentile_score
,c.*

FROM ads.shl SHL
INNER JOIN masterhr.candidate c ON lower(shl.email) LIKE lower(c.email_address)
  
