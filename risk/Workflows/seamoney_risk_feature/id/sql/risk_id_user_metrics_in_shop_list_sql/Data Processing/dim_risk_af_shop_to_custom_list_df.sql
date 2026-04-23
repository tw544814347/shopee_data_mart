--********************************************************************--
-- Author:         jiaqi.chen@shopee.com
-- Created Time:   2023-04-26T16:23:08.830Z
-- Description:    用户在指定商家list下支付的次数和金额
--********************************************************************--

-- source risk.ods__credit_risk_control_id_db__custom_list_rare_type_tab__df
-- shop_id: data_type ||'_'|| custom_list_id (多段数据逗号分隔)
insert overwrite table ${SCHEMA}.dim_risk_af_shop_to_custom_list_df partition (grass_region, grass_date)
select 
    data as shop_id, 
    concat_ws(',', collect_set(concat_ws('_', data_type, custom_list_id))) as custom_list_infos,
    'id' as grass_region,
    '${ds}' as grass_date
from ${SCHEMA}.dwd_risk_id_credit_custom_list_df 
where data_type = 12 and grass_date = '${ds}' and status = 1
group by data
union all 
select 
    data as shop_id, 
    concat_ws(',', collect_set(concat_ws('_', data_type, custom_list_id))) as custom_list_infos,
    'th' as grass_region,
    '${ds}' as grass_date
from ${SCHEMA}.dwd_risk_th_credit_custom_list_df 
where data_type = 12 and grass_date = '${ds}' and status = 1
group by data
union all 
select 
    data as shop_id, 
    concat_ws(',', collect_set(concat_ws('_', data_type, custom_list_id))) as custom_list_infos,
    'my' as grass_region,
    '${ds}' as grass_date
from ${SCHEMA}.dwd_risk_my_credit_custom_list_df 
where data_type = 12 and grass_date = '${ds}' and status = 1
group by data
union all 
select 
    data as shop_id, 
    concat_ws(',', collect_set(concat_ws('_', data_type, custom_list_id))) as custom_list_infos,
    'ph' as grass_region,
    '${ds}' as grass_date
from ${SCHEMA}.dwd_risk_ph_credit_custom_list_df 
where data_type = 12 and grass_date = '${ds}' and status = 1
group by data
union all 
select 
    data as shop_id, 
    concat_ws(',', collect_set(concat_ws('_', data_type, custom_list_id))) as custom_list_infos,
    'sg' as grass_region,
    '${ds}' as grass_date
from ${SCHEMA}.dwd_risk_sg_credit_custom_list_df 
where data_type = 12 and grass_date = '${ds}' and status = 1
group by data
union all 
select 
    data as shop_id, 
    concat_ws(',', collect_set(concat_ws('_', data_type, custom_list_id))) as custom_list_infos,
    'vn' as grass_region,
    '${ds}' as grass_date
from ${SCHEMA}.dwd_risk_vn_credit_custom_list_df 
where data_type = 12 and grass_date = '${ds}' and status = 1
group by data
--union all 
--select 
--    data as shop_id, 
--    concat_ws(',', collect_set(concat_ws('_', data_type, custom_list_id))) as custom_list_infos,
--    'tw' as grass_region,
--    '${ds}' as grass_date
--from ${SCHEMA}.ods__credit_risk_control_tw_db__custom_list_rare_type_tab__df 
--where data_type = 12 and grass_date = '${ds}' and status = 1
--group by data
;