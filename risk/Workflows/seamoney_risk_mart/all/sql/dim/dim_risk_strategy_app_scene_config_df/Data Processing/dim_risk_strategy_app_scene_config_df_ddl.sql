drop table if exists ${SCHEMA}.dim_risk_strategy_app_scene_config_df
;

create external table if not exists ${SCHEMA}.dim_risk_strategy_app_scene_config_df
(
        app_id string COMMENT '<comment><description>App identifier</description><calculationLogic>app_id</calculationLogic><enum>No enum</enum></comment>',
        scene_id string COMMENT '<comment><description>Scene identifier</description><calculationLogic>scene_id</calculationLogic><enum>No enum</enum></comment>',
        scene_type string COMMENT '<comment><description>Scene type, indicates if it is workflow or antifraud</description><calculationLogic>\'workflow\' or \'antifraud\'</calculationLogic><enum>workflow, antifraud</enum></comment>',
        need_write_workflow_db bigint COMMENT '<comment><description>Flag indicating if workflow DB write is needed. 0 means single node workflow with large data volume, no DB write.</description><calculationLogic>case when key=\'need_write_workflow_db\' and value=\'false\' then 0 else 1 end</calculationLogic><enum>0-False, 1-True</enum></comment>',
        parent_workflow_scene_id string COMMENT '<comment><description>Parent workflow scene identifier for antifraud nodes. Empty for workflow nodes.</description><calculationLogic>concat_ws(\',\', collect_set(parent_workflow_scene_id)) or null</calculationLogic><enum>No enum</enum></comment>',
        product_name string COMMENT '<comment><description>Product name identifier</description><calculationLogic>\'credit\', \'shopeepay\', \'invest\'</calculationLogic><enum>credit, shopeepay, invest</enum></comment>'
        )
partitioned by(
    grass_region string COMMENT '<comment><description>Grass region,Biz Local Market</description><calculationLogic>grass_region</calculationLogic><enum></enum></comment>',
    grass_date string COMMENT '<comment><description>Biz Local Date,YYYY-MM-dd</description><calculationLogic>Get Local Date From Biz Data</calculationLogic><enum>No enum</enum></comment>'
)
stored as orc tblproperties ("orc.compress" = "zstd")
LOCATION '${HDFS_PATH}/risk_mart/dim/dim_risk_strategy_app_scene_config_df'
COMMENT 'Dimension table for risk strategy information.'
;


msck repair table ${SCHEMA}.dim_risk_strategy_app_scene_config_df
;