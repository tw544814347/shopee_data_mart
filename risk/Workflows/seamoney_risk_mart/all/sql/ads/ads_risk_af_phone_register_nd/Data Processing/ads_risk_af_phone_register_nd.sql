create or replace temporary view risk_fraud_user_tag as
select 
user_id 
,grass_region 
from (
    select  user_id
            ,fraud_tag_id
            ,grass_region
            ,row_number() over(partition by user_id order by create_datetime desc ) rn 
    from    antifraud_dw.dim_user_fraud_tag_di
    where   severity = 'SEVERE'
    and   fraud_tag_status = 1
) a 
where rn =1 
;

create or replace temporary view risk_user_register as
select 
    t1.user_id      as user_id 
    ,t1.req_phone   as register_phone
    ,t1.grass_date  as register_date
    ,'ID'           as grass_region 
from risk.dwd_risk_id_user_register_di t1 
join risk_fraud_user_tag t2 on t1.user_id = t2.user_id  and t2.grass_region ='ID'
where grass_date > date_sub('${grass_date}',180)
group by 
t1.user_id    
,t1.req_phone 
,t1.grass_date

union all 
select 
    t1.user_id      as user_id 
    ,t1.req_phone   as register_phone
    ,t1.grass_date  as register_date
    ,'MY'           as grass_region 
from risk.dwd_risk_my_user_register_di t1 
join risk_fraud_user_tag t2 on t1.user_id = t2.user_id  and t2.grass_region ='MY'
where grass_date > date_sub('${grass_date}',180)
group by 
t1.user_id    
,t1.req_phone 
,t1.grass_date

union all 
select 
    t1.user_id      as user_id 
    ,t1.req_phone   as register_phone
    ,t1.grass_date  as register_date
    ,'PH'           as grass_region 
from risk.dwd_risk_ph_user_register_di t1 
join risk_fraud_user_tag t2 on t1.user_id = t2.user_id  and t2.grass_region ='PH'
where grass_date > date_sub('${grass_date}',180)
group by 
t1.user_id    
,t1.req_phone 
,t1.grass_date

union all 
select 
    t1.user_id      as user_id 
    ,t1.req_phone   as register_phone
    ,t1.grass_date  as register_date
    ,'SG'           as grass_region 
from risk.dwd_risk_sg_user_register_di t1 
join risk_fraud_user_tag t2 on t1.user_id = t2.user_id  and t2.grass_region ='SG' 
where grass_date > date_sub('${grass_date}',180)
group by 
t1.user_id    
,t1.req_phone 
,t1.grass_date
;

insert overwrite table risk.ads_risk_af_phone_register_nd partition (grass_region,grass_date)
select 
    register_phone                                                                         as register_phone
    ,regexp_replace(regexp_replace(cast(login_user_3d   as string),"\\[",""),"\\]","")     as login_user_3d
    ,regexp_replace(regexp_replace(cast(login_user_7d   as string),"\\[",""),"\\]","")     as login_user_7d
    ,regexp_replace(regexp_replace(cast(login_user_30d  as string),"\\[",""),"\\]","")     as login_user_30d
    ,regexp_replace(regexp_replace(cast(login_user_60d  as string),"\\[",""),"\\]","")     as login_user_60d
    ,regexp_replace(regexp_replace(cast(login_user_90d  as string),"\\[",""),"\\]","")     as login_user_90d
    ,regexp_replace(regexp_replace(cast(login_user_120d as string),"\\[",""),"\\]","")     as login_user_120d
    ,regexp_replace(regexp_replace(cast(login_user_150d as string),"\\[",""),"\\]","")     as login_user_150d
    ,regexp_replace(regexp_replace(cast(login_user_180d as string),"\\[",""),"\\]","")     as login_user_180d
    ,grass_region                                                                          as grass_region 
    ,'${grass_date}'                                                                       as grass_date 
from (
select 
    register_phone
    ,collect_set(case when register_date > date_sub('${grass_date}',3)
            and register_date<='${grass_date}' then user_id else null end)                       as login_user_3d
    ,collect_set(case when register_date > date_sub('${grass_date}',7)                     
            and register_date<='${grass_date}' then user_id else null end)                       as login_user_7d
    ,collect_set(case when register_date > date_sub('${grass_date}',30)                     
            and register_date<='${grass_date}' then user_id else null end)                       as login_user_30d
    ,collect_set(case when register_date > date_sub('${grass_date}',60)                     
            and register_date<='${grass_date}' then user_id else null end)                       as login_user_60d
    ,collect_set(case when register_date > date_sub('${grass_date}',90)                     
            and register_date<='${grass_date}' then user_id else null end)                       as login_user_90d
    ,collect_set(case when register_date > date_sub('${grass_date}',120)                     
            and register_date<='${grass_date}' then user_id else null end)                       as login_user_120d
    ,collect_set(case when register_date > date_sub('${grass_date}',150)                     
            and register_date<='${grass_date}' then user_id else null end)                       as login_user_150d
    ,collect_set(case when register_date > date_sub('${grass_date}',180)                     
            and register_date<='${grass_date}' then user_id else null end)                       as login_user_180d
    ,grass_region                                                                                as grass_region 
from risk_user_register 
where length(register_phone)>1
group by 
register_phone
,grass_region     
) a 
;
