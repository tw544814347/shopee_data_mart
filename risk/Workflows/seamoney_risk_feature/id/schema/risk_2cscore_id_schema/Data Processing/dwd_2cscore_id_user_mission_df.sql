DROP TABLE IF EXISTS ${SCHEMA}.dwd_2cscore_id_user_mission_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_2cscore_id_user_mission_df
(
platform_user_id       STRING ,
platform_type          BIGINT COMMENT '1 shopee ',
mission_start_score    BIGINT COMMENT 'user score when start mission',
mission_id             BIGINT COMMENT 'mission id',
mission_progress       BIGINT COMMENT 'mission progress 1:todo 2:doing 3:done',
completed_count        BIGINT COMMENT 'number of complete mission',
start_time             BIGINT COMMENT 'user mission start time（millisecond）',
completion_time        BIGINT COMMENT 'user mission completion time （millisecond）',
start_time_local       STRING COMMENT 'user mission start time（local time）',
completion_time_local  STRING COMMENT 'user mission completion time (local time)',
description            STRING COMMENT 'user mission description',
create_time            BIGINT COMMENT 'created time',
update_time            BIGINT COMMENT 'update time',
mission_template_id    BIGINT COMMENT 'mission template id',
mission_name           STRING COMMENT 'mission name',
mission_code           STRING COMMENT 'mission code',
mission_type           BIGINT COMMENT 'mission type',
mission_status         BIGINT COMMENT 'mission status -1:invalid,1:valid,2:locked',
uniqueness             BIGINT COMMENT '1:yes,-1 no',
will_get_score         BIGINT COMMENT 'Credit score that will be earned after completion',
visible_condition      STRING COMMENT 'conditions for seeing this mission',
complete_condition     STRING COMMENT 'conditions for completing this mission',
ops                    STRING COMMENT 'ops',
mission_create_time    BIGINT COMMENT 'created time',
mission_update_time    BIGINT COMMENT 'update time'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/dwd/dwd_2cscore_id_user_mission_df';
MSCK REPAIR TABLE ${SCHEMA}.dwd_2cscore_id_user_mission_df;

DROP TABLE IF EXISTS ${SCHEMA}.dwd_2cscore_id_user_mission_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_2cscore_id_user_mission_df
(
platform_user_id       STRING ,
platform_type          BIGINT COMMENT '1 shopee ',
mission_start_score    BIGINT COMMENT 'user score when start mission',
mission_id             BIGINT COMMENT 'mission id',
mission_progress       BIGINT COMMENT 'mission progress 1:todo 2:doing 3:done',
completed_count        BIGINT COMMENT 'number of complete mission',
start_time             BIGINT COMMENT 'user mission start time（millisecond）',
completion_time        BIGINT COMMENT 'user mission completion time （millisecond）',
start_time_local       STRING COMMENT 'user mission start time（local time）',
completion_time_local  STRING COMMENT 'user mission completion time (local time)',
description            STRING COMMENT 'user mission description',
create_time            BIGINT COMMENT 'created time',
update_time            BIGINT COMMENT 'update time',
mission_template_id    BIGINT COMMENT 'mission template id',
mission_name           STRING COMMENT 'mission name',
mission_code           STRING COMMENT 'mission code',
mission_type           BIGINT COMMENT 'mission type',
mission_status         BIGINT COMMENT 'mission status -1:invalid,1:valid,2:locked',
uniqueness             BIGINT COMMENT '1:yes,-1 no',
will_get_score         BIGINT COMMENT 'Credit score that will be earned after completion',
visible_condition      STRING COMMENT 'conditions for seeing this mission',
complete_condition     STRING COMMENT 'conditions for completing this mission',
ops                    STRING COMMENT 'ops',
mission_create_time    BIGINT COMMENT 'created time',
mission_update_time    BIGINT COMMENT 'update time'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/dwd/dwd_2cscore_user_mission_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.dwd_2cscore_id_user_mission_df;

