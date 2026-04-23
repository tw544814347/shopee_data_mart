----
-- Author:              chengguo.liu@shopee.com
-- Created Time:        
-- Theme Domain：       2BScore
-- Description:         2BScore id_type_no mappig
---- Data Granularity:  id_type_no

add jar hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-sha-256.jar;
create or replace temporary function sha256 as 'com.shopee.udf.RiskSha256';

create or replace temporary view tmp_credit_ph_concat_id_type_no as
select  concat(a.new_id_card_type_credit, '_', a.id_card_no_credit) as concat_id_type_no
        ,b.platform_user_id
        ,a.id_card_type_name_credit
        ,a.new_id_card_type_credit
        ,a.original_id_card_type_credit
        ,a.id_card_no_credit
        ,create_date_credit
        ,'credit' as id_source_credit
from    (
    select  credit_user_id
            ,case   when id_card_type = 4 then 'UMID'
                    when id_card_type = 3 then 'Driver License'
                    when id_card_type = 2 then 'Passport'
                    when id_card_type = 6 then 'PRC'
                    when id_card_type = 17 then 'Phil ID'
                    when id_card_type = 21 then 'e-Phil ID'
                    when id_card_type = 7 then 'Health ID'
                    when id_card_type = 8 then 'Postal ID'
                    when id_card_type = 5 then 'SSS'
                    when id_card_type = 15 then 'TIN ID'
             end as id_card_type_name_credit
            ,case   when id_card_type = 4 then 1
                    when id_card_type = 3 then 2
                    when id_card_type = 2 then 3
                    when id_card_type = 6 then 4
                    when id_card_type in (17,21) then 5
                    when id_card_type = 7 then 6
                    when id_card_type = 8 then 7
                    when id_card_type = 5 then 8
                    when id_card_type = 15 then 9
             end as new_id_card_type_credit
            ,id_card_type as original_id_card_type_credit
            ,id_card_no as id_card_no_credit
            ,date(create_time) as create_date_credit
    from    credit_uc.dwd_uc_ph_user_id_card_info_df
    where   grass_date = '${grass_date}'
      and   id_card_type in (4, 3, 2, 6, 17, 21, 7, 8, 5, 15)
) a
inner join (
    select  credit_user_id
            ,platform_user_id
    from    credit_uc.dws_aio_ph_uc_user_df
    where   grass_date = '${grass_date}'
    group by 1,2
) b
on      a.credit_user_id = b.credit_user_id
;

create or replace temporary view tmp_spp_ph_concat_id_type_no as
select  concat(new_id_card_type_spp, '_', id_card_no_spp) as concat_id_type_no
        ,*
        ,'spp' as id_source_spp
from    (
    select  platform_user_id
            ,create_date as create_date_spp
            ,id_card_type as original_id_card_type_spp
            ,id_card_no as id_card_no_spp
            ,case   when id_card_type = 6 then 'UMID'
                    when id_card_type = 2 then 'Driver License'
                    when id_card_type = 1 then 'Passport'
                    when id_card_type = 9 then 'PRC'
                    when id_card_type = 21 then 'e-Phil ID'
                    when id_card_type = 10 or id_card_type = 22 then 'Health ID'
                    when id_card_type = 13 then 'Postal ID'
                    when id_card_type = 7 then 'SSS'
                    when id_card_type = 18 then 'TIN ID'
             end as id_card_type_name_spp
            ,case   when id_card_type = 6 then 1
                    when id_card_type = 2 then 2
                    when id_card_type = 1 then 3
                    when id_card_type = 9 then 4
                    when id_card_type = 21 then 5
                    when id_card_type = 10 or id_card_type = 22 then 6
                    when id_card_type = 13 then 7
                    when id_card_type = 7 then 8
                    when id_card_type = 18 then 9
             end as new_id_card_type_spp
    from    (
        select  shopeepay_user_id as platform_user_id
                ,id_type as id_card_type
                ,regexp_replace(replace(replace(replace(replace(id_number_decrypt, " P", ""), "CRN", ""), "Crn", ""), "PRN", ""), "[^a-zA-Z0-9]", "") as id_card_no
                ,date(from_unixtime(create_time)) as create_date
        from    shopeepay.mart_dwd_us_kyc_case_record_tab_df__ph
        where   length(id_number_decrypt) > 1
          and   kyc_status = 3
          and   id_type in (6, 2, 1, 9, 21, 10, 22, 13, 7, 18)
          and   date(from_unixtime(create_time)) <= date('${grass_date}')
    )
)
where   id_card_type_name_spp is not null
;

