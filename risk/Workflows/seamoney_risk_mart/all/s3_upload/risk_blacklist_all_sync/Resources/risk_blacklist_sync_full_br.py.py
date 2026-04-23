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


def hive_to_s3(spark: SparkSession, region,biz_type, list_name,de_table_info,condition, args, args_config,biz_db,sensitive_tab,custom_list_id):
    env=args.env
    db_table_name = list_name
    table_name = db_table_name
    db_name = 'smcdrisk_antifraud'
    index=0
    sql_tamplate =""
    risk_id_all_list_sql ="""
    with risk_{region}_all_list as(
    select
        t1.email_addr    as data 
        ,t1.description  as table_name
        ,16              as data_type 
        ,-1              as status
        
    from risk.ods__{biz_db}_{region}_db__custom_list_email_tab__df t1 
    where grass_date =date_sub('{grass_date}',1)
    and data_source='DE'  
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.email_addr 
    ,t1.description
    union all 
    select
        t1.fb_account    as data 
        ,t1.description  as table_name
        ,15              as data_type
        ,-1              as status
    from risk.ods__{biz_db}_{region}_db__custom_list_fbaccount_tab__df t1 
    where grass_date =date_sub('{grass_date}',1)
    and data_source='DE' 
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.fb_account 
    ,t1.description
    union all 
    select
        t1.id_no         as data 
        ,t1.description  as table_name
        ,3               as data_type
        ,-1              as status
    from risk.ods__{biz_db}_{region}_db__custom_list_id_no_tab__df{sensitive_tab} t1 
    where grass_date =date_sub('{grass_date}',1) 
    and data_source='DE' 
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.id_no 
    ,t1.description
    union all 
    select
        t1.ip            as data 
        ,t1.description  as table_name
        ,7               as data_type
        ,-1              as status
    from risk.ods__{biz_db}_{region}_db__custom_list_ip_tab__df t1 
    where grass_date =date_sub('{grass_date}',1)
    and data_source='DE' 
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.ip 
    ,t1.description
    union all 
    select
        t1.kredit_account as data 
        ,t1.description   as table_name
        ,2                as data_type
        ,-1               as status
    from risk.ods__{biz_db}_{region}_db__custom_list_kredit_account_tab__df t1 
    where grass_date =date_sub('{grass_date}',1)
    and data_source='DE' 
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.kredit_account 
    ,t1.description
    union all 
    select
        t1.phone_no      as data 
        ,t1.description  as table_name
        ,4               as data_type
        ,-1              as status
    from risk.ods__{biz_db}_{region}_db__custom_list_phone_tab__df{sensitive_tab} t1 
    where grass_date =date_sub('{grass_date}',1)
    and data_source='DE' 
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.phone_no 
    ,t1.description
    union all 
    select
        t1.shopee_account          as data 
        ,t1.description            as table_name
        ,1                         as data_type
        ,-1                        as status
    from risk.ods__{biz_db}_{region}_db__custom_list_shopee_account_tab__df t1 
    where grass_date =date_sub('{grass_date}',1) 
    and data_source='DE' 
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.shopee_account 
    ,t1.description
    union all 
    select
        t1.tddf          as data 
        ,t1.description  as table_name
        ,14              as data_type
        ,-1              as status
    from risk.ods__{biz_db}_{region}_db__custom_list_tddf_tab__df t1 
    where grass_date =date_sub('{grass_date}',1)
    and data_source='DE' 
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.tddf 
    ,t1.description
    union all 
    select
        t1.uname         as data 
        ,t1.description  as table_name
        ,17              as data_type
        ,-1              as status
    from risk.ods__{biz_db}_{region}_db__custom_list_uname_tab__df t1 
    where grass_date =date_sub('{grass_date}',1)
    and data_source='DE' 
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.uname 
    ,t1.description
    union all 
    select 
        t1.data          as data 
        ,t1.description  as table_name
        ,t1.data_type    as data_type
        ,-1              as status
    from risk.ods__{biz_db}_{region}_db__custom_list_rare_type_tab__df t1 
    where grass_date =date_sub('{grass_date}',1) 
    and data_source='DE' 
    and custom_list_id='{custom_list_id}'
    and status=1
    group by t1.data 
    ,t1.description
    ,t1.data_type
    )""".format(grass_date=args.gs,region=region.lower(),biz_db=biz_db,sensitive_tab=sensitive_tab,custom_list_id=custom_list_id)
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
    insert overwrite table risk.ads_risk_br_blacklist_di_us partition(table_name,grass_date)
        select 
        data                             as data 
        ,datatype                        as datatype 
        ,'DE daily update {grass_date}' as remark         
        ,table_name                      as description     
        ,status                          as status  
        ,'{biz_typte}'                   as biz_typte
        ,table_name                      as table_name 
        ,date_sub('{grass_date}',1)      as grass_date
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
    """ .format(grass_date=args.gs,grass_region=region,sql_union=sql_union,biz_db=biz_db,biz_typte=biz_typte)
                    
    str_sql = risk_id_all_list_sql + sql_final
    print(str_sql)
    df = spark.sql(str_sql)


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
        where grass_region='BR'
        group by 
        list_name
        ,de_table_name 
        ,priority
        ,custom_list_id
        ,grass_region
    ) b on a.region = b.grass_region and  a.de_table_name = b.de_table_name 
    where a.import_type='full'
    and a.region='BR'
    and a.create_date>='2023-08-24' 
    and a.create_date <> 'history'
    group by a.region 
        ,a.biz_type
        ,b.list_name
        ,b.custom_list_id
    """
    listname_df = spark.sql(sql).toPandas()
    sensitive_region=['ID','MY','PH','TH']
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
        if table_biz_type == 'credit':
            biz_db='credit_risk_control'
        if table_biz_type == 'shopeepay':
            biz_db='shopeepay_risk_control'
        if table_region in sensitive_region: 
            if table_biz_type == 'credit':
                sensitive_tab='__sensitive'
        print(table_region,'->',table_biz_type,'->',list_name,'->',de_table_info,'->',sensitive_tab,'->',custom_list_id)
        hive_to_s3(spark, table_region, table_biz_type ,list_name,de_table_info,filter_cond, args, args_config,biz_db,sensitive_tab,custom_list_id)



