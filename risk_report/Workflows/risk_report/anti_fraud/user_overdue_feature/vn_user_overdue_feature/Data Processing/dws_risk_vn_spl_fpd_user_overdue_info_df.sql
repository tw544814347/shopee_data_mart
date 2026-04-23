--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_fpd_user_overdue_info_df (
    credit_user_id                        STRING        COMMENT 'credit_user_id',
    platform_user_id                      STRING        COMMENT 'platform_user_id',
    reactivate_date                       STRING        COMMENT 'reactivate_date ',
    fpd_month_bill_date                   STRING        COMMENT 'fpd bill date',
    fpd_overdue_amt                       DECIMAL(20,10) COMMENT 'first bill overdue amount',
    fpd_measurable_days                   BIGINT        COMMENT 'number of days passed due day of the user first bill',
    fpd_3term_measurable_days             BIGINT        COMMENT 'days after the third bills due date',
    fpd_max_dpd_eod                       BIGINT        COMMENT 'first bill max overdue days eod',
    fpd_max_dpd                           BIGINT        COMMENT 'first bill max overdue days',
    fpd_3term_max_dpd_eod                 BIGINT        COMMENT 'first three bills historical max overdue days eod',
    fpd_3term_max_dpd                     BIGINT        COMMENT 'first three bills historical max overdue days',

    fpd_overdue_amt_after_react           DECIMAL(20,10) COMMENT 'first bill overdue amount (after react/recredit)',
    fpd_measurable_days_after_react       BIGINT        COMMENT 'number of days passed due day of the user first bill (after react/recredit)',
    fpd_3term_measurable_days_after_react BIGINT        COMMENT 'days after the third bills due date (after react/recredit)',
    fpd_max_dpd_eod_after_react           BIGINT        COMMENT 'first bill max overdue days eod (after react/recredit)',
    fpd_max_dpd_after_react               BIGINT        COMMENT 'first bill max overdue days (after react/recredit)',
    fpd_3term_max_dpd_eod_after_react     BIGINT        COMMENT 'first three bills historical max overdue days eod (after react/recredit)',
    fpd_3term_max_dpd_after_react         BIGINT        COMMENT 'first three bills historical max overdue days (after react/recredit)'
)
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/dws/dws_risk_${reg}_aio_fpd_user_overdue_info_df/product_id = ${biz_type_code}'
;

