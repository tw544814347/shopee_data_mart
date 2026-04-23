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



def date_diff(data=None,count=3,date_format='%Y-%m-%d'):

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



def hive_to_s3(spark: SparkSession, referral_id,args, args_config,mode_type):
    env=args.env
    str_sql ="""
    select 
        platform_type     
        ,platform_user_id 
        ,referral_id      
        ,user_referral_id 
        ,cast(completed_value as string) as completed_value
    from(
        select 
        referrer_platform_type as platform_type     
        ,referee_platform_user_id as platform_user_id 
        ,referral_id      
        ,user_referral_id 
        ,count(distinct referee_order_id)  as completed_value 
        from {table_name}
        where grass_date =date_sub('{grass_date}',1)
        and referral_id ={referral_id}
        group by referrer_platform_type     
        ,referee_platform_user_id 
        ,referral_id      
        ,user_referral_id
    ) a 
    """.format(grass_date=args.gs,table_name=args.table_name,referral_id=referral_id)
    rs_df = spark.sql(str_sql)
    df = rs_df.filter(col("platform_type") == "1").select(
            col("platform_type").alias("platformType"),
            col("platform_user_id").alias("platformUserId"),
            col("user_referral_id").alias("userReferralId"),
            col("completed_value").alias("completedValue"),
    )
    print('sql-->',str_sql)
    #导数至S3的文件命名
    s3filename = args.gs.replace("-","")+"_"+str(referral_id)
    #导数至S3的地址
    region = args.region 
    lower_region =str(region).lower()
    path = "{region}/{file_env}/{path_name}".format(**args_config[env],lower_region=lower_region)

    #定期清理路径
    del_path= "s3a://{bucketname}/{path}/{del_date}/".format(**args_config[env], path=path, del_date=date_diff('{grass_date}'.format(**args_config[env])).replace("-",""))

    filepath = "s3a://{bucketname}/{path}/{file_date}/".format(**args_config[env], path=path, file_date=args.gs.replace("-",""))
    df.repartition(args_config[env]['filenum']).write.format(args_config[env]['fileformat']).option("header", args_config[env]['fileheader']).mode("{mode_type}".format(mode_type=mode_type)).save(filepath)
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
    parser.add_argument('-file_env', type=str, required=True)
    parser.add_argument('-region', type=str, required=True)
    parser.add_argument('-table_name', type=str, required=True)
    parser.add_argument('-path_name', type=str, required=True)
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
            "accesskey":"credit_sync" if args.accesskey is None else args.accesskey,
            "secretkey":"DKQhI5RyXIzt" if args.secretkey is None else args.secretkey,
            "endpoint":"s3g.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
            "grass_date":args.gs,
            "file_env":args.file_env,
            "path_name":args.path_name,
            "region":args.region,
            "table_name":args.table_name,
            "filenum":20 if args.filenum is None else args.filenum,
            "fileformat":'avro' if args.fileformat is None else args.fileformat,
            "fileheader":True if args.fileheader is None else args.fileheader,
        },
        "staging": {
            "bucketname":args.bucketname,
            "accesskey":"staging_risk" if args.accesskey is None else args.accesskey,
            "secretkey":"2b8mNHsyckCY" if args.secretkey is None else args.secretkey,
            "endpoint":"s3g-uat.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
            "grass_date":args.gs,
            "file_env":args.file_env,
            "path_name":args.path_name,
            "region":args.region,
            "table_name":args.table_name,
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
    referral_id
    from {table_name}
    where grass_date =date_sub('{grass_date}',1)
    group by referral_id
    """.format(grass_date=args.gs,table_name=args.table_name)
    referral_id_df = spark.sql(sql).toPandas()
    mode_type = "Overwrite"
    for i in range(len(referral_id_df)):
        row = referral_id_df.iloc[i] 
        referral_id = row['referral_id']
        print('referral_id-->',referral_id)
        hive_to_s3(spark, referral_id,args, args_config,mode_type)
        mode_type = "Append"
        #update by 2024-12-18 发现s3处理缺了，不知道是不是太频繁了，先处理一个mission就等2分钟
        time.sleep(120)



