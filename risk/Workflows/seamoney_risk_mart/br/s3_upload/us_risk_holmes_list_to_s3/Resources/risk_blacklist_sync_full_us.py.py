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

# update by zongyi.lu@shopee.comg List-screening 支持按DE数据源配置 https://jira.shopee.io/browse/SPSK-184747 (因为需要按地区切换，因此新增脚本来兼容)
# update by wei.tao@shopee.com 修复 need_screening 字段逻辑问题 -20250113 业务反馈，核查后发现是 20241107 开始缺失; 告警到 highest alarm 群

# DQC告警阈值默认配置
DEFAULT_DQC_CONFIG = {
    'check_type': 'over_threshold',
    'add_ratio_threshold': 1.0,
    'add_count_threshold': 10000,
    'delete_ratio_threshold': 0.5,
    'delete_count_threshold': 10000
}

def date_diff(data=None,count=3,date_format='%Y-%m-%d'):

    if data is None:
        data = datetime.now().strftime(date_format)
    # 将时间字符串转换为 datetime 格式的时间
    today = datetime.strptime(data, date_format)
    offset = timedelta(days=count)
    re_date = (today - offset).strftime(date_format)
    return re_date

def get_total_row_count(directory_path, file_format):
    """
    读取指定路径下的所有数据文件，并计算总行数（不包括 header）。
    :param directory_path: S3 路径
    :param file_format: 文件格式（csv, parquet, json, orc等）
    :return: 数据总行数
    """
    try:
        df = spark.read.format(file_format).option("header", True).load(directory_path)
        return df.count()  # 统计总行数（不包括 header）
    except Exception as e:
        print(f"读取 {directory_path} 失败: {e}")
        return -1  # 读取失败，返回 -1

