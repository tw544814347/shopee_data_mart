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

def alert(c,seatalk_url="https://openapi.seatalk.io/webhook/group/IQFl6JVwSdO4jZvimuGHUA",email_list=[]):
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
    parser.add_argument('-env', type=str, required=True)
    parser.add_argument('-emaillist', type=str, required=False )
    parser.add_argument('-gs', type=str, required=True)
    parser.add_argument('-seatalkhook', type=str, required=True)
    parser.add_argument('-schema', type=str, required=True)
    parser.add_argument('-tab', type=str, required=True)
    parser.add_argument('-cond', type=str, required=False)

    args = parser.parse_args()


    seatalk_url=args.seatalkhook
    email_list=args.emaillist.split(',')


    spark = SparkSession \
        .builder \
        .appName("dqc hive data") \
        .enableHiveSupport() \
        .config("hive.exec.dynamici.partition", "true") \
        .config("hive.exec.dynamic.partition.mode", "nonstrict") \
        .getOrCreate()

    str_sql="select distinct dqc_title,warn_msg  from {schema}.{table_name} where grass_date='{grass_date}' {condition}".format(schema=args.schema,grass_date=args.gs,table_name=args.tab,condition=args.cond)
    print(str_sql)
    warn_list = spark.sql(str_sql).collect()


    print(len(warn_list))
    if not warn_list is None:
        if len(warn_list)>0:
            for i in range(len(warn_list)):
                warn=None
                warn=warn_list[i]
                if warn:
                    alert("\ndqc type:{dqctype}\nenvironment:{env}\nGrass_date:{grass_date}\nWarn_msg:\n{warn_msg}".format(dqctype=warn['dqc_title'],
                                                                                                                           env=args.env,
                                                                                                                           warn_msg=warn['warn_msg'],
                                                                                                                           grass_date=args.gs),seatalk_url,email_list)
            sys.exit(0)


