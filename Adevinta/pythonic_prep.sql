select distinct
a.deviceisbot,
a.screensize,
a.published,
CAST(from_iso8601_timestamp(b.publishedlocaltime ) AS timestamp) as published_local_dt,
b.sessionid,
a.environmentid,
a.type,
a.devicetype,
REPLACE (a.useragent, ',', '') as useragent,
a.objecttype,
a.eventname,
lower(a.id) as event_id
from subito_databox.yellow_pulse_simple_28d a
left join (
			select distinct *
			from subito_databox.insights_sessions_enrichment_365d b
			where environment_id is not null
			/*and environment_id not in ('sdrn:schibsted:environment:df5e3095-e3bc-4cc6-9ea1-8320fd08f4d6', 'sdrn:schibsted:environment:9a7cd3a4-c094-4591-99bf-cdc10226f78f', 'sdrn:schibsted:environment:f0a11332-37b3-4d34-9268-79d585f8a8d1', 'sdrn:schibsted:environment:6d6b87d7-2cce-4a71-a1c6-e5b5c780b99f', 'sdrn:schibsted:environment:aae528d1-8342-4d31-b165-3cf830b401c1', 'sdrn:schibsted:environment:f563a5df-617f-44b4-907e-0eebd4a6ff0d', 'sdrn:schibsted:environment:5c0425f6-9ad0-4a7d-9525-8852d3248d9a', 'sdrn:schibsted:environment:e2b84740-5eb5-4557-a8c4-077b478a1569', 'sdrn:schibsted:environment:53f77001-f22e-4ae6-a955-5a3d66f68c57', 'sdrn:schibsted:environment:c4f7f792-1c1f-4762-87e7-5dea2a80c3fe', 'sdrn:schibsted:environment:c0f9f67c-a67b-4af6-81ee-dd4643dae42d', 'sdrn:schibsted:environment:9915aad2-4f67-42be-9429-3bdcc95e4bff', 'sdrn:schibsted:environment:d6d66a35-85d8-4f15-ac63-8aaca670a3a4', 'sdrn:schibsted:environment:51f390ca-d1ff-4dad-b02f-da66b271f6cc', 'sdrn:schibsted:environment:ac6cc41f-3ac0-4579-b5e9-8bb3870a5eb8', 'sdrn:schibsted:environment:156067f6-7b59-42bf-a79e-a7b0fe1aff7b', 'sdrn:schibsted:environment:6e43d8a8-bf6e-4439-8450-e182ae4fc19f', 'sdrn:schibsted:environment:fbe0ef04-3548-4bcc-907c-0c882008a89b', 'sdrn:schibsted:environment:492a60ab-8b92-42b2-98f4-a4302962fab8', 'sdrn:schibsted:environment:e6091ccf-b48c-45cc-ad36-ab3bab4ab32a', 'sdrn:schibsted:environment:eac93575-7592-47ac-87ac-82dc38773129', 'sdrn:schibsted:environment:3ac3e962-2b88-4477-ac29-fa896ae2c8bf', 'sdrn:schibsted:environment:92d91040-05e2-4dfa-b020-47623970ad55', 'sdrn:schibsted:environment:0f349c27-8f25-4ed1-841a-93d5c0456736', 'sdrn:schibsted:environment:56459975-9859-442c-b20c-c8bfb9770591', 'sdrn:schibsted:environment:d135c2a8-b8d7-4590-9a94-bcac1d65c01a', 'sdrn:schibsted:environment:a6e7ff9e-2ef4-4755-8e67-8c50c9c43ecd', 'sdrn:schibsted:environment:a8be252d-d2df-425d-98b5-fc7d397efe8a', 'sdrn:schibsted:environment:ca9a9412-9b72-418c-bbea-b0ea23a570a4', 'sdrn:schibsted:environment:7e062389-4362-4911-8054-6720eb173552', 'sdrn:schibsted:environment:efaafb99-3f9b-4cf7-aee6-6a1063003621', 'sdrn:schibsted:environment:8a147811-c629-4fcc-8ce7-6478f15f887d', 'sdrn:schibsted:environment:c643dcd7-f834-42d4-b889-df72cf3e640d', 'sdrn:schibsted:environment:e74365f8-21c5-42be-9129-bc3256cb8ece', 'sdrn:schibsted:environment:3a86c83a-f6f9-436d-a8be-9ce13b07736b', 'sdrn:schibsted:environment:5b8969e3-0236-4e8f-815d-333cb400abb4', 'sdrn:schibsted:environment:144751a6-504a-4325-ba8a-3665017d67ac', 'sdrn:schibsted:environment:155704a5-ac66-42d8-a3e5-59ca740b1682', 'sdrn:schibsted:environment:e0f53b9b-5228-4f7e-9795-1d2447e428f3', 'sdrn:schibsted:environment:6adda732-cbe1-4f5f-aed8-e792ed68b15f', 'sdrn:schibsted:environment:eead35dc-4a9f-47f2-8d5a-582cfac41139', 'sdrn:schibsted:environment:82fc336f-82f0-4653-a7fb-e48dee57122f', 'sdrn:schibsted:environment:68d2ef8c-1194-4a67-97f5-44ebbe4823f1', 'sdrn:schibsted:environment:2758ef37-9f31-46fc-b3a9-9eddb828a8b1', 'sdrn:schibsted:environment:1c0c72db-7223-4fa6-970e-633f31b743b3', 'sdrn:schibsted:environment:0fa6cb35-b7e3-40b7-b089-bdd1785eade9')
			*/and b.published between '2022-01-20 00:00:00' and '2022-01-21 00:00:00'
			) b on a.environmentid = b.environment_id and lower(b.event_id) = lower(a.id)
where a.published between  '2022-01-20T00:00:00+00:00' and '2022-01-20T06:00:00+00:00'
and a.deviceisbot = False
and a.eventname is not null
and a.eventname not like 'Trust%'
ORDER by a.published asc
limit 200
