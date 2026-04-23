#!/usr/bin/python
# -*- encoding: utf-8
import json
import os
import argparse
import re
import sys
from datetime import datetime,timedelta
import time 

import requests
from pyspark.sql import SparkSession
from pyspark.conf import SparkConf
from pyspark.sql.functions import col



def hive_to_s3(spark: SparkSession, region,product_line,db_tab,schema,grass_date,args, args_config,mode_type):
    env=args.env
    str_sql ="""
    select 
    region
    ,product_line
    ,db_tab
    ,grass_date
    ,datacount
    from {schema}.temp__brus_datacount_statistics_s3_us
     where grass_date ='{grass_date}'
    and region ='{region}'
    and product_line ='{product_line}'
    and db_tab ='{db_tab}'
    """.format(region=region,product_line=product_line,db_tab=db_tab,grass_date=grass_date,schema=schema)
    print('sql-->',str_sql)
    df = spark.sql(str_sql)
    #导数至S3的文件命名
    s3filename = str(db_tab)
    #导数至S3的地址
    # region = args.region 
    # lower_region =str(region).lower()
    path = "temp__brus_datacount_statistics_s3_us/region={region}/product_line={product_line}/db_tab={db_tab}/grass_date={grass_date}".format(region=region,product_line=product_line,db_tab=db_tab,grass_date=grass_date)

    filepath = "s3a://{bucketname}/{path}/".format(**args_config[env], path=path, )
    df.repartition(args_config[env]['filenum']).write.format(args_config[env]['fileformat']).option("header", True).mode("{mode_type}".format(mode_type=mode_type)).save(filepath)
    print('filepath-->',filepath)
    print('s3filename-->',s3filename)
    sc = spark.sparkContext
    Path = sc._gateway.jvm.org.apache.hadoop.fs.Path
    FileSystem = sc._gateway.jvm.org.apache.hadoop.fs.FileSystem
    fs = FileSystem.get(sc._jvm.java.net.URI.create("s3a://{bucketname}".format(**args_config[env])),sc._jsc.hadoopConfiguration())

    print("s3apath s3a=%s"%filepath)
    if fs.exists(Path(filepath)):
        fileindex=1
        for f in fs.listStatus(Path(filepath)):
            print(f.getPath().toString())
            if(f.getPath().getName().startswith("part-")):
                fs.rename(f.getPath(),Path(filepath + "{s3filename}_{fileindex}.{fileformat}".format(**args_config[env],s3filename=s3filename,fileindex=str(fileindex).zfill(3))))
                fileindex = fileindex+1

        for f in fs.listStatus(Path(filepath)):
            print(f.getPath().toString())


if __name__ == "__main__":
    # parse parameters
    parser = argparse.ArgumentParser(description='HiveToS3 tools')
    parser.add_argument('-env', type=str, required=True)
    parser.add_argument('-bucketname', type=str, required=True )
    parser.add_argument('-gs', type=str, required=True)
    parser.add_argument('-schema', type=str, required=True)


    args = parser.parse_args()
    env=args.env

    args_config = {
        "live": {
            "bucketname":args.bucketname,
        #     "accesskey":"risk",
        #    "secretkey":"v1PoyCyyvmxL",
            "accesskey":"zongyi.lu",
           "secretkey":"4kgnyF27zxhh",
            "endpoint":"us.s3g.data-infra.shopee.io" ,
            "grass_date":args.gs,
            "schema":args.schema,
            "filenum":1,
            "fileformat":'parquet',
        },

    }

    conf = SparkConf() \
        .set("spark.s3.enabled", True) \
        .set("spark.hadoop.fs.s3a.path.style.access", True) \
        .set("spark.hadoop.fs.s3a.bucket.{bucketname}.access.key".format(**args_config[env]), "{accesskey}".format(**args_config[env])) \
        .set("spark.hadoop.fs.s3a.bucket.{bucketname}.secret.key".format(**args_config[env]), "{secretkey}".format(**args_config[env])) \
        .set("spark.hadoop.fs.s3a.bucket.{bucketname}.endpoint".format(**args_config[env]), "{endpoint}".format(**args_config[env])) \
        .set("fs.s3a.change.detection.version.required", False) \
        .set("fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")

    spark = SparkSession \
        .builder \
        .config(conf=conf) \
        .appName("HiveToS3") \
        .enableHiveSupport() \
        .getOrCreate()
    sql = """
    select 
    region
    ,product_line
    ,db_tab
    ,grass_date
    from {schema}.temp__brus_datacount_statistics_s3_us
     where grass_date ='{grass_date}'
     and region='US'
    group by region
    ,product_line
    ,db_tab
    ,grass_date
    """.format(grass_date=args.gs,schema=args.schema)
    table_df = spark.sql(sql).toPandas()
    mode_type = "Overwrite"
    for i in range(len(table_df)):
        row = table_df.iloc[i] 
        region = row['region']
        product_line = row['product_line']
        db_tab = row['db_tab']
        grass_date = row['grass_date']
        schema=args.schema
        print('table_info-->',region,'--',product_line,'--',db_tab,'--',schema,'--',grass_date)
        hive_to_s3(spark, region,product_line,db_tab,schema,grass_date,args, args_config,mode_type)
        mode_type = "Append"



