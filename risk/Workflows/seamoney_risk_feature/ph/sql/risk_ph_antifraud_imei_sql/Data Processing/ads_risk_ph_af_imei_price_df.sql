--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-10
-- Theme Domain：       risk ph imei
-- Description:         与ID一样，提供imei价格函数，沿用ID的Profile: RiskAfimeiPrice jira: https://jira.shopee.io/browse/SPFDT-44632
-- Data Granularity:    
-- 变更历史：
--********************************************************************--

insert overwrite  table risk.ads_risk_ph_af_imei_price_df partition(grass_date ='${grass_date}')
select  
    imei_sub           as imei_sub
    ,max_loanamount    as max_loanamount
    ,medium_loanamount as medium_loanamount
    ,min_loanamount    as min_loanamount
    ,cnt_req            as cnt_req
from smcdrisk_antifraud.f_ph_hpl_imei_price_agg_df
where grass_date ='${grass_date}'
;
