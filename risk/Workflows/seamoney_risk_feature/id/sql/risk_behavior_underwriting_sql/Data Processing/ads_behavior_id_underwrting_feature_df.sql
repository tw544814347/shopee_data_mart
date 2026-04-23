--********************************************************************--
-- Author:              huangwei@shopee.com
-- Created Time:        2023-11-01
-- Theme Domain：       risk-feature
-- Description:         spl/bcl/scl user_behavior underwirting feature
-- Data Granularity:    credit_user_id
-- 变更历史：
--    v1 by zongyi.lu@shopee.com，2023-12-14 增加注释，新增字段limit_utilization_90d/180d(spl/bcl), jira https://jira.shopee.io/browse/SPFDT-25987
--    v2 by zongyi.lu@shopee.com，2024-02-19 增加注释，新增字段shopee_account_status, jira https://jira.shopee.io/browse/SPFDT-30849
--    v3 by zongyi.lu@shopee.com, 2024-04-09 增加字段, jira https://jira.shopee.io/browse/SPFDT-34942 字段映射 https://docs.google.com/spreadsheets/d/1-HUkKJYaypiyvUUjTscfzh-fqFW_LshVnyEfTwShsX0/edit#gid=0
--                first_billed_from_now_bcl_floating credit_mart.wide_bcl_id_behavior_user_df.num_months_floating
--                first_billed_from_now_floating credit_mart.tdm_id_user_bill_df.num_months_floating
--                repaid_bills_num_user_floating credit_mart.tdm_id_user_bill_df.repaid_bills_num_floating
--  v4  by chengguo.liu@shopee.com, 上游业务系统floating due date迭代， bill维度数据 first_billed_from_now_bcl、first_billed_from_now、repaid_bills_num_user取'2024-04-11'分区
--         待业务切换至带有'_floating'后缀的新feature
--  v5 by zongyi.lu@shopee.com ,2024-09-10 发现关联credit_mart.dwd_behavior_feature_id_user_df 导致credit_user_id 重复,先做子查询保证credit_user_id唯一再关联
--  v6 by zongyi.lu@shopee.com ,2024-09-11 发现关联credit_uc.dws_spl_id_uc_user_df(用户销户重新激活)需要has_valid_activated=1
--  v7 by wei.tao 20250303 新增字段：average_limit_utilization_{1/3/7/14/30}d_{spl/bcl}  credit_mart.wide_spl_id_behavior_user_df / credit_mart.wide_bcl_id_behavior_user_df
--  added by wei.tao@shopee.com ,2025-03-04 新增条件，为了保证 credit_user_id 唯一 
--********************************************************************--
create or replace temporary view tmp_spl_id_user_account_status as
    select 
    user_id as platform_user_id
    ,status as shopee_account_status
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
    and grass_region = 'ID'
    and grass_date = '${ds}'
;

