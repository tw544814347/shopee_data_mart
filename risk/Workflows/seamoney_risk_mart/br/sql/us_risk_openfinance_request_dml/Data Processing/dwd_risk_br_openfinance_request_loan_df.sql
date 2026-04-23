drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- drop table if exists ${SCHEMA}.dwd_risk_br_openfinance_${category}_df;
create external table if not exists ${SCHEMA}.dwd_risk_br_openfinance_request_${category}_df (
    flow_no             string  comment 'flow_number'
    ,shopee_user_id      string comment 'list(Shopee user id)'
    ,cpf                string comment 'BR user id card no'
    ,request_date       string comment 'request date'
    ,request_time   string comment 'request date time'
    ,data               string comment 'grouped identity data, as risk feature input'
)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd","orc.stripe.size"="268435456"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_openfinance_request_df/grass_region=BR/feature_name=get_open_finance_personal_${category}_data';
-- msck repair table ${SCHEMA}.dwd_risk_br_openfinance_${category}_df;

insert overwrite ${SCHEMA}.dwd_risk_br_openfinance_request_${category}_df partition (grass_date = '${ds}')
select flow_no,
        shopee_user_id,
       cpf,
       date(request_time) as request_date,
       request_time,
       to_json(
           named_struct(
               "cpf", cpf,
               "get_open_finance_personal_${category}_data", get_open_finance_personal_${category}_data
           )
       ) as data
from (
    select  flow_no,
            shopee_user_id,
            cpf,
            max(request_time) as request_time,
            collect_list(
                   named_struct(
                    "organisation_name", organisation_name,
                    "data", data
                )
            ) as get_open_finance_personal_${category}_data
    from (
        select  flow_no,
                shopee_user_id,
                cpf,
                organisation_name,
                max(request_time) as request_time,
                collect_set(
                       named_struct(
                        "consent_id", prev_consent_id,
                        "request_time", prev_request_time,
                        "rsp", prev_rsp,
                        "url", prev_url
                    )
                ) as data
        from (
            select  flow_no
                    ,shopee_user_id
                    ,cpf
                    ,request_time
                    ,organisation_name
                    ,prev_rsp
                    ,prev_url 
                    ,prev_consent_id
                    ,prev_request_time
                    ,row_number() over (partition by flow_no, shopee_user_id, cpf, prev_url order by prev_request_time desc) as rn
            from (
                select t1.flow_no   as flow_no
                        ,t1.shopee_user_id  as shopee_user_id
                        ,t1.cpf as cpf
                        ,t1.request_time as request_time
                        ,t2.organisation_name   as organisation_name
                        ,case when t1.request_time >= t2.request_time then t2.consent_id  else null end  as prev_consent_id
                        ,case when t1.request_time >= t2.request_time then t2.request_time else null end as prev_request_time
                        ,case when t1.request_time >= t2.request_time then t2.rsp else null end as prev_rsp
                        ,case when t1.request_time >= t2.request_time then t2.url else null end as prev_url
                from (
                    select flow_no,
                           cpf,
                           request_time,
                           shopee_user_id
                    from (
                        select  consent_id,
                                flow_no,
                                cpf,
                                shopee_user_id,
                                format_time(request_time, '${grass_region}') as request_time,
                                row_number() over (partition by flow_no, shopee_user_id order by request_time desc) as rn
                        from (
                            SELECT  get_json_object(req_data, '$.ConsentId')                as consent_id,
                                    split(get_json_object(req_data, '$.ConsentId'), ':')[1] as organisation_name,
                                    date_format(to_timestamp(get_json_object(resp_raw_data, '$.meta.requestDateTime'),"yyyy-MM-dd'T'HH:mm:ss'Z'"), 'yyy-MM-dd HH:mm:ss')    as request_time, 
                                    get_json_object(req_data, '$.Cpf')                          as cpf,
                                    get_json_object(header_data, '$.FlowNo')                    as flow_no,
                                    get_json_object(header_data, '$.PlatformUserId')            as shopee_user_id   -- 未来由于DFS项目可能变成shopeepay_user_id, 先观望
                            FROM risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df
                            WHERE grass_date = '${ds}'
                              AND data_source_name = 'Openfinance'
                              AND get_json_object(req_data, '$.Url') LIKE '${url}'
                        )
                    )
                    where rn = 1
                ) t1
                left join (  
                    select  consent_id,
                            url,
                            rsp,
                            cpf,
                            shopee_user_id,
                            organisation_name,
                            request_time
                    from (
                        select  cpf,
                                shopee_user_id,
                                consent_id,
                                organisation_name,
                                format_time(request_time, '${grass_region}')    as request_time,
                                url,
                                rsp
                        from (
                            SELECT  get_json_object(req_data, '$.Cpf')                as cpf,
                                    get_json_object(req_data, '$.ConsentId')                as consent_id,
                                    split(get_json_object(req_data, '$.ConsentId'), ':')[1] as organisation_name,
                                    get_json_object(req_data, '$.Url') AS url,
                                    get_json_object(header_data, '$.PlatformUserId')            as shopee_user_id,   -- 未来由于DFS项目可能变成shopeepay_user_id, 先观望
                                    date_format(to_timestamp(get_json_object(resp_raw_data, '$.meta.requestDateTime'),"yyyy-MM-dd'T'HH:mm:ss'Z'"), 'yyy-MM-dd HH:mm:ss')    as request_time, 
                                    resp_raw_data as rsp
                            FROM risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df
                            WHERE grass_date = '${ds}'
                            AND data_source_name = 'Openfinance'
                            AND get_json_object(req_data, '$.Url') LIKE '${url}'
                        )
                        where url is not null
                    )
                ) t2
                on t1.cpf = t2.cpf
                and t1.shopee_user_id = t2.shopee_user_id
            )
            where prev_request_time is not null
        )
        where rn = 1
        group by flow_no,
        shopee_user_id,
        cpf,
        organisation_name
    )
    group by flow_no,
    cpf,
    shopee_user_id
)
;