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


def hive_to_s3(spark: SparkSession, region,biz_type, list_name,de_table_info,condition, args, args_config):
    env=args.env
    db_table_name = list_name
    table_name = db_table_name
    db_name = 'smcdrisk_antifraud'
    index=0
    sql_tamplate =""
    for de_table in de_table_info:
        if spark.catalog._jcatalog.tableExists(db_name, de_table.split(':')[0]):
            print(de_table.split(':')[0],'exists')
            de_table_name = de_table.split(':')[0]
            priority = de_table.split(':')[1]
            sub_sql = """
            select 
            data
            ,datatype
            ,'DE daily update {gs}' as remark
            ,'{db_table_name}'as description
            ,status 
            ,'{de_table_name}' as  detable 
            ,{priority} as priority
            from smcdrisk_antifraud.{de_table_name} 
            where 1=1 
            {condition}""".format(gs=args.gs,db_table_name=db_table_name,de_table_name=de_table_name,priority=priority,condition=condition)
            if index==0:
                sql_tamplate = sub_sql
            else:
                sql_tamplate =sql_tamplate + '  union all  '+sub_sql 
            index = index+1
        else:
            print(db_table_name,'does not exists')
        
    sql_union = """
    select 
        data
        ,datatype
        ,remark
        ,description
        ,status 
        ,detable
    from (
        select 
            data
            ,datatype
            ,remark
            ,description
            ,status 
            ,detable
            ,row_number() over(partition by data,datatype order by priority asc) rn 
        from ({sql_tamplate}) a
        ) a 
    where rn =1  """.format(sql_tamplate=sql_tamplate)
                    
    str_sql = sql_union
    print(str_sql)
    df = spark.sql(str_sql)
    from datetime import datetime
    current_hour = datetime.now().strftime("%H")
    print("current_hour->>>",current_hour)

    #导数至S3的文件命名
    s3filename = table_name+"_"+args.gs.replace("-","")+str(current_hour)
    #导数至S3的地址
    path = "{region}/{biz_type}/{table_name}".format(**args_config[env],region=region,biz_type=biz_type, table_name=table_name)

    #定期清理路径
    del_path= "s3a://{bucketname}/{path}/{del_date}/".format(**args_config[env], path=path, del_date=date_diff('{grass_date}'.format(**args_config[env])).replace("-",""))

    filepath = "s3a://{bucketname}/{path}/{file_date}/{current_hour}/".format(**args_config[env], path=path, file_date=args.gs.replace("-",""),current_hour=current_hour)
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

    # print("s3apath=[%s]"%del_path)
    # if fs.exists(Path(del_path)):
    #     fs.delete(Path(del_path), True)
    #     print("del s3apath=[%s] ok." %del_path)
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
            "endpoint":"s3g.data-infra.shopee.io" if args.endpoint is None else args.endpoint,
            "grass_date":args.gs,
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
        a.region 
        ,a.biz_type
        ,b.list_name 
        ,collect_set(concat(a.de_table_name,':',b.priority)) de_table_info 
    from risk.dim_risk_list_name a 
    join (
        select 
        list_name
        ,de_table_name 
        ,cast(priority as string ) priority
        ,grass_region
        from risk.dim_risk_af_listname_priority
        group by 
        list_name
        ,de_table_name 
        ,priority
        ,grass_region
    ) b on a.region = b.grass_region and  a.de_table_name = b.de_table_name 
    where a.import_type='incremental'
    and a.biz_type='credit'
    and a.region  not in('TW','VN','SG','TH','PH','MY','ID')
    and a.create_date>='2023-08-01' 
    group by a.region 
        ,a.biz_type
        ,b.list_name
    """
    listname_df = spark.sql(sql).toPandas()
    for i in range(len(listname_df)):
        row = listname_df.iloc[i] 
        table_region = row['region']
        table_biz_type = row['biz_type']
        de_table_info = row['de_table_info'] 
        list_name = row['list_name']
        print(table_region,'->',table_biz_type,'->',list_name,'->',de_table_info)
        filter_cond=''
        hive_to_s3(spark, table_region, table_biz_type ,list_name,de_table_info,filter_cond, args, args_config)



