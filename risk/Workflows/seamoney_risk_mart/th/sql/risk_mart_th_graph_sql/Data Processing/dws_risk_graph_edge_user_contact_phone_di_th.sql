------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2023-12-06
-- Description:         Risk Graph需求， 边类型 contact_phone; ID数据量大，全量每天5T存储，单独一张表和存储，初始化后不再每天调度
-- Data Granularity:    
-- PRD:                 
-- Jira:                https://jira.shopee.io/browse/SPFDT-24909
------------------------------------------------------------------------


create or replace temporary function phone_number_parse as 'com.shopee.udf.PhoneNumberParse' using jar 'hdfs://${IDC_NAMESPACE}/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp' using jar 'hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar';

insert overwrite table risk.dws_risk_graph_edge_user_contact_phone_di partition(grass_region,edge_name,grass_date)
select  concat('userid/', userid) as platform_user_id
        ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
        ,concat('phone/', phone) as destination_node
        ,xxhash64(concat('phone/', phone)) as hash_destination_node
        ,cast(create_date as string) as create_date
        ,cast(last_date as string) as last_date
        ,to_json(
            named_struct(
                'userid',userid
                ,'phone',phone
                ,'name',name
            )
        ) as extend_info
        ,'${grass_region}' as grass_region
        ,'contact_phone' as edge_name
        ,'${grass_date}' as grass_date
from    (
    select  userid
            ,phone
            ,create_date
            ,create_date as last_date
            ,name
    from    (
        select  userid
                ,phone_number_parse(decode(account, 'utf-8'), '${grass_region}') as phone
                ,from_unixtime(report_time, 'yyyy-MM-dd') as create_date
                ,lower(trim(decode(name, 'utf-8'))) as name
        from marketplace.shopee_contact_${region}_db__contact_tab__reg_continuous_s0_live
        where   from_unixtime(report_time, 'yyyy-MM-dd') = '${grass_date}'
          and   acctype = 1
          and   report_time > 0
    )
    where   phone <> ''
)
;

