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

# update by zongyi.lu@shopee.comg List-screening 支持按DE数据源配置 https://jira.shopee.io/browse/SPSK-184747 (因为需要按地区切换，因此新增脚本来兼容)


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


def date_diff(data=None,count=3,date_format='%Y-%m-%d'):

    if data is None:
        data = datetime.now().strftime(date_format)
    # 将时间字符串转换为 datetime 格式的时间
    today = datetime.strptime(data, date_format)
    offset = timedelta(days=count)
    re_date = (today - offset).strftime(date_format)
    return re_date

def dqc_fluctuation(spark: SparkSession,db_table_name):
    dqc_sql="""
    select 
    tt1.list_name 
    ,case when tt2.list_name is not null and tt2.skip_dqc='1' then '0'
          else tt1.is_alarm end is_alarm
    from (
        select 
        t1.list_name
        -- 数据量大于前7天均值且波动删除/新增波动大于20%,则告警
        -- 如果全都是删除,也告警
        ,max(case when t2.list_name is not null and t1.cnt_1>t3.cnt_3 and ABS(round((t1.cnt_1-t2.cnt_2)/(t2.cnt_2*1.0),2))>0.2 then 1 
                  when t4.list_name is not null and t4.cnt_all = t4.cnt_delete then 1 else 0 end) is_alarm
        from (
            select 
            description as list_name 
            ,status 
            ,count(1) cnt_1
            from risk.ads_risk_blacklist_incremental_df
            where grass_date='{grass_date}'
            and grass_region='{grass_region}'
            and description = '{list_name}'
            group by description
            ,status
        ) t1 
        left join (
            select 
            description as list_name 
            ,status 
            ,count(1) cnt_2
            from risk.ads_risk_blacklist_incremental_df
            where grass_date = date_sub('{grass_date}',1)
            and grass_region='{grass_region}'
            and description = '{list_name}'
            group by description 
            ,status
        ) t2 on t1.list_name = t2.list_name and t1.status = t2.status
        left join(
            select 
            description as list_name 
            ,cast(count(1)/7 as bigint) cnt_3
            from risk.ads_risk_blacklist_incremental_df
            where grass_date >= date_sub('{grass_date}',7)
            and grass_region='{grass_region}'
            and grass_date<'{grass_date}'
            and description = '{list_name}'
            group by description 
        ) t3 on t1.list_name = t3.list_name
        left join (
           select 
            description as list_name 
            ,count(1) cnt_all 
            ,count(case when status=-1 then 1 else null end)cnt_delete
            from risk.ads_risk_blacklist_incremental_df
            where grass_date='{grass_date}'
            and grass_region='{grass_region}'
            and description = '{list_name}'
            group by description
        ) t4 on t1.list_name = t4.list_name
        group by t1.list_name
    ) tt1 
    -- 配置是否跳过dqc
    left join risk.dim_risk_list_skip_dqc tt2 on tt1.list_name = tt2.list_name 
    """.format(list_name=list_name,grass_date=args.gs,grass_region=args.region)
    
    df = spark.sql(dqc_sql)
    is_alarm = 0
    if df.count() == 0:
        is_alarm = 0
    else:
        is_alarm = df.select("is_alarm").first()[0]
    return is_alarm

