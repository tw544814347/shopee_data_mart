--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-10
-- Theme Domain：       workflow_step
-- Description:         将workflow_steps_tab 从统一topic中还原
-- Data Granularity:    
-- 变更历史：
--      update by 2024-05-08 zongyi.lu@shopee.com 1.https://confluence.shopee.io/pages/viewpage.action?pageId=2181906399
--      update by 2024-08-21 zongyi.lu@shopee.com 新增 哪些场景需要还原，按照下面的sql结果来过滤
--********************************************************************--

create or replace view ${SCHEMA}.dwd_risk_${region}_af_kafka_workflow_step_di as
select
    *
from ${SCHEMA}.dwd_risk_${region}_af_kafka_workflow_step_di_v2
;