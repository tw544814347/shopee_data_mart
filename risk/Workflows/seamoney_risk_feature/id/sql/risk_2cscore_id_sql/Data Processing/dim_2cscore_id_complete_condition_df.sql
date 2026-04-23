--注意转移符号，在直接用spark提交，和封装过的spark脚本提交sql脚本时，转义符个数不同
--2026-03-24  chengguo.liu - 合规要求，credit_score_id_db切换至新db  smeter_score_id_db
INSERT OVERWRITE TABLE ${SCHEMA}.dim_2cscore_id_complete_condition_df PARTITION (grass_date='${ds}')
select  get_json_object(json, '$.variable')
        ,get_json_object(json, '$.operation')
        ,get_json_object(json, '$.value')
        ,mission_id
        ,mission_name
        ,mission_code
        ,mission_type
        ,mission_status
from    (
    select  explode(split(regexp_replace(regexp_replace(complete_condition, '\\[|\\]', ''), '\\}\\,', '\\}\\!'), '\\!')) as json
            ,mission_id
            ,mission_name
            ,mission_code
            ,mission_type
            ,mission_status
    from    risk.ods__smeter_score_id_db__mission_tab__df
    where   grass_date = '${ds}'
    and   complete_condition <> '[]'

) t
;
