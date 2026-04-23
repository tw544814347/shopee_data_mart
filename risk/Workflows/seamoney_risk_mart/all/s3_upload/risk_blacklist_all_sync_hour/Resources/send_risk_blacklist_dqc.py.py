#!/usr/bin/python
# -*- encoding: utf-8
import json
import os
import argparse
import re
import sys
from datetime import datetime

import requests
from pyspark.sql import SparkSession

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
    parser = argparse.ArgumentParser(description='DQC warn tools')
    parser.add_argument('-gs', type=str, required=True)
    args = parser.parse_args()
    email_list=['zongyi.lu@shopp.com']


    spark = SparkSession \
        .builder \
        .appName("Risk SPL Plus List Cnt DQC") \
        .enableHiveSupport() \
        .config("hive.exec.dynamici.partition", "true") \
        .config("hive.exec.dynamic.partition.mode", "nonstrict") \
        .getOrCreate()

    str_sql="""select 
                collect_set(result) msg
                from(
                    select 
                    concat(table_name,' => ',status,' => cnt:',cnt_today,' => fluctuation:',cast(fluctuation_type as string),'%') as result
                    from (
                        select 
                        t1.grass_region 
                        ,t1.table_name 
                        ,case when t1.status='1' then 'Add' 
                            when t1.status='-1' then 'Delete' end status 
                        ,t1.cnt_today
                        ,coalesce(t2.cnt_lastday,0) as cnt_lastday
                        ,abs(case when coalesce(t2.cnt_lastday,0)=0 then 1
                            when coalesce(t2.cnt_lastday,0)>0 then round(((t1.cnt_today-t2.cnt_lastday)*1.0000)/(t2.cnt_lastday*1.0000),4) end)*100 as fluctuation_type 
                        from (
                            select 
                            tt1.grass_region 
                            ,tt1.table_name 
                            ,tt1.status 
                            ,count(1) cnt_today
                            from risk.ads_risk_blacklist_full_df tt1 
                            where tt1.grass_date='{grass_date}'
                            and length(tt1.table_name )>1
                            group by 
                            tt1.grass_region 
                            ,tt1.table_name 
                            ,tt1.status 
                        ) t1 
                        left join (
                            select 
                            grass_region 
                            ,table_name 
                            ,status 
                            ,count(1) cnt_lastday
                            from risk.ads_risk_blacklist_full_df tt2 
                            where tt2.grass_date=date_sub('{grass_date}',1)
                            group by tt2.grass_region 
                            ,tt2.table_name 
                            ,tt2.status 
                        ) t2 on t1.grass_region = t2.grass_region and t1.table_name = t2.table_name and t1.status = t2.status
                        order by t1.table_name
                    )a 
                    where a.cnt_today>50000
                    and fluctuation_type>30
                )b   
               """.format(grass_date=args.gs)
    print(str_sql)
    warn_list = spark.sql(str_sql).collect()
    print(warn_list[0])
    print(len(warn_list))
    if not warn_list is None:
        if len(warn_list)>1:
            for i in range(len(warn_list)):
                warn=None
                warn=warn_list[i]
                if warn:
                    seatalk_url="https://openapi.seatalk.io/webhook/group/DpIS_B2TTNes-mtlYPf6PA"
                    alert("Risk Blacklit \nenvironment:prod\nGrass_date:{grass_date}\nMsg:\{msg}\n GSheet:https://docs.google.com/spreadsheets/d/1WG9Yi3OtFoJoZ7rY6vMMnIlQ_lCz6KEcsNyCGvWAB2Y/edit?gid=0#gid=0".format(msg=warn['msg'], grass_date=args.gs),seatalk_url,email_list)