def insert_dqc_info(spark: SparkSession, region, biz_type, list_name, args):
    """记录DQC指标信息到 ads_risk_blacklist_dqc_info_df 表"""
    # 查询增量表和mart表统计信息
    stats_sql = """
    select 
        coalesce(sum(case when status = 1 then 1 else 0 end), 0) as status_1_cnt
        ,coalesce(sum(case when status = -1 then 1 else 0 end), 0) as status_minus_1_cnt
        ,concat_ws(',',collect_set(detable)) as table_list
    from risk.ads_risk_blacklist_incremental_df
    where grass_date = date_sub('{gs}',1)
        and grass_region = '{region}'
        and description = '{list_name}'
    """.format(gs=args.gs, region=region, list_name=list_name)
    
    mart_sql = """
    select coalesce(count(1), 0) as list_cnt
    from risk.dwd_risk_{region}_{biz_type}_custom_list_df
    where grass_date = date_sub('{gs}',1)
        and data_source = 'DE'
        and custom_list_name = '{list_name}'
        and status = '1'
    """.format(region=region.lower(), biz_type=biz_type, gs=args.gs, list_name=list_name)
    
    stats_row = spark.sql(stats_sql).first()
    status_1_cnt = stats_row['status_1_cnt']
    status_minus_1_cnt = stats_row['status_minus_1_cnt']
    table_list = stats_row['table_list']
    list_cnt = spark.sql(mart_sql).first()['list_cnt']
    
    status_1_ratio = round(status_1_cnt / float(list_cnt), 4) if list_cnt > 0 else 0.0
    status_minus_1_ratio = round(status_minus_1_cnt / float(list_cnt), 4) if list_cnt > 0 else 0.0
    
    print(f"DQC Info - list:{list_name}, add:{status_1_cnt}, del:{status_minus_1_cnt}, total:{list_cnt}")
    
    # ========== 熔断告警逻辑 ==========
    dqc_critical_triggered = False
    seatalk_url = "https://openapi.seatalk.io/webhook/group/-CGK6sCRSvW1gsjYZKwPAw"  # highest alarm
    
    # 规则1：新增表无需熔断
    if status_1_cnt > 0 and list_cnt == 0:
        print(f"✅ 新增表无需熔断: {list_name} - 增量新增:{status_1_cnt}条 (新增表)")
    else:
        # 规则2：新增数据占比超过100%，且新增数据量大于10000条
        if status_1_cnt > 0 and list_cnt > 0 and status_1_ratio > 1.0 and status_1_cnt > 10000:
            print(f"🚨 新增数据告警触发熔断: {list_name} - 新增{status_1_cnt}条({status_1_ratio:.2%})")
            alert_msg = f"""DQC告警: 新增数据异常
环境: prod
日期: {args.gs}
地区: {region}
业务类型: {biz_type}
名单: {list_name}
新增数据量: {status_1_cnt}条
Mart表总量: {list_cnt}条
新增占比: {status_1_ratio:.2%}
原因: 新增数据占比超过100%，且新增数据量大于10000条
⚠️ 已跳过S3数据同步"""
            alert(alert_msg, seatalk_url, [])
            dqc_critical_triggered = True
        
        # 规则3：名单数据全删
        if status_minus_1_cnt > 0 and status_minus_1_cnt >= list_cnt:
            print(f"🚨 删除数据告警触发熔断: {list_name} - 名单数据全删, 共{status_minus_1_cnt}条")
            alert_msg = f"""DQC告警: 删除数据异常
环境: prod
日期: {args.gs}
地区: {region}
业务类型: {biz_type}
名单: {list_name}
删除数据量: {status_minus_1_cnt}条
Mart表总量: {list_cnt}条
删除占比: 100%
原因: 名单数据全删
⚠️ 已跳过S3数据同步"""
            alert(alert_msg, seatalk_url, [])
            dqc_critical_triggered = True
        # 规则4：删除占比超过50%，且删除数据量大于10000条
        elif status_minus_1_cnt > 0 and list_cnt > 0 and status_minus_1_ratio > 0.5 and status_minus_1_cnt > 10000:
            print(f"🚨 删除数据告警触发熔断: {list_name} - 删除{status_minus_1_cnt}条({status_minus_1_ratio:.2%})")
            alert_msg = f"""DQC告警: 删除数据异常
环境: prod
日期: {args.gs}
地区: {region}
业务类型: {biz_type}
名单: {list_name}
删除数据量: {status_minus_1_cnt}条
Mart表总量: {list_cnt}条
删除占比: {status_minus_1_ratio:.2%}
原因: 删除占比超过50%，且删除数据量大于10000条
⚠️ 已跳过S3数据同步"""
            alert(alert_msg, seatalk_url, [])
            dqc_critical_triggered = True
    
    # 插入DQC信息表
    # 增量同步的表，增量对比逻辑在业务侧维护，每天业务表只存对比之后的1和-1，biz_table_cnt赋为默认值-9999
    # 全量同步和增量同步共用dqc表，增量同步在名单级别做dqc，即'{list_name}' as list_name
    insert_sql = """
    insert overwrite table risk.ads_risk_blacklist_dqc_info_df partition(grass_region, biz_type, list_name, grass_date)
    select 
        -9999 as biz_table_cnt
        ,{list_cnt} as mart_table_cnt
        ,{status_1_cnt} as status_1_cnt
        ,{status_1_ratio} as status_1_ratio
        ,{status_minus_1_cnt} as status_minus_1_cnt
        ,{status_minus_1_ratio} as status_minus_1_ratio
        ,'incremental' as list_type
        ,'{table_list}' as table_list
        ,'{region}' as grass_region
        ,'{biz_type}' as biz_type
        ,'{list_name}' as list_name
        ,date_sub('{gs}',1) as grass_date
    """.format(region=region, gs=args.gs, list_name=list_name, biz_type=biz_type,
               list_cnt=list_cnt, status_1_cnt=status_1_cnt, status_1_ratio=status_1_ratio,
               status_minus_1_cnt=status_minus_1_cnt, status_minus_1_ratio=status_minus_1_ratio,
               table_list=table_list)
    
    spark.sql(insert_sql)
    
    # 返回熔断标记
    return dqc_critical_triggered

