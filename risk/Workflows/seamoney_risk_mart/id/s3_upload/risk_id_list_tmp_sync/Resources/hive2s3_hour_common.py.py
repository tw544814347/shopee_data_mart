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

if __name__ == "__main__":
    # parse parameters
    parser = argparse.ArgumentParser(description='HiveToS3 tools')
    parser.add_argument('-env', type=str, required=True)
    parser.add_argument('-bucketname', type=str, required=True )
    parser.add_argument('-sql', type=str, required=True)
    parser.add_argument('-gs', type=str, required=True)
    parser.add_argument('-hour', type=str, required=True)
    parser.add_argument('-path', type=str, required=True)
    parser.add_argument('-filename', type=str, required=True)
    parser.add_argument('-accesskey', type=str, required=False)
    parser.add_argument('-secretkey', type=str, required=False)
    parser.add_argument('-endpoint', type=str, required=False)
    parser.add_argument('-filenum', type=int, required=False)
    parser.add_argument('-fileformat', type=str, required=False)
    parser.add_argument('-fileheader', type=str, required=False)

    args = parser.parse_args()
    env=args.env
    str_sql=args.sql

    args_config = {
        "live": {
           "bucketname":args.bucketname,
           "path":args.path,
           "accesskey":"risk" if args.accesskey is None else args.accesskey,
           "secretkey":"v1PoyCyyvmxL" if args.secretkey is None else args.secretkey,
           "endpoint":"s3g.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
           "grass_date":args.gs,
           "s3filename":args.filename+"_"+args.gs.replace("-","")+"_"+args.hour,
           "filenum":20 if args.filenum is None else args.filenum,
           "fileformat":'csv' if args.fileformat is None else args.fileformat,
           "fileheader":True if args.fileheader is None else args.fileheader,
        },
        "staging": {
           "bucketname":args.bucketname,
           "path":args.path,
           "accesskey":"zongyi.lu" if args.accesskey is None else args.accesskey,
           "secretkey":"ahJsjlryGu4I" if args.secretkey is None else args.secretkey,
           "endpoint":"s3g-uat.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
           "grass_date":args.gs,
           "s3filename":args.filename+"_"+args.gs.replace("-","")+"_"+args.hour,
           "filenum":20 if args.filenum is None else args.filenum,
           "fileformat":'csv' if args.fileformat is None else args.fileformat,
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
    now = datetime.now()

    # 提取当前小时
    current_hour = now.hour
    # print('current_hour -->>',current_hour)
    filepath = "s3a://{bucketname}/{path}/{file_date}/{hour}/".format(**args_config[env],file_date=args.gs.replace("-",""),hour=current_hour)

    #default 2days before
    del_path= "s3a://{bucketname}/{path}/{del_date}/".format(**args_config[env],del_date=date_diff('{grass_date}'.format(**args_config[env])).replace("-",""))
    spark = SparkSession \
             .builder \
             .config(conf=conf) \
             .appName("HiveToS3") \
             .enableHiveSupport() \
             .getOrCreate()
    print(str_sql)
    print(filepath)

    df= spark.sql(str_sql)
    print('df.count()->>>>>',df.count())
    if df.count() > 0:
        df.repartition(args_config[env]['filenum']).write.format(args_config[env]['fileformat']).option("header", args_config[env]['fileheader']).mode("Overwrite").save(filepath)
        sc = spark.sparkContext
        Path = sc._gateway.jvm.org.apache.hadoop.fs.Path
        FileSystem = sc._gateway.jvm.org.apache.hadoop.fs.FileSystem
        conf = sc._gateway.jvm.org.apache.hadoop.conf.Configuration
        fs = FileSystem.get(sc._jvm.java.net.URI.create("s3a://{bucketname}".format(**args_config[env])),sc._jsc.hadoopConfiguration())

        print("s3apath s3a=%s"%filepath)
        if fs.exists(Path(filepath)):
            fileindex=1
            for f in fs.listStatus(Path(filepath)):
                print(f.getPath().toString())
                if(f.getPath().getName().startswith("part-")):
                    fs.rename(f.getPath(),Path(filepath + "{s3filename}_{fileindex}.{fileformat}".format(**args_config[env],fileindex=str(fileindex).zfill(3))))
                    fileindex = fileindex+1
    #             print("s3a=%s"%filepath)

            for f in fs.listStatus(Path(filepath)):
                print(f.getPath().toString())

        print("s3apath=[%s]"%del_path)
        if fs.exists(Path(del_path)):
            fs.delete(Path(del_path), True)
            print("del s3apath=[%s] ok." %del_path)
        else:
            print("Not found s3apath=[%s]"%del_path)
    else:
        print('数据为0,不上传数据')