##---------------------------------------------------------------##---------------------------------------------------------------
def alert_empty_path(path, seatalk_url="https://openapi.seatalk.io/webhook/group/PBm_smSvTeyxleGfzI6png",email_list=[]):    
     # https://openapi.seatalk.io/webhook/group/PBm_smSvTeyxleGfzI6png 勤劳的机器人
     # https://openapi.seatalk.io/webhook/group/uR-2p4JQTTGZ4ihgfsbWDQ medium alert
     # https://openapi.seatalk.io/webhook/group/IQFl6JVwSdO4jZvimuGHUA highest alarm
    content = '{0} 路径下的文件为空'.format(path)
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
##---------------------------------------------------------------##---------------------------------------------------------------

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
            from risk.ads_risk_blacklist_full_df
            where grass_date='{grass_date}'
            and grass_region = '{grass_region}'
            and description = '{list_name}'
            group by description
            ,status
        ) t1 
        left join (
            select 
            description as list_name 
            ,status 
            ,count(1) cnt_2
            from risk.ads_risk_blacklist_full_df
            where grass_date = date_sub('{grass_date}',1)
            and grass_region = '{grass_region}'
            and description = '{list_name}'
            group by description 
            ,status
        ) t2 on t1.list_name = t2.list_name and t1.status = t2.status
        left join(
            select 
            description as list_name 
            ,cast(count(1)/7 as bigint) cnt_3
            from risk.ads_risk_blacklist_full_df
            where grass_date >= date_sub('{grass_date}',7)
            and grass_region = '{grass_region}'
            and grass_date<'{grass_date}'
            and description = '{list_name}'
            group by description 
        ) t3 on t1.list_name = t3.list_name
        left join (
           select 
            description as list_name 
            ,count(1) cnt_all 
            ,count(case when status=-1 then 1 else null end)cnt_delete
            from risk.ads_risk_blacklist_full_df
            where grass_date='{grass_date}'
            and grass_region = '{grass_region}'
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

def collect_detable_statistics_and_alert(spark: SparkSession, df, de_table_counts, region, args, list_name, biz_type, exists_de_tables, threshold_config_dict, custom_list_id):
    """
    统计对比名单级别, 业务表跟mart表的数据量差异
    Returns:
        bool: True表示发生告警, False表示无告警
    """
    # ========== 从配置字典获取阈值 ==========
    # 按 region + biz_type + list_name 精确匹配，未配置则使用默认值
    key = (region.upper(), biz_type, list_name)
    config = threshold_config_dict.get(key, DEFAULT_DQC_CONFIG)
    
    check_type = config['check_type']
    add_ratio_threshold = config['add_ratio_threshold']
    add_count_threshold = config['add_count_threshold']
    delete_ratio_threshold = config['delete_ratio_threshold']
    delete_count_threshold = config['delete_count_threshold']
    
    config_source = "配置表" if key in threshold_config_dict else "代码默认"
    print(f"名单 {list_name} 使用{config_source}阈值: check_type={check_type}, add_ratio={add_ratio_threshold}, add_count={add_count_threshold}, delete_ratio={delete_ratio_threshold}, delete_count={delete_count_threshold}")
    
    # 固定使用 medium 级别告警URL
    seatalk_url = "https://openapi.seatalk.io/webhook/group/-CGK6sCRSvW1gsjYZKwPAw"
    # ========== 配置获取逻辑结束 ==========
    
    # 为避免不同业务类型的同名列表DQC数据覆盖，使用带业务类型前缀的表名
    dqc_table_name = f"{biz_type}__{list_name}"
    
    # 统计各业务表数据量和占比
    de_table_stats_df = df.groupBy("detable", "status").count().collect()
    dqc_critical_triggered = False  # 标记是否有告警
    
    # 查询mart表中对应list_name的总数据量（一次查询即可）
    mart_count_sql = f"""
    select count(1) as mart_table_cnt
    from risk.dwd_risk_{region.lower()}_{biz_type}_custom_list_df
    where grass_date = date_sub('{args.gs}', 1)
    and data_source = 'DE'
    and custom_list_id = '{custom_list_id}'
    and status = 1
    """
    mart_table_cnt_result = spark.sql(mart_count_sql).collect()
    mart_table_cnt = mart_table_cnt_result[0]["mart_table_cnt"] if mart_table_cnt_result else 0
    print(f"list_name: {list_name} 的 mart 表总数据量: {mart_table_cnt}")
    
    # 汇总所有detable的数据量
    total_status_1_cnt = 0
    total_status_minus_1_cnt = 0
    total_de_table_cnt = sum(de_table_counts.get(detable, 0) for detable in exists_de_tables)
    
    # 遍历统计数据，汇总新增和删除数量
    for row in de_table_stats_df:
        detable, status, status_cnt = row["detable"], row["status"], row["count"]
        
        # 过滤掉不属于当前list_name的历史数据污染
        if detable not in exists_de_tables:
            print(f"跳过dqc统计: {detable}，不属于当前list_name: {list_name}")
            continue
        
        if status == 1:
            total_status_1_cnt += status_cnt
        elif status == -1:
            total_status_minus_1_cnt += status_cnt
    
    # 计算汇总后的比例
    total_status_1_ratio = total_status_1_cnt / mart_table_cnt if mart_table_cnt > 0 else 0.0
    total_status_minus_1_ratio = total_status_minus_1_cnt / mart_table_cnt if mart_table_cnt > 0 else 0.0
    
    # ========== 根据 check_type 执行不同的检查逻辑 ==========
    if check_type == 'no_increment':
        # 零增量告警模式：只检查增量为0和全删
        print(f"使用零增量告警模式检查: {list_name}")
        
        # 告警条件1: 增量数据为0（没有任何新增数据）
        # 不管业务表是否有数据，只要增量为0就熔断
        if total_status_1_cnt == 0:
            print(f"🚨 零增量告警触发熔断: {list_name} - 增量数据为0")
            alert_msg = f"""DQC告警: 零增量数据异常
环境: prod
日期: {args.gs}
地区: {region}
业务类型: {biz_type}
名单: {list_name}
业务表数据量: {total_de_table_cnt}条
新增数据量: 0条
原因: 增量数据为0，名单未正常更新
⚠️ 已跳过S3数据同步"""
            alert(alert_msg, seatalk_url, [])
            dqc_critical_triggered = True
        
        # 告警条件2: 名单数据全删
        if total_de_table_cnt == 0 and total_status_minus_1_cnt > 0:
            print(f"🚨 全删告警触发熔断: {list_name} - 名单数据全删, 共{total_status_minus_1_cnt}条")
            alert_msg = f"""DQC告警: 删除数据异常
环境: prod
日期: {args.gs}
地区: {region}
业务类型: {biz_type}
名单: {list_name}
删除数据量: {total_status_minus_1_cnt}条
删除占比: 100%
原因: 名单数据全删
⚠️ 已跳过S3数据同步"""
            alert(alert_msg, seatalk_url, [])
            dqc_critical_triggered = True
        
        # 如果都没告警，说明数据正常
        if not dqc_critical_triggered:
            print(f"✅ {list_name} 数据检查通过: 有新增数据({total_status_1_cnt}条) 且 未全删")
    
    else:
        # 超阈值告警模式（默认）：检查新增/删除是否超过阈值
        print(f"使用超阈值告警模式检查: {list_name}")
        
        # 告警条件1: 新增数据量占比和数量都超过阈值
        if total_de_table_cnt > 0 and mart_table_cnt > 0 and total_status_1_ratio > add_ratio_threshold and total_status_1_cnt > add_count_threshold:
            print(f"🚨 新增数据告警触发熔断: {list_name} - 新增{total_status_1_cnt}条({total_status_1_ratio:.2%}), 阈值: {add_ratio_threshold:.0%}/{add_count_threshold}条")
            alert_msg = f"""DQC告警: 新增数据异常
环境: prod
日期: {args.gs}
地区: {region}
业务类型: {biz_type}
名单: {list_name}
新增数据量: {total_status_1_cnt}条
新增占比: {total_status_1_ratio:.2%}
原因: 新增数据占比超过{add_ratio_threshold:.0%}，且新增数据量大于{add_count_threshold}条
⚠️ 已跳过S3数据同步"""
            alert(alert_msg, seatalk_url, [])
            dqc_critical_triggered = True
        
        # 告警条件2: 名单数据全删
        if total_de_table_cnt == 0 and total_status_minus_1_cnt > 0:
            print(f"🚨 删除数据告警触发熔断: {list_name} - 名单数据全删, 共{total_status_minus_1_cnt}条")
            alert_msg = f"""DQC告警: 删除数据异常
环境: prod
日期: {args.gs}
地区: {region}
业务类型: {biz_type}
名单: {list_name}
删除数据量: {total_status_minus_1_cnt}条
删除占比: 100%
原因: 名单数据全删
⚠️ 已跳过S3数据同步"""
            alert(alert_msg, seatalk_url, [])
            dqc_critical_triggered = True
        # 告警条件3: 删除占比和数量都超过阈值
        elif total_de_table_cnt > 0 and mart_table_cnt > 0 and total_status_minus_1_ratio > delete_ratio_threshold and total_status_minus_1_cnt > delete_count_threshold:
            print(f"🚨 删除数据告警触发熔断: {list_name} - 删除{total_status_minus_1_cnt}条({total_status_minus_1_ratio:.2%}), 阈值: {delete_ratio_threshold:.0%}/{delete_count_threshold}条")
            alert_msg = f"""DQC告警: 删除数据异常
环境: prod
日期: {args.gs}
地区: {region}
业务类型: {biz_type}
名单: {list_name}
删除数据量: {total_status_minus_1_cnt}条
删除占比: {total_status_minus_1_ratio:.2%}
原因: 删除占比超过{delete_ratio_threshold:.0%}，且删除数据量大于{delete_count_threshold}条
⚠️ 已跳过S3数据同步"""
            alert(alert_msg, seatalk_url, [])
            dqc_critical_triggered = True
    
    # 收集list_name对应的表清单
    table_list = ','.join(sorted(exists_de_tables))
    
    # 插入汇总后的DQC统计数据（list_name维度）
    insert_dqc_sql = """
    insert overwrite table risk.ads_risk_blacklist_dqc_info_df partition(grass_region,biz_type,list_name,grass_date)
    select
    {total_de_table_cnt}             as biz_table_cnt
    ,{mart_table_cnt}                as mart_table_cnt
    ,{status_1_cnt}                  as status_1_cnt         
    ,{status_1_ratio}                as status_1_ratio     
    ,{status_minus_1_cnt}            as status_minus_1_cnt  
    ,{status_minus_1_ratio}          as status_minus_1_ratio
    ,'full' as list_type
    ,'{table_list}' as table_list
    ,'{grass_region}' as grass_region
    ,'{biz_type}' as biz_type
    ,'{list_name}' as list_name
    ,date_sub('{gs}',1) as grass_date
    """.format(
        total_de_table_cnt=total_de_table_cnt,
        mart_table_cnt=mart_table_cnt,
        status_1_cnt=total_status_1_cnt,
        status_1_ratio=total_status_1_ratio,
        status_minus_1_cnt=total_status_minus_1_cnt,
        status_minus_1_ratio=total_status_minus_1_ratio,
        table_list=table_list,
        grass_region=region.upper(),
        biz_type=biz_type,
        list_name=list_name,
        gs=args.gs
    )
    print(f"DQC统计插入: {list_name} (业务表总计:{total_de_table_cnt}, Mart表总计:{mart_table_cnt}, 新增:{total_status_1_cnt}, 删除:{total_status_minus_1_cnt}, 新增占比:{total_status_1_ratio:.2%}, 删除占比:{total_status_minus_1_ratio:.2%})")
    spark.sql(insert_dqc_sql)
    
    return dqc_critical_triggered


def hive_to_s3(spark: SparkSession, region,biz_type, list_name,de_table_info,condition, args, args_config,biz_db,sensitive_tab,custom_list_id,biz_name,threshold_config_dict):
    env=args.env
    db_table_name = list_name
    table_name = db_table_name
    db_name = 'smcdrisk_antifraud'
    index=0
    sql_tamplate =""
    # 用于存储每个DE表的原始数据量
    de_table_counts = {}
    # 新增：记录当前list_name应该处理的DE表名集合，用于DQC统计过滤
    exists_de_tables = set()
    risk_id_all_list_sql ="""
    with risk_{region}_all_list as(
    select
        t1.data          as data 
        ,t1.description  as table_name
        ,t1.data_type    as data_type 
        ,-1              as status
        ,screening_switch as screening_type 
    from risk.dwd_risk_{region}_{biz_name}_custom_list_df t1 
    where grass_date =date_sub('{grass_date}',1)
    and data_source='DE'  
    and custom_list_id='{custom_list_id}'
    and status=1
        group by t1.data 
        ,t1.description
        ,t1.data_type
        ,screening_switch
    )""".format(grass_date=args.gs,region=region.lower(),biz_name=biz_name,custom_list_id=custom_list_id)
    for de_table in de_table_info:
        if spark.catalog._jcatalog.tableExists(db_name, de_table.split(':')[0]):
            de_table_name = de_table.split(':')[0]
            exists_de_tables.add(de_table_name)
            priority = de_table.split(':')[1]
            screening_type = de_table.split(':')[2]
            
            sub_sql = """
            select 
            cast(data as string) data
            ,datatype
            ,'DE daily update {gs}' as remark
            ,'{db_table_name}'as description
            ,1 as status 
            ,'{de_table_name}' as  detable 
            ,{priority} as priority
            ,{screening_type} as screening_type
            from smcdrisk_antifraud.{de_table_name} 
            where 1=1 
            {condition}""".format(gs=args.gs,db_table_name=db_table_name,de_table_name=de_table_name,priority=priority,screening_type=screening_type,condition=condition)
            
            # 直接执行sub_sql并计算数据量
            temp_df = spark.sql(sub_sql)
            de_table_cnt = temp_df.count()
            de_table_counts[de_table_name] = de_table_cnt
            print(f"业务表 {de_table_name} 原始数据量: {de_table_cnt}")
            
            if index==0:
                sql_tamplate = sub_sql
            else:
                sql_tamplate =sql_tamplate + '  union all  '+sub_sql 
            index = index+1
        else:
            de_table_name = de_table.split(':')[0]
            print(f"表 {de_table_name} 不存在，跳过当次循环，继续执行下一张表")
            continue
        
    # 检查是否有可用的表，如果没有则跳过整个处理流程
    if not sql_tamplate:
        print(f"警告：名单 {list_name} 的所有表都不存在，跳过处理")
        return
    
    sql_union = """
    select 
        data      as data
        ,datatype as datatype
        ,detable  as table_name
        ,status   as status
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

    sql_final = """
        select 
        data                             as data 
        ,datatype                        as datatype 
        ,'DE daily update {grass_date}' as remark         
        ,table_name                      as description     
        ,status                          as status  
        ,table_name                      as detable 
        ,case when screening_type=1 then 'no_need_screening'
              else 'need_screening' end                as screening_type
        from (
            select 
                data                     as data
                ,datatype                as datatype
                ,table_name              as table_name 
                ,'{grass_region}'        as grass_region 
                ,sum(status) as status 
                ,max(screening_type) as screening_type
            from (
                select
                    t1.data          as data 
                    ,t2.dict_name    as datatype
                    ,t1.table_name   as table_name
                    ,-1              as status
                    ,screening_type  as screening_type
                from risk_{grass_region}_all_list t1 
                left join (
                    select 
                    dict_value
                    ,dict_name 
                    from risk.dim_risk_{grass_region}_{biz_db}_dict_df 
                    where grass_date=date_sub('{grass_date}',1)
                    and parent_dict_key='dataType' 
                    group by dict_value
                    ,dict_name 
                ) t2 on t1.data_type = t2.dict_value
                group by t1.data 
                ,t2.dict_name
                ,t1.table_name
                ,screening_type
                union all 
                {sql_union}
            ) a 
        group by data 
        ,datatype 
        ,table_name
        ) a 
        where status<>0
    """ .format(grass_date=args.gs,grass_region=region,sql_union=sql_union,biz_db=biz_name)

    insert_sql = """
    insert overwrite table risk.ads_risk_blacklist_full_df partition(grass_region='{grass_region}',table_name,grass_date)
        select 
        data                             as data 
        ,datatype                        as datatype 
        ,'DE daily update {grass_date}' as remark         
        ,table_name                      as description     
        ,status                          as status  
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
                    ,screening_type  as screening_type
                from risk_{grass_region}_all_list t1 
                left join (
                    select 
                    dict_value
                    ,dict_name 
                    from risk.dim_risk_{grass_region}_{biz_db}_dict_df 
                    where grass_date=date_sub('{grass_date}',1)
                    and parent_dict_key='dataType' 
                    group by dict_value
                    ,dict_name 
                ) t2 on t1.data_type = t2.dict_value
                group by t1.data 
                ,t2.dict_name
                ,t1.table_name
                ,screening_type
                union all 
                {sql_union}
            ) a 
        group by data 
        ,datatype 
        ,table_name
        ) a 
        where status<>0
    """ .format(grass_date=args.gs,grass_region=region,sql_union=sql_union,biz_db=biz_name)
          
    str_sql = risk_id_all_list_sql + sql_final
    print(str_sql)
    write_table_sql = risk_id_all_list_sql + insert_sql
    print(write_table_sql)
    df1 = spark.sql(write_table_sql)
    time.sleep(60)
    df = spark.sql(str_sql)
    
    # 只调用统计函数，不进行告警
    dqc_critical_triggered = collect_detable_statistics_and_alert(spark, df, de_table_counts, region, args, list_name, biz_type, exists_de_tables, threshold_config_dict, custom_list_id)
    
    # 通过group by status分组
    grouped_df = df.groupBy("status").count()
    from datetime import datetime
    current_hour = datetime.now().strftime("%H")
    print("current_hour->>>",current_hour)

    # 加一层dqc 判断波动是否在合理范围内,否则告警
    # is_alarm = dqc_fluctuation(spark,db_table_name)
    is_alarm = 0

    # 检查是否所有分组的status都等于-1
    # -1 条数大于50条才告警,避免有些名单一天删几条数据也会触发告警
    # 新增大于20%的波动
    all_pass = (
        (grouped_df.filter(col("status") == -1).count() == grouped_df.count() and grouped_df.count()>50)
        or grouped_df.filter(col("status") == -1).count() > 1000000
        or is_alarm==1
    )
    if  all_pass:
        email_list=[]
        # 上午批次不告警,因为可能会存在推送名单时间与名单跑数时间冲突的情况,导致status全都是-1
        # 下午批次全都是-1 才发出告警
        if current_hour>12:
            seatalk_url="https://openapi.seatalk.io/webhook/group/DpIS_B2TTNes-mtlYPf6PA"
            alert("\ndqc type:Holmes listname DQC \nenvironment:prod\nGrass_date:{grass_date}\nWarn_msg:\n{list_name} all data status=-1".format(list_name=table_name, grass_date=args.gs),seatalk_url,email_list)
        else:
            print("{list_name}上午批次数据status全都是-1,跳过同步数据".format(list_name=table_name))
    else:
        if dqc_critical_triggered:
            print(f"{list_name}检测到数据异常告警，跳过S3数据同步")
        else:
            print("{list_name}数据无异常,同步至s3".format(list_name=table_name))
            need_screening_df = df.filter(col("screening_type") == "need_screening").select(
                col("data"),
                col("datatype"),
                col("remark"),
                col("description"),
                col("status"),
                col("detable"),
            )
            no_need_screening_df = df.filter(col("screening_type") == "no_need_screening").select(
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

            #定期清理路径
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
            #             print("s3a=%s"%filepath)
            #     for f in fs.listStatus(Path(filepath)):
            #         print(f.getPath().toString())
            file_format = args_config[env]['fileformat']  # 例如 "csv"、"parquet"、"json"

            if fs.exists(Path(need_screening_filepath)):
                fileindex=1
                for f in fs.listStatus(Path(need_screening_filepath)):
                    print(f.getPath().toString())
                    if(f.getPath().getName().startswith("part-")):
                        fs.rename(f.getPath(),Path(need_screening_filepath + "{s3filename}_{fileindex}.{fileformat}".format(**args_config[env],s3filename=need_screening_s3filename,fileindex=str(fileindex).zfill(3))))
                        fileindex = fileindex+1
                        print("s3a=%s"%need_screening_filepath)

                # **判断整个 need_screening_filepath 目录的数据总行数**
                total_rows = get_total_row_count(need_screening_filepath, file_format)

                if total_rows == 0 and not need_screening_df.rdd.isEmpty():  
                    print(f"WARNING: No actual data found in {need_screening_filepath}, BUT there's data in the data source, all files are empty or contain only headers!")
                    alert_empty_path(need_screening_filepath)
                elif total_rows == -1:
                    print(f"ERROR: Failed to read {need_screening_filepath}, please check file format and permissions!")
                # *************************************************

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
                
                # **判断整个 no_need_screening_filepath 目录的数据总行数**
                total_rows = get_total_row_count(no_need_screening_filepath, file_format)

                if total_rows == 0 and not no_need_screening_df.rdd.isEmpty():
                    print(f"WARNING: No actual data found in {no_need_screening_filepath}, BUT there's data in the data source, all files are empty or contain only headers!")
                    alert_empty_path(no_need_screening_filepath)
                elif total_rows == -1:
                    print(f"ERROR: Failed to read {no_need_screening_filepath}, please check file format and permissions!")
                # *************************************************

                for f in fs.listStatus(Path(no_need_screening_filepath)):
                    print(f.getPath().toString())
            else:
                print("Not found s3apath=[%s]"%del_path)


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
    where a.import_type='full'
    and a.region='{region}'
    group by a.region 
        ,a.biz_type
        ,b.list_name
        ,b.custom_list_id
    """.format(region=args.region)
    listname_df = spark.sql(sql).toPandas()
    
    # ========== 一次性读取所有告警阈值配置 ==========
    threshold_config_sql = """
    select 
        grass_region
        ,biz_type
        ,list_name
        ,check_type
        ,add_ratio_threshold
        ,add_count_threshold
        ,delete_ratio_threshold
        ,delete_count_threshold
    from risk.dim_risk_list_dqc_threshold_config_tab_df
    """
    
    threshold_config_df = spark.sql(threshold_config_sql).toPandas()
    # 将配置转换为字典，key为(region, biz_type, list_name)
    threshold_config_dict = {}
    for _, row in threshold_config_df.iterrows():
        key = (row['grass_region'], row['biz_type'], row['list_name'])
        threshold_config_dict[key] = {
            'check_type': row['check_type'] or DEFAULT_DQC_CONFIG['check_type'],
            'add_ratio_threshold': float(row['add_ratio_threshold']) if row['add_ratio_threshold'] is not None and str(row['add_ratio_threshold']).strip() != '' else DEFAULT_DQC_CONFIG['add_ratio_threshold'],
            'add_count_threshold': int(float(row['add_count_threshold'])) if row['add_count_threshold'] is not None and str(row['add_count_threshold']).strip() != '' else DEFAULT_DQC_CONFIG['add_count_threshold'],
            'delete_ratio_threshold': float(row['delete_ratio_threshold']) if row['delete_ratio_threshold'] is not None and str(row['delete_ratio_threshold']).strip() != '' else DEFAULT_DQC_CONFIG['delete_ratio_threshold'],
            'delete_count_threshold': int(float(row['delete_count_threshold'])) if row['delete_count_threshold'] is not None and str(row['delete_count_threshold']).strip() != '' else DEFAULT_DQC_CONFIG['delete_count_threshold']
        }
    print(f"成功加载 {len(threshold_config_dict)} 条告警阈值配置")
    # ========== 配置读取结束 ==========
    
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
        print(table_region,'->',table_biz_type,'->',list_name,'->',de_table_info,'->',sensitive_tab,'->',custom_list_id)
        hive_to_s3(spark, table_region, table_biz_type ,list_name,de_table_info,filter_cond, args, args_config,biz_db,sensitive_tab,custom_list_id,biz_name,threshold_config_dict)



