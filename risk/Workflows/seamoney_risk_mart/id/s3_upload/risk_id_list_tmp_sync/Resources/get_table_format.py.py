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
    sql = """
    select 
    schema
    ,table_name
    ,total_bytes
    ,last7_day_query_count
    ,location
    ,output_format
    ,case when instr(location,'ingestion') >0 then 'ingestion'
        when instr(location,'risk_kafka') >0 then 'risk_kafka'
        when instr(location,'risk_mart') >0 then 'risk_mart'
        when instr(location,'projects/risk/hdfs/prod/ods') >0 then 'risk_ods'
        when instr(location,'projects/risk/hdfs/prod/ads') >0 then 'risk_mart'
        when instr(location,'projects/risk/hdfs/prod/dwd') >0 then 'risk_mart'
        when instr(location,'projects/risk/hdfs/prod/dws') >0 then 'risk_mart'
        when instr(location,'projects/risk/hdfs/prod/dim') >0 then 'risk_mart'
        when instr(location,'projects/risk/hdfs/prod/risk_feature') >0 then 'risk_feature'
        else 'other' end table_type 
    from (
    select 
    schema
    ,table_name
    ,total_bytes
    ,last7_day_query_count
    ,get_json_object(metadata,'$.location') location
    ,get_json_object(metadata,'$.outputFormat') output_format
    ,row_number() over(partition by get_json_object(metadata,'$.location') order by create_time desc) rn 
    from data_metamart.dim_datamap_hive_table_info_df
    where grass_date='2024-04-04'
    and schema='risk'
    and status='Active'
    and idc_region='SG'
    and table_name not like 'ods%'
    and table_name not like '%test%'
    ) a 
    where rn =1 
    """
    desc_sql = 'DESCRIBE FORMATTED {schema}.{table_name}'
    col_df = spark.sql(sql.format(grass_date=grass_date)).toPandas()
    for i in range(len(col_df)):
        raw=col_df.iloc[i]
        schema = raw['schema']
        table_name = raw['table_name']
        total_bytes = raw['total_bytes']
        last7_day_query_count = raw['last7_day_query_count']
        location = raw['location']
        output_format = raw['output_format'].replace('org.apache.hadoop.hive.ql.io.','')
        table_type = raw['table_type']

        if spark.catalog._jcatalog.tableExists(schema, table_name):
            print(schema,'.',table_name,' ---->exists')        
            data_type_df =spark.sql(desc_sql.format(schema=schema,table_name=table_name)).filter("col_name = 'Table Properties'").select('data_type').rdd.flatMap(lambda x: x).collect()
            data_type=",".join(str(x) for x in data_type_df)
            if 'snappy' in data_type.lower():
                compress_type='snappy'
            elif 'zstd' in data_type.lower():
                compress_type='zstd'
            else :
                compress_type='snappy'
            
            print(schema,';',table_name,';',total_bytes,';',last7_day_query_count,';',location,';',table_type,';',output_format,';',compress_type)
        else :
            print(schema,'.',table_name,' ---->not exists')