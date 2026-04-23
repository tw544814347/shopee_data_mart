--**************************************************************************
-- ** 所属主题: Risk
-- ** 功能描述: 交易退款分析
-- ** 创建者 : xiaobin
-- ** 创建日期: 20280829
-- ** 修改日志:
-- ** 修改日期 修改人 修改内容
-- 20280829 新增 weighted_nmv_spp 指标，核心逻辑（权重分配） weighted_nmv_spp = nmv_l1m * 0.5 + avg_nmv_l3m * 0.3 + avg_nmv_l6m * 0.2
-- Jira:https://jira.shopee.io/browse/SPFDT-54656
--**************************************************************************

-- drop table if exists ${SCHEMA}.dws_shop_${region}_weighted_nmv_spp_nd;
create external table if not exists ${SCHEMA}.dws_shop_${region}_weighted_nmv_spp_nd
(
 shop_id     bigint  comment 'shop id/merchart id'
,weighted_nmv_spp      decimal(30,10)  comment 'shop id/merchart id'
)
comment 'Tag:risk mart summary table'
partitioned by
(
    grass_date     string      comment 'data process time'   
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_shop_weighted_nmv_spp_nd/grass_region=${REGION}';



WITH merchant_base AS 
    (SELECT merchant_id
     FROM
        (SELECT merchant_id
        FROM shopeepay_risk.ads_risk_spp_merchant_transaction_user_onus_df__id
        WHERE grass_date = CAST(CURRENT_DATE - INTERVAL '1' DAY AS STRING)
            AND transaction_type_name IN ('Payment', 'Capture')
            AND is_success = 1
            AND merchant_scope_name = 'On_us Merchant'
        GROUP BY 1

        UNION ALL

        SELECT merchant_id
        FROM shopeepay_risk.ads_risk_spp_merchant_transaction_user_offus_df__id
        WHERE grass_date = CAST(CURRENT_DATE - INTERVAL '1' DAY AS STRING)
            AND is_success = 1
            AND point_of_initiation IN ('1', '2', '4')
            AND merchant_scope_name = 'On_us Merchant'
        GROUP BY 1
        )
    GROUP BY 1
    )

-- national_id : merchant_id -> 1 : n

,national_id_tab AS 
    (SELECT CAST(a.entity_id AS STRING) AS merchant_id
            ,(CASE WHEN (national_id IS NULL OR national_id = '') THEN 0 ELSE 1 END) AS has_valid_national_id
            ,COALESCE(national_id, '0') AS national_id
    FROM
        (SELECT entity_id
                ,customer_entity_id
         FROM merchantservice.mss_merchant_info_id_db__customer_entity_info_relation_tab__reg_daily_s0_live
         WHERE entity_type = 2
               -- 0:None 
               -- 1:ISV/group company partner 
               -- 2:merchant partner 
               -- 3:store 
               -- 4:staff
               AND relation_status = 1
               -- 1.Active 
               -- 2.Inactive 
               -- 3.Invalid
         GROUP BY 1, 2
        ) a
    LEFT JOIN 
        (SELECT id
                ,national_id
                ,info_status
         FROM merchantservice.mss_merchant_info_id_db__customer_entity_info_tab__reg_daily_s0_live
         WHERE info_status = 1
               -- 1.Active 
               -- 2.Inactive 
               -- 3.Invalid
         GROUP BY 1, 2, 3
        ) b 
    ON a.customer_entity_id = b.id
    INNER JOIN merchant_base c 
    ON CAST(a.entity_id AS STRING) = c.merchant_id
    )

-- platform_uid : credit_uid -> 1:1
,platform_uid_tab AS
    (SELECT platform_user_id
            ,credit_user_id
     FROM
        (SELECT platform_user_id
                ,credit_user_id
                ,ROW_NUMBER() OVER(PARTITION BY credit_user_id ORDER BY CAST(last_application_time AS timestamp) DESC) AS rank1
                ,ROW_NUMBER() OVER(PARTITION BY platform_user_id ORDER BY CAST(last_application_time AS timestamp) DESC) AS rank2
         FROM credit_uc.dws_all_prod_id_uc_user_df
         WHERE grass_date = CAST(CURRENT_DATE - INTERVAL '1' DAY AS STRING)
               AND has_valid_activated = 1
               AND has_activated = 1
        )
     WHERE rank2 = 1
           AND rank1 = 1
    )

,platform_id_tab AS
    (SELECT a.credit_user_id
            ,a.platform_user_id
            ,b.id_card_no
     FROM platform_uid_tab a
     INNER JOIN 
        (SELECT CAST(user_id AS STRING) AS credit_user_id
                ,id_card_no  -- id_card_no : credit_user_id -> 1 : n
                ,kyc_update_time
                ,ROW_NUMBER() OVER(PARTITION BY id_card_no ORDER BY kyc_update_time DESC) AS rank
        FROM credit_uc.dwd_uc_id_user_base_info_df
        WHERE grass_date = CAST(CURRENT_DATE - INTERVAL '1' DAY AS STRING)
              AND id_card_no IS NOT NULL  
        ) b
    ON a.credit_user_id = b.credit_user_id
    WHERE b.rank = 1  -- deduplicate so id_card_no : credit_user_id -> 1 : 1
    )


-- uinque key: merchant_id
-- platform_user_id/credit_user_id: has missing value and duplications (1 natural person can have multiple merchants)
,merchant_credit_tab AS
    (SELECT *
     FROM
        (SELECT a.merchant_id
               ,a.national_id
               ,(CASE WHEN b.platform_user_id IS NULL THEN 0 ELSE 1 END) AS has_matching_puid
               ,b.platform_user_id
               ,b.credit_user_id
         FROM national_id_tab a
         LEFT JOIN platform_id_tab b 
         ON a.national_id = b.id_card_no
         WHERE a.has_valid_national_id = 1
        )
     WHERE has_matching_puid = 1
    )

,all_onus_mer_tab AS(
    SELECT DATE(create_time) AS txn_date
            ,as_transaction_sn AS transaction_sn
            ,total_amount
            ,store_id -- 0 for most merchant_scope_name = 'Off_us Merchant'
            ,merchant_id -- null for most merchant_scope_name = 'Off_us Merchant'
    FROM shopeepay_risk.ads_risk_spp_merchant_transaction_user_onus_df__id
    WHERE grass_date = CAST(CURRENT_DATE - INTERVAL '1' DAY AS STRING)
        AND transaction_type_name IN ('Payment', 'Capture')
        AND date_format(create_time, 'yyyy-MM-dd') >= date_sub('${grass_date}', 180)
        AND is_success = 1
        AND merchant_scope_name = 'On_us Merchant'
    UNION ALL
    SELECT DATE(create_time) AS txn_date
            ,transaction_sn
            ,total_amount
            ,store_id
            ,merchant_id
    FROM shopeepay_risk.ads_risk_spp_merchant_transaction_user_offus_df__id
    WHERE grass_date = CAST(CURRENT_DATE - INTERVAL '1' DAY AS STRING)
        AND date_format(create_time, 'yyyy-MM-dd') >= date_sub('${grass_date}', 180)
        AND is_success = 1
        AND point_of_initiation IN ('1', '2', '4')
        AND merchant_scope_name = 'On_us Merchant'  
)


,nmv_tab AS (
    SELECT merchant_id
            ,nmv_l1m * 0.5 + avg_nmv_l3m * 0.3 + avg_nmv_l6m * 0.2 AS weighted_nmv_spp
    FROM (
        SELECT merchant_id
                ,coalesce(sum(case when txn_date >= date_sub('${grass_date}', 30) then total_amount  else 0 end)/1.0, 0) as nmv_l1m
                ,coalesce(sum(case when txn_date >= date_sub('${grass_date}', 90) then total_amount  else 0 end)/3.0, 0) as avg_nmv_l3m
                ,coalesce(sum(case when txn_date >= date_sub('${grass_date}', 180) then total_amount  else 0 end)/6.0, 0) as avg_nmv_l6m
        FROM all_onus_mer_tab
        GROUP BY 1
    )
)

,shop_id_tab AS
    (SELECT CAST(user_id AS STRING) AS platform_user_id
            ,shop_id
     FROM mp_user.dim_user__id_s0_live
     WHERE grass_region = 'ID'
       and grass_date = date('${grass_date}')
     GROUP BY 1,2
    )

,consolidate_tab AS
    (SELECT platform_user_id
            ,shop_id
            ,SUM(weighted_nmv_spp) AS weighted_nmv_spp
     FROM
        (SELECT a.merchant_id
                ,a.platform_user_id
                ,c.shop_id
                ,a.credit_user_id
                ,COALESCE(b.weighted_nmv_spp, 0) AS weighted_nmv_spp
         FROM merchant_credit_tab a
         LEFT JOIN nmv_tab b
         ON a.merchant_id = b.merchant_id
         LEFT JOIN shop_id_tab c
         ON a.platform_user_id = c.platform_user_id
        )
     GROUP BY 1,2
    )

-- 写入数据
insert overwrite ${SCHEMA}.dws_shop_${region}_weighted_nmv_spp_nd PARTITION (grass_date)
select
    cast(shop_id as bigint) as shop_id
    ,weighted_nmv_spp
    , '${grass_date}' as grass_date
from consolidate_tab
