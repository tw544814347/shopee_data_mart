--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-12-12
-- Theme Domain：       seller
-- Description:         TW SPL Seller KYC flow automation
-- Data Granularity:    store_id(shop_id)
-- Jira&Prd:            https://jira.shopee.io/browse/SPFDT-27202    https://docs.google.com/document/d/1Tm_pSDH55jrmNzXvWJSv0S_iSx-nplmE/edit
-- s3 信息:              https://confluence.shopee.io/display/FSDT/07.+TW+seller+kyc+s3
--********************************************************************--

create or replace temporary view tmp_shop_list_table as
select 
data as shop_id 
from risk.dwd_risk_tw_credit_custom_list_rare_type_df
where grass_date ='${grass_date}'
and status = 2 
and custom_list_id = 20 
and data_type = 12
group by data
;

insert overwrite table risk.ads_risk_tw_seller_kyc_info_df partition (grass_date) 
select 
t1.shop_id                                                      as store_id 
,t2.user_id                                                     as user_id 
,t2.brand_nme                                                   as brand_name
,get_json_object(t3.extinfo,'$.name')                           as resp_name
,get_json_object(t3.extinfo,'$.id_number')                      as resp_id
,get_json_object(t3.extinfo,'$.business_name')                  as vendor_name
,get_json_object(t3.extinfo,'$.business_registration_number')   as vendor_no
,'${grass_date}'                                                as grass_date 
from tmp_shop_list_table t1 
join (
    select 
    shop_id
    ,user_id 
    ,shop_name as brand_nme
    from mp_user.dim_shop__reg_s0_live 
    where grass_region ='TW'
    and grass_date='${grass_date}'
) t2 on t1.shop_id = t2.shop_id
left join (
    select 
    user_id 
    ,extinfo
    ,row_number() over(partition by user_id order by update_time desc) rn 
    from shopeepay.dwd_kyc_tw_user_kyc_record_tab_df_sensitive
) t3 on t2.user_id = t3.user_id and t3.rn=1
;