'''
Description: 
Author: zongyi.lu
Email: zongyi.lue@shopee.com
Date: 2023-04-04 18:03:27
LastEditTime: 2023-04-04 18:10:50
LastEditors: zongyi.lu
update: 20231107 新增过滤逻辑custom_list_tab.status=1  https://jira.shopee.io/browse/SPFDT-21434
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
#     ,screening_type string comment 'true false'
#     ,screening_switch     bigint               comment 'the manual audit switch: 1-off, 2-on' 
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
        .appName("dim_risk_af_listname_priority") \
        .enableHiveSupport() \
        .getOrCreate()
    region_list =['BR','MX']
    # region_list =['MY']
    sql = """
    select 
    cast(list_id as string)               as custom_list_id
    ,list_name       as list_name 
    ,de_table_name   as de_table_name
    ,'credit' as biz_type
    ,upper('{region}') as region
    ,de_table_config
    ,screening_switch
    from risk.dim_risk_{region}_credit_custom_list_info_df
    where grass_date='{grass_date}'
    and list_source='DE'
    and status=1
    and de_table_name is not null 
    union all 
    select 
    cast(list_id as string)               as custom_list_id
    ,list_name       as list_name 
    ,de_table_name   as de_table_name
    ,'shopeepay'       as biz_type
    ,upper('{region}') as region
    ,de_table_config
    ,screening_switch
    from risk.dim_risk_{region}_shopeepay_custom_list_info_df
    where grass_date='{grass_date}'
    and list_source='DE'
    and status=1
    and de_table_name is not null 
    """
    sql_2 = """
    select 
    cast(list_id as string)               as custom_list_id
    ,list_name       as list_name 
    ,de_table_name   as de_table_name
    ,'credit' as biz_type
    ,upper('{region}') as region
    ,de_table_config
    ,screening_switch
    from risk.dim_risk_{region}_credit_custom_list_info_df
    where grass_date='{grass_date}'
    and list_source='DE'
    and status=1
    and de_table_name is not null 

    """
    result_list=[]
    for region in region_list :
        if region =='TW' or region =='MX':
            sql = sql_2
        listname_df = spark.sql(sql.format(grass_date=grass_date,region=region.lower())).toPandas()
        for i in range(len(listname_df)):
            raw = listname_df.iloc[i] 
            str_de_table_config = raw['de_table_config']
            if str_de_table_config is not None:
                de_table_config = json.loads(str_de_table_config)
            table_name = raw['de_table_name'].split(',')
            for table in table_name:
                if str_de_table_config is None:
                    need_screening=""
                if str_de_table_config is not None:
                    need_screening = str(de_table_config[table_name.index(table)]['NeedScreening'])
                result_list.append([raw['custom_list_id'],raw['list_name'],table,table_name.index(table)+1,raw['biz_type'],need_screening,raw['screening_switch'],region])
    print(result_list)
    # 写入hive 表
    pd_df = pd.DataFrame(result_list,columns=['custom_list_id','list_name','de_table_name','priority','biz_type','screening_type','screening_switch','grass_region'])
    spark_df = spark.createDataFrame(pd_df)
    spark_df.write.format("hive").insertInto("risk.dim_risk_af_listname_priority",True)




