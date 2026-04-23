#!/usr/bin/python3
# encoding: utf-8
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
import pandas as pd

import re,json,sys,os
import random
import math
import datetime
import argparse


#20240401 by zhugj


parser = argparse.ArgumentParser(description='SG2US DQC tools')
parser.add_argument('-dt', type=str, required=True,
                    help="grass_date or begin_ds")
parser.add_argument('-region', type=str, required=True,
                    help="SG or US")
parser.add_argument('-prj', type=str, required=True,
                    help="product_line")

args = parser.parse_args()
yesterday=args.dt
region = args.region
product_line = args.prj


spark = SparkSession.builder \
            .appName('FP-SG2US-DQC-Credit') \
            .master('yarn') \
            .config('spark.sql.execution.arrow.pyspark.enabled', True) \
            .config('spark.sql.session.timeZone', 'UTC') \
            .config('spark.driver.memory','16G') \
            .config('spark.executor.memory', '16g') \
            .config('spark.executor.cores', '4') \
            .config('spark.num.executors', '64') \
            .config('hive.exec.dynamic.partition.mode', 'nonstrict') \
            .config('spark.ui.showConsoleProgress', True) \
            .config('spark.sql.repl.eagerEval.enabled', True) \
            .enableHiveSupport() \
            .getOrCreate()



tab_list = """
ads_risk_br_uw_fes_process_di
ads_risk_bcl_br_instalment_dpd_df
ads_risk_spl_br_bill_dpd_df
ads_risk_spl_br_loan_mob_dpd_df
ads_risk_br_uw_spl_process_di
dwd_risk_af_blacklist_df
dwd_risk_br_uw_bcl_process_di_dist
dwd_risk_br_af_credit_workflow_di
dwd_risk_br_af_credit_workflow_step_di
dwd_risk_br_af_final_result_lab_shadow_di
dws_risk_br_uw_bcl_process_di
dwd_risk_br_af_node_result_lab_shadow_di
dwd_risk_br_af_shopeepay_workflow_step_di
dwd_risk_br_credit_custom_list_df
dwd_risk_br_invest_af_final_result_di
dwd_risk_br_invest_af_node_result_di
dwd_risk_br_shopeepay_custom_list_df
dwd_risk_br_spp_af_final_result_lab_shadow_di
dwd_risk_br_spp_af_node_result_lab_shadow_di
dws_risk_shop_txn_ctime_df
dwd_risk_br_spp_gateway_req_rsp_final_result_di
dwd_risk_br_spp_gateway_req_rsp_node_result_di
dwd_risk_br_strategy_final_result_merge_di
dwd_risk_br_strategy_node_result_merge_di
dwd_risk_br_user_identity_log_df
dws_risk_shop_txn_df
dwd_risk_br_uw_quod_income_base_info_pincome_df
dwd_risk_br_uw_quod_score_base_info_history_address_df
dwd_risk_br_uw_quod_score_base_info_history_email_df
ads_shopeepay_risk_br_af_workflow_2fa_di
dwd_risk_br_uw_quod_score_base_info_history_mobile_phone_df
dwd_risk_br_uw_quod_score_base_info_history_name_df
dwd_risk_br_uw_quod_score_base_info_history_phone_df
dwd_risk_br_uw_quod_score_base_info_inquiry_df
dwd_risk_br_uw_quod_score_base_info_qscore_df
dwd_risk_br_uw_quod_score_cpf_overview_df
dwd_risk_br_uw_quod_score_credit_lines_consortium_detached_payment_df
dwd_risk_br_uw_quod_score_credit_lines_consortium_df
dwd_risk_br_uw_quod_score_credit_lines_consortium_future_installment_df
dwd_risk_br_uw_quod_score_credit_lines_consortium_pre_installment_df
dwd_risk_br_uw_quod_score_credit_lines_consortium_pre_installment_payment_df
dwd_risk_br_uw_quod_score_credit_lines_creditcard_df
dwd_risk_br_uw_quod_score_credit_lines_creditcard_pre_installment_df
dws_risk_buyer_txn_df
dwd_risk_br_uw_quod_score_credit_lines_creditcard_pre_installment_payment_df
dwd_risk_br_uw_quod_score_credit_lines_loan_detached_payment_df
dwd_risk_br_credit_custom_list_rare_type_df
dws_risk_br_uw_spl_process_di
dwd_risk_br_uw_quod_score_credit_lines_loan_df
dwd_risk_br_uw_quod_score_credit_lines_loan_future_installment_df
dwd_risk_br_uw_quod_score_credit_lines_loan_pre_instal_payment_df
dwd_risk_br_uw_quod_score_credit_lines_loan_pre_installment_df
dwd_risk_br_uw_quod_score_credit_lines_loan_pre_installment_di
dwd_risk_br_uw_quod_score_credit_lines_revolving_df
dwd_risk_br_uw_quod_score_credit_lines_revolving_pre_installment_df
dwd_risk_br_uw_quod_score_enterprises_df
dwd_risk_br_uw_quod_score_negative_annotation_df
ads_risk_br_uw_bcl_process_di
dwd_risk_br_uw_quod_score_negative_ccfnotes_df
dwd_risk_br_uw_quod_score_negative_lawsuit_df
dwd_risk_br_uw_quod_score_protest_content_registry_df
dwd_risk_br_uw_quod_score_protest_df
dwd_risk_br_uw_risk_trade_df
dws_risk_af_user_login_nd
dwd_risk_br_uw_serasa_bad_check_df
dws_risk_user_frequency_gps_df
dwd_risk_br_uw_serasa_inquiries_df
dwd_risk_br_uw_serasa_notary_info_df
dwd_risk_br_uw_serasa_payment_history_df
dwd_risk_br_uw_serasa_pefin_info_df
dwd_risk_br_uw_serasa_personal_info_df
dws_risk_bcl_br_user_mob_dpd_df
dwd_risk_br_uw_serasa_refin_info_df
dwd_risk_br_uw_serasa_score_df
dwd_risk_user_phone_bind_df
dwd_risk_br_uw_serasa_spc_inquiries_df
dwd_risk_br_af_shopeepay_workflow_di
dwd_risk_br_uw_process_di
dwd_risk_br_uw_serasa_spc_negative_df
dwd_risk_br_uw_serasa_stolen_documents_df
dwd_risk_spp_af_blacklist_df
dwd_br_af_risk_screen_df
dws_risk_af_user_device_list_nd
dwd_risk_checkout_di
dws_risk_bcl_br_loan_dpd_df
dwd_risk_br_uw_fes_process_di_dist
dws_risk_spl_br_loan_dpd_df
dws_risk_user_login_info_df
dim_risk_user_address_df
wide_bcl_br_application_apply_risk_af_uw_info_nd
wide_bcl_br_behavior_withdraw_risk_af_info_nd
dim_risk_shop_df
dws_risk_br_uw_fes_process_di
ads_risk_br_seller_feature_df
wide_fes_br_application_apply_risk_af_uw_info_nd
wide_spl_br_application_apply_risk_af_uw_info_nd
wide_spl_br_behavior_checkout_risk_af_info_nd""".strip().split("\n")

