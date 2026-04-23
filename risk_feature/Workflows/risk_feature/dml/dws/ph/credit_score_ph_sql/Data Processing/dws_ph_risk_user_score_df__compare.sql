select a.platform_user_id,a.model_version,a.model_type,a.score,b.score
from 
(
select * from risk.dws_risk_user_score_df 
where grass_date = '${ds}' and grass_region = '${REGION}' 
) a 
left join 
(
    select * from risk_feature.dws_risk_user_score_df 
where grass_date = '${ds}' and grass_region = '${REGION}' 
) b 
on a.platform_user_id= b.platform_user_id  and a.model_version = b.model_version and a.model_type=b.model_type
where json_parse(a.score) <> json_parse(b.score)