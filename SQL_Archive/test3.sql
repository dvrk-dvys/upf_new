SELECT  
interview_summary_guid, 
interviewer_vote, 

CASE WHEN interviewer_vote IN ('INCLINED','STRONG_HIRE') THEN 'INCLINED'
     WHEN interviewer_vote IN ('NOT_INCLINED','STRONG_NO_HIRE') THEN 'NOT_INCLINED' END AS processed_vote,
     outcome_vote



FROM masterhr.interview_activity ia
INNER JOIN (SELECT *
            FROM (SELECT *,
                        RANK() OVER (PARTITION BY job_icims_id ORDER BY snapshot_end_timestamp DESC) AS rnk
                  FROM masterhr.requisition)
            WHERE rnk = 1
            AND country IN ('USA', 'CAN')) r ON ia.job_icims_id = r.job_icims_id
LEFT JOIN ads.applicants metadata ON ia.candidate_icims_id = metadata.icims_id            

WHERE 1=1
AND ia.hire_type NOT IN ('Campus Intern','Campus Fte')
AND ia.event_type = 'On-site'
AND ia.event_start_dt BETWEEN '2016-01-01' AND '2019-03-01'
AND ia.work_step = 'Interview Event'
AND ia.event_status = 'Occurred'
AND r.job_classification_title IN ('Manager I, Operations', 'Manager II, Operations', 'Manager III, Operations')
AND event_role != 'SHADOW'
AND applicant_type = 'EXTERNAL'
AND outcome_vote = 'NOT_INCLINED'
AND interview_summary_guid IN (
'f059c1d3-04d0-47ae-94ec-b335da145e25',
'fc1f9a57-ff35-4907-b089-653332bc6b1c',
'f8ead548-e49b-424d-8c4e-d8c15e2d84d8',
'f825e2ed-7ff1-423e-8b86-6c92af0535709',
'f7ffdbfb-d07b-44ed-b359-0b2233b5291b',
'f5680c90-8f1d-4a25-b5b5-ac16d129bbbf',
'f0292b08-873a-4352-beea-7f64463367a1',
'edf170d8-8052-40dd-a7ed-c6be7a0577a1',
'e7bc1b68-1304-4dd4-a9f2-d6901423c238',
'c9d814e8-e48c-4f3a-babe-a0f77af5e7b3',
'ba6d7292-32e7-465b-973c-096561a3f1e7',
'b98feff0-978b-495b-b0b1-8be7ecff6c6f',
'b4e890d2-1204-42fb-887a-112ae42f4349',
'b1353c5a-c925-4ab2-b7e3-a44611d9e047',
'aefa24fe-f931-40d5-81a9-3ac41f8ff03f',
'acdf42a2-782b-4c48-a28e-0fbeb5cf9218',
'ac9aa75f-9e5f-4d7c-9985-28bae5d2088a',
'a823ec53-f703-4811-a720-92f7abd95da0',
'85268299-7747-4603-9c30-7b12082fe3ff',
'6163190f-6b59-4044-9e7f-6a0ffb34f76d',
'5d3dc826-13a6-44e4-887b-3e465261c6dc',
'572eb2bb-4821-424e-87f6-c42d84188d8b',
'554393b4-b117-4761-aa23-f34b5552be2d',
'410d28e2-c10f-4420-8762-470d9b9e3738',
'3948f034-0917-4520-b45e-361af572d3fb',
'242f148f-8f27-49f9-bb8f-985840f3ade1',
'0fa647cb-08e5-470b-96ea-ff6ac03216ac',
'0f5ce1d9-b65d-492b-a83a-3887b5c9c843',
'0ab011a6-8f36-4f19-bf7d-cc8bcbd64c32',
'056af318-c7e9-49f7-8d2e-3541c96f44e8',
'02ba7147-b70c-4807-b34d-50b9abe247eb'


)

--GROUP BY  interview_summary_guid, outcome_vote, processed_vote
