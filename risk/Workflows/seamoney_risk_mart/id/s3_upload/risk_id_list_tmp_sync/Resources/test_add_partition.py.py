#!/usr/bin/python
# -*- encoding: utf-8
import os
import sys
import datetime
import requests
import json
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
import pandas as pd 

import requests
from pyspark.sql import SparkSession
from pyspark.conf import SparkConf

grass_date = (datetime.datetime.today() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")
print(grass_date)


if __name__ == "__main__":
    spark = SparkSession \
        .builder \
        .appName("dim_risk_af_listname_priority") \
        .enableHiveSupport() \
        .getOrCreate()
    region_list =['ID','MY','PH','TH','BR']
    # region_list =['MY']
    sql = """
    select 
    'ID' as grass_region 
    ,tn
    ,scene_id 
    ,grass_date
    ,dt 
    ,count(1) cnt 
    from risk.ods_risk_live_kafka_gateway_req_rsp_di_id
    where dt>=date_sub('{grass_date}',1)
    group by tn
    ,scene_id 
    ,grass_date
    ,dt 
    """
    col_df = spark.sql(sql.format(grass_date=grass_date)).toPandas()
    for i in range(len(col_df)):
        raw=col_df.iloc[i]
        grass_region = raw['grass_region']
        tn = raw['tn']
        scene_id = raw['scene_id']
        grass_date = raw['grass_date']
        dt = raw['dt']
        # add_partition_sql="""alter table risk.ods_risk_live_kafka_gateway_req_rsp_di add if not exists partition(grass_region='{grass_region}',tn='{tn}',scene_id='{scene_id}',grass_date='{grass_date}',dt='{dt}')""".format(grass_region=grass_region,tn=tn,scene_id=scene_id,grass_date=grass_date,dt=dt)
        # print('add_partition_sql====>',add_partition_sql)
        # result_df=spark.sql(add_partition_sql)
        # if result_df.count() >= 0:
        #     print("Execute SQL statement successfully!")
        # else:
        #     print("Fail to execute SQL statement!")