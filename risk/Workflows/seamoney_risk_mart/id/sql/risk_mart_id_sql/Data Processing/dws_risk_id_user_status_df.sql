insert overwrite table ${SCHEMA}.dws_risk_id_user_status_df partition (grass_date)
select  user_id
        ,coalesce(datediff('${grass_date}', prev_action_date), -9999) as last_frozen_control_live_days_from_now
        ,'${grass_date}' as grass_date
from    (
    select  user_id
            ,case   when max_by(action, live_date) = 'freeze' then 'BAU freeze'
                    when max_by(action, live_date) = 'decrement' then 'BAU decrement'
                    ELSE max_by(action, live_date)
             end as prev_action
            ,max_by(control_test, live_date) AS prev_action_control_test
            ,max(live_date) AS prev_action_date
    from    ${SCHEMA}.dwd_risk_id_limit_freeze_decrement_history_df
    where   grass_date = '${grass_date}'
      and   (
                    action <> 'recover'
                or  control_test <> 'control'
            )
    group by user_id
) t
where   lower(prev_action) like '%freeze%'
  and   lower(prev_action_control_test) like '%control%'
;

