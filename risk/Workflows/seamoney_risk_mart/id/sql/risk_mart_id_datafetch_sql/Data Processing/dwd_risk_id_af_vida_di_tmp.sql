--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-02-01
-- Theme Domain：       外部数据
-- Description:         ID 用户外部数据,https://docs.google.com/spreadsheets/d/1tCaiMiy4NT7Mx2apgnAQZwSHIXBllsQta6EszrVXcSs/edit#gid=812575074
-- Data Granularity:    credit_user_id
-- 变更历史：
--      update by xiaobin.qiu@shopee.com， 增加注释，切换risk.dwd_br_af_risk_screen_df Mart表
--********************************************************************--
ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
drop temporary function if exists json_to_array; 
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite table ${SCHEMA}.dwd_risk_id_af_vida_di_tmp partition (grass_date)
select 
case when length(get_json_object(t1.header_data, '$.CreditUserId')) >1 then get_json_object(t1.header_data, '$.CreditUserId')
     else t3.credit_user_id end                                  as credit_user_id
,t1.request_key                                                  as request_key
,t1.data_source_name                                             as data_source_name
,t1.data_source_code                                             as data_source_code
,get_json_object(t1.resp_raw_data, '$.data.eventId')             as kyc_event_id
,get_json_object(t1.resp_raw_data, '$.data.certificateIssued')   as kyc_status_raw
,case when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10 
      when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0 
      else null end               as score_pob 
,case when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10 
      when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0 
      else null end               as score_full_name 
,null                             as score_address 
,null                             as score_province 
,null                             as score_city 
,case when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10 
      when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0 
      else null end               as score_dob 
,null                             as score_district 
,null                             as score_village 
,case when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10 
      when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0 
      else null end               as score_nik 
,null                             as score_mother_maiden_name 
,null                             as score_family_card_no 
,case when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10 
      when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0 
      else null end               as score_demographic 
,case when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10 
      when get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0 
      else null end               as score_selfiephoto 
,case when t2.kyc_event_id is not null  then cast(t2.score as DECIMAL(10,2)) else null end as score_liveness 
,t1.trace_id 
,t1.create_time 
,t1.update_time
,to_date(t1.create_time) as grass_date
from risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df t1 
left join (
     select 
     kyc_event_id
     ,get_json_object(tbl.fields,'$.field') field
     ,get_json_object(tbl.fields,'$.score') score
     from (
           select 
           get_json_object(t1.resp_raw_data, '$.data.eventId') as kyc_event_id
           ,get_json_object(t1.resp_raw_data, '$.data.fields') as fields
           from risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df t1
           where grass_date ='${grass_date}'
           and data_source_name in('VidaLdnFull','VidaCfFull')
     ) a 
     lateral view explode(json_to_array(fields)) tbl as fields 
     where get_json_object(tbl.fields,'$.field')='liveness'
) t2 on get_json_object(t1.resp_raw_data, '$.data.eventId') = t2.kyc_event_id
left join (
    select 
    credit_user_id
    ,id_card_no
    from (
        select  
            credit_user_id
            ,id_card_no
            ,row_number() over(partition by id_card_no order by create_time asc) as rn	-- 最早的身份证那条记录
        from  (
            select  
                create_time
                ,cast(user_id as string) as credit_user_id
                ,id_card_no
            from    credit.ods__credit_usercenter_member_id_db__user_base_info_tab__df
            where   grass_date='${grass_date}'
            union all 
            select  create_time
                    ,cast(user_id as string) as credit_user_id
                    ,id_card_no
            from    credit.ods__ldn_usercenter_member_id_db__user_base_info_tab__df
            where   grass_date='${grass_date}'
        ) a 
    ) a 
    where   rn = 1
) t3 on get_json_object(t1.req_data, '$.GovID') = t3.id_card_no
where t1.grass_date ='${grass_date}'
and t1.data_source_name in('VidaLdnFull','VidaCfFull')
union all 
--------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
  case when length(get_json_object(t.header_data, '$.CreditUserId')) >1 then get_json_object(t.header_data, '$.CreditUserId')
       else t3.credit_user_id 
  end as credit_user_id,
  t.request_key AS request_key,
  t.data_source_name AS data_source_name,
  t.data_source_code AS data_source_code,
  get_json_object(t.resp_raw_data, '$.data.transactionId') AS kyc_event_id,
  get_json_object(t.resp_raw_data, '$.data.statusCode') AS kyc_status_raw,
  NULL AS score_pob,
  a.score_full_name AS score_full_name,
  NULL AS score_address,
  NULL AS score_province,
  NULL AS score_city,
  a.score_dob AS score_dob,
  NULL AS score_district,
  NULL AS score_village,
  a.score_nik AS score_nik,
  NULL AS score_mother_maiden_name,
  NULL AS score_family_card_no,
  NULL AS score_demographic,
  a.score_selfiephoto AS score_selfiephoto,
  NULL AS score_liveness,
  t.trace_id AS trace_id,
  format_time(t.create_time,'ID') as create_time,
  format_time(t.update_time,'ID') as update_time,
  date(t.create_time) as grass_date
