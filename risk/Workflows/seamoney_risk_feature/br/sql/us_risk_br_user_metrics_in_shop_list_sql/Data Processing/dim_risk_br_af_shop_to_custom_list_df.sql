--********************************************************************--
-- Author:         jiaqi.chen@shopee.com
-- Created Time:   2023-04-26T16:23:08.830Z
-- Description:    用户在指定商家list下支付的次数和金额
--********************************************************************--

-- source risk.ods__credit_risk_control_id_db__custom_list_rare_type_tab__df
-- shop_id: data_type ||'_'|| custom_list_id (多段数据逗号分隔)
-- 因为BR前置依赖的调度时间比其他地区晚，所以此处br的维表数据单独处理
insert overwrite table ${SCHEMA}.dim_risk_af_shop_to_custom_list_df partition (grass_region, grass_date)
select 
    data as shop_id, 
    concat_ws(',', collect_set(concat_ws('_', data_type, custom_list_id))) as custom_list_infos,
    'br' as grass_region,
    '${ds}' as grass_date
from ${SCHEMA}.dwd_risk_br_credit_custom_list_df 
where data_type = 12 and grass_date = '${ds}' and status = 1
group by data
;