create or replace temporary view tmp_spl_id_behavior_user as
select
    credit_user_id,
    SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 1) THEN total_limit_util_spl ELSE 0 END)  AS total_limit_utilization_1d_spl,
    SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 3) THEN total_limit_util_spl ELSE 0 END)  AS total_limit_utilization_3d_spl,
    SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 7) THEN total_limit_util_spl ELSE 0 END)  AS total_limit_utilization_7d_spl,
    SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 14) THEN total_limit_util_spl ELSE 0 END) AS total_limit_utilization_14d_spl,
    SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 30) THEN total_limit_util_spl ELSE 0 END) AS total_limit_utilization_30d_spl,
    SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 90) THEN total_limit_util_spl ELSE 0 END) AS total_limit_utilization_90d_spl,
    SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 180) THEN total_limit_util_spl ELSE 0 END) AS total_limit_utilization_180d_spl,
    COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 1) THEN grass_date ELSE NULL END)  AS grass_date_cnt_1d_spl,
    COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 3) THEN grass_date ELSE NULL END)  AS grass_date_cnt_3d_spl,
    COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 7) THEN grass_date ELSE NULL END)  AS grass_date_cnt_7d_spl,
    COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 14) THEN grass_date ELSE NULL END) AS grass_date_cnt_14d_spl,
    COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 30) THEN grass_date ELSE NULL END) AS grass_date_cnt_30d_spl,
    COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 90) THEN grass_date ELSE NULL END) AS grass_date_cnt_90d_spl,
    COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 180) THEN grass_date ELSE NULL END) AS grass_date_cnt_180d_spl,
    MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 1) THEN total_limit_util_spl ELSE 0 END)  AS max_limit_utilization_1d_spl,
    MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 3) THEN total_limit_util_spl ELSE 0 END)  AS max_limit_utilization_3d_spl,
    MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 7) THEN total_limit_util_spl ELSE 0 END)  AS max_limit_utilization_7d_spl,
    MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 14) THEN total_limit_util_spl ELSE 0 END) AS max_limit_utilization_14d_spl,
    MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 30) THEN total_limit_util_spl ELSE 0 END) AS max_limit_utilization_30d_spl,
    MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 90) THEN total_limit_util_spl ELSE 0 END) AS max_limit_utilization_90d_spl,
    MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 180) THEN total_limit_util_spl ELSE 0 END) AS max_limit_utilization_180d_spl
from (
select 
    credit_user_id                     as credit_user_id
    ,((COALESCE(common_perm_used_credit_amount,0))+(COALESCE(common_temp_used_credit_amount,0))+(COALESCE(installment_perm_used_credit_amount,0))                            
        + (COALESCE(common_perm_frozen_credit_amount,0))+(COALESCE(common_temp_frozen_credit_amount,0))+ (COALESCE(lite_used_credit_amount,0))
        + (COALESCE(installment_perm_frozen_credit_amount,0)) + (COALESCE(lite_frozen_credit_amount,0))
     )                  
     /
     ((COALESCE(common_perm_credit_limit,0))+(COALESCE(common_temp_credit_limit,0))+(COALESCE(installment_perm_credit_limit,0))+(COALESCE(lite_credit_limit,0))
     )      as total_limit_util_spl
    ,grass_date                         as grass_date
from credit_mart.dws_spl_id_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) + coalesce(installment_perm_credit_limit,0) + coalesce(lite_credit_limit,0) > 0 
and biz_type = 3
and grass_date >=date_sub('${grass_date}',180)
) a 
group by credit_user_id
;

create or replace temporary view tmp_bcl_id_behavior_user as
select
credit_user_id
,sum(case when grass_date>=date_sub('${grass_date}',1) then total_limit_util_bcl else 0 end)   as total_limit_utilization_1d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',3) then total_limit_util_bcl else 0 end)   as total_limit_utilization_3d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',7) then total_limit_util_bcl else 0 end)   as total_limit_utilization_7d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',14) then total_limit_util_bcl else 0 end)  as total_limit_utilization_14d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_bcl else 0 end)  as total_limit_utilization_30d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_bcl else 0 end)  as total_limit_utilization_90d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_bcl else 0 end) as total_limit_utilization_180d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',1) then grass_date else null end)   as grass_date_cnt_1d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',3) then grass_date else null end)   as grass_date_cnt_3d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',7) then grass_date else null end)   as grass_date_cnt_7d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',14) then grass_date else null end)  as grass_date_cnt_14d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',30) then grass_date else null end)  as grass_date_cnt_30d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',90) then grass_date else null end)  as grass_date_cnt_90d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',180) then grass_date else null end) as grass_date_cnt_180d_bcl
,max(case when grass_date>=date_sub('${grass_date}',1) then total_limit_util_bcl else 0 end)   as max_limit_utilization_1d_bcl
,max(case when grass_date>=date_sub('${grass_date}',3) then total_limit_util_bcl else 0 end)   as max_limit_utilization_3d_bcl
,max(case when grass_date>=date_sub('${grass_date}',7) then total_limit_util_bcl else 0 end)   as max_limit_utilization_7d_bcl
,max(case when grass_date>=date_sub('${grass_date}',14) then total_limit_util_bcl else 0 end)  as max_limit_utilization_14d_bcl
,max(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_bcl else 0 end)  as max_limit_utilization_30d_bcl
,max(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_bcl else 0 end)  as max_limit_utilization_90d_bcl
,max(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_bcl else 0 end) as max_limit_utilization_180d_bcl
from (
select 
    credit_user_id                     as credit_user_id
    ,((COALESCE(common_perm_used_credit_amount,0))+(COALESCE(common_temp_used_credit_amount,0))
        +(COALESCE(common_perm_frozen_credit_amount,0))+(COALESCE(common_temp_frozen_credit_amount,0))
     )
     /
     ((COALESCE(common_perm_credit_limit,0))+(COALESCE(common_temp_credit_limit,0))
     )      as total_limit_util_bcl
    ,grass_date                         as grass_date
from credit_mart.dws_bcl_id_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) > 0
and biz_type = 1
and grass_date >=date_sub('${grass_date}',180)
) a 
group by credit_user_id
;

