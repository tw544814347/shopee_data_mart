create or replace temporary view tmp_spl_vn_behavior_user as
select
    credit_user_id
    ,sum(case when grass_date>=date_sub('${grass_date}',3) then total_limit_util_spl else 0 end)        as total_limit_utilization_3d_spl
    ,sum(case when grass_date>=date_sub('${grass_date}',7) then total_limit_util_spl else 0 end)        as total_limit_utilization_7d_spl
    ,sum(case when grass_date>=date_sub('${grass_date}',14) then total_limit_util_spl else 0 end)       as total_limit_utilization_14d_spl
    ,sum(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_spl else 0 end)       as total_limit_utilization_30d_spl
    ,sum(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_spl else 0 end)       as total_limit_utilization_90d_spl
    ,sum(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_spl else 0 end)      as total_limit_utilization_180d_spl
    ,sum(case when grass_date>=date_sub('${grass_date}',360) then total_limit_util_spl else 0 end)      as total_limit_utilization_360d_spl
    ,sum(case when grass_date>=date_sub('${grass_date}',720) then total_limit_util_spl else 0 end)      as total_limit_utilization_720d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',3) then grass_date else null end)    as grass_date_cnt_3d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',7) then grass_date else null end)    as grass_date_cnt_7d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',14) then grass_date else null end)   as grass_date_cnt_14d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',30) then grass_date else null end)   as grass_date_cnt_30d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',90) then grass_date else null end)   as grass_date_cnt_90d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',180) then grass_date else null end)  as grass_date_cnt_180d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',360) then grass_date else null end)  as grass_date_cnt_360d_spl
    ,count(distinct case when grass_date>=date_sub('${grass_date}',720) then grass_date else null end)  as grass_date_cnt_720d_spl
from (
    select 
        credit_user_id                      as credit_user_id
        ,--total_user_credit_utilisation      
        (
            COALESCE(common_perm_used_credit_amount, 0) +
            COALESCE(common_temp_used_credit_amount, 0) +
            COALESCE(installment_perm_used_credit_amount, 0) +
            --COALESCE(lite_used_credit_amount, 0) +
            COALESCE(common_perm_frozen_credit_amount, 0) +
            COALESCE(common_temp_frozen_credit_amount, 0) +
            COALESCE(installment_perm_frozen_credit_amount, 0)
            --COALESCE(lite_frozen_credit_amount, 0)
        ) / (
            COALESCE(common_perm_credit_limit, 0) +
            COALESCE(common_temp_credit_limit, 0) +
            COALESCE(installment_perm_credit_limit, 0)
            --COALESCE(lite_credit_limit, 0)
        )
        as total_limit_util_spl
        ,grass_date                         as grass_date
    from credit_mart.dws_spl_vn_account_df
    where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) + coalesce(installment_perm_credit_limit,0) --+ coalesce(lite_credit_limit,0) 
        > 0
        and biz_type = 3
        and grass_date >= date_sub('${grass_date}', 720)
) a 
group by credit_user_id
;


drop table if exists ${SCHEMA}.ads_average_limit_utilization_vn_spl_df;
create table if not exists ${SCHEMA}.ads_average_limit_utilization_vn_spl_df stored as parquet
select 
    concat_ws('_', substr(md5(user_info.credit_user_id), 0, 2), user_info.credit_user_id) as key
    ,coalesce(spl_info.total_limit_utilization_3d_spl/spl_info.grass_date_cnt_3d_spl, -9999) as average_limit_utilization_3d_spl
    ,coalesce(spl_info.total_limit_utilization_7d_spl/spl_info.grass_date_cnt_7d_spl, -9999) as average_limit_utilization_7d_spl
    ,coalesce(spl_info.total_limit_utilization_14d_spl/spl_info.grass_date_cnt_14d_spl, -9999) as average_limit_utilization_14d_spl
    ,coalesce(spl_info.total_limit_utilization_30d_spl/spl_info.grass_date_cnt_30d_spl, -9999) as average_limit_utilization_30d_spl
    ,coalesce(spl_info.total_limit_utilization_90d_spl/spl_info.grass_date_cnt_90d_spl, -9999) as average_limit_utilization_90d_spl
    ,coalesce(spl_info.total_limit_utilization_180d_spl/spl_info.grass_date_cnt_180d_spl, -9999) as average_limit_utilization_180d_spl
    ,coalesce(spl_info.total_limit_utilization_360d_spl/spl_info.grass_date_cnt_360d_spl, -9999) as average_limit_utilization_360d_spl
    ,coalesce(spl_info.total_limit_utilization_720d_spl/spl_info.grass_date_cnt_720d_spl, -9999) as average_limit_utilization_720d_spl
from (
    select 
        credit_user_id
    from credit_uc.dws_spl_vn_uc_user_df 
    where grass_date='${ds}' 
    union 
    select 
        credit_user_id
    from credit_uc.dws_bcl_vn_uc_user_df 
    where grass_date='${ds}'
) as user_info
left join tmp_spl_vn_behavior_user as spl_info on user_info.credit_user_id = spl_info.credit_user_id 