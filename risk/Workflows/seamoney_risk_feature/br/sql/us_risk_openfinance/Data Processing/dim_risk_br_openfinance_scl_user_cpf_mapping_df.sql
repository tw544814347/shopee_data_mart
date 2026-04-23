use ${SCHEMA};
-- drop table if exists ${SCHEMA}.dim_risk_br_openfinance_scl_user_cpf_mapping_df;
create external table if not exists ${SCHEMA}.dim_risk_br_openfinance_scl_user_cpf_mapping_df
(

    credit_user_id                   string 
    ,cnpj                            string
    ,product_type                    string 
    ,cpf                             string
    ,user_name                       string
    ,row_key                         string
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/dim_risk_br_openfinance_scl_user_cpf_mapping_df/grass_region=BR'
;

-- msck repair table ${SCHEMA}.dim_risk_br_openfinance_scl_user_cpf_mapping_df;
-- refresh table ${SCHEMA}.dim_risk_br_openfinance_scl_user_cpf_mapping_df;

insert overwrite ${SCHEMA}.dim_risk_br_openfinance_scl_user_cpf_mapping_df partition (grass_date = '${ds}')
select t1.credit_user_id        -- cnpj_credit_user_id
        ,t1.id_card_no as cnpj      -- cnpj
        ,cast(t1.product_id as string) as product_type            -- 2:SCL
        ,case   when t1.len_id_card_no = 11 then t1.id_card_no
                when t1.len_id_card_no = 14 then t2.id_card_no end as cpf -- 管理员 cpf
        ,case   when t1.len_id_card_no = 11 then t1.user_name
                when t1.len_id_card_no = 14 then t2.user_name end  as user_name -- 管理员 user_name
        ,concat_ws('_',substring(md5(t1.credit_user_id),1,2), cast(credit_user_id as string)) as row_key
from (
    select cast(user_id as string)  as credit_user_id
            ,id_card_no
            ,length(id_card_no) as len_id_card_no 
            ,replace(user_name, " ", "|") as user_name
            ,biz_type as product_id
    from credit.ods__credit_usercenter_member_br_db__user_admin_map_tab__df
    where grass_date = '${ds}'
    and biz_type = 2
    and (length(id_card_no) = 14 or length(id_card_no) = 11)
) t1 
left join (
    select tt1.user_id, tt1.id_card_no, tt1.full_name as user_name, tt1.shareholder_index, tt1.shareholder_role, tt2.shareholder_cnt
    from (
        select user_id
                ,id_card_no 
                ,replace(full_name, " ", "|")   as full_name
                ,shareholder_index
                ,shareholder_role
        from credit.ods__credit_usercenter_member_br_db__user_shareholder_product_tab__df 
        where grass_date = '${ds}'
        and biz_type = 2
    ) tt1 left join (
        select user_id
                ,count(shareholder_index) as shareholder_cnt
        from credit.ods__credit_usercenter_member_br_db__user_shareholder_product_tab__df 
        where grass_date = '${ds}'
        and biz_type = 2
        group by 1
        having count(shareholder_index) > 1
    ) tt2 on cast(tt1.user_id as string) = cast(tt2.user_id as string)
) t2 on t1.credit_user_id = cast(t2.user_id as string)
where if(t2.shareholder_cnt > 1, t2.shareholder_role = 1, 1=1)