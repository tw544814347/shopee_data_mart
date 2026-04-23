#!/usr/bin/python
# -*- coding: utf-8 -*-
import json
import os
import argparse
import re
import sys
from datetime import datetime,timedelta

import requests
from pyspark.sql import SparkSession
from pyspark.conf import SparkConf
from pyspark.sql.functions import col


def date_diff(data=None,count=60,date_format='%Y-%m-%d'):

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
            "accesskey":"risk_feature" if args.accesskey is None else args.accesskey,
            "secretkey":"bSc1Ua7jqqIw" if args.secretkey is None else args.secretkey,
            "endpoint":"s3g.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
            "grass_date":args.gs,
            "s3filename":args.filename,
            "filenum":20 if args.filenum is None else args.filenum,
            "fileformat":'avro' if args.fileformat is None else args.fileformat,
            "fileheader":True if args.fileheader is None else args.fileheader,
        },
        "staging": {
            "bucketname":args.bucketname,
            "path":args.path,
            "accesskey":"staging_risk" if args.accesskey is None else args.accesskey,
            "secretkey":"2b8mNHsyckCY" if args.secretkey is None else args.secretkey,
            "endpoint":"s3g-uat.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
            "grass_date":args.gs,
            "s3filename":args.filename+"_"+args.gs.replace("-",""),
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

    print(str_sql)
    df= spark.sql(str_sql)
    task_id_list = df.groupBy("task_id").agg(col("task_id")).collect()
    print(f"task_id_list:{task_id_list}")
    for task_id in task_id_list:
        task_id = task_id[0]
        task_date = task_id.split("_")[0]
        print(f"task_id:{task_id}")
        # 本脚本上传S3的文件名，根据task_id来生成，不是传参的filename
        args_config[env]['s3filename'] = task_id
        task_df = df.filter(col("task_id") == task_id).select(
            col("row_num").alias("No"),
            col("backtest_date").alias("Backtest date"),
            col("id_type").alias("ID Type"),
            col("id_no").alias("ID Number"),
            col("phone_no").alias("Mobile Number"),
            col("hit_list_type").alias("Blacklist (1) or Greylist (2)"),
            col("reason_code").alias("Reason Code"),
            col("score").alias("ST Score"),
            col("name").alias("Name"),
            col("dob").alias("Date of Birth")
        )
        # 修改路径结构：增加task_id子目录
        filepath = "s3a://{bucketname}/{path}/{task_date}/{task_id}/".format(
            bucketname=args_config[env]['bucketname'],
            path=args_config[env]['path'],
            task_id=task_id,
            task_date=task_date
        )
        print(filepath)
        task_df.repartition(args_config[env]['filenum']).write.format(args_config[env]['fileformat']).option("header", args_config[env]['fileheader']).option("mapreduce.fileoutputcommitter.marksuccessfuljobs", "false").mode("Overwrite").save(filepath)

        print("s3apath s3a=%s"%filepath)
        if fs.exists(Path(filepath)):
            fileindex=1
            for f in fs.listStatus(Path(filepath)):
                print(f.getPath().toString())
                if(f.getPath().getName().startswith("part-")):
                    fs.rename(f.getPath(),Path(filepath + "{s3filename}_{fileindex}.{fileformat}".format(**args_config[env],fileindex=str(fileindex).zfill(3))))
                    fileindex = fileindex+1
            for f in fs.listStatus(Path(filepath)):
                print(f.getPath().toString())

        # 手动创建 _SUCCESS 文件
        success_file_path = filepath + "_SUCCESS"
        success_stream = fs.create(Path(success_file_path))
        success_stream.close()
        print("create success file=[%s] ok." % success_file_path)