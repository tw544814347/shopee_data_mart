'''
Description: 
Author: zongyi.lu
Email: zongyi.lue@shopee.com
Date: 2023-09-11 18:03:27
LastEditors: zongyi.lu
Update: 20231127 上游BE修改了逻辑,需要重新适配取 'ALL_APP_SCENE','RISK_TOPICS',
Update: 20240820 BR的数据不在SG更新,因此将BR依赖去掉以及不跑BR数据; 相当于表dim_risk_af_pharse_topic_extend 中BR数据不再更新
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

# drop table if exists ${SCHEMA}.dim_risk_af_pharse_topic_extend;
# create external table if not exists ${SCHEMA}.dim_risk_af_pharse_topic_extend
# (
#     biz               string comment 'credit/spp/ldn/cf'
#     ,is_show          int comment '1-Y 0-N'
#     ,version          string comment 'version'
#     ,operator         string comment 'operator'
#     ,config_name      string comment 'config_name'
#     ,app_id           string comment 'app_id'
#     ,topic_name       string comment 'topic_name'
#     ,scene_id         string commnet 'scene_id'
# )
# partitioned by
# (
#     grass_region   string          comment         'partition key'
# )
# stored as orc tblproperties ("orc.compress"="SNAPPY")
# location '${HDFS_PATH}/risk_mart/dim/dim_risk_af_pharse_topic_extend';

grass_date = (datetime.datetime.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")
print(grass_date)

if __name__ == "__main__":
    spark = SparkSession \
        .builder \
        .appName("dim_risk_af_listname_priority") \
        .enableHiveSupport() \
        .getOrCreate()
    region_list =['ID','MY','PH','TH','SG','VN','TW']
    # region_list =['PH']
    sql = """
    select 
    biz
    ,is_show 
    ,version
    ,operator
    ,config_name
    ,config_value
    ,upper('{region}') as region
    from risk.ods__credit_risk_holmes{has_live}_{region}_db__business_config_tab__df
    where grass_date='{grass_date}'
    and config_name in( 'ALL_APP_SCENE' ,'RISK_TOPICS')
    and version_status =2 
    and config_status =1 ; 
    """
    result_list=[]
    for region in region_list :
        has_live=""
        if region=='ID':
            has_live='_live'
        listname_df = spark.sql(sql.format(has_live=has_live,grass_date=grass_date,region=region.lower())).toPandas()
        print(sql.format(has_live=has_live,grass_date=grass_date,region=region.lower()))
        for i in range(len(listname_df)):
            topic_name=""
            raw = listname_df.iloc[i] 
            biz = raw['biz']
            is_show = raw['is_show']
            version = raw['version']
            operator = raw['operator']
            config_name = raw['config_name']
            config_value = raw['config_value']
            config_value_json = json.loads(config_value)
            scene_id_dic={}
            if len(config_value_json)==0:
                    print("config_name's value","is empty.")
            elif config_name == 'ALL_APP_SCENE':
                for key,value in config_value_json.items():
                    scene_id_list=[]
                    if 'scenes' in value:
                        scenes_json= value.get('scenes')
                        if '{' in str(scenes_json):
                            scene_id_json = scenes_json.get('af')
                            if '{' in str(scene_id_json):
                                for scene_id in scene_id_json:
                                    scene_id_list.append(scene_id)
                                    if biz=='credit':
                                        topic_name='{region}_live_credit_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                                    elif biz=='invest':
                                        topic_name='{region}_live_invest_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                                    elif biz=='spp':
                                        topic_name='{region}_live_spp_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                                    else :
                                        topic_name='{region}_live_credit_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                                    result_list.append([raw['biz'],int(raw['is_show']),raw['version'],raw['operator'],raw['config_name'],key,topic_name,str(scene_id),region])
                    if 'workflows' in value:
                        workflows_json= value.get('workflows')
                        if '{' in str(workflows_json):
                            for scene_id in workflows_json:
                                scene_id_list.append(scene_id)
                                if biz=='credit':
                                    topic_name='{region}_live_credit_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                                elif biz=='invest':
                                    topic_name='{region}_live_invest_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                                elif biz=='spp':
                                    topic_name='{region}_live_spp_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                                else :
                                    topic_name='{region}_live_credit_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                                result_list.append([raw['biz'],int(raw['is_show']),raw['version'],raw['operator'],raw['config_name'],key,topic_name,str(scene_id),region])

                    # for scene_id in value:
                        # if biz=='credit':
                        #     topic_name='{region}_live_credit_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                        # elif biz=='invest':
                        #     topic_name='{region}_live_invest_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                        # elif biz=='spp':
                        #     topic_name='{region}_live_spp_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                        # else :
                        #     topic_name='{region}_live_credit_risk_gateway_req_rsp_{app_id}'.format(region=region.lower(),app_id=key)
                        # # print(topic_name,scene_id)
                        # result_list.append([raw['biz'],int(raw['is_show']),raw['version'],raw['operator'],raw['config_name'],key,topic_name,str(scene_id),region])
            # RISK_TOPICS 是自定义的topic, 格式:['id_live_credit_risk_gateway_req_rsp_chp_10045','id_live_credit_risk_gateway_req_rsp_chp_10044']
            else:
                for tn in config_value_json:
                    tn_sceneid = tn.split('_')[-2:]
                    app_id = tn_sceneid[0]
                    scene_id = str(tn_sceneid[1])
                    topic_name = tn.replace('_'+scene_id,'')
                    result_list.append([raw['biz'],int(raw['is_show']),raw['version'],raw['operator'],raw['config_name'],app_id,topic_name,str(scene_id),region])

    print(result_list)
    # 写入hive 表
    pd_df = pd.DataFrame(result_list,columns=['biz','is_show','version','operator','config_name','app_id','topic_name','scene_id','grass_region'])
    spark_df = spark.createDataFrame(pd_df)
    spark_df.write.format("hive").insertInto("risk.dim_risk_af_pharse_topic_extend",True)




