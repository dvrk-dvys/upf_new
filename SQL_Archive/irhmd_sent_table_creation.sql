DROP TABLE  opsdw.irhmd_sent_2020;  
CREATE TABLE IF NOT EXISTS opsdw.irhmd_sent_2020
(

               
        Address VARCHAR(2000)   ENCODE lzo
        ,Bounce_Type VARCHAR(2000)   ENCODE lzo
        ,Bounced VARCHAR(2000)   ENCODE lzo
        ,Distribution_ID VARCHAR(2000)   ENCODE lzo
        ,Distribution_Channel VARCHAR(2000)   ENCODE lzo
        ,Distribution_Type VARCHAR(2000)   ENCODE lzo
        ,First_Name VARCHAR(2000)   ENCODE lzo
        ,Last_Name VARCHAR(2000)   ENCODE lzo
        ,Opened VARCHAR(2000)   ENCODE lzo
        ,Opened_Date DATE   ENCODE delta32k    
        ,Recipient_ID VARCHAR(2000)   ENCODE lzo
        ,Send_Date DATE   ENCODE delta32k  
        ,Survey_Completed VARCHAR(2000)   ENCODE lzo
        ,Survey_Completed_Date DATE   ENCODE delta32k  
        ,Survey_ID VARCHAR(2000)   ENCODE lzo
        ,Survey_Started VARCHAR(2000)   ENCODE lzo
        ,Survey_Started_Date DATE ENCODE delta32k
        ,rgltry_rgn_cd VARCHAR(2000)   ENCODE lzo 
        ,QS VARCHAR(2000)   ENCODE lzo
        ,_cachedDate DATE ENCODE delta32k
        ,_recordId VARCHAR(2000)   ENCODE lzo
        ,_recordedDate DATE ENCODE delta32k

          
)
;

SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.irhmd_sent_2020 to jorharj;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.irhmd_sent_2020 to group opsta_biuser;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT ALL on opsdw.irhmd_sent_2020 to ops_ta_rs_etl;RESET SESSION AUTHORIZATION;
