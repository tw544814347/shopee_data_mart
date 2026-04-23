insert overwrite table ${SCHEMA}.dwd_risk_af_user_device_manual_login_nd partition(grass_region,grass_date)
select 
concat(substr(md5(cast(user_id as string)), 0, 2),'_', cast(user_id as string) , '_szdf_',dfpinfosz__securitydeviceid,'_',case when is_success='true' then 'success' else 'failed' end ,'_',cast(floor(event_timestamp/1000) as string)) as szdf_rowkey 
,concat(substr(md5(cast(user_id as string)), 0, 2),'_',cast(user_id as string),'_spdf_',regexp_replace(shopee_df_plain,'_','-'),'_',case when is_success='true' then 'success' else 'failed' end,'_',cast(floor(event_timestamp/1000) as string)) as spdf_rowkey
,dfpinfosz__securitydeviceid as szdf_device_id 
,regexp_replace(shopee_df_plain,'_','-') as shopee_df_plain
,grass_region 
,grass_date 
from antifraud_dw.dwd_evt_shopee_login_di 
where grass_date ='${grass_date}'
and grass_region in('BR') 
and is_auto_login = 'false' 
;