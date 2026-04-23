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
    email_list=[]


    spark = SparkSession \
        .builder \
        .appName("Risk SPL Plus List Cnt DQC") \
        .enableHiveSupport() \
        .config("hive.exec.dynamici.partition", "true") \
        .config("hive.exec.dynamic.partition.mode", "nonstrict") \
        .getOrCreate()

    str_sql="""select 
                concat(table_name,' cnt:',cnt ) as msg
                from (
                select 
                'smcdrisk_antifraud.ph_spl_plus_shop_whitelist' as table_name 
                ,count(1) as cnt 
                from risk.ads_risk_ph_spl_plus_pricing_center_shop_whitelist_df
                where grass_date='{grass_date}' 
                union all 
                select 
                'smcdrisk_antifraud.ph_spl_plus_user_blacklist' as table_name 
                ,count(1) as cnt 
                from risk.ads_risk_ph_spl_plus_pricing_center_user_blacklist_df
                where grass_date='{grass_date}' 
                union all 
                select 
                'smcdrisk_antifraud.ph_spl_plus_item_blacklist' as table_name 
                ,count(1) as cnt 
                from risk.ads_risk_ph_spl_plus_pricing_center_item_blacklist_df
                where grass_date='{grass_date}' 
                ) a  
               """.format(grass_date=args.gs)
    print(str_sql)
    warn_list = spark.sql(str_sql).collect()
    print(warn_list[0])
    print(len(warn_list))
    warn=""
    if not warn_list is None:
        if len(warn_list)>0:
            for i in range(len(warn_list)):
                warn=warn+warn_list[i]['msg']
                if warn !="":
                    warn = warn+'\n'
    if warn != "":
        print(warn)
        seatalk_url="https://openapi.seatalk.io/webhook/group/JaWohJqJRGWKeBhohyOPzA"
        # seatalk_url="https://openapi.seatalk.io/webhook/group/uR-2p4JQTTGZ4ihgfsbWDQ"
        alert("Risk PH SPL Plus List Cnt \nenvironment:prod\nGrass_date:{grass_date}\nCnt_msg:\n{msg}".format(msg=warn, grass_date=args.gs),seatalk_url,email_list)