-- 授信跑批的一批特征
INSERT OVERWRITE TABLE ${SCHEMA}.ads_behavior_underwrting_feature_df PARTITION (grass_region='ID',grass_date='${ds}')

SELECT
    a.credit_user_id
    -- user level
    ,a.account_label as spl_user_tag

    -- bcl、bcl status
    , b.num_months  as first_billed_from_now_spl
    , c1.num_months  as first_billed_from_now_bcl

    -- user level
    , d1.num_months  as first_billed_from_now
    , d1.repaid_bills_num as repaid_bills_num_user

    -- BCL、SPL 是否有降额动作
    , e.user_status as credit_user_status
    , case when f.credit_user_id is not null then f.is_limit_decrease_spl else  0  end as is_limit_decrease_spl
    , case when f.credit_user_id is not null then f.is_limit_decrease_bcl else  0  end as is_limit_decrease_bcl

    -- OS: out standing 未偿还贷款额度
    , g.principal_os as os_spl
    , h.principal_os as os_bcl

    --EIR: effective interest rate 用户bcl实际利率
    , i.eir_tenure2  as eir_tenure2_bcl
    , i.eir_tenure3  as eir_tenure3_bcl    
    , i.eir_tenure6  as eir_tenure6_bcl
    , i.eir_tenure12  as eir_tenure12_bcl

    --EIR: effective interest rate 用户spl实际利率
    , j.eir_tenure1  as eir_tenure1_spl
    , j.eir_tenure2  as eir_tenure2_spl    
    , j.eir_tenure3  as eir_tenure3_spl
    , j.eir_tenure6  as eir_tenure6_spl
    , j.eir_tenure12  as eir_tenure12_spl
    , j.eir_tenure18  as eir_tenure18_spl
    , j.eir_tenure24  as eir_tenure24_spl
    , c.repaid_bills_num as repaid_bills_num_cashloan
    , c.lastest_bill_max_dpd_120d as latest_dpd_cashloan

    -- bcl/spl limit_utilization
    ,t11.total_limit_utilization_90d_spl/grass_date_cnt_90d_spl   as average_limit_utilization_90d_spl
    ,t11.total_limit_utilization_180d_spl/grass_date_cnt_180d_spl as average_limit_utilization_180d_spl
    ,t11.max_limit_utilization_90d_spl                            as max_limit_utilization_90d_spl
    ,t11.max_limit_utilization_180d_spl                           as max_limit_utilization_180d_spl
    ,t12.total_limit_utilization_90d_bcl/grass_date_cnt_90d_bcl   as average_limit_utilization_90d_bcl
    ,t12.total_limit_utilization_180d_bcl/grass_date_cnt_180d_bcl as average_limit_utilization_180d_bcl
    ,t12.max_limit_utilization_90d_bcl                            as max_limit_utilization_90d_bcl
    ,t12.max_limit_utilization_180d_bcl                           as max_limit_utilization_180d_bcl

    -- user account status
    ,a.shopee_account_status

    -- spl user eligible tenure
    ,case when j.eir_tenure1>0  or j.eir_tenure1  is not null then 1 else 0 end as eligible_tenure1_spl 
    ,case when j.eir_tenure2>0  or j.eir_tenure2  is not null then 1 else 0 end as eligible_tenure2_spl 
    ,case when j.eir_tenure3>0  or j.eir_tenure3  is not null then 1 else 0 end as eligible_tenure3_spl 
    ,case when j.eir_tenure6>0  or j.eir_tenure6  is not null then 1 else 0 end as eligible_tenure6_spl 
    ,case when j.eir_tenure12>0 or j.eir_tenure12 is not null then 1 else 0 end as eligible_tenure12_spl
    ,case when j.eir_tenure18>0 or j.eir_tenure18 is not null then 1 else 0 end as eligible_tenure18_spl
    ,case when j.eir_tenure24>0 or j.eir_tenure24 is not null then 1 else 0 end as eligible_tenure24_spl
    ,c.num_months_floating as first_billed_from_now_bcl_floating
    ,d.num_months_floating as first_billed_from_now_floating
    ,d.repaid_bills_num_floating as repaid_bills_num_user_floating
    ,b.last_chp_disburse_time
    ,b.first_spl_disburse_time
    ,h.is_disbursed as is_bcl_disbursed
    ,d.repaid_bills_num_bcl
    ,t14.repaid_bills_num_chp
    ,t14.repaid_bills_num_spl
    ,t13.is_spl_disbursed
    ,t13.is_chp_disbursed

    ,t11.total_limit_utilization_1d_spl/grass_date_cnt_1d_spl   as average_limit_utilization_1d_spl
    ,t11.total_limit_utilization_3d_spl/grass_date_cnt_3d_spl   as average_limit_utilization_3d_spl
    ,t11.total_limit_utilization_7d_spl/grass_date_cnt_7d_spl   as average_limit_utilization_7d_spl
    ,t11.total_limit_utilization_14d_spl/grass_date_cnt_14d_spl as average_limit_utilization_14d_spl
    ,t11.total_limit_utilization_30d_spl/grass_date_cnt_30d_spl as average_limit_utilization_30d_spl

    ,t11.max_limit_utilization_1d_spl                            as max_limit_utilization_1d_spl
    ,t11.max_limit_utilization_3d_spl                            as max_limit_utilization_3d_spl
    ,t11.max_limit_utilization_7d_spl                            as max_limit_utilization_7d_spl
    ,t11.max_limit_utilization_14d_spl                           as max_limit_utilization_14d_spl
    ,t11.max_limit_utilization_30d_spl                           as max_limit_utilization_30d_spl

    ,t12.total_limit_utilization_1d_bcl/grass_date_cnt_1d_bcl   as average_limit_utilization_1d_bcl
    ,t12.total_limit_utilization_3d_bcl/grass_date_cnt_3d_bcl   as average_limit_utilization_3d_bcl
    ,t12.total_limit_utilization_7d_bcl/grass_date_cnt_7d_bcl   as average_limit_utilization_7d_bcl
    ,t12.total_limit_utilization_14d_bcl/grass_date_cnt_14d_bcl as average_limit_utilization_14d_bcl
    ,t12.total_limit_utilization_30d_bcl/grass_date_cnt_30d_bcl as average_limit_utilization_30d_bcl

    ,t12.max_limit_utilization_1d_bcl                            as max_limit_utilization_1d_bcl
    ,t12.max_limit_utilization_3d_bcl                            as max_limit_utilization_3d_bcl
    ,t12.max_limit_utilization_7d_bcl                            as max_limit_utilization_7d_bcl
    ,t12.max_limit_utilization_14d_bcl                           as max_limit_utilization_14d_bcl
    ,t12.max_limit_utilization_30d_bcl                           as max_limit_utilization_30d_bcl

