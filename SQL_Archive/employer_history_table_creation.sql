DROP TABLE  opsdw.employer_history;  
CREATE TABLE IF NOT EXISTS opsdw.employer_history
(
               
          candidate_icims_id	VARCHAR(2000)   ENCODE lzo
          
          ,Professional_Experience_1_Employer VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_1_Title VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_1_Start_Date DATE   ENCODE delta32k 
          ,Professional_Experience_1_End_Date DATE   ENCODE delta32k 
          ,Professional_Experience_1_Country VARCHAR(2000)   ENCODE lzo
          
          ,Professional_Experience_2_Employer VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_2_Title VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_2_Start_Date DATE   ENCODE delta32k 
          ,Professional_Experience_2_End_Date DATE   ENCODE delta32k 
          ,Professional_Experience_2_Country VARCHAR(2000)   ENCODE lzo
          
          ,Professional_Experience_3_Employer VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_3_Title VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_3_Start_Date DATE   ENCODE delta32k 
          ,Professional_Experience_3_End_Date DATE   ENCODE delta32k 
          ,Professional_Experience_3_Country VARCHAR(2000)   ENCODE lzo
          
          ,Professional_Experience_4_Employer VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_4_Title VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_4_Start_Date DATE   ENCODE delta32k 
          ,Professional_Experience_4_End_Date DATE   ENCODE delta32k 
          ,Professional_Experience_4_Country VARCHAR(2000)   ENCODE lzo
          
          ,Professional_Experience_5_Employer VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_5_Title VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_5_Start_Date DATE   ENCODE delta32k 
          ,Professional_Experience_5_End_Date DATE   ENCODE delta32k 
          ,Professional_Experience_5_Country VARCHAR(2000)   ENCODE lzo
          
          ,Professional_Experience_6_Employer VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_6_Title VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_6_Start_Date DATE   ENCODE delta32k 
          ,Professional_Experience_6_End_Date DATE   ENCODE delta32k 
          ,Professional_Experience_6_Country VARCHAR(2000)   ENCODE lzo
          
          ,Professional_Experience_7_Employer VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_7_Title VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_7_Start_Date DATE   ENCODE delta32k 
          ,Professional_Experience_7_End_Date DATE   ENCODE delta32k 
          ,Professional_Experience_7_Country VARCHAR(2000)   ENCODE lzo
          
          ,Professional_Experience_8_Employer VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_8_Title VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_8_Start_Date DATE   ENCODE delta32k 
          ,Professional_Experience_8_End_Date DATE   ENCODE delta32k 
          ,Professional_Experience_8_Country VARCHAR(2000)   ENCODE lzo
          
          ,Professional_Experience_9_Employer VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_9_Title VARCHAR(2000)   ENCODE lzo
          ,Professional_Experience_9_Start_Date DATE   ENCODE delta32k 
          ,Professional_Experience_9_End_Date DATE   ENCODE delta32k 
          ,Professional_Experience_9_Country VARCHAR(2000)   ENCODE lzo
        
          
)
;

SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.employer_history to jorharj;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT SELECT on opsdw.employer_history to group opsta_biuser;RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION jorharj;GRANT ALL on opsdw.employer_history to ops_ta_rs_etl;RESET SESSION AUTHORIZATION;
