--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2025-10-09
-- Theme Domain：       key metrics mart NXB table
-- Description:         store "Next X Bill" (NXB) 
-- Data Granularity:    grass_date
-- Jira: https://jira.shopee.io/browse/SPFDT-54775
-- Confluence: https://docs.google.com/document/d/18phpogzubeMqoo9vLuUE3q7GJulp9KfJr4VBiUZ2z9U/edit?tab=t.0
-- Examples: https://docs.google.com/spreadsheets/d/1ff9h1uplpQHsLQxV6wiqG0O-PZrS7XbTfbMgQ-a7H1Y/edit?gid=0#gid=0

--********************************************************************--

-- drop table if exists ${SCHEMA}.dim_risk_reg_nxb_df;
create external table if not exists ${SCHEMA}.dim_risk_reg_nxb_df
(
    nxb                 int         comment 'next x bill (x values 1-36)'
    ,nxb_start_date     string      comment 'add_months(date_add(grass_date, 1), NXB - 1)'
    ,nxb_end_date       string      comment 'date_sub(add_months(date_add(grass_date, 1), NXB), 1)'
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_reg_nxb_df/';

-- msck repair table ${SCHEMA}.dim_risk_reg_nxb_df;

WITH base AS (
    SELECT 
        '${ds}' AS grass_date,
        dayofmonth(date_add('${ds}', 1)) AS nxb_start_day,
        dayofmonth('${ds}') AS nxb_end_day
),

nxb_range AS (
    SELECT explode(sequence(0, 36)) AS NXB
),

NXB_all AS (
    SELECT
        grass_date,
        r.nxb,
        add_months(date_add(grass_date, 1), r.NXB - 1) AS nxb_start_date,
        date_sub(add_months(date_add(grass_date, 1), r.NXB), 1) AS nxb_end_date
    FROM base 
    CROSS JOIN nxb_range r
)


insert overwrite ${SCHEMA}.dim_risk_reg_nxb_df partition(grass_date)
SELECT  nxb
        ,nxb_start_date
        ,nxb_end_date
        ,grass_date
FROM NXB_all