def hive_to_s3(spark: SparkSession, region,biz_type, list_name,de_table_info,condition, args, args_config):
    env=args.env
    db_table_name = list_name
    table_name = db_table_name
    db_name = 'smcdrisk_antifraud'
    print('region--->',region)
    index=0
    sql_tamplate =""
    for de_table in de_table_info:
        if spark.catalog._jcatalog.tableExists(db_name, de_table.split(':')[0]):
            print(de_table.split(':')[0],'exists')
            de_table_name = de_table.split(':')[0]
            priority = de_table.split(':')[1]
            screening_type = de_table.split(':')[2]
            sub_sql = """
            select 
            data
            ,datatype
            ,'DE daily update {gs}' as remark
            ,'{db_table_name}'as description
            ,status 
            ,'{de_table_name}' as  detable 
            ,{priority} as priority
            ,{screening_type} as screening_type
            from smcdrisk_antifraud.{de_table_name} 
            where 1=1 
            {condition}""".format(gs=args.gs,db_table_name=db_table_name,de_table_name=de_table_name,priority=priority,screening_type=screening_type,condition=condition)
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
        ,screening_type as screening_type
    from (
        select 
            data
            ,datatype
            ,remark
            ,description
            ,status 
            ,detable
            ,screening_type
            ,row_number() over(partition by data,datatype order by priority asc) rn 
        from ({sql_tamplate}) a
        ) a 
    where rn =1  """.format(sql_tamplate=sql_tamplate)
                    
    str_sql = sql_union
    insert_sql = """insert overwrite table risk.ads_risk_blacklist_incremental_df partition(grass_region='{grass_region}',table_name,grass_date)
    select 
        data
        ,datatype
        ,remark
        ,description
        ,status 
        ,detable
        ,detable                         as table_name 
        ,date_sub('{grass_date}',1)      as grass_date 
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
    where rn =1
    """.format(grass_date=args.gs,grass_region=region,sql_tamplate=sql_tamplate)
    print("insert_sql---->",insert_sql)
    df = spark.sql(str_sql)
    df1 = spark.sql(insert_sql)
    from datetime import datetime
    current_hour = datetime.now().strftime("%H")
    print("current_hour->>>",current_hour)
    # 加一层dqc 判断波动是否在合理范围内,否则告警
    is_alarm = dqc_fluctuation(spark,db_table_name)
    print("is_alarm---->",is_alarm)
    if is_alarm == 0:
        need_screening_df = df.filter(col("screening_type") == "2").select(
            col("data"),
            col("datatype"),
            col("remark"),
            col("description"),
            col("status"),
            col("detable"),
        )
        no_need_screening_df = df.filter(col("screening_type") == "1").select(
            col("data"),
            col("datatype"),
            col("remark"),
            col("description"),
            col("status"),
            col("detable"),
        )
        #导数至S3的文件命名
        s3filename = table_name+"_"+args.gs.replace("-","")+str(current_hour)
        need_screening_s3filename = "need_screening_"+table_name+"_"+args.gs.replace("-","")+str(current_hour)
        no_need_screening_s3filename = "no_need_screening_"+table_name+"_"+args.gs.replace("-","")+str(current_hour)
        #导数至S3的地址
        path = "{region}/{biz_type}/{table_name}".format(**args_config[env],region=region,biz_type=biz_type, table_name=table_name)

        # #定期清理路径
        del_path= "s3a://{bucketname}/{path}/{del_date}/".format(**args_config[env], path=path, del_date=date_diff('{grass_date}'.format(**args_config[env])).replace("-",""))

        # filepath = "s3a://{bucketname}/{path}/{file_date}/{current_hour}/".format(**args_config[env], path=path, file_date=args.gs.replace("-",""),current_hour=current_hour)
        need_screening_filepath = "s3a://{bucketname}/{path}/{file_date}/{current_hour}/need_screening/".format(**args_config[env], path=path, file_date=args.gs.replace("-",""),current_hour=current_hour)
        no_need_screening_filepath = "s3a://{bucketname}/{path}/{file_date}/{current_hour}/no_need_screening/".format(**args_config[env], path=path, file_date=args.gs.replace("-",""),current_hour=current_hour)
        
        # df.repartition(args_config[env]['filenum']).write.format(args_config[env]['fileformat']).option("header", args_config[env]['fileheader']).mode("Overwrite").save(filepath)
        need_screening_df.repartition(args_config[env]['filenum']).write.format(args_config[env]['fileformat']).option("header", args_config[env]['fileheader']).mode("Overwrite").save(need_screening_filepath)
        no_need_screening_df.repartition(args_config[env]['filenum']).write.format(args_config[env]['fileformat']).option("header", args_config[env]['fileheader']).mode("Overwrite").save(no_need_screening_filepath)

        sc = spark.sparkContext
        Path = sc._gateway.jvm.org.apache.hadoop.fs.Path
        FileSystem = sc._gateway.jvm.org.apache.hadoop.fs.FileSystem
        fs = FileSystem.get(sc._jvm.java.net.URI.create("s3a://{bucketname}".format(**args_config[env])),sc._jsc.hadoopConfiguration())

        print("s3apath s3a=%s"%need_screening_filepath)
        print("s3apath s3a=%s"%no_need_screening_filepath)

        # if fs.exists(Path(filepath)):
        #     fileindex=1
        #     for f in fs.listStatus(Path(filepath)):
        #         print(f.getPath().toString())
        #         if(f.getPath().getName().startswith("part-")):
        #             fs.rename(f.getPath(),Path(filepath + "{s3filename}_{fileindex}.{fileformat}".format(**args_config[env],s3filename=s3filename,fileindex=str(fileindex).zfill(3))))
        #             fileindex = fileindex+1
        #     #             print("s3a=%s"%filepath)

        #     for f in fs.listStatus(Path(filepath)):
        #         print(f.getPath().toString())
        if fs.exists(Path(need_screening_filepath)):
            fileindex=1
            for f in fs.listStatus(Path(need_screening_filepath)):
                print(f.getPath().toString())
                if(f.getPath().getName().startswith("part-")):
                    fs.rename(f.getPath(),Path(need_screening_filepath + "{s3filename}_{fileindex}.{fileformat}".format(**args_config[env],s3filename=need_screening_s3filename,fileindex=str(fileindex).zfill(3))))
                    fileindex = fileindex+1
                    print("s3a=%s"%need_screening_filepath)
            for f in fs.listStatus(Path(need_screening_filepath)):
                print(f.getPath().toString())
        if fs.exists(Path(no_need_screening_filepath)):
            fileindex=1
            for f in fs.listStatus(Path(no_need_screening_filepath)):
                print(f.getPath().toString())
                if(f.getPath().getName().startswith("part-")):
                    fs.rename(f.getPath(),Path(no_need_screening_filepath + "{s3filename}_{fileindex}.{fileformat}".format(**args_config[env],s3filename=no_need_screening_s3filename,fileindex=str(fileindex).zfill(3))))
                    fileindex = fileindex+1
                    print("s3a=%s"%no_need_screening_filepath)
            for f in fs.listStatus(Path(no_need_screening_filepath)):
                print(f.getPath().toString())

        else:
            print("Not found s3apath=[%s]"%del_path)
    else :
        seatalk_url="https://openapi.seatalk.io/webhook/group/uR-2p4JQTTGZ4ihgfsbWDQ"
        alert("\nHolmes listname DQC \nenvironment:prod\nGrass_date:{grass_date}\nWarn_msg:\n{list_name} DQC failed ".format(list_name=table_name, grass_date=args.gs),seatalk_url,email_list)


if __name__ == "__main__":
    # parse parameters
    parser = argparse.ArgumentParser(description='HiveToS3 tools')
    parser.add_argument('-env', type=str, required=True)
    parser.add_argument('-bucketname', type=str, required=True )
    parser.add_argument('-gs', type=str, required=True)
    parser.add_argument('-region', type=str, required=True)
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
            "grass_region":args.region,
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
            "grass_region":args.region,
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
        ,collect_set(concat(a.de_table_name,':',b.priority,':',b.screening_type)) de_table_info 
    from risk.dim_risk_list_name a 
    join (
        select 
        list_name
        ,de_table_name 
        ,cast(priority as string ) priority
        ,custom_list_id
        ,grass_region
        ,case when length(screening_type)>1 and lower(screening_type) ='true' then 2
              when length(screening_type)>1 and lower(screening_type) ='false' then 1
              when length(screening_type)<=1 and screening_switch = 1 then 1
              when length(screening_type)<=1 and screening_switch = 2 then 2 else 1  end screening_type

        from risk.dim_risk_af_listname_priority
        group by 
        list_name
        ,de_table_name 
        ,priority
        ,custom_list_id
        ,grass_region
        ,case when length(screening_type)>1 and lower(screening_type) ='true' then 2
              when length(screening_type)>1 and lower(screening_type) ='false' then 1
              when length(screening_type)<=1 and screening_switch = 1 then 1
              when length(screening_type)<=1 and screening_switch = 2 then 2 else 1  end
    ) b on a.region = b.grass_region and  a.de_table_name = b.de_table_name 
    where a.import_type='incremental'
    and a.region='{region}'
    group by a.region 
        ,a.biz_type
        ,b.list_name
        ,b.custom_list_id
    """.format(region=args.region)
    listname_df = spark.sql(sql).toPandas()
    for i in range(len(listname_df)):
        row = listname_df.iloc[i] 
        table_region = row['region']
        table_biz_type = row['biz_type']
        de_table_info = row['de_table_info'] 
        list_name = row['list_name']
        print(table_region,'->',table_biz_type,'->',list_name,'->',de_table_info)
        filter_cond=''
        
        # 先执行DQC检查和统计，获取熔断标记
        dqc_critical_triggered = insert_dqc_info(spark, table_region, table_biz_type, list_name, args)
        
        # 如果熔断告警触发，则跳过S3数据同步
        if dqc_critical_triggered:
            print(f"⚠️ 名单 {list_name} 触发熔断告警，跳过S3数据同步")
        else:
            # 未触发熔断，执行正常的S3数据同步流程
            hive_to_s3(spark, table_region, table_biz_type ,list_name,de_table_info,filter_cond, args, args_config)



