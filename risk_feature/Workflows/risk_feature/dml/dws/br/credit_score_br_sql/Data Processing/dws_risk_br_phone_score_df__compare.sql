select a.phone_number,a.score,b.score
from 
(
select * from risk.dws_risk_phone_score_df 
where grass_date = '${ds}' and grass_region = '${REGION}' 
) a 
left join 
(
    select * from risk_feature.dws_risk_phone_score_df 
where grass_date = '${ds}' and grass_region = '${REGION}' 
) b 
on a.phone_number= b.phone_number 
where json_parse(a.score) <> json_parse(b.score)