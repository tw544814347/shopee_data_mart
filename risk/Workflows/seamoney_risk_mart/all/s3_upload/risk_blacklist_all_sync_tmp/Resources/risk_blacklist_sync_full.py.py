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



def hive_to_s3(spark: SparkSession, region,biz_type, list_name,de_table_info,condition, args, args_config,biz_db,sensitive_tab,custom_list_id,biz_name):
    env=args.env
    db_table_name = list_name
    table_name = db_table_name
    db_name = 'smcdrisk_antifraud'
    index=0
    sql_tamplate =""
    risk_id_all_list_sql ="""
    with risk_{region}_all_list as(
    select
        t1.data          as data 
        ,t1.description  as table_name
        ,t1.data_type    as data_type 
        ,-1              as status
    from risk.dwd_risk_{region}_{biz_name}_custom_list_df t1 
    where grass_date =date_sub('{grass_date}',1)
    and data_source='DE'  
    and custom_list_id='{custom_list_id}'
    and status=1
        group by t1.data 
        ,t1.description
        ,t1.data_type
    )""".format(grass_date=args.gs,region=region.lower(),biz_name=biz_name,custom_list_id=custom_list_id)
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
            ,1 as status 
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
        data      as data
        ,datatype as datatype
        ,detable  as table_name
        ,status   as status
        
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

    sql_final = """
        select 
        data                             as data 
        ,datatype                        as datatype 
        ,'DE daily update {grass_date}' as remark         
        ,table_name                      as description     
        ,status                          as status  
        ,table_name                      as detable 
        from (
            select 
                data                     as data
                ,datatype                as datatype
                ,table_name              as table_name 
                ,'{grass_region}'        as grass_region 
                ,sum(status) as status 
            from (
                select
                    t1.data          as data 
                    ,t2.dict_name    as datatype
                    ,t1.table_name   as table_name
                    ,-1              as status
                from risk_{grass_region}_all_list t1 
                left join (
                    select 
                    dict_value
                    ,dict_name 
                    from risk.ods__{biz_db}_{grass_region}_db__dict_tab__df 
                    where grass_date=date_sub('{grass_date}',1)
                    and parent_dict_key='dataType' 
                    group by dict_value
                    ,dict_name 
                ) t2 on t1.data_type = t2.dict_value
                group by t1.data 
                ,t2.dict_name
                ,t1.table_name
                union all 
                {sql_union}
            ) a 
        group by data 
        ,datatype 
        ,table_name
        ) a 
        where status<>0
    """ .format(grass_date=args.gs,grass_region=region,sql_union=sql_union,biz_db=biz_db)

    insert_sql = """
    insert overwrite table risk.ads_risk_blacklist_full_df partition(grass_region,table_name,grass_date)
        select 
        data                             as data 
        ,datatype                        as datatype 
        ,'DE daily update {grass_date}' as remark         
        ,table_name                      as description     
        ,status                          as status  
        ,upper('{grass_region}')         as grass_region 
        ,table_name                      as table_name 
        ,'{grass_date}'                  as grass_date 
        from (
            select 
                data                     as data
                ,datatype                as datatype
                ,table_name              as table_name 
                ,'{grass_region}'        as grass_region 
                ,sum(status) as status 
            from (
                select
                    t1.data          as data 
                    ,t2.dict_name    as datatype
                    ,t1.table_name   as table_name
                    ,-1              as status
                from risk_{grass_region}_all_list t1 
                left join (
                    select 
                    dict_value
                    ,dict_name 
                    from risk.ods__{biz_db}_{grass_region}_db__dict_tab__df 
                    where grass_date=date_sub('{grass_date}',1)
                    and parent_dict_key='dataType' 
                    group by dict_value
                    ,dict_name 
                ) t2 on t1.data_type = t2.dict_value
                group by t1.data 
                ,t2.dict_name
                ,t1.table_name
                union all 
                {sql_union}
            ) a 
        group by data 
        ,datatype 
        ,table_name
        ) a 
        where status<>0
    """ .format(grass_date=args.gs,grass_region=region,sql_union=sql_union,biz_db=biz_db)
    str_sql_tmp ="""
        select  
        data                             as data 
        ,datatype                        as datatype 
        ,'DE daily update 2024-07-16'    as remark         
        ,table_name                      as description     
        ,'1'                             as status  
        ,table_name                      as detable
        from dev_risk.ads_risk_blacklist_full_df_20240716
        where grass_date='2024-07-16'
        and status='-1'
    """
          
    # str_sql = risk_id_all_list_sql + sql_final
    str_sql = str_sql_tmp
    time.sleep(60)
    df = spark.sql(str_sql)
    # 通过group by status分组
    grouped_df = df.groupBy("status").count()
    from datetime import datetime
    # current_hour = datetime.now().strftime("%H")
    current_hour = 18
    print("current_hour->>>",current_hour)
    # 检查是否所有分组的status都等于-1
    # -1 条数大于50条才告警,避免有些名单一天删几条数据也会触发告警
    all_pass = (
        grouped_df.filter(col("status") == -1).count() == grouped_df.count()
        and grouped_df.count()>50
    )
    if  all_pass:
        email_list=[]
        # 上午批次不告警,因为可能会存在推送名单时间与名单跑数时间冲突的晴空,导致status全都是-1
        # 下午批次全都是-1 才发出告警
        if current_hour>12:
            seatalk_url="https://openapi.seatalk.io/webhook/group/DpIS_B2TTNes-mtlYPf6PA"
            alert("\ndqc type:Holmes listname DQC \nenvironment:prod\nGrass_date:{grass_date}\nWarn_msg:\n{list_name} all data status=-1".format(list_name=table_name, grass_date=args.gs),seatalk_url,email_list)
        else:
            print("{list_name}上午批次数据status全都是-1,跳过同步数据".format(list_name=table_name))
    else:
        print("{list_name}数据无异常,同步至s3".format(list_name=table_name))
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
                    print("s3a=%s"%filepath)

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
        ,b.custom_list_id
        ,collect_set(concat(a.de_table_name,':',b.priority)) de_table_info 
    from risk.dim_risk_list_name a 
    join (
        select 
        list_name
        ,de_table_name 
        ,cast(priority as string ) priority
        ,custom_list_id
        ,grass_region
        from risk.dim_risk_af_listname_priority
        group by 
        list_name
        ,de_table_name 
        ,priority
        ,custom_list_id
        ,grass_region
    ) b on a.region = b.grass_region and  a.de_table_name = b.de_table_name 
    where a.import_type='full'
    and a.create_date>='2023-08-24' 
    and a.create_date <> 'history'
    and a.de_table_name='blacklist_overdue_id'
    group by a.region 
        ,a.biz_type
        ,b.list_name
        ,b.custom_list_id
    """
    listname_df = spark.sql(sql).toPandas()
    # sensitive_region=['ID','MY','PH','TH']
    for i in range(len(listname_df)):
        sensitive_tab=""
        row = listname_df.iloc[i] 
        table_region = row['region']
        table_biz_type = row['biz_type']
        de_table_info = row['de_table_info'] 
        list_name = row['list_name']
        custom_list_id=row['custom_list_id']
        filter_cond=''
        biz_db = "" 
        biz_name = ""
        if table_biz_type == 'credit':
            biz_db='credit_risk_control'
            biz_name = 'credit'
        if table_biz_type == 'shopeepay':
            biz_db='shopeepay_risk_control'
            biz_name = 'shopeepay'
        # if table_region in sensitive_region: 
        #     if table_biz_type == 'credit':
        #         sensitive_tab='__sensitive'
        print(table_region,'->',table_biz_type,'->',list_name,'->',de_table_info,'->',sensitive_tab,'->',custom_list_id)
        hive_to_s3(spark, table_region, table_biz_type ,list_name,de_table_info,filter_cond, args, args_config,biz_db,sensitive_tab,custom_list_id,biz_name)