CREATE OR REPLACE TEMP VIEW bill as (
    select 
        base.credit_user_id,
        base.platform_user_id,
        base.biz_type,
        base.bill_id,
        base.bill_term,
        base.max_dpd_eod,
        base.max_dpd,
        base.dpd_eod,
        base.dpd,
        base.principal_repayable,
        to_date(base.month_due_time) as month_due_date,
        datediff(to_date('${ds_t_0}'), to_date(month_due_time)) as days_from_today,
        dense_rank() over(partition by base.credit_user_id, base.platform_user_id order by base.bill_term asc) as bill_rk,
        max_reactivate_date,
        to_date(base.month_bill_time) as month_bill_date
    from (
        select 
            credit_user_id,
            platform_user_id,
            biz_type,
            bill_id,
            bill_term,
            max_dpd_eod,
            max_dpd,
            dpd_eod,
            dpd,
            principal_repayable,
            month_due_time,
            month_bill_time
        from credit_mart.dws_${biz_type_string}_aio_${reg}_instalment_repayment_df 
        where grass_date = '${ds}' and platform_type = 1
            and bill_term is not null 
            and biz_type in (${biz_type_code}) 
            and ${spl_control_condition}
            and (
            case when '${risk_tab_biz_type}' = 'spl' then product_id = 3
              when '${risk_tab_biz_type}' = 'chp' then product_id = 3
              when '${risk_tab_biz_type}' = 'bcl' then product_id = 1
              when '${risk_tab_biz_type}' = 'tl' then product_id = 11
              else false end) 
    ) as base
    left join (
        select 
            credit_user_id,
            platform_user_id,
            biz_type,
            max(greatest(to_date(activate_time), to_date(recredit_time))) as max_reactivate_date
        from credit_mart.dwd_${biz_type_string}_aio_${reg}_account_df
        where grass_date = '${ds}' and platform_type = 1
            and biz_type in (${biz_type_code}) 
            and ${spl_control_condition}
            and (
            case when '${risk_tab_biz_type}' = 'spl' then product_id = 3
              when '${risk_tab_biz_type}' = 'chp' then product_id = 3
              when '${risk_tab_biz_type}' = 'bcl' then product_id = 1
              when '${risk_tab_biz_type}' = 'tl' then product_id = 11
              else false end) 
        group by credit_user_id, platform_user_id, biz_type
    ) react_tab
    on base.credit_user_id = react_tab.credit_user_id 
        and base.biz_type = react_tab.biz_type
        and base.platform_user_id = react_tab.platform_user_id 
);
Cache table bill;
CREATE OR REPLACE TEMP VIEW bill_after_react as (
    select 
        credit_user_id,
        platform_user_id,
        biz_type,
        bill_id,
        bill_term,
        max_dpd_eod,
        max_dpd,
        dpd_eod,
        dpd,
        principal_repayable,
        month_due_date,
        days_from_today,
        bill_rk,
        max_reactivate_date,
        month_bill_date,
        dense_rank() over(partition by base.credit_user_id, base.platform_user_id order by base.bill_term asc) as bill_rk_after_react
    from bill as base
    where month_bill_date > base.max_reactivate_date
);
Cache table bill_after_react;
CREATE OR REPLACE TEMP VIEW instalment as (
    select 
        base.credit_user_id,
        base.platform_user_id,
        base.bill_id,
        base.bill_term,
        base.instalment_id,
        base.floating_nxb as instalment_term,
        base.biz_type,
        base.principal_repayable,
        base.max_dpd_eod,
        base.max_dpd,
        base.dpd_eod,
        base.dpd,
        datediff(to_date('${ds_t_0}'), to_date(base.month_due_time)) as days_from_today,
        dense_rank() over(partition by base.credit_user_id, base.platform_user_id order by base.floating_nxb asc) as bill_rk,
        max_reactivate_date,
        to_date(base.month_bill_time) as month_bill_date
    from (
        select 
            credit_user_id,
            platform_user_id,
            bill_id,
            bill_term,
            instalment_id,
            datediff(grass_date, to_date(month_due_time)),
            case
                when -datediff(grass_date, to_date(month_due_time)) >= -1 then -1
                when to_date(month_due_time) < grass_date then -ceil(datediff(grass_date, to_date(month_due_time)) / 30)
                else null
            end as floating_nxb,
            to_date(month_due_time) as month_due_date,
            month_due_time,
            max_dpd_eod,
            max_dpd,
            dpd_eod,
            dpd,
            biz_type,
            principal_repayable,
            month_bill_time
        from credit_mart.dws_${biz_type_string}_aio_${reg}_instalment_repayment_df
        where grass_date = '${ds}' and platform_type = 1
            and biz_type in (${biz_type_code}) 
            and ${bcl_control_condition}
            and (
            case when '${risk_tab_biz_type}' = 'spl' then product_id = 3
              when '${risk_tab_biz_type}' = 'chp' then product_id = 3
              when '${risk_tab_biz_type}' = 'bcl' then product_id = 1
              when '${risk_tab_biz_type}' = 'tl' then product_id = 11
              else false end) 
    ) as base
    left join (
        select 
            credit_user_id,
            platform_user_id,
            biz_type,
            max(greatest(to_date(activate_time), to_date(recredit_time))) as max_reactivate_date
        from credit_mart.dwd_${biz_type_string}_aio_${reg}_account_df
        where grass_date = '${ds}' and platform_type = 1
            and biz_type in (${biz_type_code}) 
            and ${bcl_control_condition}
            and (
            case when '${risk_tab_biz_type}' = 'spl' then product_id = 3
              when '${risk_tab_biz_type}' = 'chp' then product_id = 3
              when '${risk_tab_biz_type}' = 'bcl' then product_id = 1
              when '${risk_tab_biz_type}' = 'tl' then product_id = 11
              else false end)  
        group by credit_user_id, platform_user_id, biz_type
    ) react_tab
    on base.credit_user_id = react_tab.credit_user_id 
        and base.biz_type = react_tab.biz_type
        and base.platform_user_id = react_tab.platform_user_id
);
Cache table instalment;
CREATE OR REPLACE TEMP VIEW instalment_after_react as (
    select 
        credit_user_id,
        platform_user_id,
        bill_id,
        bill_term,
        instalment_id,
        instalment_term,
        biz_type,
        principal_repayable,
        max_dpd_eod,
        max_dpd,
        dpd_eod,
        dpd,
        days_from_today,
        bill_rk,
        max_reactivate_date,
        month_bill_date,
        dense_rank() over(partition by base.credit_user_id, base.platform_user_id order by base.bill_term asc) as bill_rk_after_react
    from instalment as base
    where month_bill_date > base.max_reactivate_date
);
Cache table instalment_after_react;

