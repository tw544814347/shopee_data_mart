--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2026-03-23
-- Theme Domain：       user mission
-- Description:         user mission, 只取  mission_type in (30,31,32,33,34,35) 
--                      1：KYC任务 2：SPL订单量任务 3：SPL GMV任务
-- mission_type=30 --> shopee订单数
-- mission_type=31 --> shopee订单GMV
-- mission_type=32 --> PDAM Bill
-- mission_type=33 --> PLN Bill
-- mission_type=34 --> BPJS Bill
-- mission_type=35 --> Shopeepay Topup
-- Data Granularity:    user_mission_id
-- Update               
/* 
jira: https://jira.shopee.io/browse/SPFDT-61723
PRD: 
FRF: 
*/
--********************************************************************--
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

drop table if exists risk.dwd_risk_${region}_2cscore_mission_result_df;
create external table if not exists risk.dwd_risk_${region}_2cscore_mission_result_df
(
mission_id           string comment 'mission_id'
,mission_name        string comment 'mission_name'
,mission_type        string comment 'mission_type'
,biz_type            string comment '1-bcl,2-scl,3-spl'
,complete_duration   bigint comment 'complete_duration'
,reward_duration     bigint comment 'reward_duration'
,user_mission_id     string comment 'user_mission_id'
,platform_user_id    string comment 'platform_user_id is shopee_user_id'
,credit_user_id      string comment 'credit_user_id'
,start_time          string comment 'user mission start_time(local time)'
,complete_time       string comment 'user mission complete_time(local time)'
,reward_time         string comment 'reward_time'
,start_timestamp     bigint comment 'user mission start_timestamp'
,complete_timestamp  bigint comment 'user mission complete_timestamp'
,reward_timestamp    bigint comment 'reward_timestamp'
,complete_value      string comment 'complete_value'
,create_time         string comment 'create_time local time'
,reward_rank         bigint comment 'mission reward limit condition value'
,action_id           string comment 'mission reward item id'
,user_mission_status bigint comment 'user_mission_status,3 is already reward'
,min_spend_amount      bigint comment ' check min_spend_amount condition'
,need_min_spend_amount int comment ' check min_spend_amount condition'
,tenure_num_list       array<string> comment 'set tenure_num condition'
,need_tenure_num_list  int comment ' check tenure_num condition'
,business_domain_list  array<string> comment 'set channel id condition'
,need_business_domain_list  int comment ' check business_domain condition'
,category_list         array<string> comment 'set category condition'
,need_category_list    int comment ' check category condition'
,shop_list             array<string> comment 'set shop condition'
,need_shop_list        int comment ' check shop condition'
,mission_criteria      struct<min_spend_amount:bigint,tenure_num_list:array<string>,business_domain_list:array<string>,category_list:array<string>,shop_list:array<string>> comment 'mission criteria json'
,mission_reward        array<struct<rank:bigint,action_id_list:array<string>>> comment 'mission reward json'
,mission_result        string comment 'user misson result, for calculating the mission progress'
)
partitioned by (grass_date     string   comment "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_reg_2cscore_mission_result_df/grass_region=${upper_region}';
;


-- msck repair table risk.dwd_risk_${region}_2cscore_mission_result_df;
refresh table risk.dwd_risk_${region}_2cscore_mission_result_df;

-- 汇总
insert overwrite table risk.dwd_risk_${region}_2cscore_mission_result_df partition(grass_date='${grass_date}')
----  mission_type=30 --> shopee订单数 
select 
    t1.mission_id
    ,t1.mission_name
    ,t1.mission_type
    ,t1.biz_type
    ,t1.complete_duration
    ,t1.reward_duration
    ,t1.user_mission_id
    ,t1.platform_user_id
    ,t1.credit_user_id
    ,t1.start_time
    ,t1.complete_time
    ,t1.reward_time
    ,t1.start_timestamp
    ,t1.complete_timestamp
    ,t1.reward_timestamp
    ,t1.complete_value
    ,t1.create_time
    ,t1.reward_rank
    ,t1.action_id
    ,t1.user_mission_status
    ,t1.min_spend_amount
    ,t1.need_min_spend_amount
    ,t1.tenure_num_list
    ,t1.need_tenure_num_list
    ,t1.business_domain_list
    ,t1.need_business_domain_list
    ,t1.category_list
    ,t1.need_category_list
    ,t1.shop_list
    ,t1.need_shop_list
    ,t1.mission_criteria
    ,t1.mission_reward
    ,count(distinct t2.order_id) mission_result
from risk.dim_risk_${region}_promotion_mission_info_df t1 
left join (
        select
            cast(buyer_id as string) as shopee_user_id
            ,cast(shop_id as string) as shop_id
            ,cast(seller_id as string) as seller_id
            ,order_id
            ,create_datetime
            ,create_timestamp
            ,gmv
            ,grass_date
        from
            mp_order.dwd_order_all_ent_df__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = '${upper_region}'
            and order_fe_status_id = 3
            and create_datetime is not null
            -- 限定时间范围,缩小数据量
            and grass_date >= (select to_date(min(start_time)) as min_start_time from risk.dim_risk_${region}_promotion_mission_info_df where grass_date='${grass_date}')
            and create_timestamp >= (select min(start_timestamp) as start_timestamp from risk.dim_risk_${region}_promotion_mission_info_df where grass_date='${grass_date}')
) 
t2 
-- 针对mission_type=30，需要关联到订单表，计算符合条件的订单数量
-- 1.订单时间在任务开始时间和结束时间之间
-- 2.订单的金额要超过任务设定最小消费金额(可选)
-- 3.订单所属店铺要在任务指定的shop列表中（可选）
on t1.platform_user_id = t2.shopee_user_id 
and t2.create_timestamp between  t1.start_timestamp and t1.complete_timestamp
and t2.gmv > 0       -- 去掉为0的订单数
and if(t1.need_min_spend_amount=1,t2.gmv >= t1.min_spend_amount,True)
and if(t1.need_shop_list=1,array_contains(t1.shop_list, t2.shop_id),True)

where t1.grass_date = '${grass_date}'
and t1.mission_type=30
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32

-- mission_type=31 --> shopee订单GMV
union all 
select 
    t1.mission_id
    ,t1.mission_name
    ,t1.mission_type
    ,t1.biz_type
    ,t1.complete_duration
    ,t1.reward_duration
    ,t1.user_mission_id
    ,t1.platform_user_id
    ,t1.credit_user_id
    ,t1.start_time
    ,t1.complete_time
    ,t1.reward_time
    ,t1.start_timestamp
    ,t1.complete_timestamp
    ,t1.reward_timestamp
    ,t1.complete_value
    ,t1.create_time
    ,t1.reward_rank
    ,t1.action_id
    ,t1.user_mission_status
    ,t1.min_spend_amount
    ,t1.need_min_spend_amount
    ,t1.tenure_num_list
    ,t1.need_tenure_num_list
    ,t1.business_domain_list
    ,t1.need_business_domain_list
    ,t1.category_list
    ,t1.need_category_list
    ,t1.shop_list
    ,t1.need_shop_list
    ,t1.mission_criteria
    ,t1.mission_reward
    ,sum(coalesce(t2.gmv,0)) mission_result
from risk.dim_risk_${region}_promotion_mission_info_df t1 
left join (
        select
            cast(buyer_id as string) as shopee_user_id
            ,cast(shop_id as string) as shop_id
            ,cast(seller_id as string) as seller_id
            ,cast(level1_global_be_category_id as string) as level1_global_be_category_id
            ,order_id
            ,create_datetime
            ,create_timestamp
            ,gmv
            ,grass_date
        from
            mp_order.dwd_order_item_all_ent_df__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = '${upper_region}'
            and order_fe_status_id = 3
            and create_datetime is not null
            -- 限定时间范围,缩小数据量
            and grass_date >= (select to_date(min(start_time)) as min_start_time from risk.dim_risk_${region}_promotion_mission_info_df where grass_date='${grass_date}')
            and create_timestamp >= (select min(start_timestamp) as start_timestamp from risk.dim_risk_${region}_promotion_mission_info_df where grass_date='${grass_date}')
) 
t2 
-- 针对mission_type=31，需要关联到订单item表，计算符合条件的订单数量
-- 1.订单时间在任务开始时间和结束时间之间
-- 2.订单的金额要超过任务设定最小消费金额(可选)
-- 3.订单所属店铺要在任务指定的shop列表中（可选）
-- 4.由于31有category id的判断条件，这里我们改成用mp_order.dwd_order_item_all_ent_df__reg_s0_live, category id用表里的level1_category_id
on t1.platform_user_id = t2.shopee_user_id 
and t2.create_timestamp between  t1.start_timestamp and t1.complete_timestamp
and t2.gmv > 0       -- 去掉为0的订单数
and if(t1.need_min_spend_amount=1,t2.gmv >= t1.min_spend_amount,True)
and if(t1.need_shop_list=1,array_contains(t1.shop_list, t2.shop_id),True)
and if(t1.need_category_list=1,array_contains(t1.category_list, t2.level1_global_be_category_id),True)
where t1.grass_date = '${grass_date}'
and t1.mission_type=31
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32

-- mission_type=32 --> PDAM Bill
-- mission_type=33 --> PLN Bill
-- mission_type=34 --> BPJS Bill
--  20101: BPJS
--  20102: PDAM
--  20103: PLN
union all 
select 
    t1.mission_id
    ,t1.mission_name
    ,t1.mission_type
    ,t1.biz_type
    ,t1.complete_duration
    ,t1.reward_duration
    ,t1.user_mission_id
    ,t1.platform_user_id
    ,t1.credit_user_id
    ,t1.start_time
    ,t1.complete_time
    ,t1.reward_time
    ,t1.start_timestamp
    ,t1.complete_timestamp
    ,t1.reward_timestamp
    ,t1.complete_value
    ,t1.create_time
    ,t1.reward_rank
    ,t1.action_id
    ,t1.user_mission_status
    ,t1.min_spend_amount
    ,t1.need_min_spend_amount
    ,t1.tenure_num_list
    ,t1.need_tenure_num_list
    ,t1.business_domain_list
    ,t1.need_business_domain_list
    ,t1.category_list
    ,t1.need_category_list
    ,t1.shop_list
    ,t1.need_shop_list
    ,t1.mission_criteria
    ,t1.mission_reward
    ,count(distinct t2.order_id) mission_result
from risk.dim_risk_${region}_promotion_mission_info_df t1 
left join (
        select
            cast(user_id as string) as shopee_user_id
            ,order_id
            ,create_time as create_timestamp
            ,case
                when category_id = '20102' then 32
                when category_id = '20103' then 33
                when category_id = '20101' then 34
                else -1
            end mission_type
        from digitalpurchase.${region}_order_dwd_dp_trd_ord_df_s0_live
        where
            grass_date = '${grass_date}'
            and order_status in ('OR3', 'OR5', 'OR6')
            and category_id in ('20102', '20103', '20101')
            -- 限定时间范围,缩小数据量
            and create_time >= (select min(start_timestamp) as start_timestamp from risk.dim_risk_${region}_promotion_mission_info_df where grass_date='${grass_date}')
) 
t2 
-- 针对mission_type=32,33,34，需要关联到订单表，计算符合条件的订单数量
-- 1.订单时间在任务开始时间和结束时间之间(仅此限制)
on t1.platform_user_id = t2.shopee_user_id and t1.mission_type=t2.mission_type
and t2.create_timestamp between  t1.start_timestamp and t1.complete_timestamp
where t1.grass_date = '${grass_date}'
and t1.mission_type in(32,33,34)
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32

-- mission_type=35 --> Shopeepay Topup
union all 
select 
    t1.mission_id
    ,t1.mission_name
    ,t1.mission_type
    ,t1.biz_type
    ,t1.complete_duration
    ,t1.reward_duration
    ,t1.user_mission_id
    ,t1.platform_user_id
    ,t1.credit_user_id
    ,t1.start_time
    ,t1.complete_time
    ,t1.reward_time
    ,t1.start_timestamp
    ,t1.complete_timestamp
    ,t1.reward_timestamp
    ,t1.complete_value
    ,t1.create_time
    ,t1.reward_rank
    ,t1.action_id
    ,t1.user_mission_status
    ,t1.min_spend_amount
    ,t1.need_min_spend_amount
    ,t1.tenure_num_list
    ,t1.need_tenure_num_list
    ,t1.business_domain_list
    ,t1.need_business_domain_list
    ,t1.category_list
    ,t1.need_category_list
    ,t1.shop_list
    ,t1.need_shop_list
    ,t1.mission_criteria
    ,t1.mission_reward
    ,count(distinct t2.order_id) mission_result
from risk.dim_risk_${region}_promotion_mission_info_df t1 
left join (
        select
            cast(user_id as string) as shopee_user_id
            ,transaction_sn as order_id
            ,create_time as create_timestamp
            ,amount
        from shopeepay.dwd_wallet_${region}_transaction_tab_df
        where
            transaction_type = 1 and status = 3
            -- 限定时间范围,缩小数据量
            and create_time >= (select min(start_timestamp) as start_timestamp from risk.dim_risk_${region}_promotion_mission_info_df where grass_date='${grass_date}')
        union
        select
            shopee_user_id
            ,uws_order_sn as order_id
            ,create_time as create_timestamp
            ,net_amount as amount
        from shopeepay.mart_dwd_wide_user_order_wallet_all_ent_df__${region}
        where
            order_type_name = 'Topup' and order_status_name = 'SUCCESS'
            -- 限定时间范围,缩小数据量
            and create_time >= (select min(start_timestamp) as start_timestamp from risk.dim_risk_${region}_promotion_mission_info_df where grass_date='${grass_date}')
) 
t2 
-- 针对mission_type=35，需要关联到订单表，计算符合条件的订单数量
-- 1.订单时间在任务开始时间和结束时间之间
-- 2.订单的金额要超过任务设定最小消费金额
on t1.platform_user_id = t2.shopee_user_id 
and t2.create_timestamp between  t1.start_timestamp and t1.complete_timestamp
and t2.amount > 0       -- 去掉为0的订单数
and if(t1.need_min_spend_amount=1,t2.amount >= t1.min_spend_amount,True)
where t1.grass_date = '${grass_date}'
and t1.mission_type in(35)
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
;