FROM   (
    select 
        a.credit_user_id,
        max(a.account_label)         as account_label,
        max(b.shopee_account_status) as shopee_account_status
    from
    ( 
    select credit_user_id,account_label,platform_user_id from credit_uc.dws_spl_id_uc_user_df where grass_date='${ds}' 
    union 
    select credit_user_id,null as account_label,platform_user_id from credit_uc.dws_bcl_id_uc_user_df where grass_date='${ds}'
    ) a 
    left join tmp_spl_id_user_account_status b on a.platform_user_id = b.platform_user_id 
    where a.credit_user_id is not null 
    group  by credit_user_id
    ) a
-- spl Behavior
left join credit_mart.wide_spl_id_behavior_user_df b on (a.credit_user_id = b.credit_user_id and b.grass_date='${ds}')

-- bcl Behavior
left join  credit_mart.wide_bcl_id_behavior_user_df c on (a.credit_user_id = c.credit_user_id and c.grass_date='${ds}')
-- bcl Behavior   cl bill维度数据取历史分区 '2024-04-11'
left join  credit_mart.wide_bcl_id_behavior_user_df c1 on (a.credit_user_id = c1.credit_user_id and c1.grass_date='2024-04-11')

-- user bill feature
left join credit_mart.tdm_id_user_bill_df d on (a.credit_user_id = d.credit_user_id and d.grass_date='${ds}')
-- user bill feature,   cl bill维度数据取历史分区 '2024-04-11'
left join credit_mart.tdm_id_user_bill_df d1 on (a.credit_user_id = d1.credit_user_id and d1.grass_date='2024-04-11')

