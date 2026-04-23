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
def alert(c,seatalk_url="https://openapi.seatalk.io/webhook/group/aWmxYuMPSb2Fh8o5VAJoCg",email_list=[]):
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
        .appName("Risk DS Metric DQC") \
        .enableHiveSupport() \
        .config("hive.exec.dynamici.partition", "true") \
        .config("hive.exec.dynamic.partition.mode", "nonstrict") \
        .getOrCreate()

    str_sql="""select concat(grass_region,'_',product_id,'-> ', dqc_type) as error_msg  
               from risk.ads_risk_aio_ds_metric_dqc_df 
               where grass_date='{grass_date}'
               group by concat(grass_region,'_',product_id,'-> ', dqc_type)
               """.format(grass_date=args.gs)
    print(str_sql)
    warn_list = spark.sql(str_sql).collect()
    warn=""
    print(len(warn_list))
    if not warn_list is None:
        if len(warn_list)>0:
            for i in range(len(warn_list)):
                warn=warn+warn_list[i]['error_msg']
                if warn !="":
                    warn = warn+'\n'
    if warn != "":
        seatalk_url="https://openapi.seatalk.io/webhook/group/aWmxYuMPSb2Fh8o5VAJoCg"
        # seatalk_url="https://openapi.seatalk.io/webhook/group/XikEhDSNQYyTfiFMUkZh9g"
        alert("\ndqc type:Risk DS Metric DQC \nenvironment:prod\nGrass_date:{grass_date}\nWarn_msg:\{msg}".format(msg=warn, grass_date=args.gs),seatalk_url,email_list)


