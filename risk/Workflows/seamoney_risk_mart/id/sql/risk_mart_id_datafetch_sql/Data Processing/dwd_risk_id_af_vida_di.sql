--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-02-01
-- Theme Domain：       外部数据
-- Description:         ID 用户外部数据,https://docs.google.com/spreadsheets/d/1tCaiMiy4NT7Mx2apgnAQZwSHIXBllsQta6EszrVXcSs/edit#gid=812575074
-- Data Granularity:    credit_user_id
-- 变更历史：
--      update by zongyi.lu@shopee.com 新增 'VidaLdnFull','VidaCfFull' 的数据 
--      update by zongyi.lu@shopee.com jira: https://jira.shopee.io/browse/SPFDT-35759 1.修改字段score_pob逻辑(存量2个数据源的字段, 后续2024-03-21起增量数据改为null) 2. 新增VidaCfFr&VidaCfDemog 数据源(可以暂时先不加了 目前还卡在签合约阶段 可能会没那么快上线) 3.历史数据中create_time update_time 统一转成local
--      update by wei.tao 20250521 jira: https://jira.shopee.io/browse/SPFDT-51591 新增数据源 'VidaCfFullNew', 'VidaCfFrNew', 'VidaCfDemogNew', 'VidaLdnFullNew' ; 解析逻辑： https://docs.google.com/spreadsheets/d/1tCaiMiy4NT7Mx2apgnAQZwSHIXBllsQta6EszrVXcSs/edit?gid=812575074#gid=812575074
--********************************************************************--
ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
drop temporary function if exists json_to_array; 
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite table ${SCHEMA}.dwd_risk_id_af_vida_di partition (grass_date)
select  coalesce(if(t1.credit_user_id='',null,t1.credit_user_id),t3.credit_user_id) as credit_user_id
        ,t1.request_key
        ,t1.data_source_name
        ,t1.data_source_code
        ,t1.kyc_event_id
        ,t1.kyc_status_raw
        ,t2.score_pob
        ,t2.score_full_name
        ,t2.score_address
        ,t2.score_province
        ,t2.score_city
        ,t2.score_dob
        ,t2.score_district
        ,t2.score_village
        ,t2.score_nik
        ,t2.score_mother_maiden_name
        ,t2.score_family_card_no
        ,t2.score_demographic
        ,t2.score_selfiePhoto
        ,t2.score_liveness
        ,t1.trace_id
        ,format_time(t1.create_time,'ID') as create_time
        ,format_time(t1.update_time,'ID') as update_time
        ,date(t1.create_time) as grass_date
from    (
    select  get_json_object(header_data, '$.CreditUserId') as credit_user_id
            ,get_json_object(resp_raw_data, '$.data.kycEventId') as kyc_event_id
            ,get_json_object(resp_raw_data, '$.data.kycStatus') as kyc_status_raw
            ,cast(get_json_object(req_data, '$.GovID') as string) AS id_card_no
            ,request_key
            ,data_source_name
            ,data_source_code
            ,trace_id
            ,update_time
            ,create_time
    from    risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
    where   grass_date = '${ds}'
      --and   date(create_time) = '${ds}'
      and   data_source_name = 'VidaData'
      and   get_json_object(resp_raw_data, '$.data.kycEventId') is not null
) t1
left join (
    --t1和t2其实是同一份数据，只是因为t2涉及到列转行，避免数据膨胀，所以只包含了需要列换行的列
    select  kyc_event_id
            ,max(CASE WHEN field = 'pob' THEN score ELSE NULL END) AS score_pob
            ,max(CASE WHEN field = 'full_name' THEN score ELSE NULL END) AS score_full_name
            ,max(CASE WHEN field = 'address' THEN score ELSE NULL END) AS score_address
            ,max(CASE WHEN field = 'province' THEN score ELSE NULL END) AS score_province
            ,max(CASE WHEN field = 'city' THEN score ELSE NULL END) AS score_city
            ,max(CASE WHEN field = 'dob' THEN score ELSE NULL END) AS score_dob
            ,max(CASE WHEN field = 'district' THEN score ELSE NULL END) AS score_district
            ,max(CASE WHEN field = 'village' THEN score ELSE NULL END) AS score_village
            ,max(CASE WHEN field = 'nik' THEN score ELSE NULL END) AS score_nik
            ,max(CASE WHEN field = 'mother_maiden_name' THEN score ELSE NULL END) AS score_mother_maiden_name
            ,max(CASE WHEN field = 'family_card_no' THEN score ELSE NULL END) AS score_family_card_no
            ,(sum(IF(field IN ('pob', 'full_name', 'address', 'province', 'city', 'dob', 'district', 'village', 'nik', 'mother_maiden_name', 'family_card_no')  and score >= 0, score, null))) / (count(IF(field IN ('pob', 'full_name', 'address', 'province', 'city', 'dob', 'district', 'village', 'nik', 'mother_maiden_name', 'family_card_no') and score >= 0, score, null))) AS score_demographic	--这个字段上面所有score的平均数
            ,max(CASE WHEN field = 'selfiePhoto' THEN score ELSE NULL END) AS score_selfiePhoto
            ,max(CASE WHEN field = 'liveness' THEN score ELSE NULL END) AS score_liveness
    from    (
        select  get_json_object(t21.resp_raw_data, '$.data.kycEventId') as kyc_event_id
                ,t24.field
                ,cast(t24.score as decimal(10, 2)) as score
        from    (
            select  *
            from    risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
            where   grass_date = '${ds}'
              --and   date(create_time) = '${ds}'
              and   data_source_name = 'VidaData'
              and   get_json_object(resp_raw_data, '$.data.kycEventId') is not null
        ) t21
        lateral view explode(split(replace(regexp_replace(get_json_object(resp_raw_data, '$.data.fields'), '\\[|\\]', ''), '},{', '},,,{'), ',,,')) t22 AS field_obj
        lateral view explode(array(field_obj)) t23 AS field_json
        lateral view json_tuple(field_json, 'field', 'score') t24 AS field, score
    )
    group by kyc_event_id
) t2
on      t1.kyc_event_id = t2.kyc_event_id
left join (
    select *
    from (
        select  *
                ,ROW_NUMBER() OVER(PARTITION BY id_card_no ORDER BY create_time ASC) AS rn	-- 最早的身份证那条记录
        from    (
            select  create_time
                    ,CAST(user_id AS string) AS credit_user_id
                    ,id_card_no
            from    credit.ods__credit_usercenter_member_id_db__user_base_info_tab__df
            where   grass_date='${ds}'
            union all 
            select  create_time
                    ,CAST(user_id AS string) AS credit_user_id
                    ,id_card_no
            from    credit.ods__ldn_usercenter_member_id_db__user_base_info_tab__df
            where   grass_date='${ds}'
        )
    )
    where   rn = 1
) t3 on t1.id_card_no = t3.id_card_no
union all 
select 
case when length(get_json_object(t1.header_data, '$.CreditUserId')) >1 then get_json_object(t1.header_data, '$.CreditUserId')
     else t3.credit_user_id end                                  as credit_user_id
