SELECT a.platform_user_id, a.model_version, a.model_type, a.score, b.score
FROM (
    SELECT *
    FROM risk.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 1 and 6
) a
LEFT JOIN (
    SELECT *
    FROM risk_feature.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 1 and 6
) b
ON a.platform_user_id = b.platform_user_id
   AND a.model_version = b.model_version
   AND a.model_type = b.model_type
   and a.biz_type = b.biz_type
WHERE a.score <> b.score
  AND json_parse(a.score) <> json_parse(b.score);


SELECT a.platform_user_id, a.model_version, a.model_type, a.score, b.score
FROM (
    SELECT *
    FROM risk.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 7 and 12
) a
LEFT JOIN (
    SELECT *
    FROM risk_feature.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 7 and 12
) b
ON a.platform_user_id = b.platform_user_id
   AND a.model_version = b.model_version
   AND a.model_type = b.model_type
   and a.biz_type = b.biz_type
WHERE a.score <> b.score
  AND json_parse(a.score) <> json_parse(b.score);



SELECT a.platform_user_id, a.model_version, a.model_type, a.score, b.score
FROM (
    SELECT *
    FROM risk.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 13 and 18
) a
LEFT JOIN (
    SELECT *
    FROM risk_feature.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 13 and 18
) b
ON a.platform_user_id = b.platform_user_id
   AND a.model_version = b.model_version
   AND a.model_type = b.model_type
   and a.biz_type = b.biz_type
WHERE a.score <> b.score
  AND json_parse(a.score) <> json_parse(b.score);




SELECT a.platform_user_id, a.model_version, a.model_type, a.score, b.score
FROM (
    SELECT *
    FROM risk.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 19 and 24
) a
LEFT JOIN (
    SELECT *
    FROM risk_feature.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 19 and 24
) b
ON a.platform_user_id = b.platform_user_id
   AND a.model_version = b.model_version
   AND a.model_type = b.model_type
   and a.biz_type = b.biz_type
WHERE a.score <> b.score
  AND json_parse(a.score) <> json_parse(b.score);


SELECT a.platform_user_id, a.model_version, a.model_type, a.score, b.score
FROM (
    SELECT *
    FROM risk.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 25 and 30
) a
LEFT JOIN (
    SELECT *
    FROM risk_feature.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 25 and 30
) b
ON a.platform_user_id = b.platform_user_id
   AND a.model_version = b.model_version
   AND a.model_type = b.model_type
   and a.biz_type = b.biz_type
WHERE a.score <> b.score
  AND json_parse(a.score) <> json_parse(b.score);
  
SELECT a.platform_user_id, a.model_version, a.model_type, a.score, b.score
FROM (
    SELECT *
    FROM risk.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 31 and 32
) a
LEFT JOIN (
    SELECT *
    FROM risk_feature.dws_risk_user_score_df
    WHERE grass_date = '${ds}' AND grass_region = '${REGION}' AND mod(crc32(to_utf8(platform_user_id)), 32) between 31 and 32
) b
ON a.platform_user_id = b.platform_user_id
   AND a.model_version = b.model_version
   AND a.model_type = b.model_type
   and a.biz_type = b.biz_type
WHERE a.score <> b.score
  AND json_parse(a.score) <> json_parse(b.score);
