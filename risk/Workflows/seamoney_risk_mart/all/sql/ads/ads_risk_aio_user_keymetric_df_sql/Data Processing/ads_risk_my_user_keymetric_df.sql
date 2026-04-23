--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-05
-- Theme Domain：       风控指标体系
-- Description:         风控指标体系 
-- Data Granularity:     
-- 变更历史： 
--         update by zongyi.lu@shopee.com 1.激活指标改成risk 反欺诈数据 2.新增cpl + tl
--********************************************************************--

insert overwrite table ${SCHEMA}.ads_risk_${region}_user_keymetric_df partition(grass_date ='${grass_date}')
select 
spl_count_apply_activation_user_cnt_1d      
,spl_count_activation_user_cnt_1d           
,bcl_count_apply_activation_user_cnt_1d     
,bcl_count_activation_user_cnt_1d           
,cpl_count_apply_activation_user_cnt_1d
,cpl_count_activation_user_cnt_1d
,tl_count_apply_activation_user_cnt_1d
,tl_count_activation_user_cnt_1d
,bcl_count_apply_withdraw_user_cnt_1d       
,bcl_count_withdrawal_user_cnt_1d           
,scl_count_apply_withdraw_user_cnt_1d       
,scl_count_withdrawal_user_cnt_1d     
,tl_count_apply_withdraw_user_cnt_1d       
,tl_count_withdrawal_user_cnt_1d        
,spl_count_apply_activation_user_cnt_30d    
,spl_count_activation_user_cnt_30d          
,bcl_count_apply_activation_user_cnt_30d    
,bcl_count_activation_user_cnt_30d
,cpl_count_apply_activation_user_cnt_30d
,cpl_count_activation_user_cnt_30d
,tl_count_apply_activation_user_cnt_30d
,tl_count_activation_user_cnt_30d       
,bcl_count_apply_withdraw_user_cnt_30d      
,bcl_count_withdrawal_user_cnt_30d          
,scl_count_apply_withdraw_user_cnt_30d      
,scl_count_withdrawal_user_cnt_30d    
,tl_count_apply_withdraw_user_cnt_30d       
,tl_count_withdrawal_user_cnt_30d
,spl_count_apply_activation_user_cnt_td     
,spl_count_activation_user_cnt_td           
,bcl_count_apply_activation_user_cnt_td     
,bcl_count_activation_user_cnt_td      
,cpl_count_apply_activation_user_cnt_td
,cpl_count_activation_user_cnt_td
,tl_count_apply_activation_user_cnt_td
,tl_count_activation_user_cnt_td     
,bcl_count_apply_withdraw_user_cnt_td       
,bcl_count_withdrawal_user_cnt_td           
,scl_count_apply_withdraw_user_cnt_td       
,scl_count_withdrawal_user_cnt_td     
,tl_count_apply_withdraw_user_cnt_td       
,tl_count_withdrawal_user_cnt_td  
,null as svl_count_apply_activation_user_cnt_1d
,null as svl_count_activation_user_cnt_1d
,null as svl_count_apply_activation_user_cnt_30d
,null as svl_count_activation_user_cnt_30d
,null as svl_count_apply_activation_user_cnt_60d
,null as svl_count_activation_user_cnt_60d
,null as svl_count_apply_activation_user_cnt_90d
,null as svl_count_activation_user_cnt_90d
,null as svl_count_apply_activation_user_cnt_120d
,null as svl_count_activation_user_cnt_120d
,null as svl_count_apply_activation_user_cnt_180d
,null as svl_count_activation_user_cnt_180d
,null as svl_count_apply_activation_user_cnt_td
,null as svl_count_activation_user_cnt_td
,null as scf_count_apply_activation_user_cnt_1d
,null as scf_count_activation_user_cnt_1d
,null as scf_count_apply_activation_user_cnt_30d
,null as scf_count_activation_user_cnt_30d
,null as scf_count_apply_activation_user_cnt_60d
,null as scf_count_activation_user_cnt_60d
,null as scf_count_apply_activation_user_cnt_90d
,null as scf_count_activation_user_cnt_90d
,null as scf_count_apply_activation_user_cnt_120d
,null as scf_count_activation_user_cnt_120d
,null as scf_count_apply_activation_user_cnt_180d
,null as scf_count_activation_user_cnt_180d
,null as scf_count_apply_activation_user_cnt_td
,null as scf_count_activation_user_cnt_td
,case when spl_count_apply_activation_user_cnt_1d>0 then spl_count_activation_user_cnt_1d/spl_count_apply_activation_user_cnt_1d else null end as spl_count_user_apply_activation_rate_1d  
,case when bcl_count_apply_activation_user_cnt_1d>0 then bcl_count_activation_user_cnt_1d/bcl_count_apply_activation_user_cnt_1d else null end as bcl_count_user_apply_activation_rate_1d     
,case when cpl_count_apply_activation_user_cnt_1d>0 then cpl_count_activation_user_cnt_1d/cpl_count_apply_activation_user_cnt_1d else null end as cpl_count_user_apply_activation_rate_1d    
,case when tl_count_apply_activation_user_cnt_1d>0 then tl_count_activation_user_cnt_1d/tl_count_apply_activation_user_cnt_1d else null end as tl_count_user_apply_activation_rate_1d    
,case when bcl_count_apply_withdraw_user_cnt_1d>0 then bcl_count_withdrawal_user_cnt_1d/bcl_count_apply_withdraw_user_cnt_1d else null end     as bcl_count_user_apply_withdrawal_rate_1d     
,case when scl_count_apply_withdraw_user_cnt_1d>0 then scl_count_withdrawal_user_cnt_1d/scl_count_apply_withdraw_user_cnt_1d else null end     as scl_count_user_apply_withdrawal_rate_1d     
,case when tl_count_apply_withdraw_user_cnt_1d>0 then tl_count_withdrawal_user_cnt_1d/tl_count_apply_withdraw_user_cnt_1d else null end     as tl_count_user_apply_withdrawal_rate_1d     
,case when spl_count_apply_activation_user_cnt_30d>0 then spl_count_activation_user_cnt_30d/spl_count_apply_activation_user_cnt_30d else null end as spl_count_user_apply_activation_rate_30d    
,case when bcl_count_apply_activation_user_cnt_30d>0 then bcl_count_activation_user_cnt_30d/bcl_count_apply_activation_user_cnt_30d else null end as bcl_count_user_apply_activation_rate_30d    
,case when cpl_count_apply_activation_user_cnt_30d>0 then cpl_count_activation_user_cnt_30d/cpl_count_apply_activation_user_cnt_30d else null end as cpl_count_user_apply_activation_rate_30d    
,case when tl_count_apply_activation_user_cnt_30d>0 then tl_count_activation_user_cnt_30d/tl_count_apply_activation_user_cnt_30d else null end as tl_count_user_apply_activation_rate_30d    
,case when bcl_count_apply_withdraw_user_cnt_30d>0 then bcl_count_withdrawal_user_cnt_30d/bcl_count_apply_withdraw_user_cnt_30d else null end   as bcl_count_user_apply_withdrawal_rate_30d    
,case when scl_count_apply_withdraw_user_cnt_30d>0 then scl_count_withdrawal_user_cnt_30d/scl_count_apply_withdraw_user_cnt_30d else null end   as scl_count_user_apply_withdrawal_rate_30d    
,case when tl_count_apply_withdraw_user_cnt_30d>0 then tl_count_withdrawal_user_cnt_30d/tl_count_apply_withdraw_user_cnt_30d else null end   as tl_count_user_apply_withdrawal_rate_30d    
,case when spl_count_apply_activation_user_cnt_td>0 then spl_count_activation_user_cnt_td/spl_count_apply_activation_user_cnt_td else null end as spl_count_user_apply_activation_rate_td     
,case when bcl_count_apply_activation_user_cnt_td>0 then bcl_count_activation_user_cnt_td/bcl_count_apply_activation_user_cnt_td else null end as bcl_count_user_apply_activation_rate_td     
,case when cpl_count_apply_activation_user_cnt_td>0 then cpl_count_activation_user_cnt_td/cpl_count_apply_activation_user_cnt_td else null end as cpl_count_user_apply_activation_rate_td    
,case when tl_count_apply_activation_user_cnt_td>0 then tl_count_activation_user_cnt_td/tl_count_apply_activation_user_cnt_td else null end as tl_count_user_apply_activation_rate_td    
,case when bcl_count_apply_withdraw_user_cnt_td>0 then bcl_count_withdrawal_user_cnt_td/bcl_count_apply_withdraw_user_cnt_td else null end     as bcl_count_user_apply_withdrawal_rate_td     
,case when scl_count_apply_withdraw_user_cnt_td>0 then scl_count_withdrawal_user_cnt_td/scl_count_apply_withdraw_user_cnt_td else null end     as scl_count_user_apply_withdrawal_rate_td 
,case when tl_count_apply_withdraw_user_cnt_td>0 then tl_count_withdrawal_user_cnt_td/tl_count_apply_withdraw_user_cnt_td else null end     as tl_count_user_apply_withdrawal_rate_td 

