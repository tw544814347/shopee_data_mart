--********************************************************************--
-- Author:             li.lill@shopee.com
-- Created Time:       2026-03-20
-- Description:        [TH/VN/BR]新增mirror的af数据,node result表
-- PRD:                https://jira.shopee.io/browse/SPFDT-61697                  
--********************************************************************--
-- drop table if exists risk.dwd_risk_${region}_af_node_result_mirror_di;
create table if not exists risk.dwd_risk_${region}_af_node_result_mirror_di
(
        id                BIGINT COMMENT '<comment><description>Primary key identifier, fixed value 0</description><calculationLogic>0</calculationLogic><enum>No enum</enum></comment>',
        flow_no           STRING COMMENT '<comment><description>Workflow flow number from RiskReqHeader</description><calculationLogic>get_json_object(value, \'$.Req.RiskReqHeader.FlowNo\')</calculationLogic><enum>No enum</enum></comment>',
        node_id           BIGINT COMMENT '<comment><description>Node identifier from NodeResult array</description><calculationLogic>cast(get_json_object(NodeResult_array, \'$.NodeId\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        node_idx          BIGINT COMMENT '<comment><description>Node index from NodeResult array</description><calculationLogic>cast(get_json_object(NodeResult_array, \'$.NodeIdx\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        node_name         STRING COMMENT '<comment><description>Node name from NodeResult array</description><calculationLogic>get_json_object(NodeResult_array, \'$.NodeName\')</calculationLogic><enum>No enum</enum></comment>',
        parent_node_id    BIGINT COMMENT '<comment><description>Parent node identifier, fixed value 0</description><calculationLogic>0</calculationLogic><enum>No enum</enum></comment>',
        node_type         STRING COMMENT '<comment><description>Node type from NodeResult array, process_feature/pf normalized to PF</description><calculationLogic>case when lower(node_type) in (\'process_feature\',\'pf\') then \'PF\' else node_type end</calculationLogic><enum>L1, L2, L3, Index, RG, PF</enum></comment>',
        begin_time        BIGINT COMMENT '<comment><description>Node execution begin timestamp from NodeResult array</description><calculationLogic>cast(get_json_object(NodeResult_array, \'$.BeginTime\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        end_time          BIGINT COMMENT '<comment><description>Node execution end timestamp from NodeResult array</description><calculationLogic>cast(get_json_object(NodeResult_array, \'$.EndTime\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        result            STRING COMMENT '<comment><description>Node execution result from NodeResult array</description><calculationLogic>get_json_object(NodeResult_array, \'$.Result\')</calculationLogic><enum>No enum</enum></comment>',
        result_type       STRING COMMENT '<comment><description>Result type, currently empty string</description><calculationLogic>\'\'</calculationLogic><enum>No enum</enum></comment>',
        make_decision     BIGINT COMMENT '<comment><description>Make decision flag, fixed value 0</description><calculationLogic>0</calculationLogic><enum>No enum</enum></comment>',
        create_time       BIGINT COMMENT '<comment><description>Request timestamp from RiskReqHeader</description><calculationLogic>cast(get_json_object(value, \'$.Req.RiskReqHeader.ReqTime\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        tree_node_type    DECIMAL(20,0) COMMENT '<comment><description>Tree node type as decimal from NodeResult array</description><calculationLogic>get_json_object(NodeResult_array, \'$.TreeNodeType\')</calculationLogic><enum>No enum</enum></comment>',
        tree_node_id      BIGINT COMMENT '<comment><description>Tree node identifier from NodeResult array</description><calculationLogic>cast(get_json_object(NodeResult_array, \'$.TreeNodeId\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        data_status       BIGINT COMMENT '<comment><description>Data status from NodeResult array</description><calculationLogic>cast(get_json_object(NodeResult_array, \'$.DataStatus\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        handle_begin_time BIGINT COMMENT '<comment><description>Handle begin timestamp from RiskInsight</description><calculationLogic>cast(get_json_object(value, \'$.Rsp.RiskInsight.HandleBeginTime\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        platform_user_id  STRING COMMENT '<comment><description>Platform user identifier from CommonHeader</description><calculationLogic>get_json_object(value, \'$.ReqParams.CommonHeader.platform_user_id\')</calculationLogic><enum>No enum</enum></comment>',
        risk_scene_id     STRING COMMENT '<comment><description>Risk scene identifier from dimension table</description><calculationLogic>scene_id from dim_risk_strategy_app_scene_config_df</calculationLogic><enum>No enum</enum></comment>',
        tree_node_type_string    STRING COMMENT '<comment><description>Tree node type as string from NodeResult array</description><calculationLogic>get_json_object(NodeResult_array, \'$.TreeNodeType\')</calculationLogic><enum>No enum</enum></comment>',
        workflow_flow_no    STRING COMMENT '<comment><description>Workflow flow number from RiskReqHeader</description><calculationLogic>get_json_object(value, \'$.Req.RiskReqHeader.WorkflowFlowNo\')</calculationLogic><enum>No enum</enum></comment>',
        `source_platform_type` STRING COMMENT '<comment><description>Original platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_type")</calculationLogic><enum>No enum</enum></comment>',
        `source_platform_user_id` STRING COMMENT '<comment><description>Original platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
        `traffic_platform_type` STRING COMMENT '<comment><description>Traffic platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_type")</calculationLogic><enum>No enum</enum></comment>',
        `traffic_platform_user_id` STRING COMMENT '<comment><description>Traffic platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
        `shopeepay_user_id` STRING COMMENT '<comment><description>ShopeePay user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.shopeepay_user_id")</calculationLogic><enum>No enum</enum></comment>',
        platform_type STRING COMMENT '<comment><description>Platform type identifier</description><calculationLogic>cast(platform_type as STRING) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>1-Shopee, 5-ShopeePay</enum></comment>'
    )
partitioned by(
    topic_name STRING COMMENT '<comment><description>Kafka topic name derived from region and app_id</description><calculationLogic>concat(region, \'_live_credit_risk_gateway_req_rsp_\', app_id)</calculationLogic><enum>No enum</enum></comment>',
    grass_date STRING COMMENT '<comment><description>Biz Local Date based on ReqTime</description><calculationLogic>to_date(format_time(ReqTime, region))</calculationLogic><enum>No enum</enum></comment>',
    process_date STRING COMMENT '<comment><description>Data processing date from source dt partition</description><calculationLogic>dt</calculationLogic><enum>No enum</enum></comment>'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_kafka/dwd/dwd_risk_reg_af_node_result_mirror_di/grass_region=${upper_region}'
COMMENT 'Data warehouse detail table for credit risk strategy node result, exploded from NodeResult array and filtered by node_type.'
;
-- msck repair table risk.dwd_risk_${region}_af_node_result_mirror_di;

insert overwrite table risk.dwd_risk_${region}_af_node_result_mirror_di partition (topic_name,grass_date,process_date)
select 
    id,
    flow_no,
    node_id,
    node_idx,
    node_name,
    parent_node_id,
    case when lower(node_type) in ('process_feature','pf') then 'PF' else node_type end as node_type,
    begin_time,
    end_time,
    result,
    result_type,
    make_decision,
    create_time,
    cast(tree_node_type as DECIMAL(20,0)) as tree_node_type,
    tree_node_id,
    data_status,
    handle_begin_time,
    platform_user_id,
    risk_scene_id,
    tree_node_type as tree_node_type_string,
    workflow_flow_no,
    source_platform_type,
    source_platform_user_id,
    traffic_platform_type,
    traffic_platform_user_id,
    shopeepay_user_id,
    platform_type,
    topic_name,
    grass_date,
    process_date
from (
    select
        id,
        flow_no,
        workflow_flow_no,
        cast(
            get_json_object(Rsp_RiskInsight_NodeResult_array, '$.NodeId') as bigint
        ) as node_id,
        cast(
            get_json_object(Rsp_RiskInsight_NodeResult_array, '$.NodeIdx') as bigint
        ) as node_idx,
        get_json_object(Rsp_RiskInsight_NodeResult_array, '$.NodeName') as node_name,
        parent_node_id,
        get_json_object(Rsp_RiskInsight_NodeResult_array, '$.NodeType') as node_type,
        cast(
            get_json_object(Rsp_RiskInsight_NodeResult_array, '$.BeginTime') as bigint
        ) as begin_time,
        cast(
            get_json_object(Rsp_RiskInsight_NodeResult_array, '$.EndTime') as bigint
        ) as end_time,
        get_json_object(Rsp_RiskInsight_NodeResult_array, '$.Result') as result,
        result_type,
        make_decision,
        create_time,
            get_json_object(
                Rsp_RiskInsight_NodeResult_array,
                '$.TreeNodeType'
            ) as tree_node_type,
        
        cast(
            get_json_object(Rsp_RiskInsight_NodeResult_array, '$.TreeNodeId') as bigint
        ) as tree_node_id,
        cast(
            get_json_object(Rsp_RiskInsight_NodeResult_array, '$.DataStatus') as bigint
        ) as data_status,
        handle_begin_time,
        platform_user_id,
        kafka_source,
        topic_name,
        risk_scene_id,
        source_platform_type,
        source_platform_user_id,
        traffic_platform_type,
        traffic_platform_user_id,
        shopeepay_user_id,
        platform_type,
        grass_date,
        process_date
    from
        (
            select
                id,
                flow_no,
                workflow_flow_no,
                explode (
                            from_json(Rsp_RiskInsight_NodeResult_array_temp, 'array<string>')
                        ) as Rsp_RiskInsight_NodeResult_array,
                parent_node_id,
                result_type,
                make_decision,
                create_time,
                handle_begin_time,
                platform_user_id,
                kafka_source,
                topic_name,
                risk_scene_id,
                source_platform_type,
                source_platform_user_id,
                traffic_platform_type,
                traffic_platform_user_id,
                shopeepay_user_id,
                platform_type,
                grass_date,
                process_date
            from
                (
                    select
                        0 as id,
                        flow_no,
                        workflow_flow_no,
                        node_results as Rsp_RiskInsight_NodeResult_array_temp,
                        0 as parent_node_id,
                        '' as result_type,
                        0 as make_decision,
                        create_time,
                        handle_begin_time,
                        platform_user_id,
                        'di' as kafka_source,
                        concat('${region}_live_credit_risk_gateway_req_rsp_', app_id)  as topic_name,
                        scene_id   as risk_scene_id,
                        source_platform_type,
                        source_platform_user_id,
                        traffic_platform_type,
                        traffic_platform_user_id,
                        shopeepay_user_id,
                        platform_type,
                        -- update by dongbo.yu 2025.09.16 这个函数的用法中不需要中间的from_unixtime函数,加上的话，会额外再偏移8小时
                        grass_date,
                        dt as process_date
                    from  risk.dwd_risk_${region}_live_kafka_gateway_aio_log_mirror_di
                    where dt >= cast(date_sub('${grass_date}', 0) as string)
                    and   dt <= cast(date_add('${grass_date}', 1) as string)
                    --   update by dongbo.yu 2025-09-25 cause app_id=kredit, scene_id=30025中上报的platform_user_id='' , issue report by min.ge@seamoney.com
                    -- and length(trim(get_json_object(t1.value, '$.ReqParams.CommonHeader.platform_user_id'))) between 1 and 14
                )
        ) 
        
)a 
where lower(node_type) IN ('l1','l2','l3','index','rg','process_feature','pf');
