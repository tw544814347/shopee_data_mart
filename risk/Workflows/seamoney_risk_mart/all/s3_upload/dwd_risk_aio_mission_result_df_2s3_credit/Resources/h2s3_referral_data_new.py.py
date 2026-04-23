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

def wait_for_success_file(fs,Path, temp_path, max_retries=30, delay=2):
    """
    等待 `_SUCCESS` 文件生成以确认写入完成。

    参数:
        fs: FileSystem 对象。
        temp_path: 临时存储路径。
        max_retries: 最大重试次数。
        delay: 每次重试的时间间隔（秒）。

    返回:
        True:如果 `_SUCCESS` 文件已生成。
        False:如果达到最大重试次数仍未生成。
    """
    retries = 0
    success_file_path = f"{temp_path}_SUCCESS"

    while retries < max_retries:
        try:
            if fs.exists(Path(success_file_path)):
                print(f"检测到 `_SUCCESS` 文件: {success_file_path}")
                return True
        except Exception as e:
            print(f"检查 `_SUCCESS` 文件时发生异常: {e}")

        retries += 1
        print(f"重试 {retries}/{max_retries}: 等待 `_SUCCESS` 文件...")
        time.sleep(delay)

    print(f"超时：在 {temp_path} 未检测到 `_SUCCESS` 文件，达到最大重试次数 {max_retries}。")

    return False


def hive_to_s3(spark: SparkSession,args, args_config,mode_type):
    try:
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
            and referrer_platform_type='1'
            group by referrer_platform_type     
            ,referee_platform_user_id 
            ,referral_id      
            ,user_referral_id
        ) a 
        """.format(grass_date=args.gs,table_name=args.table_name)
        print('sql-->',str_sql)
        rs_df = spark.sql(str_sql)

        # 获取所有 unique 的 referral_id
        referral_ids = rs_df.select("referral_id").distinct().collect()

        sc = spark.sparkContext
        Path = sc._gateway.jvm.org.apache.hadoop.fs.Path
        FileSystem = sc._gateway.jvm.org.apache.hadoop.fs.FileSystem
        fs = FileSystem.get(sc._jvm.java.net.URI.create("s3a://{bucketname}".format(**args_config[env])),sc._jsc.hadoopConfiguration())
        
        #导数至S3的地址
        region = args.region 
        lower_region =str(region).lower()
        path = "{region}/{file_env}/{path_name}".format(**args_config[env],lower_region=lower_region)

        #定期清理路径
        # del_path= "s3a://{bucketname}/{path}/{del_date}/".format(**args_config[env], path=path, del_date=date_diff('{grass_date}'.format(**args_config[env])).replace("-",""))

        filepath = "s3a://{bucketname}/{path}/{file_date}/".format(**args_config[env], path=path, file_date=args.gs.replace("-",""))
        # 删除已有的数据存储路径
        file_path = Path(filepath)
        if fs.exists(file_path):
            fs.delete(file_path, True)
            print(f"Deleted file path: {file_path}")
            
        # 遍历每个 referral_id 并按需保存
        for row in referral_ids:
            referral_id = row['referral_id']
            # 按 referral_id 筛选数据
            filtered_df = rs_df.filter(col("referral_id") == referral_id).select(
                col("platform_type").alias("platformType"),
                col("platform_user_id").alias("platformUserId"),
                col("user_referral_id").alias("userReferralId"),
                col("completed_value").alias("completedValue"),
            )

            #导数至S3的文件命名
            s3filename = args.gs.replace("-","")+"_"+str(referral_id)

            temp_path = f"{filepath}{referral_id}/"

            filtered_df.repartition(args_config[env]['filenum']).write.format(args_config[env]['fileformat']).option("header", args_config[env]['fileheader']).mode("{mode_type}".format(mode_type=mode_type)).save(temp_path)

            # 确保 `_SUCCESS` 文件生成
            if not wait_for_success_file(fs, Path,temp_path):
                print(f"写入失败：未在路径 {temp_path} 检测到 `_SUCCESS` 文件。")
                return
            # 获取并处理 `part-*` 文件
            try:
                part_files = [f for f in fs.listStatus(Path(temp_path)) if f.getPath().getName().startswith("part-")]
                if not part_files:
                    print(f"在路径 {temp_path} 中未找到 `part-*` 文件。")
                    return
            
                for i, part_file in enumerate(part_files, start=1):
                    new_name = f"{filepath}{s3filename}_{str(i).zfill(3)}.csv"
                    fs.rename(part_file.getPath(), Path(new_name))
                    print(f"Renamed {part_file.getPath()} to {new_name}")

                # print("s3apath s3a=%s"%filepath)
                # 删除临时存储路径
                temp_dir_path = Path(temp_path)
                if fs.exists(temp_dir_path):
                    fs.delete(temp_dir_path, True)
                    print(f"Deleted temporary path: {temp_path}")
            except Exception as e:
                print(f"处理 `part-*` 文件时发生错误: {e}")
    

        success_path = Path(f"{filepath}_SUCCESS")
        # 创建 _SUCCESS 文件
        if not fs.exists(success_path):
            fs.create(success_path).close()
            print(f"_SUCCESS file created at {filepath}")
        
        for f in fs.listStatus(Path(filepath)):
            print(f.getPath().toString())
         
         # 成功完成任务返回 True
        return True
    except Exception as e:
        print(f"Error in hive_to_s3 for: {e}")
        # 发生错误返回 False
        return False


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
    
    mode_type = "Overwrite"

    #update by dongbo.yu 2024-12-18   调用 hive_to_s3 并检查其返回值
    success = hive_to_s3(spark, args, args_config, mode_type)

    if not success:
        # 打印错误信息并记录失败任务
        c="Error occurred while processing {grass_date} {table_name}......".format(grass_date=args.gs,table_name=args.table_name)
        print(c)
        alert(c,seatalk_url='https://openapi.seatalk.io/webhook/group/XikEhDSNQYyTfiFMUkZh9g')
        sys.exit(1)
    