insert overwrite table ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_fpd_user_overdue_info_df partition(grass_date = '${ds}')
SELECT 
    tab1.credit_user_id                                                AS credit_user_id,
    tab1.platform_user_id                                              AS platform_user_id,

    tab1.max_reactivate_date                                           AS reactivate_date,
    tab1.first1_month_bill_date                                        AS fpd_month_bill_date,
    tab1.first1_overdue_amt                                            AS fpd_overdue_amt,
    tab1.first1_max_days_from_today                                    AS fpd_measurable_days,
    tab1.first3_max_days_from_today                                    AS fpd_3term_measurable_days,
    tab1.first1_max_dpd_eod                                            AS fpd_max_dpd_eod,
    tab1.first1_max_dpd                                                AS fpd_max_dpd,
    tab1.first3_max_dpd_eod                                            AS fpd_3term_max_dpd_eod,
    tab1.first3_max_dpd                                                AS fpd_3term_max_dpd,

    tab2.first1_overdue_amt_after_react               AS fpd_overdue_amt_after_react,
    tab2.first1_max_days_from_today_after_react       AS fpd_measurable_days_after_react,
    tab2.first3_max_days_from_today_after_react       AS fpd_3term_measurable_days_after_react,
    tab2.first1_max_dpd_eod_after_react               AS fpd_max_dpd_eod_after_react,
    tab2.first1_max_dpd_after_react                   AS fpd_max_dpd_after_react,
    tab2.first3_max_dpd_eod_after_react               AS fpd_3term_max_dpd_eod_after_react,
    tab2.first3_max_dpd_after_react                   AS fpd_3term_max_dpd_after_react

from 
(
    select 
        credit_user_id, biz_type, max_reactivate_date, platform_user_id,
        coalesce(max(if(bill_rk = 1, month_bill_date, '9999-12-31')),'9999-12-31') as first1_month_bill_date,
        coalesce(sum(if(bill_rk = 1, principal_repayable,0)),0) as first1_overdue_amt,
        coalesce(max(if(bill_rk = 1, days_from_today+1,-9999)),-9999) as first1_max_days_from_today,
        coalesce(max(if(bill_rk = 3, days_from_today+1,-9999)),-9999) as first3_max_days_from_today,
        coalesce(max(if(bill_rk = 1, max_dpd_eod,-9999)),-9999) as first1_max_dpd_eod,
        coalesce(max(if(bill_rk = 1, max_dpd,-9999)),-9999) as first1_max_dpd,
        coalesce(max(if(bill_rk <= 3, max_dpd_eod,-9999)),-9999) as first3_max_dpd_eod,
        coalesce(max(if(bill_rk <= 3, max_dpd,-9999)),-9999) as first3_max_dpd
    from ${bill_instalment_type} 
    where bill_rk <= 3
    group by credit_user_id, biz_type, max_reactivate_date, platform_user_id
) as tab1
left join 
(
    select 
        credit_user_id, biz_type, max_reactivate_date, platform_user_id, 
        coalesce(sum(if(bill_rk_after_react = 1, principal_repayable,0)),0) as first1_overdue_amt_after_react,
        coalesce(max(if(bill_rk_after_react = 1, days_from_today+1,-9999)),-9999) as first1_max_days_from_today_after_react,
        coalesce(max(if(bill_rk_after_react = 3, days_from_today+1,-9999)),-9999) as first3_max_days_from_today_after_react,
        coalesce(max(if(bill_rk_after_react = 1, max_dpd_eod,-9999)),-9999) as first1_max_dpd_eod_after_react,
        coalesce(max(if(bill_rk_after_react = 1, max_dpd,-9999)),-9999) as first1_max_dpd_after_react,
        coalesce(max(if(bill_rk_after_react <= 3, max_dpd_eod,-9999)),-9999) as first3_max_dpd_eod_after_react,
        coalesce(max(if(bill_rk_after_react <= 3, max_dpd,-9999)),-9999) as first3_max_dpd_after_react
    from ${bill_instalment_type}_after_react
    where bill_rk_after_react <= 3
    group by credit_user_id, biz_type, max_reactivate_date, platform_user_id
) as tab2
on tab1.credit_user_id = tab2.credit_user_id and tab1.biz_type = tab2.biz_type and tab1.platform_user_id = tab2.platform_user_id
;
