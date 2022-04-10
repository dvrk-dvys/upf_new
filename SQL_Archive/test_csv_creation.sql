DROP TABLE  opsdw.beamery_csv_logins;  
CREATE TABLE IF NOT EXISTS opsdw.beamery_csv_logins
(
               
          user_name	VARCHAR(2000)   ENCODE lzo
          ,user_email VARCHAR(2000)   ENCODE lzo
          ,aliase	VARCHAR(2000)   ENCODE lzo
          ,job_code VARCHAR(2000)   ENCODE lzo
          ,job_title VARCHAR(2000)   ENCODE lzo
          ,L3 VARCHAR(2000)   ENCODE lzo
          ,L4 VARCHAR(2000)   ENCODE lzo
          ,L5 VARCHAR(2000)   ENCODE lzo
          ,L6 VARCHAR(2000)   ENCODE lzo
          ,L7 VARCHAR(2000)   ENCODE lzo
          ,team VARCHAR(2000)   ENCODE lzo
          ,role VARCHAR(2000)   ENCODE lzo
          ,last_login DATE   ENCODE delta32k
          ,total_logins_past_week VARCHAR(1000)   ENCODE lzo
          ,last_action DATE   ENCODE delta32k          
          ,total_actions_in_beamery_past_week VARCHAR(2000)   ENCODE lzo
          ,logged_in_in_last_30_days VARCHAR(2000)   ENCODE lzo
          
          
)
;

SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.beamery_csv_logins to jorharj;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.beamery_csv_logins to group opsta_biuser;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT ALL on opsdw.beamery_csv_logins to ops_ta_rs_etl;RESET SESSION AUTHORIZATION;
