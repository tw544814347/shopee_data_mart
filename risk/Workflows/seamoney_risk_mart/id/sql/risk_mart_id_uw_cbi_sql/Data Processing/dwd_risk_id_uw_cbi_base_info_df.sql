--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-18
-- Theme Domain：       外部数据 cbi base_info(因为SlikReports 可能会存在多个report_no,因此需要先取SlikReports.error!=True的最新一条) 后续的表都基于这份数据做解析
-- Description:         外部数据 cbi base_info
-- Data Granularity:    https://docs.google.com/spreadsheets/d/1tCaiMiy4NT7Mx2apgnAQZwSHIXBllsQta6EszrVXcSs/edit?gid=1916042379#gid=1916042379
--                      jira: https://jira.shopee.io/browse/SPFDT-45018
-- 变更历史：
--********************************************************************--
add jar hdfs://R2/projects/risk/hdfs/udf/get_cbi_report_no.jar;
drop temporary function if exists get_cbi_report_no; 
create temporary function get_cbi_report_no as 'com.shopee.udf.GetCbiReportlist';

insert overwrite table risk.dwd_risk_id_uw_cbi_base_info_df partition(grass_date='${grass_date}')
select 
t4.trace_id
,t4.credit_user_id  
,t4.platform_user_id
,t4.flow_no         
,t4.ktp_no          
,t4.cbi_status      
,t4.cbi_is_error 
,t4.cbi_report_no
,t4.rinf_report_date_time as report_update_time
,t4.report_error
,t4.report_status
,t4.slik_report
from(
    select 
    t3.trace_id
    ,t3.credit_user_id  
    ,t3.platform_user_id
    ,t3.flow_no         
    ,t3.ktp_no          
    ,t3.cbi_status      
    ,t3.cbi_is_error 
    ,t3.report_no as cbi_report_no
    ,t3.rinf_report_date_time
    ,t3.report_error 
    ,t3.report_status
    ,t3.report_info as slik_report
    ,row_number() over(partition by t3.trace_id order by report_error_type , rinf_report_date_time desc) rn -- 排序规则: 取error=false 的最新一条
    from (
        select 
        t2.trace_id
        ,t2.credit_user_id  
        ,t2.platform_user_id
        ,t2.flow_no         
        ,t2.ktp_no          
        ,t2.cbi_status      
        ,t2.cbi_is_error 
        ,tbl.report_no
        ,get_json_object(t2.slik_report,concat('$.',tbl.report_no)) as report_info     
        ,get_json_object(get_json_object(t2.slik_report,concat('$.',tbl.report_no)),'$.result.BureauReport.ReportInfo.RINF_ReportDateTime') rinf_report_date_time 
        ,get_json_object(get_json_object(t2.slik_report,concat('$.',tbl.report_no)),'$.error') report_error
        ,get_json_object(get_json_object(t2.slik_report,concat('$.',tbl.report_no)),'$.status') report_status
        ,case when get_json_object(get_json_object(t2.slik_report,concat('$.',tbl.report_no)),'$.error')='flase' then 2 else 1 end report_error_type
        from(
            select
                t1.trace_id                 
                ,get_json_object(t1.header_data,'$.CreditUserId')   as credit_user_id          
                ,get_json_object(t1.header_data,'$.PlatformUserId') as platform_user_id        
                ,get_json_object(t1.header_data,'$.FlowNo')         as flow_no                 
                ,get_json_object(t1.req_data,'$.IdNumber')          as ktp_no                  
                ,get_json_object(t1.resp_raw_data,'$.SlikReports')  as slik_report         
                ,get_json_object(t1.resp_raw_data,'$.status')       as cbi_status              
                ,get_json_object(t1.resp_raw_data,'$.error')        as cbi_is_error 
                ,get_cbi_report_no(t1.resp_raw_data)                as report_no_list -- 可能会有多个report_no,返回 reportno1,reportno2...这样的格式
                from risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df t1 
            where t1.grass_date ='${grass_date}'
            and t1.data_source_name='CBI'
        ) t2 
        lateral view explode(split(report_no_list,',')) tbl as report_no
    ) t3 
) t4 
where t4.rn=1
;


