--DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_graph_vertex_info_version_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_graph_vertex_info_version_df
(
    vertex_value      string comment 'source vertex',
    hash_vertex_value string comment 'hash source vertex',
    create_date      string comment 'create_date',
    last_date       string comment 'last_date',
    extend_info           string comment 'destination_node extend info'
)
comment 'Risk Graph Data Edge'
partitioned by
(
    version_name string comment 'version_name',
    vertex_name string comment 'vertex name, login/register_mail etc.',
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_vertex_info_version_df/grass_region=${grass_region}';
--MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_graph_vertex_info_version_df;


insert overwrite table ${SCHEMA}.dws_risk_id_graph_vertex_info_version_df partition (version_name,vertex_name, grass_date)
select  destination_node       as vertex_value
        ,hash_destination_node as hash_vertex_value
        ,create_date
        ,last_date
        ,extend_info
        ,'v2' as version_name
        ,vertex_name
        ,grass_date
from    (
    select  destination_node
            ,hash_destination_node
            ,create_date
            ,last_date
            ,extend_info
            ,version_name
            ,case
                when edge_name in ('login') and get_json_object(extend_info,'$.device_type') = '1' then 'device_spdf'
                when edge_name in ('login') and get_json_object(extend_info,'$.device_type') = '2' then 'device_szdf'
                when edge_name in ('buyer_shipping_address','seller_shipping_address') then 'address'
                when edge_name in ('bank_account') then 'bank_account'
                when edge_name in ('credit_card') then 'credit_card'
                when edge_name in ('register_email') then 'email'
                when edge_name in ('register_phone','ec_phone','buyer_shipping_phone','seller_shipping_phone','buyer_topup_phone','buyer_postpaid_phone','contact_phone') then 'phone'
                when edge_name in ('dp_account_no') then 'dp_account_no'
                when edge_name in ('kyc', 'kyc_spp', 'kyc_spp_all', 'kyc_uc', 'kyc_uc_all', 'kyc_mp', 'kyc_mp_verified', 'kyc_mp_all') then 'kyc'
                when edge_name in ('buyer_shipping_address_phone') then 'buyer_shipping_address_phone'
            end as vertex_name
            ,grass_date
            ,row_number() over (partition by hash_destination_node order by last_date desc) as rank
    from    ${SCHEMA}.dws_risk_id_graph_edge_user_info_version_df
    where   version_name = 'v2'
      and   grass_date = '${grass_date}'
)
where   rank = 1
  and   vertex_name is not null
;