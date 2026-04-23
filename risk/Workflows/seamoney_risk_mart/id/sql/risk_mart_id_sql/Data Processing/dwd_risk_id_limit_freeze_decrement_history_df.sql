insert overwrite table ${SCHEMA}.dwd_risk_id_limit_freeze_decrement_history_df partition (grass_date)
select  userid
        ,user_id
        ,product
        ,action
        ,control_test
        ,quota_before_spl
        ,quota_after_spl
        ,quota_before_bcl
        ,quota_after_bcl
        ,description
        ,operator
        ,live_date
        ,'${grass_date}' as grass_date
from    smcdrisk_policy.id_spl_cl_limit_freeze_decrement_history
;

