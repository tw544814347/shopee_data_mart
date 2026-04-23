
insert overwrite table ${SCHEMA}.ads_shopeefraud_${region}_user_list_df partition (grass_date = '${ds}')
select 1                    as id
       ,user_id             as userid
       ,fraud_tag_status    as status
       ,fraud_tag_id        as tagid
       ,create_timestamp    as ctime
       ,modify_timestamp    as mtime
from antifraud_dw.dim_user_fraud_tag_di
where grass_region = '${region}'
  and grass_date = '${ds}'
  and severity = 'SEVERE'
  and fraud_tag_status = 1
  
;


refresh table ${SCHEMA}.ads_shopeefraud_${region}_user_list_df
;

