-- prd https://docs.google.com/document/d/14lANlkmDV0H1eyjVMOXbg10QEuxQENNBFK5IqWcPDQo/edit
-- 对于一个user id，shopee df/szdf 视为credit 非新设备，若：
-- 1> 该shopee df/szdf 在过去180天内在特定产品、特定场景里激活或交易/提现成功过 （PH 市场下，该阈值为360天）
-- 2> 重新激活的请求不含在内
-- ** 特定产品、场景：
-- SPL: DP 支付(10024)、MP 支付(10034)、CsB 支付(10044)、BsC 支付(10054)、激活(10013)  {region}_live_credit_risk_gateway_req_rsp_spjup
-- BCL: 激活(10013)、提现(10026)  {region}_live_credit_risk_gateway_req_rsp_spj' 
-- SCL: 激活(10003)、提现(10004)  {region}_live_credit_risk_gateway_req_rsp_spjup 

--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-10-01
-- Theme Domain：       反欺诈
-- Description:         user_id 在近180&360天中的login设备list
-- Data Granularity:    platform_user_id
-- 变更历史：
--      update by xiaobin.qiu@shopee.com， 增加注释，切换risk.dwd_br_af_risk_screen_df Mart表
--      update by: zongyi.lu,2023-10-30
--                           update content: (https://jira.shopee.io/browse/SPFDT-23834)
--                           1.workflow 表的grass date – 可以和下面的create time 的限制一致
--                           2.最后join 的时候需要限制CAST(FROM_UNIXTIME(req_time) AS DATE) > current_date - interval '181'  day （PH 是366天）
--                           3.final result 处将device_fingerprint 的筛选逻辑去掉
--       update by: zongyi.lu,2023-12-11
--                             jira: https://jira.shopee.io/browse/SPFDT-27638
--                             1.最后生成spdf_list和szdf_list时,要分别过滤掉空设备（备注:SPFDT-23834的final_result过滤逻辑是为了防止过滤掉spdf为空szdf不为空的数据）case: [1988304b89e4a9ef_33f5bda80704,] 这种情况就改成 [1988304b89e4a9ef_33f5bda80704]
--                             2.user_base改成用全量用户表mp_user.dim_user__reg_s0_live -- 没有df的user_id, spdf & szdf 改成 null
--                             3.空值设成%null%而不是[]
--      update by: chengguo.liu 2025-06-23  新增SG地区逻辑: https://jira.shopee.io/browse/SPFDT-52960
--********************************************************************--


add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


create or replace temporary view tmp_risk_strategy_final_result as
select 
    a.flow_no
    ,a.platform_user_id
    ,a.device_fingerprint
    ,a.req_time
    ,format_time(a.req_time,'ID') as req_time_local
    ,a.workflow_flow_no
    ,a.topic_name
    ,a.risk_scene_id
    ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf
    ,get_json_object(extension, '$.is_spl_activated')                                     as is_spl_activated
    ,get_json_object(extension, '$.is_cashloan_activated')                                as is_cashloan_activated
    ,'ID'                                                                                 as grass_region
from risk.dwd_risk_id_strategy_final_result_merge_di a 
join (
    select 
        topic_name
        ,scene_id
    from risk.dim_risk_af_pharse_topic 
    where grass_region = 'ID'
    and tn_type='live'
    and is_fs_topic='1'
    group by 
        topic_name
        ,scene_id
)b on a.topic_name = b.topic_name and a.risk_scene_id = b.scene_id
where grass_date>=date_sub('${grass_date}',190)
and grass_date<='${grass_date}'
and a.topic_name in('id_live_credit_risk_gateway_req_rsp_kredit'
,'id_live_credit_risk_gateway_req_rsp_spj'
,'id_live_credit_risk_gateway_req_rsp_spjup')
and a.risk_scene_id in(
10013,10024,10034,10044,10054,10026,10003,10004
)
-- and device_fingerprint is not null
-- and device_fingerprint <>''
-- and device_fingerprint <>' '
group by a.flow_no
        ,a.platform_user_id
        ,a.device_fingerprint
        ,a.req_time
        ,format_time(a.req_time,'ID')
        ,a.workflow_flow_no
        ,a.topic_name
        ,a.risk_scene_id
        ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id')
        ,get_json_object(extension, '$.is_spl_activated')
        ,get_json_object(extension, '$.is_cashloan_activated')

union all 

-- MY地区
select 
    a.flow_no
    ,a.platform_user_id
    ,a.device_fingerprint
    ,a.req_time
    ,format_time(a.req_time,'MY') as req_time_local
    ,a.workflow_flow_no
    ,a.topic_name
    ,a.risk_scene_id
    ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf
    ,get_json_object(extension, '$.is_spl_activated')                                     as is_spl_activated
    ,get_json_object(extension, '$.is_cashloan_activated')                                as is_cashloan_activated
    ,'MY'                                                                                 as grass_region
from risk.dwd_risk_my_strategy_final_result_merge_di a 
join (
    select 
        topic_name
        ,scene_id
    from risk.dim_risk_af_pharse_topic 
    where grass_region = 'MY'
    and tn_type='live'
    and is_fs_topic='1'
    group by 
        topic_name
        ,scene_id
)b on a.topic_name = b.topic_name and a.risk_scene_id = b.scene_id 
where grass_date>=date_sub('${grass_date}',190)
and grass_date<='${grass_date}'
group by a.flow_no
        ,a.platform_user_id
        ,a.device_fingerprint
        ,a.req_time
        ,format_time(a.req_time,'MY')
        ,a.workflow_flow_no
        ,a.topic_name
        ,a.risk_scene_id
        ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id')
        ,get_json_object(extension, '$.is_spl_activated')
        ,get_json_object(extension, '$.is_cashloan_activated')

-- SG地区
union all
select 
    a.flow_no
    ,a.platform_user_id
    ,a.device_fingerprint
    ,a.req_time
    ,format_time(a.req_time,'SG') as req_time_local
    ,a.workflow_flow_no
    ,a.topic_name
    ,a.risk_scene_id
    ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf
    ,get_json_object(extension, '$.is_spl_activated')                                     as is_spl_activated
    ,get_json_object(extension, '$.is_cashloan_activated')                                as is_cashloan_activated
    ,'SG'                                                                                 as grass_region
from risk.dwd_risk_sg_strategy_final_result_merge_di a 
join (
    select 
        topic_name
        ,scene_id
    from risk.dim_risk_af_pharse_topic 
    where grass_region = 'SG'
    and tn_type='live'
    and is_fs_topic='1'
    group by 
        topic_name
        ,scene_id
)b on a.topic_name = b.topic_name and a.risk_scene_id = b.scene_id 
where grass_date>=date_sub('${grass_date}',190)
and grass_date<='${grass_date}'
group by a.flow_no
        ,a.platform_user_id
        ,a.device_fingerprint
        ,a.req_time
        ,format_time(a.req_time,'SG')
        ,a.workflow_flow_no
        ,a.topic_name
        ,a.risk_scene_id
        ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id')
        ,get_json_object(extension, '$.is_spl_activated')
        ,get_json_object(extension, '$.is_cashloan_activated')

-- VN地区
union all 
    select 
    a.flow_no
    ,a.platform_user_id
    ,a.device_fingerprint
    ,a.req_time
    ,format_time(a.req_time,'VN') as req_time_local
    ,a.workflow_flow_no
    ,a.topic_name
    ,a.risk_scene_id
    ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf
    ,get_json_object(extension, '$.is_spl_activated')                                     as is_spl_activated
    ,get_json_object(extension, '$.is_cashloan_activated')                                as is_cashloan_activated
    ,'VN'                                                                                 as grass_region
from risk.dwd_risk_vn_strategy_final_result_merge_di a 
join (
    select 
        topic_name
        ,scene_id
    from risk.dim_risk_af_pharse_topic 
    where grass_region = 'VN'
    and tn_type='live'
    and is_fs_topic='1'
    group by 
        topic_name
        ,scene_id
)b on a.topic_name = b.topic_name and a.risk_scene_id = b.scene_id 
where grass_date>=date_sub('${grass_date}',190)
and grass_date<='${grass_date}'
-- and device_fingerprint is not null
-- and device_fingerprint <>''
-- and device_fingerprint <>' '
group by a.flow_no
        ,a.platform_user_id
        ,a.device_fingerprint
        ,a.req_time
        ,format_time(a.req_time,'VN')
        ,a.workflow_flow_no
        ,a.topic_name
        ,a.risk_scene_id
        ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id')
        ,get_json_object(extension, '$.is_spl_activated')
        ,get_json_object(extension, '$.is_cashloan_activated')

union all 

-- PH地区
select 
    a.flow_no
    ,a.platform_user_id
    ,a.device_fingerprint
    ,a.req_time
    ,format_time(a.req_time,'PH') as req_time_local
    ,a.workflow_flow_no
    ,a.topic_name
    ,a.risk_scene_id
    ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf
    ,get_json_object(extension, '$.is_spl_activated')                                     as is_spl_activated
    ,get_json_object(extension, '$.is_cashloan_activated')                                as is_cashloan_activated
    ,'PH'                                                                                 as grass_region
from risk.dwd_risk_ph_strategy_final_result_merge_di a 
join (
    select 
        topic_name
        ,scene_id
    from risk.dim_risk_af_pharse_topic 
    where grass_region = 'PH'
    and tn_type='live'
    and is_fs_topic='1'
    group by 
        topic_name
        ,scene_id
)b on a.topic_name = b.topic_name and a.risk_scene_id = b.scene_id 
where grass_date>=cast(date_sub('${grass_date}',370) as string)
and grass_date<='${grass_date}'
-- and device_fingerprint is not null
-- and device_fingerprint <>''
-- and device_fingerprint <>' '
group by a.flow_no
        ,a.platform_user_id
        ,a.device_fingerprint
        ,a.req_time
        ,format_time(a.req_time,'PH')
        ,a.workflow_flow_no
        ,a.topic_name
        ,a.risk_scene_id
        ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id')
        ,get_json_object(extension, '$.is_spl_activated')
        ,get_json_object(extension, '$.is_cashloan_activated')

union all 

-- TH地区
select 
    a.flow_no
    ,a.platform_user_id
    ,a.device_fingerprint
    ,a.req_time
    ,format_time(a.req_time,'TH') as req_time_local
    ,a.workflow_flow_no
    ,a.topic_name
    ,a.risk_scene_id
    ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf
    ,get_json_object(extension, '$.is_spl_activated')                                     as is_spl_activated
    ,get_json_object(extension, '$.is_cashloan_activated')                                as is_cashloan_activated
    ,'TH'                                                                                 as grass_region
from risk.dwd_risk_th_strategy_final_result_merge_di a 
join (
    select 
        topic_name
        ,scene_id
    from risk.dim_risk_af_pharse_topic 
    where grass_region = 'TH'
    and tn_type='live'
    and is_fs_topic='1'
    group by 
    topic_name
    ,scene_id
)b on a.topic_name = b.topic_name and a.risk_scene_id = b.scene_id 
where grass_date>=date_sub('${grass_date}',190)
and grass_date<='${grass_date}'
-- and device_fingerprint is not null
-- and device_fingerprint <>''
-- and device_fingerprint <>' '
group by a.flow_no
        ,a.platform_user_id
        ,a.device_fingerprint
        ,a.req_time
        ,format_time(a.req_time,'TH')
        ,a.workflow_flow_no
        ,a.topic_name
        ,a.risk_scene_id
        ,get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id')
        ,get_json_object(extension, '$.is_spl_activated')
        ,get_json_object(extension, '$.is_cashloan_activated')
;

create or replace temporary view tmp_workflow_tab as

-- ID 地区
select 
    flow_no
    ,'ID' as grass_region
from  risk.dwd_risk_id_af_credit_workflow_di
where grass_date >= date_sub('${grass_date}',190)
and run_step <>''
and run_step like '%pass%' -- so final result also passed or verify passed
group by flow_no

union all 
-- MY 地区
select 
    flow_no
    ,'MY' as grass_region
from  risk.dwd_risk_my_af_credit_workflow_di 
where grass_date >= date_sub('${grass_date}',190)
--and from_unixtime(create_time)>= date_sub('${grass_date}',190)
and run_step <>''
and run_step like '%pass%' -- so final result also passed or verify passed
group by flow_no

union all 
select 
    flow_no
    ,'SG' as grass_region
from  risk.dwd_risk_sg_af_credit_workflow_di 
where grass_date >= date_sub('${grass_date}',190)
and run_step <>''
and run_step like '%pass%' -- so final result also passed or verify passed
group by flow_no

union all 
-- VN地区
select 
    flow_no
    ,'VN' as grass_region
from  risk.dwd_risk_vn_af_credit_workflow_di 
where grass_date >= date_sub('${grass_date}',190)
--and from_unixtime(create_time)>= date_sub('${grass_date}',190)
and run_step <>''
and run_step like '%pass%' -- so final result also passed or verify passed
group by  flow_no

union all 
-- PH地区,特殊一些，是370天之前
select 
    flow_no
    ,'PH' as grass_region
from  risk.dwd_risk_ph_af_credit_workflow_di 
where grass_date >= date_sub('${grass_date}',370)
--and from_unixtime(create_time)>= date_sub('${grass_date}',370)
and run_step <>''
and run_step like '%pass%' -- so final result also passed or verify passed
group by flow_no

union all 

-- TH地区
select 
    flow_no
    ,'TH' as grass_region
from  risk.dwd_risk_th_af_credit_workflow_di 
where grass_date >= date_sub('${grass_date}',190)
--and from_unixtime(create_time)>= date_sub('${grass_date}',190)
and run_step <>''
and run_step like '%pass%' -- so final result also passed or verify passed
group by flow_no
;

insert overwrite table risk.dws_risk_af_user_device_list_nd partition(grass_region,grass_date)
select 
t1.user_id                                as platform_user_id
,case when t2.platform_user_id is not null and t2.spdf_list <> '[]' then regexp_replace(regexp_replace(t2.spdf_list,',]',']'),'\\[,','[')
      else null end                       as spdf_list
,case when t2.platform_user_id is not null and t2.szdf_list <> '[]' then regexp_replace(regexp_replace(t2.szdf_list,',]',']'),'\\[,','[')
      else null end                       as szdf_list
,t1.grass_region      as grass_region
,'${grass_date}'      as grass_date
from mp_user.dim_user__reg_s0_live t1 
left join (
select 
    platform_user_id
    ,regexp_replace(array_distinct(collect_list(device_fingerprint)),'"','') as spdf_list
    ,regexp_replace(array_distinct(collect_list(szdf)),'"','')               as szdf_list
    ,grass_region                                                            as grass_region
    ,'${grass_date}'                                                         as grass_date
from (
    select 
    a.platform_user_id
    ,a.device_fingerprint
    ,a.szdf
    ,case when a.topic_name like '%_live_credit_risk_gateway_req_rsp_kredit' and risk_scene_id='10013' and a.is_spl_activated = '1' then 0
        when a.topic_name like '%_live_credit_risk_gateway_req_rsp_spj' and risk_scene_id='10013' and a.is_cashloan_activated = '1' then 0
        else 1 end as is_available
    ,a.grass_region
    from tmp_risk_strategy_final_result a 
    join tmp_workflow_tab b on a.workflow_flow_no= b.flow_no and a.grass_region = b.grass_region
    where to_date(a.req_time_local)>= case when a.grass_region='PH' then date_sub('${grass_date}',366) else  date_sub('${grass_date}',181) end
) a 
where is_available=1
group by platform_user_id,grass_region
)t2 on t1.user_id = t2.platform_user_id and t1.grass_region = t2.grass_region 
where t1.grass_date ='${grass_date}' 
and t1.grass_region in ${batch_region_am}
;


