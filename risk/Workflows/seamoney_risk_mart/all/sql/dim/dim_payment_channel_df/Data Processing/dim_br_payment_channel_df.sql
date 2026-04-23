insert overwrite table ${SCHEMA}.dim_spm_${region}_payment_channel_df
select concat_ws('_',substr(md5(cast(pps_payment_channel_id as string)),0,2),cast(pps_payment_channel_id as string))  as rowkey
      ,payment_channel_level  as qf
from shopeepay.mart_dim_pps_payment_channel_df__${region}
where pps_payment_channel_id > 0
;


insert overwrite table ${SCHEMA}.dim_apm_${region}_payment_channel_df
select concat_ws('_',substr(md5(cast(pps_payment_channel_id as string)),0,2),cast(pps_payment_channel_id as string))  as rowkey
      ,payment_channel_level  as qf
from shopeepay.mart_dim_pps_payment_channel_df__${region}
where pps_payment_channel_id > 0
;

insert overwrite table ${SCHEMA}.dim_pps_${region}_payment_client_channel_df
select concat_ws('_',substr(md5(cast(spm_client_id as string)),0,2),cast(spm_client_id as string),cast(spm_payment_channel_id as string),cast(spm_provision_channel_id as string))  as rowkey
      ,spm_client_name  as qf
from shopeepay.mart_dim_keystats_client_channel_mapping_ds__${region}
where spm_client_id > 0
 and spm_payment_channel_id > 0
 and spm_provision_channel_id > 0
 and char_length(spm_client_name) > 0
 and grass_date = '${grass_date}'
;
