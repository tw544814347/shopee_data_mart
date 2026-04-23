--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-08-22
-- Theme Domain：       anti-fraud
-- Description:         anti-fraud field shop tage, https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit#gid=400549880
-- Data Granularity:    shop_id
-- 变更历史：
--********************************************************************--
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


--drop table if exists ${SCHEMA}.dws_risk_id_shop_af_tag_df;

create external table if not exists ${SCHEMA}.dws_risk_id_shop_af_tag_df (
    shop_id 			string comment 'Shop ID'
    ,shop_risk_level 	string comment 'Shop Risk Level(Tag)'
    ,cnt_order_7d 		bigint comment 'Number of order in last 7days'
)
partitioned by (
    grass_date 			string comment 'yyyy-MM-dd',
    grass_region 		string comment 'ID'
)
stored as orc tblproperties ("orc.compress"="zstd") 
location  '${HDFS_PATH}/risk_mart/dws/dws_risk_shop_af_tag_df/grass_region=ID'
comment '
Tag:risk summary table
table description: record the graph info of the dpd user in anti-fraud field 
table source:
marketplace.shopee_account_v2_db__account_tab__reg_daily_s0_live
rescbds_credit.rescbds_credit_prod_id__user_graph_linkage_info
mp_order.dwd_order_all_ent_df__reg_s0_live
mp_user.dim_user__reg_s0_live 
';
--msck repair table ${SCHEMA}.dws_risk_id_shop_af_tag_df;
-- 有数
create or replace temporary view tmp_sl_10014_cnt_order_7d as (
    select  shop_id, -- big int
    		sum(1)	as cnt_order_7d
    from	mp_order.dwd_order_all_ent_df__reg_s0_live
    where	grass_region = 'ID'
    and   	grass_date >= current_date - interval  '8' day
	and   	grass_date <= current_date
    group by 
			shop_id
);

create or replace temporary view user_profile as (
	select	shop_id shopid
			,grass_region
	from 	mp_user.dim_shop__reg_s0_live
	where 	grass_region='ID'
  	and		grass_date = current_date - interval '1' day
);

-- 23B
create or replace temporary view tmp_order_mart__order_profile as (
    select	shop_id					as shopid
    		,seller_id 				as seller_userid
    		,gmv 					as total_price
    		,payment_method_id
    		,buyer_id 				as userid
    		,checkout_id 			as checkoutid
    		,create_datetime 		as event_time
    		,create_datetime 		as create_time
    		,date(create_datetime)	as grass_date
    		,grass_region
    from 	mp_order.dwd_order_all_ent_df__reg_s0_live
    where 	grass_region='ID'
    and 	tz_type='local'
    and 	grass_date >= (current_date - interval '6' month)
    and 	cast(from_unixtime(complete_timestamp) as date) <= current_date
    and 	order_fe_status='COMPLETED' -- Captial aware
);

-- 27K
create or replace temporary view tmp_cash_out_shop as (
	--edit user mart
	--DE table didn’t ingest to SG lumos right now, need waiting
	select	shopid
	from 	user_profile
	where 	grass_region='ID' 
    and shopid in	(
        select	cast(data as bigint)
 		--from credit.credit_risk_control_id_db__custom_list_tab
        from 	risk.dwd_risk_id_credit_custom_list_df 
 		where 	custom_list_name='cash_out_shopid'
		and		data_type='12'
        and 	grass_date = '${ds}'
		and		data not like '%-%-%'
	)
);

-- M
create or replace temporary view tmp_shop_feature_penetration_rate as (
    select	shopid 
			,seller_userid
	    	,case when GMV_3_month=0 then 0 else 1.000*credit_GMV_3month/GMV_3_month end as credit_GMV_3month_penetration_rate
			,case when Usr_3_month=0 then 0 else 1.000*credit_Usr_3month/Usr_3_month end as credit_Usr_3month_penetration_rate
	from (--change order mart
		select	a.shopid
				,a.seller_userid
				,coalesce(sum(total_price),0) 																	as GMV_3_month
				,coalesce(sum(case when payment_method_id in (14,21,24,15,19) then total_price end),0)			as credit_GMV_3month
				,coalesce(count(distinct userid),0) 															as Usr_3_month
				,coalesce(count(distinct case when payment_method_id in (14,21,24,15,19) then userid end),0)	as credit_Usr_3month
		from 	tmp_order_mart__order_profile a
        where 	grass_region='ID'
		and 	grass_date>=current_date - interval '3' month
		and 	grass_date<=current_date
        group by 
				a.shopid, a.seller_userid
    ) a
);

create or replace temporary view tmp_shop_level as (
    select	tmp_shop_feature_penetration_rate.shopid
			,tmp_shop_feature_penetration_rate.seller_userid		as seller_userid
			,case 	when tmp_cash_out_shop.shopid is not null and (credit_GMV_3month_penetration_rate>0.5 or credit_Usr_3month_penetration_rate>0.5) then 'L3'
    				when tmp_cash_out_shop.shopid is not null then 'L2'
					when (credit_GMV_3month_penetration_rate>0.5 or credit_Usr_3month_penetration_rate>0.5) then 'L1'
    				end 											as risk_level
	from 	tmp_shop_feature_penetration_rate
	left join 
			tmp_cash_out_shop 
    on 		tmp_shop_feature_penetration_rate.shopid=tmp_cash_out_shop.shopid
	where 	tmp_cash_out_shop.shopid is not null
	or 		credit_GMV_3month_penetration_rate>0.5
	or 		credit_Usr_3month_penetration_rate>0.5
);

create or replace temporary view tmp as (
    select	cast (shopid as bigint)	as shop_id 
    		,risk_level 			as shop_risk_level
    from 	tmp_shop_level
);

insert overwrite table
    ${SCHEMA}.dws_risk_id_shop_af_tag_df partition (grass_date = '${ds}', grass_region = 'ID')
select
    cast(t1.shop_id as string) as shop_id
    ,t3.shop_risk_level
    ,t2.cnt_order_7d
from
    (
        select
            shop_id
        from mp_user.dim_shop__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = 'ID'
            and grass_date = date '${ds}'
    ) t1
    left join tmp_sl_10014_cnt_order_7d as t2 on t1.shop_id = t2.shop_id
    left join tmp as t3 on t1.shop_id = t3.shop_id
;

