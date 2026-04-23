#!/usr/bin/python
# -*- encoding: utf-8
import json
import os
import argparse
import re
import sys
from datetime import datetime,timedelta

import requests
from pyspark.sql import SparkSession
from pyspark.conf import SparkConf


def date_diff(data=None,count=3,date_format='%Y-%m-%d'):

    if data is None:
        data = datetime.now().strftime(date_format)
    # 将时间字符串转换为 datetime 格式的时间
    today = datetime.strptime(data, date_format)
    offset = timedelta(days=count)
    re_date = (today - offset).strftime(date_format)
    return re_date


def hive_to_s3(spark: SparkSession, region,biz_type, list_name,de_table_info,condition, args, args_config,detable):
    env=args.env
    table_name = list_name
    index=0
        
    sql_union = """
    select 
        data
        ,datatype
        ,remark
        ,description
        ,status 
        ,table_name as detable
    from risk.ads_risk_br_blacklist_di
    where grass_date =date_sub('{grass_date}',1) 
    and table_name='{detable}'  """.format(grass_date=args.gs,biz_type=biz_type,detable=detable)
                    
    str_sql = sql_union
    print(str_sql)
    df = spark.sql(str_sql)

    #导数至S3的文件命名
    s3filename = table_name+"_"+args.gs.replace("-","")
    #导数至S3的地址
    path = "{region}/{biz_type}/{table_name}".format(**args_config[env],region=region,biz_type=biz_type, table_name=table_name)

    #定期清理路径
    del_path= "s3a://{bucketname}/{path}/{del_date}/".format(**args_config[env], path=path, del_date=date_diff('{grass_date}'.format(**args_config[env])).replace("-",""))

    filepath = "s3a://{bucketname}/{path}/{file_date}/".format(**args_config[env], path=path, file_date=args.gs.replace("-",""))
    df.repartition(args_config[env]['filenum']).write.format(args_config[env]['fileformat']).option("header", args_config[env]['fileheader']).mode("Overwrite").save(filepath)

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
        #             print("s3a=%s"%filepath)

        for f in fs.listStatus(Path(filepath)):
            print(f.getPath().toString())

    else:
        print("Not found s3apath=[%s]"%del_path)


if __name__ == "__main__":
    # parse parameters
    parser = argparse.ArgumentParser(description='HiveToS3 tools')
    parser.add_argument('-env', type=str, required=True)
    parser.add_argument('-bucketname', type=str, required=True )
    parser.add_argument('-gs', type=str, required=True)
    parser.add_argument('-accesskey', type=str, required=False)
    parser.add_argument('-secretkey', type=str, required=False)
    parser.add_argument('-endpoint', type=str, required=False)
    parser.add_argument('-filenum', type=int, required=False)
    parser.add_argument('-fileformat', type=str, required=False)
    parser.add_argument('-fileheader', type=str, required=False)


    args = parser.parse_args()
    env=args.env

    args_config = {
        "live": {
           "bucketname":args.bucketname,
           "accesskey":"risk" if args.accesskey is None else args.accesskey,
           "secretkey":"v1PoyCyyvmxL" if args.secretkey is None else args.secretkey,
           "endpoint":"us.s3g.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
           "grass_date":args.gs,
           "filenum":20 if args.filenum is None else args.filenum,
           "fileformat":'csv' if args.fileformat is None else args.fileformat,
           "fileheader":True if args.fileheader is None else args.fileheader,
        },
        "staging": {
            "bucketname":args.bucketname,
            "accesskey":"staging_risk" if args.accesskey is None else args.accesskey,
            "secretkey":"2b8mNHsyckCY" if args.secretkey is None else args.secretkey,
            "endpoint":"s3g-uat.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
            "grass_date":args.gs,
            "filenum":20 if args.filenum is None else args.filenum,
            "fileformat":'avro' if args.fileformat is None else args.fileformat,
            "fileheader":True if args.fileheader is None else args.fileheader,
        }
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
        'credit' biz_type 
        ,table_name
        ,description as list_name
    from risk.ads_risk_br_blacklist_di
    where grass_date =date_sub('{grass_date}',1)
    group by table_name
        ,description
    """.format(grass_date=args.gs)
    listname_df = spark.sql(sql).toPandas()
    for i in range(len(listname_df)):
        row = listname_df.iloc[i] 
        biz_type = row['biz_type']
        detable = row['table_name']
        de_table_info = 'BR'
        list_name = row['list_name']
        filter_cond=''
        table_region='BR'
        table_biz_type=''
        hive_to_s3(spark, table_region, biz_type ,list_name,de_table_info,filter_cond, args, args_config,detable)




