#!/usr/bin/python
# -*- encoding: utf-8
import requests
import json
import argparse
import datetime

from pyspark.sql import SparkSession
from pyspark.conf import SparkConf

def alert(src_content="send seatalk msg succ",url = "https://openapi.seatalk.io/webhook/group/-CGK6sCRSvW1gsjYZKwPAw"):
    # content="Date:{date}\n{content}\n".format(date=datetime.datetime.today(),content=src_content)
    email_list=[]
    content="{content}\n".format(content=src_content)
    post_data = {
        "tag": "text",
        "text": {
            "content": content,
        #    "at_all": True
        }
    }
    post_data['text']['mentioned_email_list']=email_list
    data = json.dumps(post_data)
    headers = {'Content-Type': 'application/json'}
    response = requests.request("POST", url=url, headers=headers, data=data)


if __name__ == "__main__":
    # parse parameters
    parser = argparse.ArgumentParser(description='Airflow tools')
    parser.add_argument('-content', type=str, required=False,help="dag1,dag2,dag3")
    parser.add_argument('-seatalk_hook', type=str, required=False,default='',help="")

    args = parser.parse_args()

    spark = SparkSession \
        .builder \
        .appName("dqc hive data") \
        .enableHiveSupport() \
        .config("hive.exec.dynamici.partition", "true") \
        .config("hive.exec.dynamic.partition.mode", "nonstrict") \
        .getOrCreate()

    if args.content !='' and args.seatalk_hook !='':
        alert(args.content,args.seatalk_hook)
    elif args.content !='' and args.seatalk_hook =='':
        alert(args.content)
    else:
        alert()