DROP TABLE  opsdw.beamery_csv_activity;  
CREATE TABLE IF NOT EXISTS opsdw.beamery_csv_activity
(
               
          aliase	VARCHAR(2000)   ENCODE lzo
          ,user_name VARCHAR(2000)   ENCODE lzo
          ,week VARCHAR(2000)   ENCODE lzo
          ,month VARCHAR(2000)   ENCODE lzo
          ,contacts_added VARCHAR(2000)   ENCODE lzo
          ,contacts_updated VARCHAR(2000)   ENCODE lzo
          ,tasks_created VARCHAR(2000)   ENCODE lzo
          ,tasks_assigned VARCHAR(2000)   ENCODE lzo
          ,tasks_completed VARCHAR(2000)   ENCODE lzo
          ,notes_logged VARCHAR(2000)   ENCODE lzo
          ,phone_calls_logged VARCHAR(2000)   ENCODE lzo          
          ,meetings_logged VARCHAR(2000)   ENCODE lzo          
          ,inmail_logged VARCHAR(2000)   ENCODE lzo          
          ,direct_messages_sent VARCHAR(2000)   ENCODE lzo          
          ,email_conversations VARCHAR(2000)   ENCODE lzo          
          ,organization_name VARCHAR(2000)   ENCODE lzo          
          ,level_3_leader VARCHAR(2000)   ENCODE lzo          
          ,level_4_leader VARCHAR(2000)   ENCODE lzo          
          ,level_5_leader VARCHAR(2000)   ENCODE lzo          
          ,level_6_leader VARCHAR(2000)   ENCODE lzo          
          ,level_7_leader VARCHAR(2000)   ENCODE lzo          
          ,cost_center VARCHAR(2000)   ENCODE lzo          
          ,company VARCHAR(2000)   ENCODE lzo          
          ,country VARCHAR(2000)   ENCODE lzo          
          
)
;

SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.beamery_csv_activity to jorharj;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.beamery_csv_activity to group opsta_biuser;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT ALL on opsdw.beamery_csv_activity to ops_ta_rs_etl;RESET SESSION AUTHORIZATION;
