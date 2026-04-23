-- drop table if exists ${SCHEMA}.ads_risk_th_sfood_seller_merchant_info_df;
create table if not exists ${SCHEMA}.ads_risk_th_sfood_seller_merchant_info_df
(
    national_id string
    ,food_avg_active_months decimal(30,10)
    ,food_has_on_us bigint
    ,food_has_individual_merchant bigint
    ,food_is_enable_wallet decimal(30,10)
    ,food_has_whitelist bigint
    ,food_has_blacklist bigint
    ,food_has_spl_sus bigint
    ,food_has_spl_whitelist bigint
)
partitioned by
(
    grass_date string comment 'yyyy-MM-dd'
)
comment 'tag: risk feature summary table'
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/ads/ads_risk_th_sfood_seller_merchant_info_df';
-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_th_sfood_seller_merchant_info_df;

-- *********************************************** 1. User Merchant Mapping ***********************************************  
with user_merchant_map_tab as (
    select national_id
        ,cast(merchant_id as bigint) as merchant_id
    from (
        select national_id, split(merchant_id_list, ', ') as merchant_id_list
        from ${SCHEMA}.ads_risk_th_sfood_seller_info_df
        where grass_date = '${ds}'
    )
    lateral view explode(merchant_id_list) t as merchant_id
)

-- *********************************************** 2. Merchant base ***********************************************  
--已修改 合并view
,prelim_tag_tab as (
	select a.merchant_id
		,a.merchant_register_time
		,max(case when b.by_pass_shopeepay = 1 then 1 else 0 end) as is_whitelist_1  -- 是否在白名单中（by_pass_shopeepay=1表示白名单）
		,max(case when b.merchant_scope = 1 then 1 else 0 end) as is_on_us_1  -- 是否为On-us商户（merchant_scope=1表示On-us）
		,max(case when c.is_using_wallet = 1 then 1 else 0 end) as is_enable_wallet  -- 是否启用钱包（is_using_wallet=1表示启用）
	from (
		select merchant_id, date(from_unixtime(register_time/1000)) as merchant_register_time  -- 注册时间（register_time单位是毫秒，需要除以1000）
		from shopeefood.shopeefood_mart_cdm_dim_th_merchant_merchant_da 
		where date(dt) = current_date - interval '1' day
	) a
		left join merchantservice.mss_merchant_info_th_db__partner_shopeepay_config_tab__reg_daily_s0_live b
			on a.merchant_id = b.partner_id  -- 关联ShopeePay配置表
		left join merchantservice.mss_merchant_info_th_db__settlement_config_tab__reg_daily_s0_live c
			on a.merchant_id = c.entity_id  -- 关联结算配置表
    group by a.merchant_id, a.merchant_register_time
)

