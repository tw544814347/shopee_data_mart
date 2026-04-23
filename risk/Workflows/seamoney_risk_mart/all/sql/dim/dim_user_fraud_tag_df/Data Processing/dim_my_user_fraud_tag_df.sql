insert overwrite table ${SCHEMA}.dim_${region_lower}_user_fraud_tag_df
select concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string))  as rowkey
      ,concat_ws(',',collect_set(concat_ws('-',fraud_tag_id,fraud_tag_status))) as qf
from antifraud_dw.dim_user_fraud_tag_hf
where grass_region = '${region_upper}'
  and grass_date = '${grass_date}'
  and user_id > 0
  and fraud_tag_id is not null
  and fraud_tag_status is not null
group by user_id
;
