--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-05-12
-- Theme Domain：       risk topic
-- Description:
--  1.风控antifraud和workflow，线上配置的所有app_id+scene_id维表
--  2.scene_type = workflow/antifraud 区分使用
--    need_write_workflow_db = 0, 是单节点的workflow，且数据量非常大,对存储压力较大,BE侧不会写DB, Data也不解析这部分workflow
--    parent_workflow_scene_id, 反欺诈节点的父workflow节点的scene_id，workflow节点的该字段为空
-- Data Granularity:    app_id+scene_id
-- 变更历史：             业务已确认不再使用，下线处理
--********************************************************************--

create or replace temporary view credit_workflow_app_scene_config as
select
    t1.app_id
    ,t1.scene_id
    ,'workflow' as scene_type
    ,min(
        case
            when lower(t3.key) = 'need_write_workflow_db' and lower(t3.value) = 'false' then 0
            else 1
        end
    ) as need_write_workflow_db
    ,null as parent_workflow_scene_id
    ,'credit' as product_name
from
    (
        select
            app_id
            ,scene_id
            ,status
            ,config_type
            ,run_mode
        from risk.ods__credit_risk_control_${region}_db__workflow_routing_tab__df
        where
            grass_date = '${grass_date}'
            and status = '1'
            and lower(config_type) = 'workflow'
            and lower(run_mode) in ('golive', 'gray')
    ) t1
    left join (
        select
            app_id
            ,scene_id
            ,event_code
        from risk.ods__credit_risk_control_${region}_db__risk_event_meta_data_tab__df
        where grass_date = '${grass_date}'
    ) t2 on t1.app_id = t2.app_id
    and t1.scene_id = t2.scene_id
    left join (
        select
            event_code
            ,key
            ,value
        from risk.ods__credit_risk_control_${region}_db__risk_event_attributes_tab__df
        where grass_date = '${grass_date}'
    ) t3 on t2.event_code = t3.event_code
group by 1, 2
;

create or replace temporary view shopeepay_workflow_app_scene_config as
select
    t1.app_id
    ,t1.scene_id
    ,'workflow' as scene_type
    ,min(
        case
            when lower(t3.key) = 'need_write_workflow_db' and lower(t3.value) = 'false' then 0
            else 1
        end
    ) as need_write_workflow_db
    ,null as parent_workflow_scene_id
    ,'shopeepay' as product_name
from
    (
        select
            app_id
            ,scene_id
            ,status
            ,config_type
            ,run_mode
        from risk.ods__shopeepay_risk_control_${spp_has_region}_db__workflow_routing_tab__df
        where
            grass_date = '${grass_date}'
            and '${region}' = '${spp_has_region}'
            and status = '1'
            and lower(config_type) = 'workflow'
            and lower(run_mode) in ('golive', 'gray')
    ) t1
    left join (
        select
            app_id
            ,scene_id
            ,event_code
        from risk.ods__shopeepay_risk_control_${spp_has_region}_db__risk_event_meta_data_tab__df
        where
            grass_date = '${grass_date}'
            and '${region}' = '${spp_has_region}'
    ) t2 on t1.app_id = t2.app_id
    and t1.scene_id = t2.scene_id
    left join (
        select
            event_code
            ,key
            ,value
        from risk.ods__shopeepay_risk_control_${spp_has_region}_db__risk_event_attributes_tab__df
        where
            grass_date = '${grass_date}'
            and '${region}' = '${spp_has_region}'
    ) t3 on t2.event_code = t3.event_code
group by 1, 2
;

create or replace temporary view credit_antifraud_app_scene_config as
select
    app_id
    ,scene_id
    ,'antifraud' as scene_type
    ,null as need_write_workflow_db
    ,concat_ws(',', collect_set(parent_workflow_scene_id)) as parent_workflow_scene_id
    ,'credit' as product_name