-- *********************************************** 3. Aggregate ***********************************************  
--已修改 合并view，使用子查询
,merchant_agg_tab as (
	select a.merchant_id
		,a.merchant_register_time
        ,case when (a.is_on_us_1 = 1 or b.is_on_us_2 = 1) then 1 else 0 end as is_on_us  -- On-us状态（任一来源为1则为1）
        ,case when (c.tag_merchant_type_tag = 'Individual' or c.tag_merchant_type_tag is null) then 1 else 0 end as is_individual  -- 是否为个人商户（Individual或null则为1）
		,a.is_enable_wallet  -- 钱包启用状态
		,case when (a.is_whitelist_1 = 1 or d.manager_merchant_id is not null) then 1 else 0 end as is_whitelist  -- 白名单状态（任一来源为1则为1）
		,case when e.manager_merchant_id is not null then 1 else 0 end as is_blacklist  -- 黑名单状态
		,case when f.merchant_id is not null then 1 else 0 end as is_spl_sus  -- SPL可疑状态
		,case when g.merchant_id is not null then 1 else 0 end as is_spl_whitelist  -- SPL白名单状态
	from prelim_tag_tab a
		left join (
			-- MCL检查1：从订单收单表检查商户是否为On-us商户
			select  a.merchant_id
					,max(case when a.merchant_scope_name = 'On_us Merchant' then 1 else 0 end) as is_on_us_2  -- On-us状态标记
			from shopeepay.mart_dwd_wide_merchant_order_acquiring_all_ent_df__th a
			inner join (
				select merchant_id
				from shopeefood.shopeefood_mart_cdm_dim_th_merchant_merchant_da 
				where date(dt) = current_date - interval '1' day
			) mb on a.merchant_id = mb.merchant_id  -- 已修改 使用inner join
			group by a.merchant_id
		) b on a.merchant_id = b.merchant_id
		left join (
			-- MSS检查1：商户类型检查
			select a.entity_id as merchant_id
				,case when customer_entity_type is null then null  -- 0:None, 1:Individual, 2:Corporate, 3:CV_foundations_firm, 4:Business
					when customer_entity_type = 1 then 'Individual'  -- 个人商户
					when customer_entity_type = 4 then 'Business'  -- 企业商户
					else 'Others'  -- 其他类型
				end as tag_merchant_type_tag
			from (
				select entity_id, customer_entity_id
				from merchantservice.mss_merchant_info_th_db__customer_entity_info_relation_tab__reg_daily_s0_live 
				where entity_type = 2 and relation_status = 1  -- entity_type=2表示商户，relation_status=1表示有效关联
			) a left join (
				select id, customer_entity_type 
				from merchantservice.mss_merchant_info_th_db__customer_entity_info_tab__reg_daily_s0_live 
				where info_status = 1  -- 信息状态有效
			) b on a.customer_entity_id = b.id 
		) c on a.merchant_id = c.merchant_id 
		left join (
			-- MSS检查3：商户白名单检查
			select cast(data as bigint) as manager_merchant_id
			from risk.dwd_risk_th_credit_custom_list_df
			where date(grass_date) = current_date - interval '1' day
				and custom_list_name = 'offline_merchant_whitelist_merchant_level'  -- 线下商户白名单（商户级别）
				and status = '1'  -- 状态有效
				and data_type = '12'  -- 数据类型：12=商户
		) d on a.merchant_id = d.manager_merchant_id
		left join (
			-- MSS检查2：商户黑名单检查
			select cast(data as bigint) as manager_merchant_id
			from risk.dwd_risk_th_credit_custom_list_df
			where date(grass_date) = current_date - interval '1' day
				and custom_list_name = 'merchant_level_blacklist'  -- 商户级别黑名单
				and status = '1'  -- 状态有效
				and data_type = '12'  -- 数据类型：12=商户
		) e on a.merchant_id = e.manager_merchant_id
		left join (
			-- MCL检查3：SPL可疑商户检查
			select merchant_id 
			from smcdrisk_antifraud.spp_p2m_spl_merch_feature_merchtag_storeid_id_tmp
			where is_spp_store_block = 1   -- SPP店铺被阻止（可疑）
			group by merchant_id
		) f on a.merchant_id = f.merchant_id
		left join (
			-- MCL检查2：SPL白名单检查
			select merchant_id 
			from smcdrisk_antifraud.spp_p2m_spl_merch_feature_merchtag_storeid_id_tmp 
			where is_spp_store_white = 1   -- SPP店铺白名单
				or is_spp_al_store_white = 1   -- SPP AL店铺白名单
				or is_food_store_white = 1   -- Food店铺白名单
				or is_mitra_store_white = 1   -- Mitra店铺白名单
				or is_hpl_store_white = 1   -- HPL店铺白名单
		) g on a.merchant_id = g.merchant_id
)

insert overwrite table ${SCHEMA}.ads_risk_th_sfood_seller_merchant_info_df partition (grass_date = '${ds}')
select a.national_id
	,avg(months_between(current_date, b.merchant_register_time)) as food_avg_active_months  -- 平均活跃月数（从注册到现在的月数）
	,max(coalesce(b.is_on_us, 0)) as food_has_on_us  -- 是否有On-us商户（如果任意一个商户为On-us则为1）
	,max(coalesce(b.is_individual, 0)) as food_has_individual_merchant  -- 是否有个人商户（如果任意一个商户为个人则为1）
	,avg(coalesce(b.is_enable_wallet, 0)) as food_is_enable_wallet  -- 钱包启用比例（0-1之间，表示启用钱包的商户占比）
	,max(coalesce(b.is_whitelist, 0)) as food_has_whitelist  -- 是否有白名单商户（如果任意一个商户在白名单则为1）
	,max(coalesce(b.is_blacklist, 0)) as food_has_blacklist  -- 是否有黑名单商户（如果任意一个商户在黑名单则为1）
	,max(coalesce(b.is_spl_sus, 0)) as food_has_spl_sus  -- 是否有SPL可疑商户（如果任意一个商户为SPL可疑则为1）
	,max(coalesce(b.is_spl_whitelist, 0)) as food_has_spl_whitelist  -- 是否有SPL白名单商户（如果任意一个商户在SPL白名单则为1）
from user_merchant_map_tab a
	left join merchant_agg_tab b
		on a.merchant_id = b.merchant_id
group by a.national_id
;