create or replace temporary view tmp_2bscore_ph_concat_id_type_no as
select *
from
(
    select  concat_id_type_no as id_type_no
            ,platform_user_id
            ,id_card_no as id_no
            ,new_id_card_type as id_type
            ,row_number() over(partition by concat_id_type_no order by create_date) as row_num
    from
    (
        select  coalesce(t1.concat_id_type_no, t2.concat_id_type_no) as concat_id_type_no
                ,coalesce(t1.platform_user_id, t2.platform_user_id) as platform_user_id
                ,coalesce(t1.new_id_card_type_credit, t2.new_id_card_type_spp) as new_id_card_type
                ,coalesce(t1.create_date_credit, t2.create_date_spp) as create_date
                ,coalesce(t1.original_id_card_type_credit, t2.original_id_card_type_spp) as original_id_card_type
                ,coalesce(t1.id_card_type_name_credit, t2.id_card_type_name_spp) as id_card_type_name
                ,coalesce(t1.id_card_no_credit, t2.id_card_no_spp) as id_card_no
                ,coalesce(t1.id_source_credit, t2.id_source_spp) as id_source
        from tmp_credit_ph_concat_id_type_no t1
        full outer join tmp_spp_ph_concat_id_type_no t2
        on t1.concat_id_type_no = t2.concat_id_type_no
    )
)
where row_num = 1
;

create or replace temporary view tmp_2bscore_ph_user_address_info_nd as
select user_id
        ,to_json(collect_list(map(
                            'address', case when lat_long = 'NA' or lat_long = 'ERROR' then ''
                                        else lat_long
                                        end,
                            'confidence_level', case when is_self_addr = 1 and order_cnt >= 10 then 'High'
                                                        when is_self_addr = 1 and order_cnt < 10 then 'Medium'
                                                        when is_self_addr = 0 and order_cnt >= 10 then 'Medium'
                                                        when is_self_addr = 0 and order_cnt < 10 then 'Low'
                                                else ''
                                                end 
        ))) AS address_info
from (
    select t1.user_id
        ,t1.zipcode
        ,t1.state
        ,t1.city
        ,t1.district
        ,t1.town
        ,t1.address
        ,t1.is_self_addr
        ,t1.order_cnt
        ,t2.lat_long
    from risk.ads_2bscore_ph_user_address_info_nd t1
    left join (
        select  zipcode
                ,state
                ,city
                ,district
                ,town
                ,address
                ,lat_long
                ,grass_date
        from    risk.dim_2bscore_ph_user_address_lat_long_df
        where   grass_date = '${ds_t_2}'
        and     lat_long <> 'ERROR'
        and     lat_long <> 'NA'
    ) t2
    on  t1.address = t2.address
    and t1.state = t2.state
    and t1.city = t2.city
    and t1.district = t2.district
    and t1.town = t2.town
    and t1.zipcode = t2.zipcode
    where t1.grass_date = '${grass_date}'
    group by t1.user_id, t1.zipcode, t1.state, t1.city, t1.district, t1.town, t1.address, t1.is_self_addr, t1.order_cnt, t2.lat_long
)
group by user_id
;

insert overwrite table ${SCHEMA}.ads_2bscore_ph_user_kyc_info_df partition (grass_date = '${ds}')
select  t1.id_type_no
        ,t1.id_no
        ,t1.id_type
        ,t1.platform_user_id
        ,1 is_id_matched
        ,t2.score
        ,coalesce(t3.is_blacklist_hit, 0) as is_blacklist_hit
        ,t3.list_type
        ,cast(t3.reason_code as int)
        ,sha256(t1.id_no) as id_no_sha256
        ,base64(t1.id_no) as id_no_base64
        ,coalesce(t4.address_info, '') as address_info
from    (
    select  id_type_no
            ,id_no
            ,id_type
            ,platform_user_id
    from    tmp_2bscore_ph_concat_id_type_no
) t1
left join (
    select  a.userid
            ,round(a.score) score
    from    rescbds_credit.ph_tob_credit_score a
    where   grass_date = (select max(grass_date) from rescbds_credit.ph_tob_credit_score where grass_date<='${ds}')
) t2
on      t1.platform_user_id = t2.userid
left join (
    select  a.userid
            ,a.ifmatched as is_blacklist_hit
            ,a.list_type
            ,a.reason_code
    from    rescbds_credit.ph_tob_blacklist a
    where   grass_date = (select max(grass_date) from rescbds_credit.ph_tob_blacklist where grass_date<='${ds}')
) t3
on      t1.platform_user_id = t3.userid
left join tmp_2bscore_ph_user_address_info_nd t4
on      t1.platform_user_id = t4.user_id
;


