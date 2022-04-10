DROP TABLE  opsdw.shl_scores;  
CREATE TABLE IF NOT EXISTS opsdw.shl_scores
(
               
        Client_ID VARCHAR(2000)   ENCODE lzo
        ,Customer_Label VARCHAR(2000)   ENCODE lzo
        ,project_id VARCHAR(2000)   ENCODE lzo
        ,ProjectName VARCHAR(2000)   ENCODE lzo
        ,candidate_id VARCHAR(2000)   ENCODE lzo
        ,Forename VARCHAR(2000)   ENCODE lzo
        ,Surname VARCHAR(2000)   ENCODE lzo
        ,email_address VARCHAR(2000)   ENCODE lzo
        ,InstrumentTemplateLanguageName VARCHAR(2000)   ENCODE lzo
        ,UserCountryName VARCHAR(2000)   ENCODE lzo
        ,Time_Stamp DATE   ENCODE delta32k          
        ,Units_Charged VARCHAR(2000)   ENCODE lzo
        ,VATMPNR_Sten_Score VARCHAR(2000)   ENCODE lzo
        ,VATMPNR_Percentile_Score VARCHAR(2000)   ENCODE lzo
          
)
;

SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.shl_scores to jorharj;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.shl_scores to group opsta_biuser;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT ALL on opsdw.shl_scores to ops_ta_rs_etl;RESET SESSION AUTHORIZATION;
