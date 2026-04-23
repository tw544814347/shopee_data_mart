drop table if exists ${SCHEMA}.dwd_risk_${region}_${product_line}_custom_list_df;
create external table if not exists ${SCHEMA}.dwd_risk_${region}_${product_line}_custom_list_df
(
id                      bigint   comment 'id'
,data                   string   comment "data value: id_card_no,phone,email..."
,data_type              string   comment "data type: id_card_no,phone,email.."
,data_type_name         string   comment "data type: id_card_no,phone,email.."
,custom_list_id         bigint   comment "custom_list_id"
,custom_list_name       string   comment "list name from custom_list_tab"
,de_table_name          string   comment "data_source from custom_list_tab"    
,list_source            string   comment "list source from list_source"     
,list_status            string   comment "list status 1-active 0-delete"       
,data_source            string   comment "data source"  
,action_detail          string   comment "action_detail"      
,action_fail_detail     string   comment "action_fail_detail"  
,action_status          string   comment "action_status"    
,remark                 string   comment "data remark"      
,status                 string   comment "status 1-new -1:delete"      
,description            string   comment "data description"     
,creator                string   comment "data creator"    
,create_time            string   comment "data create_time"     
,update_time            string   comment "data update_time"     
,expire_time            string   comment "data expire_time"  
,screening_switch       bigint   comment "1-自动审核 2-人工审核"  
,de_table_config        string   comment "List {DETableName: table1,NeedScreening: true}"
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_custom_list_df/product_line=${product_line}/garss_region=${upper_region}';

msck repair table ${SCHEMA}.dwd_risk_${region}_${product_line}_custom_list_df;