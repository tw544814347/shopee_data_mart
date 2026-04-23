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


def date_diff(data=None,count=2,date_format='%Y-%m-%d'):

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
        #    "accesskey":"credit_sync" if args.accesskey is None else args.accesskey,
        #    "secretkey":"DKQhI5RyXIzt" if args.secretkey is None else args.secretkey,
           "endpoint":"s3g.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
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
    sc = spark.sparkContext
    Path = sc._gateway.jvm.org.apache.hadoop.fs.Path
    FileSystem = sc._gateway.jvm.org.apache.hadoop.fs.FileSystem
    conf = sc._gateway.jvm.org.apache.hadoop.conf.Configuration
    fs = FileSystem.get(sc._jvm.java.net.URI.create("s3a://{bucketname}".format(**args_config[env])),sc._jsc.hadoopConfiguration())
    filepath_list  = [
        's3a://risk-feature/ID/dws_debt_biz_plan_df'
        ]

    for del_path in filepath_list:
        print("s3apath=[%s]"%del_path)
        if fs.exists(Path(del_path)):
            fs.delete(Path(del_path), True)
            print("del s3apath=[%s] ok." %del_path)
        else:
            print("Not found s3apath=[%s]"%del_path)