-- 申请用户, 事实表 
left join (
        select 
        credit_user_id
        ,user_status
        from credit_uc.dws_spl_id_uc_user_df
        where grass_date='${ds}'
        and has_valid_activated=1
        and activate_status = 1 -- effective added by wei.tao 20250304 新增条件为了保持 credit_user_id 、 user_status 唯一
        group by credit_user_id, user_status
    ) e on  a.credit_user_id = e.credit_user_id 
-- 整合spl bcl Feature
left join  (select 
                credit_user_id
                ,max(case when product_id=3 then is_limit_decrease else  0  end) as is_limit_decrease_spl
                ,max(case when product_id=1 then is_limit_decrease else  0  end) as is_limit_decrease_bcl
            from credit_mart.dwd_behavior_feature_id_user_df 
            where grass_date='${ds}'
            group by credit_user_id
) f on a.credit_user_id =  f.credit_user_id

-- 未还bcl/spl outstanding 额度
left join (
        select
        credit_user_id
        ,max(principal_os)  as principal_os
        from credit_mart.dws_spl_id_user_df
        where grass_date='${ds}'
        group by credit_user_id
        ) g  on a.credit_user_id =  g.credit_user_id 
left join credit_mart.dws_bcl_id_user_df h  on (a.credit_user_id =  h.credit_user_id and h.grass_date='${ds}')

-- bcl/spl 费率
left join credit_mart.tdm_bcl_id_user_fee_rate_df i on (a.credit_user_id =  i.credit_user_id and i.grass_date='${ds}')
left join credit_mart.tdm_spl_id_user_fee_rate_df j on (a.credit_user_id =  j.credit_user_id and j.grass_date='${ds}')

-- bcl/spl limit_utilization
left join tmp_spl_id_behavior_user t11 on a.credit_user_id = t11.credit_user_id 
left join tmp_bcl_id_behavior_user t12 on a.credit_user_id = t12.credit_user_id
left join ${SCHEMA}.dws_risk_user_behavior_credit_info_df t13 on (a.credit_user_id = t13.credit_user_id and t13.grass_date='${ds}')
left join credit_mart.dws_spl_id_user_risk_df t14 on (a.credit_user_id = t14.credit_user_id and t14.grass_date='${ds}')
;


create or replace view ${SCHEMA}.ads_behavior_id_underwrting_feature_df as
select
    *
from ${SCHEMA}.ads_behavior_underwrting_feature_df
where
    grass_region = upper('${region}')
;