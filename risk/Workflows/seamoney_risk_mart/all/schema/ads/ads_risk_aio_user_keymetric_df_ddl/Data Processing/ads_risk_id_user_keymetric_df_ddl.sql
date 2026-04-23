DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_${region}_user_keymetric_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${region}_user_keymetric_df
(
spl_count_apply_activation_user_cnt_1d             bigint         comment 'Level 2 - The number of users that apply to activate spl'
,spl_count_activation_user_cnt_1d                  bigint         comment 'Level 1 - The number of users that successfully activated spl'
,bcl_count_apply_activation_user_cnt_1d            bigint         comment 'Level 2 - The number of users that apply to activate bcl'
,bcl_count_activation_user_cnt_1d                  bigint         comment 'Level 1 - The number of users that successfully activated bcl'
,cpl_count_apply_activation_user_cnt_1d            bigint         comment 'Level 2 - The number of users that apply to activate cpl'
,cpl_count_activation_user_cnt_1d                  bigint         comment 'Level 1 - The number of users that successfully activated cpl'
,tl_count_apply_activation_user_cnt_1d              bigint         comment 'Level 2 - the number of tl users applying for activated'
,tl_count_activation_user_cnt_1d                  bigint         comment 'Level 1 - the number of tl users with successful activated.'
,bcl_count_apply_withdraw_user_cnt_1d              bigint         comment 'Level 2 - the number of bcl users applying for withdrawal'
,bcl_count_withdrawal_user_cnt_1d                  bigint         comment 'Level 1 - the number of bcl users with successful withdrawals.'
,scl_count_apply_withdraw_user_cnt_1d              bigint         comment 'Level 2 - the number of scl users applying for withdrawal'
,scl_count_withdrawal_user_cnt_1d                  bigint         comment 'Level 1 - the number of scl users with successful withdrawals.'
,tl_count_apply_withdraw_user_cnt_1d              bigint         comment 'Level 2 - the number of tl users applying for withdrawal'
,tl_count_withdrawal_user_cnt_1d                  bigint         comment 'Level 1 - the number of tl users with successful withdrawals.'
,spl_count_apply_activation_user_cnt_30d           bigint         comment 'Level 2 - The number of users that apply to activate spl'
,spl_count_activation_user_cnt_30d                 bigint         comment 'Level 1 - The number of users that successfully activated spl'
,bcl_count_apply_activation_user_cnt_30d           bigint         comment 'Level 2 - The number of users that apply to activate bcl'
,bcl_count_activation_user_cnt_30d                 bigint         comment 'Level 1 - The number of users that successfully activated bcl'
,cpl_count_apply_activation_user_cnt_30d           bigint         comment 'Level 2 - The number of users that apply to activate cpl'
,cpl_count_activation_user_cnt_30d                 bigint         comment 'Level 1 - The number of users that successfully activated cpl'
,tl_count_apply_activation_user_cnt_30d           bigint         comment 'Level 2 - The number of users that apply to activate tl'
,tl_count_activation_user_cnt_30d                 bigint         comment 'Level 1 - The number of users that successfully activated tl'
,bcl_count_apply_withdraw_user_cnt_30d             bigint         comment 'Level 2 - the number of bcl users applying for withdrawal'
,bcl_count_withdrawal_user_cnt_30d                 bigint         comment 'Level 1 - the number of bcl users with successful withdrawals.'
,scl_count_apply_withdraw_user_cnt_30d             bigint         comment 'Level 2 - the number of scl users applying for withdrawal'
,scl_count_withdrawal_user_cnt_30d                 bigint         comment 'Level 1 - the number of scl users with successful withdrawals.'
,tl_count_apply_withdraw_user_cnt_30d             bigint         comment 'Level 2 - the number of tl users applying for withdrawal'
,tl_count_withdrawal_user_cnt_30d                 bigint         comment 'Level 1 - the number of tl users with successful withdrawals.'
,spl_count_apply_activation_user_cnt_td            bigint         comment 'Level 2 - The number of users that apply to activate spl'
,spl_count_activation_user_cnt_td                  bigint         comment 'Level 1 - The number of users that successfully activated spl'
,bcl_count_apply_activation_user_cnt_td            bigint         comment 'Level 2 - The number of users that apply to activate bcl'
,bcl_count_activation_user_cnt_td                  bigint         comment 'Level 1 - The number of users that successfully activated bcl'
,cpl_count_apply_activation_user_cnt_td            bigint         comment 'Level 2 - The number of users that apply to activate cpl'
,cpl_count_activation_user_cnt_td                  bigint         comment 'Level 1 - The number of users that successfully activated cpl'
,tl_count_apply_activation_user_cnt_td            bigint         comment 'Level 2 - The number of users that apply to activate tl'
,tl_count_activation_user_cnt_td                  bigint         comment 'Level 1 - The number of users that successfully activated tl'
,bcl_count_apply_withdraw_user_cnt_td              bigint         comment 'Level 2 - the number of bcl users applying for withdrawal'
,bcl_count_withdrawal_user_cnt_td                  bigint         comment 'Level 1 - the number of bcl users with successful withdrawals.'
,scl_count_apply_withdraw_user_cnt_td              bigint         comment 'Level 2 - the number of scl users applying for withdrawal'
,scl_count_withdrawal_user_cnt_td                  bigint         comment 'Level 1 - the number of scl users with successful withdrawals.'
,tl_count_apply_withdraw_user_cnt_td              bigint         comment 'Level 2 - the number of tl users applying for withdrawal'
,tl_count_withdrawal_user_cnt_td                  bigint         comment 'Level 1 - the number of tl users with successful withdrawals.'
,svl_count_apply_activation_user_cnt_1d bigint
,svl_count_activation_user_cnt_1d bigint
,svl_count_apply_activation_user_cnt_30d bigint
,svl_count_activation_user_cnt_30d bigint
,svl_count_apply_activation_user_cnt_60d bigint
,svl_count_activation_user_cnt_60d bigint
,svl_count_apply_activation_user_cnt_90d bigint
,svl_count_activation_user_cnt_90d bigint
,svl_count_apply_activation_user_cnt_120d bigint
,svl_count_activation_user_cnt_120d bigint
,svl_count_apply_activation_user_cnt_180d bigint
,svl_count_activation_user_cnt_180d bigint
,svl_count_apply_activation_user_cnt_td bigint
,svl_count_activation_user_cnt_td bigint
,scf_count_apply_activation_user_cnt_1d bigint
,scf_count_activation_user_cnt_1d bigint
,scf_count_apply_activation_user_cnt_30d bigint
,scf_count_activation_user_cnt_30d bigint
,scf_count_apply_activation_user_cnt_60d bigint
,scf_count_activation_user_cnt_60d bigint
,scf_count_apply_activation_user_cnt_90d bigint
,scf_count_activation_user_cnt_90d bigint
,scf_count_apply_activation_user_cnt_120d bigint
,scf_count_activation_user_cnt_120d bigint
,scf_count_apply_activation_user_cnt_180d bigint
,scf_count_activation_user_cnt_180d bigint
,scf_count_apply_activation_user_cnt_td bigint
,scf_count_activation_user_cnt_td bigint
,spl_count_user_apply_activation_rate_1d           decimal(30,10) comment 'Level 2 - The percentage of users successfully activating SPL today'
,bcl_count_user_apply_activation_rate_1d           decimal(30,10) comment 'Level 2 - The percentage of users successfully activating BCL today'
,cpl_count_user_apply_activation_rate_1d           decimal(30,10) comment 'Level 2 - The percentage of users successfully activating cpl today'
,tl_count_user_apply_activation_rate_1d           decimal(30,10) comment 'Level 2 - The percentage of users successfully activating tl today'
,bcl_count_user_apply_withdrawal_rate_1d           decimal(30,10) comment 'Level 2 - The percentage of b c l users who successfully withdrawal today'
,scl_count_user_apply_withdrawal_rate_1d           decimal(30,10) comment 'Level 2 - The percentage of scl users who successfully withdrawal today'
,tl_count_user_apply_withdrawal_rate_1d           decimal(30,10) comment 'Level 2 - The percentage of tl users who successfully withdrawal today'
,spl_count_user_apply_activation_rate_30d          decimal(30,10) comment 'Level 2 - The percentage of users successfully activating SPL last 30 days'
,bcl_count_user_apply_activation_rate_30d          decimal(30,10) comment 'Level 2 - The percentage of users successfully activating BCL last 30 days'
,cpl_count_user_apply_activation_rate_30d          decimal(30,10) comment 'Level 2 - The percentage of users successfully activating cpl last 30 days'
,tl_count_user_apply_activation_rate_30d          decimal(30,10) comment 'Level 2 - The percentage of users successfully activating tl last 30 days'
,bcl_count_user_apply_withdrawal_rate_30d          decimal(30,10) comment 'Level 2 - The percentage of b c l users who successfully withdrawal last 30 days'
,scl_count_user_apply_withdrawal_rate_30d          decimal(30,10) comment 'Level 2 - The percentage of scl users who successfully withdrawal last 30 days'
,tl_count_user_apply_withdrawal_rate_30d          decimal(30,10) comment 'Level 2 - The percentage of tl users who successfully withdrawal last 30 days'
,spl_count_user_apply_activation_rate_td           decimal(30,10) comment 'Level 2 - The percentage of users successfully activating SPL up to now.'
,bcl_count_user_apply_activation_rate_td           decimal(30,10) comment 'Level 2 - The percentage of users successfully activating BCL up to now.'
,cpl_count_user_apply_activation_rate_td           decimal(30,10) comment 'Level 2 - The percentage of users successfully activating cpl up to now.'
,tl_count_user_apply_activation_rate_td           decimal(30,10) comment 'Level 2 - The percentage of users successfully activating tl up to now.'
,bcl_count_user_apply_withdrawal_rate_td           decimal(30,10) comment 'Level 2 - The percentage of b c l users who successfully withdrawal up to now.'
,scl_count_user_apply_withdrawal_rate_td           decimal(30,10) comment 'Level 2 - The percentage of scl users who successfully withdrawal up to now.'
,tl_count_user_apply_withdrawal_rate_td           decimal(30,10) comment 'Level 2 - The percentage of tl users who successfully withdrawal up to now.'
)
PARTITIONED BY
(
  grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_aio_user_keymetric_df/grass_region=${region_upper}';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${region}_user_keymetric_df;