# tab_list="""
# ads_risk_af_device_login_nd
# dim_risk_shop_df""".strip().split("\n")

region_tab_list="""
ads_risk_af_device_login_nd
dim_risk_shop_df
dim_risk_user_address_df
dwd_risk_af_blacklist_df
dwd_risk_af_user_device_login_di
dwd_risk_af_user_device_manual_login_nd
dwd_risk_checkout_di
dwd_risk_spp_af_blacklist_df
dwd_risk_user_phone_bind_df
dws_risk_af_user_device_ip_manual_login_nd
dws_risk_af_user_device_list_nd
dws_risk_af_user_device_login_nd
dws_risk_af_user_login_nd
dws_risk_buyer_txn_df
dws_risk_shop_txn_ctime_df
dws_risk_shop_txn_df
dws_risk_user_frequency_gps_df
dws_risk_user_login_info_df
""".strip().split("\n")

print('待处理的表数量是 ' + str(len(tab_list)))

insert_sql = """
insert overwrite table {}.temp__brus_datacount_statistics_s3 partition(region,  product_line, db_tab, grass_date)
""".format(product_line)


datacheck_sql_template = """
select 
     coalesce(count(*),0) as datacount,
     '{region}' as region,
     '{product_line}' as product_line,
     '{db_tab}' as db_tab,
     '{grass_date}' as grass_date
from {schema}.{db_tab}
where grass_date='{grass_date}'
{grass_region_filter}
"""

sql_list = []

flag=0
for t in tab_list:
    grass_region_filter = ""
    if t in region_tab_list:
        grass_region_filter = "and grass_region='BR'"
        sql = datacheck_sql_template.format(db_tab = t, grass_date = yesterday, region=region, product_line=product_line, schema = product_line,grass_region_filter=grass_region_filter)  
    else:
        sql = datacheck_sql_template.format(db_tab = t, grass_date = yesterday, region=region, product_line=product_line, schema = product_line,grass_region_filter=grass_region_filter)  
    sql_list.append(sql)
    

    if len(sql_list) == 30:
        final_sql = insert_sql +  'union all'.join(sql_list)
        print(final_sql)
        spark.sql(final_sql)
        sql_list.clear()
        flag +=1
        print('第{}段已完成'.format(flag))
 
        
        
print('剩余的表长度是：' + str(len(sql_list)))
if len(sql_list)>0:
    final_sql = insert_sql + 'union all'.join(sql_list)
    spark.sql(final_sql)
    print(final_sql)

print('done')