from (
    select 
    sum(spl_count_apply_activation_user_cnt_1d  ) as spl_count_apply_activation_user_cnt_1d       
    ,sum(spl_count_activation_user_cnt_1d        ) as spl_count_activation_user_cnt_1d            
    ,sum(bcl_count_apply_activation_user_cnt_1d  ) as bcl_count_apply_activation_user_cnt_1d      
    ,sum(bcl_count_activation_user_cnt_1d        ) as bcl_count_activation_user_cnt_1d            
    ,sum(cpl_count_apply_activation_user_cnt_1d  ) as cpl_count_apply_activation_user_cnt_1d      
    ,sum(cpl_count_activation_user_cnt_1d        ) as cpl_count_activation_user_cnt_1d          
    ,sum(tl_count_apply_activation_user_cnt_1d  ) as tl_count_apply_activation_user_cnt_1d      
    ,sum(tl_count_activation_user_cnt_1d        ) as tl_count_activation_user_cnt_1d            
    ,sum(bcl_count_apply_withdraw_user_cnt_1d    ) as bcl_count_apply_withdraw_user_cnt_1d        
    ,sum(bcl_count_withdrawal_user_cnt_1d        ) as bcl_count_withdrawal_user_cnt_1d            
    ,sum(scl_count_apply_withdraw_user_cnt_1d    ) as scl_count_apply_withdraw_user_cnt_1d        
    ,sum(scl_count_withdrawal_user_cnt_1d        ) as scl_count_withdrawal_user_cnt_1d  
    ,sum(tl_count_apply_withdraw_user_cnt_1d    ) as tl_count_apply_withdraw_user_cnt_1d        
    ,sum(tl_count_withdrawal_user_cnt_1d        ) as tl_count_withdrawal_user_cnt_1d            
    ,sum(spl_count_apply_activation_user_cnt_30d ) as spl_count_apply_activation_user_cnt_30d     
    ,sum(spl_count_activation_user_cnt_30d       ) as spl_count_activation_user_cnt_30d           
    ,sum(bcl_count_apply_activation_user_cnt_30d ) as bcl_count_apply_activation_user_cnt_30d     
    ,sum(bcl_count_activation_user_cnt_30d       ) as bcl_count_activation_user_cnt_30d
    ,sum(cpl_count_apply_activation_user_cnt_30d  ) as cpl_count_apply_activation_user_cnt_30d      
    ,sum(cpl_count_activation_user_cnt_30d        ) as cpl_count_activation_user_cnt_30d          
    ,sum(tl_count_apply_activation_user_cnt_30d  ) as tl_count_apply_activation_user_cnt_30d      
    ,sum(tl_count_activation_user_cnt_30d        ) as tl_count_activation_user_cnt_30d      
    ,sum(bcl_count_apply_withdraw_user_cnt_30d   ) as bcl_count_apply_withdraw_user_cnt_30d       
    ,sum(bcl_count_withdrawal_user_cnt_30d       ) as bcl_count_withdrawal_user_cnt_30d           
    ,sum(scl_count_apply_withdraw_user_cnt_30d   ) as scl_count_apply_withdraw_user_cnt_30d       
    ,sum(scl_count_withdrawal_user_cnt_30d       ) as scl_count_withdrawal_user_cnt_30d 
    ,sum(tl_count_apply_withdraw_user_cnt_30d   ) as tl_count_apply_withdraw_user_cnt_30d       
    ,sum(tl_count_withdrawal_user_cnt_30d       ) as tl_count_withdrawal_user_cnt_30d           
    ,sum(spl_count_apply_activation_user_cnt_td  ) as spl_count_apply_activation_user_cnt_td      
    ,sum(spl_count_activation_user_cnt_td        ) as spl_count_activation_user_cnt_td            
    ,sum(bcl_count_apply_activation_user_cnt_td  ) as bcl_count_apply_activation_user_cnt_td      
    ,sum(bcl_count_activation_user_cnt_td        ) as bcl_count_activation_user_cnt_td         
    ,sum(cpl_count_apply_activation_user_cnt_td  ) as cpl_count_apply_activation_user_cnt_td      
    ,sum(cpl_count_activation_user_cnt_td        ) as cpl_count_activation_user_cnt_td          
    ,sum(tl_count_apply_activation_user_cnt_td  ) as tl_count_apply_activation_user_cnt_td      
    ,sum(tl_count_activation_user_cnt_td        ) as tl_count_activation_user_cnt_td  
    ,sum(bcl_count_apply_withdraw_user_cnt_td    ) as bcl_count_apply_withdraw_user_cnt_td        
    ,sum(bcl_count_withdrawal_user_cnt_td        ) as bcl_count_withdrawal_user_cnt_td            
    ,sum(scl_count_apply_withdraw_user_cnt_td    ) as scl_count_apply_withdraw_user_cnt_td        
    ,sum(scl_count_withdrawal_user_cnt_td        ) as scl_count_withdrawal_user_cnt_td    
    ,sum(tl_count_apply_withdraw_user_cnt_td    ) as tl_count_apply_withdraw_user_cnt_td        
    ,sum(tl_count_withdrawal_user_cnt_td        ) as tl_count_withdrawal_user_cnt_td               
    from (
    -- 激活相关
    select 
    count(distinct case when t1.topic_name = '${spl_apply_topic_name}' and t1.scene_id in(${spl_apply_scene_id}) and t1.grass_date = '${grass_date}'  then t1.platform_user_id else null end )                         as  spl_count_apply_activation_user_cnt_1d        
    ,count(distinct case when t1.topic_name = '${spl_apply_topic_name}' and t1.scene_id in(${spl_apply_scene_id}) and t1.final_result=1 and t1.grass_date = '${grass_date}' then t1.platform_user_id else null end )   as  spl_count_activation_user_cnt_1d             
    ,count(distinct case when t1.topic_name = '${bcl_apply_topic_name}' and t1.scene_id in(${bcl_apply_scene_id}) and t1.grass_date = '${grass_date}' then t1.platform_user_id else null end )                         as bcl_count_apply_activation_user_cnt_1d       
    ,count(distinct case when t1.topic_name = '${bcl_apply_topic_name}' and t1.scene_id in(${bcl_apply_scene_id}) and t1.final_result=1 and t1.grass_date = '${grass_date}' then t1.platform_user_id else null end )   as bcl_count_activation_user_cnt_1d     
    ,count(distinct case when t1.topic_name = '${cpl_apply_topic_name}' and t1.scene_id in(${cpl_apply_scene_id}) and t1.grass_date = '${grass_date}' then t1.platform_user_id else null end )                         as cpl_count_apply_activation_user_cnt_1d       
    ,count(distinct case when t1.topic_name = '${cpl_apply_topic_name}' and t1.scene_id in(${cpl_apply_scene_id}) and t1.final_result=1 and t1.grass_date = '${grass_date}' then t1.platform_user_id else null end )   as cpl_count_activation_user_cnt_1d             
    ,count(distinct case when t1.topic_name = '${tl_apply_topic_name}' and t1.scene_id in(${tl_apply_scene_id}) and t1.grass_date = '${grass_date}' then t1.platform_user_id else null end )                           as tl_count_apply_activation_user_cnt_1d       
    ,count(distinct case when t1.topic_name = '${tl_apply_topic_name}' and t1.scene_id in(${tl_apply_scene_id}) and t1.final_result=1 and t1.grass_date = '${grass_date}' then t1.platform_user_id else null end )     as tl_count_activation_user_cnt_1d             
    ,0 as bcl_count_apply_withdraw_user_cnt_1d         
    ,0 as bcl_count_withdrawal_user_cnt_1d             
    ,0 as scl_count_apply_withdraw_user_cnt_1d         
    ,0 as scl_count_withdrawal_user_cnt_1d   
    ,0 as tl_count_apply_withdraw_user_cnt_1d         
    ,0 as tl_count_withdrawal_user_cnt_1d            
    ,count(distinct case when t1.topic_name = '${spl_apply_topic_name}' and t1.scene_id in(${spl_apply_scene_id}) and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )                          as spl_count_apply_activation_user_cnt_30d      
    ,count(distinct case when t1.topic_name = '${spl_apply_topic_name}' and t1.scene_id in(${spl_apply_scene_id}) and t1.final_result=1 and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )    as spl_count_activation_user_cnt_30d            
    ,count(distinct case when t1.topic_name = '${bcl_apply_topic_name}' and t1.scene_id in(${bcl_apply_scene_id}) and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )                          as bcl_count_apply_activation_user_cnt_30d      
    ,count(distinct case when t1.topic_name = '${bcl_apply_topic_name}' and t1.scene_id in(${bcl_apply_scene_id}) and t1.final_result=1 and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )    as bcl_count_activation_user_cnt_30d     
    ,count(distinct case when t1.topic_name = '${cpl_apply_topic_name}' and t1.scene_id in(${cpl_apply_scene_id}) and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )                          as cpl_count_apply_activation_user_cnt_30d      
    ,count(distinct case when t1.topic_name = '${cpl_apply_topic_name}' and t1.scene_id in(${cpl_apply_scene_id}) and t1.final_result=1 and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )    as cpl_count_activation_user_cnt_30d     
    ,count(distinct case when t1.topic_name = '${tl_apply_topic_name}' and t1.scene_id in(${tl_apply_scene_id}) and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )                            as tl_count_apply_activation_user_cnt_30d      
    ,count(distinct case when t1.topic_name = '${tl_apply_topic_name}' and t1.scene_id in(${tl_apply_scene_id}) and t1.final_result=1 and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )      as tl_count_activation_user_cnt_30d     


    ,0 as bcl_count_apply_withdraw_user_cnt_30d        
    ,0 as bcl_count_withdrawal_user_cnt_30d            
    ,0 as scl_count_apply_withdraw_user_cnt_30d        
    ,0 as scl_count_withdrawal_user_cnt_30d  
    ,0 as tl_count_apply_withdraw_user_cnt_30d        
    ,0 as tl_count_withdrawal_user_cnt_30d     

    ,count(distinct case when t1.topic_name = '${spl_apply_topic_name}' and t1.scene_id in(${spl_apply_scene_id}) and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )                         as spl_count_apply_activation_user_cnt_td       
    ,count(distinct case when t1.topic_name = '${spl_apply_topic_name}' and t1.scene_id in(${spl_apply_scene_id}) and t1.final_result=1 and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )   as spl_count_activation_user_cnt_td             
    ,count(distinct case when t1.topic_name = '${bcl_apply_topic_name}' and t1.scene_id in(${bcl_apply_scene_id}) and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )                         as bcl_count_apply_activation_user_cnt_td       
    ,count(distinct case when t1.topic_name = '${bcl_apply_topic_name}' and t1.scene_id in(${bcl_apply_scene_id}) and t1.final_result=1 and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )   as bcl_count_activation_user_cnt_td    
    ,count(distinct case when t1.topic_name = '${cpl_apply_topic_name}' and t1.scene_id in(${cpl_apply_scene_id}) and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )                         as cpl_count_apply_activation_user_cnt_td       
    ,count(distinct case when t1.topic_name = '${cpl_apply_topic_name}' and t1.scene_id in(${cpl_apply_scene_id}) and t1.final_result=1 and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )   as cpl_count_activation_user_cnt_td    
    ,count(distinct case when t1.topic_name = '${tl_apply_topic_name}' and t1.scene_id in(${tl_apply_scene_id}) and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )                           as tl_count_apply_activation_user_cnt_td       
    ,count(distinct case when t1.topic_name = '${tl_apply_topic_name}' and t1.scene_id in(${tl_apply_scene_id}) and t1.final_result=1 and t1.grass_date >date_sub('${grass_date}',30) and t1.grass_date<='${grass_date}' then t1.platform_user_id else null end )     as tl_count_activation_user_cnt_td    

    ,0 as bcl_count_apply_withdraw_user_cnt_td         
    ,0 as bcl_count_withdrawal_user_cnt_td             
    ,0 as scl_count_apply_withdraw_user_cnt_td         
    ,0 as scl_count_withdrawal_user_cnt_td   
    ,0 as tl_count_apply_withdraw_user_cnt_td         
    ,0 as tl_count_withdrawal_user_cnt_td 
    from risk.dwd_risk_${region}_strategy_final_result_merge_di t1 
    where t1.scene_id ${apply_scene_id}
    and t1.topic_name ${apply_topic_name}

    ---- 提现相关
    union all 
    -- bcl
    select 
    0 as spl_count_apply_activation_user_cnt_1d        
    ,0 as spl_count_activation_user_cnt_1d             
    ,0 as bcl_count_apply_activation_user_cnt_1d       
    ,0 as bcl_count_activation_user_cnt_1d   
    ,0 as cpl_count_apply_activation_user_cnt_1d       
    ,0 as cpl_count_activation_user_cnt_1d  
    ,0 as tl_count_apply_activation_user_cnt_1d       
    ,0 as tl_count_activation_user_cnt_1d    

    ,count(distinct case when to_date(t1.disburse_actual_done_time)='${grass_date}' then platform_user_id else null end)                                as bcl_count_apply_withdraw_user_cnt_1d         
    ,count(distinct case when to_date(t1.disburse_actual_done_time)='${grass_date}'and t1.loan_status =999 then platform_user_id else null end)         as bcl_count_withdrawal_user_cnt_1d             
    ,0 as scl_count_apply_withdraw_user_cnt_1d         
    ,0 as scl_count_withdrawal_user_cnt_1d     
    ,0 as tl_count_apply_withdraw_user_cnt_1d         
    ,0 as tl_count_withdrawal_user_cnt_1d     

    ,0 as spl_count_apply_activation_user_cnt_30d      
    ,0 as spl_count_activation_user_cnt_30d            
    ,0 as bcl_count_apply_activation_user_cnt_30d      
    ,0 as bcl_count_activation_user_cnt_30d     
    ,0 as cpl_count_apply_activation_user_cnt_30d      
    ,0 as cpl_count_activation_user_cnt_30d   
    ,0 as tl_count_apply_activation_user_cnt_30d      
    ,0 as tl_count_activation_user_cnt_30d   

    ,count(distinct case when to_date(t1.disburse_actual_done_time)>=date_sub('${grass_date}',30) and to_date(t1.disburse_actual_done_time)<='${grass_date}' then platform_user_id else null end)                         as bcl_count_apply_withdraw_user_cnt_30d        
    ,count(distinct case when to_date(t1.disburse_actual_done_time)>=date_sub('${grass_date}',30) and to_date(t1.disburse_actual_done_time)<='${grass_date}' and t1.loan_status =999 then platform_user_id else null end) as bcl_count_withdrawal_user_cnt_30d            
    ,0 as scl_count_apply_withdraw_user_cnt_30d        
    ,0 as scl_count_withdrawal_user_cnt_30d     
    ,0 as tl_count_apply_withdraw_user_cnt_30d        
    ,0 as tl_count_withdrawal_user_cnt_30d   

    ,0 as spl_count_apply_activation_user_cnt_td       
    ,0 as spl_count_activation_user_cnt_td             
    ,0 as bcl_count_apply_activation_user_cnt_td       
    ,0 as bcl_count_activation_user_cnt_td  
    ,0 as cpl_count_apply_activation_user_cnt_td       
    ,0 as cpl_count_activation_user_cnt_td  
    ,0 as tl_count_apply_activation_user_cnt_td       
    ,0 as tl_count_activation_user_cnt_td  

    ,count(distinct platform_user_id)                                                   as bcl_count_apply_withdraw_user_cnt_30d                 
    ,count(distinct case when t1.loan_status =999  then platform_user_id else null end) as bcl_count_withdrawal_user_cnt_td             
    ,0 as scl_count_apply_withdraw_user_cnt_td         
    ,0 as scl_count_withdrawal_user_cnt_td
    ,0 as tl_count_apply_withdraw_user_cnt_td         
    ,0 as tl_count_withdrawal_user_cnt_td
    from credit_mart.dwd_bcl_${region}_txn_order_df t1 
    where grass_date ='${grass_date}'
    -- scl 
    union all 
    select 
    0 as spl_count_apply_activation_user_cnt_1d        
    ,0 as spl_count_activation_user_cnt_1d             
    ,0 as bcl_count_apply_activation_user_cnt_1d       
    ,0 as bcl_count_activation_user_cnt_1d   
    ,0 as cpl_count_apply_activation_user_cnt_1d       
    ,0 as cpl_count_activation_user_cnt_1d  
    ,0 as tl_count_apply_activation_user_cnt_1d       
    ,0 as tl_count_activation_user_cnt_1d  

    ,0 as bcl_count_apply_withdraw_user_cnt_1d         
    ,0 as bcl_count_withdrawal_user_cnt_1d             
    ,count(distinct case when to_date(t1.disburse_actual_done_time)='${grass_date}' then platform_user_id else null end)                        as scl_count_apply_withdraw_user_cnt_1d         
    ,count(distinct case when to_date(t1.disburse_actual_done_time)='${grass_date}'and t1.loan_status =999 then platform_user_id else null end) as scl_count_withdrawal_user_cnt_1d     
    ,0 as tl_count_apply_withdraw_user_cnt_1d         
    ,0 as tl_count_withdrawal_user_cnt_1d

    ,0 as spl_count_apply_activation_user_cnt_30d      
    ,0 as spl_count_activation_user_cnt_30d            
    ,0 as bcl_count_apply_activation_user_cnt_30d      
    ,0 as bcl_count_activation_user_cnt_30d     
    ,0 as cpl_count_apply_activation_user_cnt_30d      
    ,0 as cpl_count_activation_user_cnt_30d   
    ,0 as tl_count_apply_activation_user_cnt_30d      
    ,0 as tl_count_activation_user_cnt_30d   

    ,0 as bcl_count_apply_withdraw_user_cnt_30d        
    ,0 as bcl_count_withdrawal_user_cnt_30d            
    ,count(distinct case when to_date(t1.disburse_actual_done_time)>=date_sub('${grass_date}',30) and to_date(t1.disburse_actual_done_time)<='${grass_date}' then platform_user_id else null end)                         as scl_count_apply_withdraw_user_cnt_30d        
    ,count(distinct case when to_date(t1.disburse_actual_done_time)>=date_sub('${grass_date}',30) and to_date(t1.disburse_actual_done_time)<='${grass_date}' and t1.loan_status =999 then platform_user_id else null end) as scl_count_withdrawal_user_cnt_30d      
    ,0 as tl_count_apply_withdraw_user_cnt_30d        
    ,0 as tl_count_withdrawal_user_cnt_30d  

    ,0 as spl_count_apply_activation_user_cnt_td       
    ,0 as spl_count_activation_user_cnt_td             
    ,0 as bcl_count_apply_activation_user_cnt_td       
    ,0 as bcl_count_activation_user_cnt_td  
    ,0 as cpl_count_apply_activation_user_cnt_td       
    ,0 as cpl_count_activation_user_cnt_td 
    ,0 as tl_count_apply_activation_user_cnt_td       
    ,0 as tl_count_activation_user_cnt_td 

    ,0 as bcl_count_apply_withdraw_user_cnt_30d                 
    ,0 as bcl_count_withdrawal_user_cnt_td             
    ,count(distinct platform_user_id)                                                   as scl_count_apply_withdraw_user_cnt_td         
    ,count(distinct case when  t1.loan_status =999 then platform_user_id else null end) as scl_count_withdrawal_user_cnt_td
    ,0 as tl_count_apply_withdraw_user_cnt_td                 
    ,0 as tl_count_withdrawal_user_cnt_td 
    from credit_mart.dwd_scl_${region}_txn_order_df t1 
    where grass_date ='${grass_date}'
    -- tl 
    union all 
    select 
    0 as spl_count_apply_activation_user_cnt_1d        
    ,0 as spl_count_activation_user_cnt_1d             
    ,0 as bcl_count_apply_activation_user_cnt_1d       
    ,0 as bcl_count_activation_user_cnt_1d   
    ,0 as cpl_count_apply_activation_user_cnt_1d       
    ,0 as cpl_count_activation_user_cnt_1d  
    ,0 as tl_count_apply_activation_user_cnt_1d       
    ,0 as tl_count_activation_user_cnt_1d  

    ,0 as bcl_count_apply_withdraw_user_cnt_1d         
    ,0 as bcl_count_withdrawal_user_cnt_1d     
    ,0 as scl_count_apply_withdraw_user_cnt_1d         
    ,0 as scl_count_withdrawal_user_cnt_1d          
    ,count(distinct case when to_date(t1.disburse_actual_done_time)='${grass_date}' then platform_user_id else null end)                        as tl_count_apply_withdraw_user_cnt_1d         
    ,count(distinct case when to_date(t1.disburse_actual_done_time)='${grass_date}'and t1.loan_status =999 then platform_user_id else null end) as tl_count_withdrawal_user_cnt_1d     

    ,0 as spl_count_apply_activation_user_cnt_30d      
    ,0 as spl_count_activation_user_cnt_30d            
    ,0 as bcl_count_apply_activation_user_cnt_30d      
    ,0 as bcl_count_activation_user_cnt_30d  
    ,0 as cpl_count_apply_activation_user_cnt_30d      
    ,0 as cpl_count_activation_user_cnt_30d 
    ,0 as tl_count_apply_activation_user_cnt_30d      
    ,0 as tl_count_activation_user_cnt_30d    

    ,0 as bcl_count_apply_withdraw_user_cnt_30d        
    ,0 as bcl_count_withdrawal_user_cnt_30d         
    ,0 as scl_count_apply_withdraw_user_cnt_30d        
    ,0 as scl_count_withdrawal_user_cnt_30d        
    ,count(distinct case when to_date(t1.disburse_actual_done_time)>=date_sub('${grass_date}',30) and to_date(t1.disburse_actual_done_time)<='${grass_date}' then platform_user_id else null end)                         as tl_count_apply_withdraw_user_cnt_30d        
    ,count(distinct case when to_date(t1.disburse_actual_done_time)>=date_sub('${grass_date}',30) and to_date(t1.disburse_actual_done_time)<='${grass_date}' and t1.loan_status =999 then platform_user_id else null end) as tl_count_withdrawal_user_cnt_30d      

    ,0 as spl_count_apply_activation_user_cnt_td       
    ,0 as spl_count_activation_user_cnt_td             
    ,0 as bcl_count_apply_activation_user_cnt_td       
    ,0 as bcl_count_activation_user_cnt_td  
    ,0 as cpl_count_apply_activation_user_cnt_td       
    ,0 as cpl_count_activation_user_cnt_td 
    ,0 as tl_count_apply_activation_user_cnt_td       
    ,0 as tl_count_activation_user_cnt_td 

    ,0 as bcl_count_apply_withdraw_user_cnt_td                 
    ,0 as bcl_count_withdrawal_user_cnt_td        
    ,0 as scl_count_apply_withdraw_user_cnt_td                 
    ,0 as scl_count_withdrawal_user_cnt_td             
    ,count(distinct platform_user_id)                                                   as tl_count_apply_withdraw_user_cnt_td         
    ,count(distinct case when  t1.loan_status =999 then platform_user_id else null end) as tl_count_withdrawal_user_cnt_td
    from credit_mart.dwd_tl_${tl_region}_txn_order_df t1 
    where grass_date ='${grass_date}'
    and 1 = ${is_tl_online}
    ) t1 
) t11
;
