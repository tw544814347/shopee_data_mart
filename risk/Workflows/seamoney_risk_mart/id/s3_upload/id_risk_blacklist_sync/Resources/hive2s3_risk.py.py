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
from pyspark.sql.functions import col


def date_diff(data=None,count=1,date_format='%Y-%m-%d'):

    if data is None:
        data = datetime.now().strftime(date_format)
    # 将时间字符串转换为 datetime 格式的时间
    today = datetime.strptime(data, date_format)
    offset = timedelta(days=count)
    re_date = (today - offset).strftime(date_format)
    return re_date

# 告警
def alert(c,seatalk_url="https://openapi.seatalk.io/webhook/group/DpIS_B2TTNes-mtlYPf6PA",email_list=[]):
    content=str(c)
    post_data = {
        "tag": "text",
        "text": {
            "content": content,
        }
    }
    if len(email_list)!=0:
        post_data['text']['mentioned_email_list']=email_list
    data = json.dumps(post_data)
    headers = {'Content-Type': 'application/json'}
    response=requests.request("POST", url=seatalk_url, headers=headers, data=data)
    print(response.text)
    result_json=json.loads(response.text)

    if result_json["code"]==3:
        alert(content[:1000]+"...more...",seatalk_url,email_list)


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
           "accesskey":"risk" if args.accesskey is None else args.accesskey,
           "secretkey":"v1PoyCyyvmxL" if args.secretkey is None else args.secretkey,
           "endpoint":"s3g.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
           "grass_date":args.gs,
           "s3filename":args.filename+"_"+args.gs.replace("-",""),
           "filenum":20 if args.filenum is None else args.filenum,
           "fileformat":'csv' if args.fileformat is None else args.fileformat,
           "fileheader":True if args.fileheader is None else args.fileheader,
        },
        "staging": {
           "bucketname":args.bucketname,
           "path":args.path,
           "accesskey":"mingcheng.he" if args.accesskey is None else args.accesskey,
           "secretkey":"cTfCN3NbPZGK" if args.secretkey is None else args.secretkey,
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

    filepath = "s3a://{bucketname}/{path}/{file_date}/".format(**args_config[env],file_date=args.gs.replace("-",""))

    #default 10days before
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
    # 通过group by status分组
    grouped_df = df.groupBy("status").count()
    now = datetime.now()
    current_hour = now.hour
    # 检查是否所有分组的status都等于-1
    all_pass = (
        grouped_df.filter(col("status") == -1).count() == grouped_df.count()
        and grouped_df.count()>0
    )
    if  all_pass:
        print("数据status全都是-1,跳过同步数据")
        email_list=[]
        # 上午批次不告警,因为可能会存在推送名单时间与名单跑数时间冲突的晴空,导致status全都是-1
        # 下午批次全都是-1 才发出告警
        if current_hour>12:
            seatalk_url="https://openapi.seatalk.io/webhook/group/DpIS_B2TTNes-mtlYPf6PA"
            alert("\ndqc type:Holmes listname DQC \nenvironment:prod\nGrass_date:{grass_date}\nWarn_msg:\n{list_name} all data status=-1".format(list_name=args.filename,grass_date=args.gs),seatalk_url,email_list)
        else:
            print("{list_name}上午批次数据status全都是-1,跳过同步数据".format(list_name=args.filename))
    else:
        print("数据无异常,同步至s3")
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