FROM (
  SELECT 
    resp_raw_data,
    header_data,
    request_key,
    data_source_name,
    data_source_code,
    trace_id,
    create_time,
    update_time,
    req_data,
    get_json_object(resp_raw_data, '$.data.transactionId') as kyc_event_id
  FROM risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
  WHERE data_source_name IN ('VidaCfFullNew', 'VidaCfFrNew', 'VidaCfDemogNew', 'VidaLdnFullNew')
    AND grass_date = '${ds}'
) t
LEFT JOIN (
   select kyc_event_id,
            MAX(CASE WHEN b.assessment_name = 'full_name' THEN b.assessment_score ELSE NULL END) AS score_full_name,
            MAX(CASE WHEN b.assessment_name = 'dob' THEN b.assessment_score ELSE NULL END) AS score_dob,
            MAX(CASE WHEN b.assessment_name = 'nik' THEN b.assessment_score ELSE NULL END) AS score_nik,
            MAX(CASE WHEN b.assessment_name = 'selfiePhoto' THEN b.assessment_score ELSE NULL END) AS score_selfiephoto
   from 
      (
      SELECT 
      resp_raw_data,
      get_json_object(resp_raw_data, '$.data.transactionId') as kyc_event_id,
      data_source_name,
      assessment_obj.name AS assessment_name,
      assessment_obj.result * 10 AS assessment_score -- 将[0,1]范围转换为[0,10]范围
      FROM risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
      LATERAL VIEW EXPLODE(
      FROM_JSON(
            get_json_object(resp_raw_data, '$.data.assessmentResults'),
            'array<struct<name:string,result:double>>'
      )
      ) assessments AS assessment_obj
      WHERE data_source_name IN ('VidaCfFullNew', 'VidaCfFrNew', 'VidaCfDemogNew', 'VidaLdnFullNew') 
      AND grass_date = '${ds}'
      ) b
   group by kyc_event_id
) a ON t.kyc_event_id = a.kyc_event_id
-- ON t.resp_raw_data = a.resp_raw_data
-- AND t.header_data = a.header_data
-- AND t.request_key = a.request_key
-- AND t.data_source_code = a.data_source_code
LEFT JOIN (
    select 
    credit_user_id
    ,id_card_no
    from (
        select  
            credit_user_id
            ,id_card_no
            ,row_number() over(partition by id_card_no order by create_time asc) as rn	-- 最早的身份证那条记录
        from  (
            select  
                create_time
                ,cast(user_id as string) as credit_user_id
                ,id_card_no
            from    credit.ods__credit_usercenter_member_id_db__user_base_info_tab__df
            where   grass_date='${ds}'
            union all 
            select  create_time
                    ,cast(user_id as string) as credit_user_id
                    ,id_card_no
            from    credit.ods__ldn_usercenter_member_id_db__user_base_info_tab__df
            where   grass_date='${ds}'
        ) a 
    ) a 
    where   rn = 1
) t3 on get_json_object(t.req_data, '$.GovID') = t3.id_card_no
;
--------------------------------------------------------------------------------------------------------------------------------------------------------