,t1.request_key                                                  as request_key
,t1.data_source_name                                             as data_source_name
,t1.data_source_code                                             as data_source_code
,get_json_object(t1.resp_raw_data, '$.data.eventId')             as kyc_event_id
,get_json_object(t1.resp_raw_data, '$.data.certificateIssued')   as kyc_status_raw
,case when format_time(t1.create_time,'ID')>='2024-03-21' then null 
      when format_time(t1.create_time,'ID')< '2024-03-21' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10 
      when format_time(t1.create_time,'ID')< '2024-03-21' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0 
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
,format_time(t1.create_time,'ID') as create_time
,format_time(t1.update_time,'ID') as update_time
,to_date(format_time(t1.create_time,'ID')) as grass_date
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
           where grass_date ='${ds}'
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
) t3 on get_json_object(t1.req_data, '$.GovID') = t3.id_card_no
where t1.grass_date ='${ds}'
and t1.data_source_name in('VidaLdnFull','VidaCfFull')

-- new datasource
union all 
select 
case when length(get_json_object(t1.header_data, '$.CreditUserId')) >1 then get_json_object(t1.header_data, '$.CreditUserId')
     else t3.credit_user_id end                                  as credit_user_id
,t1.request_key                                                  as request_key
,t1.data_source_name                                             as data_source_name
,t1.data_source_code                                             as data_source_code
,get_json_object(t1.resp_raw_data, '$.data.eventId')             as kyc_event_id
,get_json_object(t1.resp_raw_data, '$.data.certificateIssued')   as kyc_status_raw
,case when  t1.data_source_name ='VidaCfDemog' and format_time(t1.create_time,'ID')>='2024-03-21' then null 
      when  t1.data_source_name ='VidaCfDemog' and format_time(t1.create_time,'ID')<'2024-03-21' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10
      when  t1.data_source_name ='VidaCfDemog' and format_time(t1.create_time,'ID')<'2024-03-21' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0
      else null end             as score_pob 
,case when  t1.data_source_name ='VidaCfDemog' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10
      when  t1.data_source_name ='VidaCfDemog' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0
      else null end               as score_full_name 
,null               as score_address 
,null               as score_province 
,null               as score_city 
,case when  t1.data_source_name ='VidaCfDemog' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10
      when  t1.data_source_name ='VidaCfDemog' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0
      else null end                as score_dob 
,null               as score_district 
,null               as score_village 
,case when  t1.data_source_name ='VidaCfDemog' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10
      when  t1.data_source_name ='VidaCfDemog' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0
      else null end                as score_nik 
,null               as score_mother_maiden_name 
,null               as score_family_card_no 
,case when  t1.data_source_name ='VidaCfFr' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10
      when  t1.data_source_name ='VidaCfFr' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0
      else null end                as score_demographic 
,case when t1.data_source_name ='VidaCfFr' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 200 then 10 
      when t1.data_source_name ='VidaCfFr' and get_json_object(t1.resp_raw_data, '$.data.certificateIssued') = 444 then 0 
      else null end               as score_selfiephoto 
,null as score_liveness 
,t1.trace_id 
,format_time(t1.create_time,'ID') as create_time
,format_time(t1.update_time,'ID') as update_time
,to_date(format_time(t1.create_time,'ID')) as grass_date
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
           where grass_date ='${ds}'
           and data_source_name in('VidaCfFr','VidaCfDemog')
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
) t3 on get_json_object(t1.req_data, '$.GovID') = t3.id_card_no
where t1.grass_date ='${ds}'
and t1.data_source_name in('VidaCfFr','VidaCfDemog')

-- new datasource
union all
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
  a.score_selfiephoto AS score_selfiePhoto,
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
-- 用来兜底获取 credit_user_id 的补充逻辑 
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
--
;