from
    (
        select
            t2.app_id
            ,t2.scene_id
            ,t1.scene_id as parent_workflow_scene_id
        from
            (
                select
                    workflow_id
                    ,app_id
                    ,scene_id
                from
                    (
                        select
                            workflow_id
                            ,app_id
                            ,scene_id
                        from risk.ods__credit_risk_control_${region}_db__workflow_routing_tab__df
                        where
                            grass_date = '${grass_date}'
                            and status = '1'
                            and lower(config_type) = 'workflow'
                            and lower(run_mode) in ('golive', 'gray')
                    )
            ) t1
            inner join (
                select
                    id as workflow_id
                    ,node.key as node_key
                    ,node.value.ExtInfo.AppId as app_id
                    ,node.value.ExtInfo.SceneId as scene_id
                    ,node.value as node_value
                from
                    (
                        select
                            id
                            ,config_tree
                        from risk.ods__credit_risk_control_${region}_db__risk_workflow_config_tree_tab__df
                        where grass_date = '${grass_date}'
                    ) lateral view explode (
                    map_entries(
                        from_json(
                            get_json_object(config_tree, '$.Nodes')
                            ,'map<string, struct<NodeId:string, NodeName:string, NodeType:string, Desc:string, Goto:array<struct<Condition:string, NodeId:string, Desc:string>>, ExtInfo:map<string, string>>>'
                        )
                    )
                ) as node
                where node.value.NodeType = 'anti_fraud@base'
            ) t2 on t1.workflow_id = t2.workflow_id
        union all
        select
            app_id
            ,scene_id
            ,null as parent_workflow_scene_id
        from
            (
                select
                    app_id
                    ,scene_id
                from risk.ods__credit_risk_control_${region}_db__scene_strategy_tab__df
                where
                    grass_date = '${grass_date}'
                    and running in (1, 3, 4, 5)
            )
    )
group by 1, 2
;

create or replace temporary view shopeepay_antifraud_app_scene_config as
select
    app_id
    ,scene_id
    ,'antifraud' as scene_type
    ,null as need_write_workflow_db
    ,concat_ws(',', collect_set(parent_workflow_scene_id)) as parent_workflow_scene_id
    ,'shopeepay' as product_name
from
    (
        select
            t2.app_id
            ,t2.scene_id
            ,t1.scene_id as parent_workflow_scene_id
        from
            (
                select
                    workflow_id
                    ,app_id
                    ,scene_id
                from
                    (
                        select
                            workflow_id
                            ,app_id
                            ,scene_id
                        from risk.ods__shopeepay_risk_control_${spp_has_region}_db__workflow_routing_tab__df
                        where
                            grass_date = '${grass_date}'
                            and '${region}' = '${spp_has_region}'
                            and status = '1'
                            and lower(config_type) = 'workflow'
                            and lower(run_mode) in ('golive', 'gray')
                    )
            ) t1
            inner join (
                select
                    id as workflow_id
                    ,node.key as node_key
                    ,node.value.ExtInfo.AppId as app_id
                    ,node.value.ExtInfo.SceneId as scene_id
                    ,node.value as node_value
                from
                    (
                        select
                            id
                            ,config_tree
                        from risk.ods__shopeepay_risk_control_${spp_has_region}_db__risk_workflow_config_tree_tab__df
                        where grass_date = '${grass_date}'
                        and '${region}' = '${spp_has_region}'
                    ) lateral view explode (
                    map_entries(
                        from_json(
                            get_json_object(config_tree, '$.Nodes')
                            ,'map<string, struct<NodeId:string, NodeName:string, NodeType:string, Desc:string, Goto:array<struct<Condition:string, NodeId:string, Desc:string>>, ExtInfo:map<string, string>>>'
                        )
                    )
                ) as node
                where node.value.NodeType = 'anti_fraud@base'
            ) t2 on t1.workflow_id = t2.workflow_id
        union all
        select
            app_id
            ,scene_id
            ,null as parent_workflow_scene_id
        from
            (
                select
                    app_id
                    ,scene_id
                from risk.ods__shopeepay_risk_control_${spp_has_region}_db__scene_strategy_tab__df
                where
                    grass_date = '${grass_date}'
                    and '${region}' = '${spp_has_region}'
                    and running in (1, 3, 4, 5)
            )
    )
group by 1, 2
;

insert overwrite table
    ${SCHEMA}.dim_risk_strategy_app_scene_config_df partition (
        grass_region = '${grass_region}'
        ,grass_date = '${grass_date}'
    )
select
    app_id
    ,scene_id
    ,scene_type
    ,need_write_workflow_db
    ,parent_workflow_scene_id
    ,product_name
from credit_workflow_app_scene_config
union all
select
    app_id
    ,scene_id
    ,scene_type
    ,need_write_workflow_db
    ,parent_workflow_scene_id
    ,product_name
from shopeepay_workflow_app_scene_config
union all
select
    app_id
    ,scene_id
    ,scene_type
    ,need_write_workflow_db
    ,parent_workflow_scene_id
    ,product_name
from credit_antifraud_app_scene_config
union all
select
    app_id
    ,scene_id
    ,scene_type
    ,need_write_workflow_db
    ,parent_workflow_scene_id
    ,product_name
from shopeepay_antifraud_app_scene_config
;