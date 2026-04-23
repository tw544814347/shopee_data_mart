'''
Description: 
Author: zongyi.lu
Email: zongyi.lue@shopee.com
Date: 2023-04-04 18:03:27
LastEditTime: 2023-04-04 18:10:50
LastEditors: zongyi.lu
'''
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import os
import sys
import datetime
import requests
import json
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
import pandas as pd 

# drop table if exists ${SCHEMA}.dim_risk_af_listname_priority;
# create external table if not exists ${SCHEMA}.dim_risk_af_listname_priority
# (
#     custom_list_id string comment 'custom_list_id'
#     ,list_name     string comment 'list_name'
#     ,de_table_name string comment 'de_table_name'
#     ,priority      string comment 'priority'
#     ,biz_type      string comment 'biz_type'
# )
# partitioned by
# (
#     grass_region   string          comment         'partition key'
# )
# stored as orc tblproperties ("orc.compress"="SNAPPY")
# location '${HDFS_PATH}/risk_mart/dim/dim_risk_af_listname_priority';

grass_date = (datetime.datetime.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")
print(grass_date)

if __name__ == "__main__":
    spark = SparkSession \
        .builder \
        .appName("risk_get_ods_table_cnt") \
        .enableHiveSupport() \
        .getOrCreate()
    table_list=['risk.ods__credit_risk_datafetch_my_db__data_source_api_request_log_tab__df'
,'risk.ods__credit_risk_control_sg_db__workflow_history_tab__df'
,'risk.ods__credit_risk_feature_v2_sg_db__risk_feature_new_tab__df'
,'risk.ods__credit_risk_control_vn_db__fe_strategy_group_tab__df'
,'risk.ods__credit_risk_control_vn_db__fe_strategy_scorecard_tab__df'
,'risk.ods__credit_risk_control_vn_db__fe_scene_strategy_tab__df'
,'risk.ods__credit_risk_control_vn_db__fe_strategy_rule_tab__df'
,'risk.ods__cf_risk_underwriting_id_db__invoke_policy_result_tab__df'
,'risk.ods__credit_risk_control_sg_db__credit_instalment_tab__df'
,'risk.ods__credit_risk_unicorn_sg_db__risk_function_file_extra_tab__df'
,'risk.ods__credit_risk_unicorn_sg_db__risk_function_history_tab__df'
,'risk.ods__credit_risk_unicorn_sg_db__risk_function_meta_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__fe_strategy_rule_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__fe_strategy_rule_tab__df'
,'risk.ods__credit_risk_control_sg_db__credit_sp_history_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__fe_strategy_scorecard_tab__df'
,'risk.ods__credit_risk_control_sg_db__fe_strategy_rule_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__fe_scene_strategy_tab__df'
,'risk.ods__credit_risk_control_sg_db__fe_strategy_scorecard_tab__df'
,'risk.ods__credit_risk_unicorn_sg_db__risk_function_entity_tab__df'
,'risk.ods__credit_risk_control_id_db__credit_realtime_credit_list_tab__df'
,'risk.ods__credit_risk_unicorn_sg_db__risk_function_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__fe_scene_strategy_tab__df'
,'risk.ods__credit_risk_control_sg_db__fe_strategy_group_tab__df'
,'risk.ods__credit_risk_control_sg_db__fe_scene_strategy_tab__df'
,'risk.ods__credit_risk_datafetch_th_db__data_source_api_request_log_tab__df'
,'risk.ods__credit_score_id_db__user_voucher_record_tab__df'
,'risk.ods__credit_risk_control_th_db__custom_list_apaccount_tab__df'
,'risk.ods__credit_risk_control_tw_db__credit_stat_data_tab__df'
,'risk.ods__credit_risk_control_ph_db__screen_tab__df'
,'risk.ods__credit_risk_control_vn_db__user_active_tab__df'
,'risk.ods__credit_risk_control_th_db__cashloan_instalment_history_tab__df'
,'risk.ods__credit_risk_control_th_db__cashloan_limit_history_tab__df'
,'risk.ods__credit_risk_datafetch_vn_db__data_source_api_request_log_tab__df'
,'risk.ods__credit_risk_control_ph_db__screen_ops_tab__df'
,'risk.ods__credit_risk_control_vn_db__credit_sp_history_tab__df'
,'risk.ods__credit_risk_control_vn_db__custom_list_rare_type_tab__df'
,'risk.ods__credit_risk_control_ph_db__loan_instalment_history_tab__df'
,'risk.ods__credit_risk_control_vn_db__credit_instalment_history_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__risk_event_feature_tab__df'
,'risk.ods__credit_risk_control_ph_db__loan_limit_history_tab__df'
,'risk.ods__credit_risk_control_th_db__loan_limit_tab__df'
,'risk.ods__credit_risk_datafetch_sg_db__data_source_api_request_log_tab__df'
,'risk.ods__credit_risk_control_my_db__cashloan_limit_tab__df'
,'risk.ods__credit_risk_control_th_db__custom_list_fbaccount_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__custom_list_shopee_account_tab__df'
,'risk.ods__credit_risk_control_my_db__loan_limit_history_tab__df'
,'risk.ods__credit_risk_control_my_db__dp_whitelist_history_tab__df'
,'risk.ods__credit_risk_control_my_db__cashloan_instalment_tab__df'
,'risk.ods__credit_risk_control_my_db__loan_instalment_history_tab__df'
,'risk.ods__credit_risk_control_vn_db__ticket_ops_tab__df'
,'risk.ods__credit_risk_control_ph_db__loan_instalment_tab__df'
,'risk.ods__credit_risk_control_sg_db__ser_file_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__risk_event_feature_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__risk_workflow_config_tree_tab__df'
,'risk.ods__credit_risk_control_my_db__loan_limit_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__return_code_tab__df'
,'risk.ods__credit_risk_control_sg_db__risk_event_feature_tab__df'
,'risk.ods__credit_risk_control_th_db__risk_event_module_config_tab__df'
,'risk.ods__credit_risk_control_vn_db__risk_event_feature_tab__df'
,'risk.ods__credit_risk_control_th_db__action_type_tab__df'
,'risk.ods__credit_risk_control_th_db__loan_instalment_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__scene_meta_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__risk_event_module_config_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__risk_event_action_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__workflow_routing_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__scene_meta_tab__df'
,'risk.ods__credit_risk_control_vn_db__upload_file_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__risk_action_imp_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__risk_action_combination_tab__df'
,'risk.ods__credit_risk_control_my_db__ticket_ops_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__return_code_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__risk_event_action_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__return_code_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__risk_workflow_config_tree_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__risk_event_meta_data_tab__df'
,'risk.ods__credit_risk_control_my_db__risk_event_module_config_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__risk_workflow_config_tree_tab__df'
,'risk.ods__credit_risk_control_vn_db__bpmn_fe_tab__df'
,'risk.ods__credit_risk_control_my_db__custom_list_tddf_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__risk_event_feature_tab__df'
,'risk.ods__credit_risk_control_sg_db__risk_action_imp_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__risk_event_attributes_tab__df'
,'risk.ods__credit_risk_control_sg_db__policy_tree_version_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__workflow_routing_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__risk_event_action_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__risk_event_attributes_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__risk_event_feature_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__risk_event_meta_data_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__return_code_tab__df'
,'risk.ods__credit_risk_control_sg_db__risk_event_action_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__workflow_routing_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__risk_event_module_config_tab__df'
,'risk.ods__credit_risk_control_vn_db__ser_file_tab__df'
,'risk.ods__credit_risk_control_sg_db__risk_event_module_config_tab__df'
,'risk.ods__credit_risk_control_vn_db__risk_event_meta_data_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__risk_event_action_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__return_code_tab__df'
,'risk.ods__credit_risk_control_id_db__risk_event_module_config_tab__df'
,'risk.ods__credit_risk_control_vn_db__risk_action_combination_tab__df'
,'risk.ods__credit_risk_control_vn_db__policy_file_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__scene_meta_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__risk_event_meta_data_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__risk_event_attributes_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__risk_event_meta_data_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__risk_action_combination_tab__df'
,'risk.ods__credit_risk_control_vn_db__policy_tree_version_tab__df'
,'risk.ods__credit_risk_control_sg_db__strategy_model_tab__df'
,'risk.ods__credit_risk_feature_vn_db__risk_feature_template_model_dependency_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__scene_meta_tab__df'
,'risk.ods__credit_risk_control_vn_db__node_rule_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__risk_action_combination_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__risk_event_feature_tab__df'
,'risk.ods__credit_risk_control_sg_db__bpmn_fe_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__workflow_routing_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__custom_list_action_tab__df'
,'risk.ods__credit_risk_control_vn_db__risk_action_imp_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__custom_list_action_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__risk_action_imp_tab__df'
,'risk.ods__credit_risk_feature_sg_db__risk_feature_template_model_dependency_tab__df'
,'risk.ods__credit_risk_control_sg_db__node_rule_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__risk_action_combination_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__risk_event_module_config_tab__df'
,'risk.ods__credit_risk_control_sg_db__action_node_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__risk_action_combination_tab__df'
,'risk.ods__credit_risk_control_sg_db__risk_event_meta_data_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__custom_list_action_tab__df'
,'risk.ods__credit_risk_control_vn_db__action_node_tab__df'
,'risk.ods__shopeepay_risk_control_sg_db__risk_workflow_config_tree_tab__df'
,'risk.ods__credit_risk_control_sg_db__policy_file_tab__df'
,'risk.ods__credit_risk_control_sg_db__action_type_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__risk_event_meta_data_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__risk_event_module_config_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__risk_event_module_config_tab__df'
,'risk.ods__credit_risk_control_ph_db__risk_event_module_config_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__risk_action_imp_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__risk_event_action_tab__df'
,'risk.ods__credit_risk_control_th_db__action_node_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__scene_meta_tab__df'
,'risk.ods__credit_risk_control_ph_db__action_node_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__workflow_routing_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__custom_list_action_tab__df'
,'risk.ods__credit_risk_control_sg_db__risk_action_combination_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__risk_workflow_config_tree_tab__df'
,'risk.ods__credit_risk_holmes_vn_db__business_config_tab__df'
,'risk.ods__credit_risk_control_vn_db__strategy_model_tab__df'
,'risk.ods__credit_risk_control_my_db__action_node_tab__df'
,'risk.ods__credit_risk_control_vn_db__risk_event_action_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__risk_event_attributes_tab__df'
,'risk.ods__credit_risk_control_sg_db__upload_file_tab__df'
,'risk.ods__shopeepay_risk_control_th_db__custom_list_action_tab__df'
,'risk.ods__credit_risk_control_vn_db__action_type_tab__df'
,'risk.ods__credit_risk_control_vn_db__risk_event_module_config_tab__df'
,'risk.ods__shopeepay_risk_control_vn_db__risk_event_attributes_tab__df'
,'risk.ods__shopeepay_risk_control_my_db__risk_action_imp_tab__df'
,'risk.ods__credit_risk_control_my_db__action_type_tab__df'
,'risk.ods__credit_risk_control_ph_db__action_type_tab__df'
,'risk.ods__shopeepay_risk_control_ph_db__risk_action_imp_tab__df']
    sql = """
    select 
    "{table_name}" as table_name 
    ,count(1) as cnt
    from {table_name}
    where grass_date ='2024-08-21'
    """
    
    for table_name in table_list :
        listname_df = spark.sql(sql.format(table_name = table_name)).toPandas()
        for i in range(len(listname_df)):
            raw = listname_df.iloc[i] 
            table_name = raw['table_name']
            cnt = raw['cnt']
            print(table_name,'--->',cnt)




