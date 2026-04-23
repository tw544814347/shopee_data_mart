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


def hive_to_s3(spark: SparkSession, region, db_table_name,condition, args, args_config):
    env=args.env
    db_table_name = db_table_name.replace('{region}', region.lower())
    table_name = db_table_name.split('.')[1]
    db_name = db_table_name.split('.')[0]
    if spark.catalog._jcatalog.tableExists(db_name, table_name):
        print(db_table_name,'exists')
        str_sql = "select * from {db_table_name} where 1=1 {condition}".format(db_table_name=db_table_name,condition=condition)
        print(str_sql)
        df = spark.sql(str_sql)

        #导数至S3的文件命名
        s3filename = table_name+"_"+args.gs.replace("-","")
        #导数至S3的地址
        path = "risk_qa_data/{region}/{table_name}".format(region=region, table_name=table_name)

        #定期清理路径
        del_path= "s3a://{bucketname}/{path}/{del_date}/".format(**args_config[env], path=path, del_date=date_diff('{grass_date}'.format(**args_config[env])).replace("-",""))

        filepath = "s3a://{bucketname}/{path}/{file_date}/".format(**args_config[env], path=path, file_date=args.gs.replace("-",""))
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

        print("s3apath=[%s]"%del_path)
        if fs.exists(Path(del_path)):
            fs.delete(Path(del_path), True)
            print("del s3apath=[%s] ok." %del_path)
        else:
            print("Not found s3apath=[%s]"%del_path)
    else:
        print(db_table_name,'does not exists')


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

    region_list = ['ID', 'MY', 'PH', 'TH', 'VN', 'SG', 'TW']
    sg_region_list = ['SG']

    db_tables = {
        'data_source_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__data_source_tab__df','condition':'and grass_date='},
        'risk_feature_common_args_config_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_common_args_config_tab__df','condition':'and grass_date='},
        'risk_feature_dependency_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_dependency_tab__df','condition':'and grass_date='},
        'risk_feature_outer_proto_method_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_outer_proto_method_tab__df','condition':'and grass_date='},
        'risk_feature_outer_proto_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_outer_proto_tab__df','condition':'and grass_date='},
        'risk_feature_template_choice_mapping_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_template_choice_mapping_tab__df','condition':'and grass_date='},
        'risk_feature_template_datasource_choice_mapping_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_template_datasource_choice_mapping_tab__df','condition':'and grass_date='},
        'risk_feature_template_desc_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_template_desc_tab__df','condition':'and grass_date='},
        'risk_feature_template_output_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_template_output_tab__df','condition':'and grass_date='},
        'risk_feature_template_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_template_tab__df','condition':'and grass_date='},
        'risk_feature_template_to_datasource_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_template_to_datasource_tab__df','condition':'and grass_date='},
        'risk_feature_template_choice_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_template_choice_tab__df','condition':'and grass_date='},
        'risk_feature_template_datasource_choice_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_template_datasource_choice_tab__df','condition':'and grass_date='},
        'risk_feature_template_model_dependency_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_template_model_dependency_tab__df','condition':'and grass_date='},
        'risk_feature_tab': {'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_tab__df','condition':'and grass_date='},
        'strategy_l3_group_methods_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__strategy_l3_group_methods_tab__df','condition':'and grass_date='},
        'risk_workflow_config_tree_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__risk_workflow_config_tree_tab__df','condition':'and grass_date='},
        'workflow_routing_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__workflow_routing_tab__df','condition':'and grass_date='},
        'dict_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__dict_tab__df','condition':'and grass_date='},
        'return_code_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__return_code_tab__df','condition':'and grass_date='},
        'param_pool_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__param_pool_tab__df','condition':'and grass_date='},
        'policy_tree_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__policy_tree_tab__df','condition':'and grass_date='},
        'tree_node_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__tree_node_tab__df','condition':'and grass_date='},
        'node_policy_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__node_policy_tab__df','condition':'and grass_date='},
        'node_param_config_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__node_param_config_tab__df','condition':'and grass_date='},
        'data_feature_param_config_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__data_feature_param_config_tab__df','condition':'and grass_date='},
        'strategy_model_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__strategy_model_tab__df','condition':'and grass_date='},
        'tree_node_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__tree_node_tab__df','condition':'and grass_date='},
        'node_rule_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__node_rule_tab__df','condition':'and grass_date='},
        'policy_tree_version_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__policy_tree_version_tab__df','condition':'and grass_date='},
        'policy_output_field_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__policy_output_field_tab__df','condition':'and grass_date='},
        'upload_file_tab':{'table_name':'risk.ods__credit_risk_control_{region}_db__upload_file_tab__df','condition':'and grass_date='},
        'policy_file_tab':{'table_name':'risk.ods__credit_risk_control_{region}_db__policy_file_tab__df','condition':'and grass_date='},
        'risk_event_meta_data_tab':{'table_name':'risk.ods__credit_risk_control_{region}_db__risk_event_meta_data_tab__df','condition':'and grass_date='},
        'risk_event_action_tab':{'table_name':'risk.ods__credit_risk_control_{region}_db__risk_event_action_tab__df','condition':'and grass_date='},
        'risk_action_imp_tab':{'table_name':'risk.ods__credit_risk_control_{region}_db__risk_action_imp_tab__df','condition':'and grass_date='},
        'risk_action_combination_tab':{'table_name':'risk.ods__credit_risk_control_{region}_db__risk_action_combination_tab__df','condition':'and grass_date='},
        'risk_feature_new_tab':{'table_name':'risk.ods__credit_risk_feature_{region}_db__risk_feature_new_tab__df','condition':'and grass_date='},
    }

    sg_v2_db_tables = {
        'data_source_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__data_source_tab__df','condition':'and grass_date='},
        'risk_feature_common_args_config_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_common_args_config_tab__df','condition':'and grass_date='},
        'risk_feature_outer_proto_method_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_outer_proto_method_tab__df','condition':'and grass_date='},
        'risk_feature_outer_proto_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_outer_proto_tab__df','condition':'and grass_date='},
        'risk_feature_template_choice_mapping_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_choice_mapping_tab__df','condition':'and grass_date='},
        'risk_feature_template_choice_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_choice_tab__df','condition':'and grass_date='},
        'risk_feature_template_datasource_choice_mapping_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_datasource_choice_mapping_tab__df','condition':'and grass_date='},
        'risk_feature_template_datasource_choice_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_datasource_choice_tab__df','condition':'and grass_date='},
        'risk_feature_template_desc_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_desc_tab__df','condition':'and grass_date='},
        'risk_feature_template_output_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_output_tab__df','condition':'and grass_date='},
        'risk_feature_template_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_tab__df','condition':'and grass_date='},
        'risk_feature_template_to_datasource_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_to_datasource_tab__df','condition':'and grass_date='},
        'risk_feature_warm_up_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_warm_up_tab__df','condition':'and grass_date='},
        'risk_feature_dependency_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_dependency_tab__df','condition':'and grass_date='},
        'risk_feature_template_model_dependency_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_model_dependency_tab__df','condition':'and grass_date='},
        'risk_feature_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_tab__df','condition':'and grass_date='},
        'risk_entity_template_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_entity_template_tab__df','condition':'and grass_date='},
        'risk_feature_template_choice_new_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_choice_new_tab__df','condition':'and grass_date='},
        'risk_feature_template_datasource_choice_new_tab': {'table_name':'risk.ods__credit_risk_feature_v2_{region}_db__risk_feature_template_datasource_choice_new_tab__df','condition':'and grass_date='},

    }
    # region_list = ['ID']
    # sg_region_list = ['SG']
    # db_tables = {
    #     'node_param_config_tab': {'table_name':'risk.ods__credit_risk_control_{region}_db__node_param_config_tab__df','condition':'and grass_date='},
        
    # }
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
    # database_name='dev_risk'
    # table_name='ods__test_partition111'
    # if spark.catalog._jcatalog.tableExists(database_name, table_name):
    #     print(f"The table {database_name}.{table_name} exists.")
    # else:
    #     print(f"The table {database_name}.{table_name} does not exist.")

    for region in region_list:
        for table_name, options in db_tables.items():
            if 'condition' in options.keys():
                filter_cond = options['condition']+"'"+'{grass_date}'.format(**args_config[env])+"'"
                hive_to_s3(spark, region, options['table_name'],filter_cond, args, args_config)
            else :
                filter_cond=''
                hive_to_s3(spark, region, options['table_name'],filter_cond, args, args_config)
    
    # sg v2 db 单独
    for region in sg_region_list:
        for table_name, options in sg_v2_db_tables.items():
            if 'condition' in options.keys():
                filter_cond = options['condition']+"'"+'{grass_date}'.format(**args_config[env])+"'"
                hive_to_s3(spark, region, options['table_name'],filter_cond, args, args_config)
            else :
                filter_cond=''
                hive_to_s3(spark, region, options['table_name'],filter_cond, args, args_config)



