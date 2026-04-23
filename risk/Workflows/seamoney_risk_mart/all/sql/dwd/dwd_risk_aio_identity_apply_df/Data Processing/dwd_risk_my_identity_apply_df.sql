--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-11-28
-- Theme Domain：       identity_apply mart表
-- Description:         identity_apply 2024-09-27之前extend_info中没有traceid需要补充(补充规则:https://docs.google.com/spreadsheets/d/1pvtivL96IXS1s9AertvFFkKvwaQrdyUnGFPV3WYwC8Y/edit?gid=0#gid=0)
--                      由于ods表可能会bootstrap backfill,因此traceid补充放在mart表(因为不同地区上线时间不一样,因此统一2024-09-30之前的才要转)
-- Data Granularity:    
-- 变更历史：
-- update by wei.tao@shopee.com 2024-12-06 修复hit_cache字段(--修复主要逻辑：目前identity_apply_tab表中的数据表示外数请求数据，identity_fetch_tab中的数据代表了实际发起外调请求的数据。如果apply表中请求的数据，在fetch表中没找到，那么就代表命中了缓存，将identity表中的hit_cache字段设置为2，否则设置为1.)
-- update by zongyi.lu@shopee.com 2024-12-09 不存在key 对应的value 应该是<nil> 而不是nil
-- update by zongyi.lu@shopee.com 2024-12-11 新增存储时间的处理, data表中updatetime+缓存时间需要大于apply表中的updatetime
--********************************************************************--

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


create or replace temporary view  identity_apply_trace_id_tab as 
select 
    t1.id                          
    ,t1.request_key                
    ,t1.unique_key                 
    ,t1.data_source_name           
    ,t1.req_header                 
    ,t1.req                        
    ,t1.extra_info                 
    ,t1.resp_code                  
    ,t1.hit_cache                  
    ,t1.trace_id                   
    ,t1.app_key                    
    ,t1.flow_no                    
    ,t1.data_year_month            
    ,t1.create_time                
    ,t1.update_time   
    -- 只有hit_cache=2 才需要补
    ,case when t1.hit_cache=2 and t2.update_date >=to_date(t1.update_time) then  nvl(t2.trace_id,'nil') 
          else 'nil' end as new_trace_id             
from (
    select
    id                        
    ,unique_key               
    ,data_source_name         
    ,req_header               
    ,req                      
    ,extra_info               
    ,resp_code                
    ,hit_cache                
    ,trace_id                 
    ,app_key                  
    ,flow_no                  
    ,data_year_month          
    ,create_time   
    ,update_time 
    ,case when upper('${region}')='ID' and data_source_name = 'Dukcapil' then md5(concat(data_source_name,'#','BirthDate=',birth_date,'#','IdCardNo=',id_card_no,'#','UserName=',user_name))
          when upper('${region}')='ID' and data_source_name = 'IndosatTenure' then md5(concat(data_source_name,'#','PhoneNo=',phone_no))
          when upper('${region}')='ID' and data_source_name = 'IndosatCustom' then md5(concat(data_source_name,'#','Msisdn=',msisdn))
          when upper('${region}')='ID' and data_source_name = 'TelcoScore' then md5(concat(data_source_name,'#','Phone=',phone))
          when upper('${region}')='ID' and data_source_name = 'FDCData' then md5(concat(data_source_name,'#','IdentityNumber=',identity_number,'#','Reason=',reason))
          when upper('${region}')='ID' and data_source_name = 'VidaData' then md5(concat(data_source_name,'#','Address=',address,'#','City=',city,'#','CommentConsentAt=',comment_consent_at,'#','ConsentedAt=',consented_at,'#','ConsentGiven=',consent_given,'#','District=',district,'#','Dob=',dob,'#','Email=',email,'#','FullName=',full_name,'#','GovID=',gov_id,'#','IDCardPhoto=',id_card_photo,'#','Mobile=',mobile,'#','PartnerTrxID=',partner_trx_id,'#','Pob=',pob,'#','Province=',province,'#','SelfiePhoto=',self_ie_photo,'#','Village=',village))
          when upper('${region}')='ID' and data_source_name = 'BPSData' then md5(concat(data_source_name,'#','IdNumber=',id_number))
          when upper('${region}')='ID' and data_source_name = 'BPJSData' then md5(concat(data_source_name,'#','Aktif=',aktif,'#','AlamatTK=',alamat_tk,'#','BlthUpah=',blth_upah,'#','Email=',email,'#','Handphone=',hand_phone,'#','JenisKelamin=',jenis_kelamin,'#','NamaLengkap=',nama_lengkap,'#','NamaPerusahaan=',nama_perusahaan,'#','NomorIdentitas=',nomor_identitas,'#','TglDaftar=',tgl_daftar,'#','Upah=',upah))
          when upper('${region}')='ID' and data_source_name = 'VidaDemogData' then md5(concat(data_source_name,'#','Address=',address,'#','City=',city,'#','CommentConsentAt=',comment_consent_at,'#','ConsentedAt=',consented_at,'#','ConsentGiven=',consent_given,'#','District=',district,'#','Dob=',dob,'#','Email=',email,'#','FullName=',full_name,'#','GovID=',gov_id,'#','IDCardPhoto=',id_card_photo,'#','Mobile=',mobile,'#','PartnerTrxID=',partner_trx_id,'#','Pob=',pob,'#','Province=',province,'#','SelfiePhoto=',self_ie_photo,'#','Village=',village))
          when upper('${region}')='ID' and data_source_name = 'VidaFRData' then md5(concat(data_source_name,'#','Address=',address,'#','City=',city,'#','CommentConsentAt=',comment_consent_at,'#','ConsentedAt=',consented_at,'#','ConsentGiven=',consent_given,'#','District=',district,'#','Dob=',dob,'#','Email=',email,'#','FullName=',full_name,'#','GovID=',gov_id,'#','IDCardPhoto=',id_card_photo,'#','Mobile=',mobile,'#','PartnerTrxID=',partner_trx_id,'#','Pob=',pob,'#','Province=',province,'#','SelfiePhoto=',self_ie_photo,'#','Village=',village))
          when upper('${region}')='ID' and data_source_name = 'BPSDataV11' then md5(concat(data_source_name,'#','IdNumber=',id_number))
          when upper('${region}')='ID' and data_source_name = 'MultiHead' then md5(concat(data_source_name,'#','Msisdn=',msisdn,'#','KtpNo=',ktp_no))
          when upper('${region}')='ID' and data_source_name = 'VidaCfDemog' then md5(concat(data_source_name,'#','Dob=',dob,'#','Email=',email,'#','FullName=',full_name,'#','GovID=',gov_id,'#','IDCardPhoto=',id_card_photo,'#','Mobile=',mobile,'#','SelfiePhoto=',self_ie_photo))
          when upper('${region}')='ID' and data_source_name = 'VidaCfFr' then md5(concat(data_source_name,'#','Dob=',dob,'#','Email=',email,'#','FullName=',full_name,'#','GovID=',gov_id,'#','IDCardPhoto=',id_card_photo,'#','Mobile=',mobile,'#','SelfiePhoto=',self_ie_photo))
          when upper('${region}')='ID' and data_source_name = 'VidaCfFull' then md5(concat(data_source_name,'#','Dob=',dob,'#','Email=',email,'#','FullName=',full_name,'#','GovID=',gov_id,'#','IDCardPhoto=',id_card_photo,'#','Mobile=',mobile,'#','SelfiePhoto=',self_ie_photo))
          when upper('${region}')='ID' and data_source_name = 'VidaLdnFull' then md5(concat(data_source_name,'#','Dob=',dob,'#','Email=',email,'#','FullName=',full_name,'#','GovID=',gov_id,'#','IDCardPhoto=',id_card_photo,'#','Mobile=',mobile,'#','SelfiePhoto=',self_ie_photo))
          when upper('${region}')='ID' and data_source_name = 'CBI' then md5(concat(data_source_name,'#','IdNumber=',id_number))
          when upper('${region}')='ID' and data_source_name = 'NPWP' then md5(concat(data_source_name,'#','Nik=',nik))
          when upper('${region}')='ID' and data_source_name = 'FDCDataV5.2' then md5(concat(data_source_name,'#','KTP=',ktp,'#','Reason=',reason))
        
          when upper('${region}')='BR' and data_source_name = 'IDWallIRS' then md5(concat(data_source_name,'#','BirthDay=',birth_day,'#','CnhNumber=',cnh_number,'#','CPF=',cpf,'#','Name=',name,'#','RgNumber=',rg_number,'#','SelfieUrl=',self_id_url))
          when upper('${region}')='BR' and data_source_name = 'IDWallDL' then md5(concat(data_source_name,'#','BirthDay=',birth_day,'#','CPF=',cpf,'#','Name=',name))
          when upper('${region}')='BR' and data_source_name = 'IDWallFaceLink' then md5(concat(data_source_name,'#','CPF=',cpf,'#','SelfieUrl=',self_id_url))
          when upper('${region}')='BR' and data_source_name = 'QuodPresumeIncome' then md5(concat(data_source_name,'#','CPF=',cpf))
          when upper('${region}')='BR' and data_source_name = 'QuodReport' then md5(concat(data_source_name,'#','CPF=',cpf,'#','IncludeCreditLinesData=',include_credit_lines_data))
          when upper('${region}')='BR' and data_source_name = 'QuodAuthRegistration' then md5(concat(data_source_name,'#','CPF=',cpf))
          when upper('${region}')='BR' and data_source_name = 'QuodIndicators' then md5(concat(data_source_name,'#','CPF=',cpf))
          when upper('${region}')='BR' and data_source_name = 'QuodScore' then md5(concat(data_source_name,'#','CPF=',cpf))
          when upper('${region}')='BR' and data_source_name = 'QuodFraudScore' then md5(concat(data_source_name,'#','CPF=',cpf))
          when upper('${region}')='BR' and data_source_name = 'SerasaInfo' then md5(concat(data_source_name,'#','DocumentNumber=',document_number))
          when upper('${region}')='BR' and data_source_name = 'SerasaReport' then md5(concat(data_source_name,'#','CPF=',cpf))
          when upper('${region}')='BR' and data_source_name = 'ItauEntriesStatistics' then md5(concat(data_source_name,'#','IdKey=',id_key))
          when upper('${region}')='BR' and data_source_name = 'ItauPersonStatistics' then md5(concat(data_source_name,'#','IdPerson=',id_person))
          when upper('${region}')='BR' and data_source_name = 'QitechSCR' then md5(concat(data_source_name,'#','DocumentNumber=',document_number))

          when upper('${region}')='SG' and data_source_name = 'ExperianBNPL' then md5(concat(data_source_name,'#','CustomerName=',custome_name,'#','IdNo=',id_no,'#','IdType=',id_type,'#','Product=',product))

          when upper('${region}')='TH' and data_source_name = 'ThAdvanceAI' then md5(concat(data_source_name,'#','IdNumberMd5=',id_number_md5))
          when upper('${region}')='TH' and data_source_name = 'DopaData' then md5(concat(data_source_name,'#','BirthDay=',birth_day,'#','FirstName=',first_name,'#','LaserCode=',laser_code,'#','LastName=',last_name,'#','PID=',pid))
          when upper('${region}')='TH' and data_source_name = 'LedData' then md5(concat(data_source_name,'#','DocumentNumber=',document_number))

          when upper('${region}')='VN' and data_source_name = 'QueryTaxInfo' then md5(concat(data_source_name,'#','IdNo=',id_no))
          when upper('${region}')='VN' and data_source_name = 'CreditBureau' then md5(concat(data_source_name,'#','PlatformUserId=',platformuser_id))

          when upper('${region}')='PH' and data_source_name = 'FinScore' then md5(concat(data_source_name,'#','MobileNumber=',mobile_number))
          when upper('${region}')='PH' and data_source_name = 'CrifData' then md5(concat(data_source_name,'#','Number=',number,'#','Type=',type))
          when upper('${region}')='PH' and data_source_name = 'NewFinScoreV2' then md5(concat(data_source_name,'#','MobileNumber=',mobile_number))
          when upper('${region}')='PH' and data_source_name = 'TelcoScore' then md5(concat(data_source_name,'#','MobileNumber=',mobile_number))

          when upper('${region}')='MY' and data_source_name = 'CTOSData' then md5(concat(data_source_name,'#','CallCcrisDecision=',call_ccris_decision,'#','CallConsentDecision=',call_consent_decision,'#','CallCtosDecision=',call_ctos_decision,'#','CallFicoDecision=',call_fico_decision,'#','CallIeDecision=',call_ie_decision,'#','CallTrexDecision=',call_trex_decision,'#','ICLCNo=',iclc_no,'#','MobileNo=',mobile_no,'#','Name=',name,'#','NICBRNo=',nicbr_no))

     end as request_key
    from(
        select 
        id                        
             
        ,unique_key               
        ,data_source_name         
        ,req_header               
        ,req                      
        ,extra_info               
        ,resp_code                
        ,case when identity_fetch_tab.trace_id is null then 2 -- wei.tao on 24/12/06       
              else 1
            end as hit_cache                
        ,identity_apply_tab.trace_id     -- wei.tao on 24/12/06                       
        ,app_key                  
        ,flow_no                  
        ,data_year_month          
        ,format_time(create_time,upper('${region}')) as create_time   
        ,format_time(update_time,upper('${region}')) as update_time                 
        ,nvl(get_json_object(req,'$.IdCardNo'),'<nil>')        as id_card_no
        ,nvl(get_json_object(req,'$.UserName'),'<nil>')         as user_name
        ,nvl(get_json_object(req,'$.BirthDate'),'<nil>')        as birth_date
        ,nvl(get_json_object(req,'$.PhoneNo'),'<nil>')          as phone_no
        ,nvl(get_json_object(req,'$.Msisdn'),'<nil>')           as msisdn
        ,nvl(get_json_object(req,'$.Phone'),'<nil>')            as phone
        ,nvl(get_json_object(req,'$.IdentityNumber'),'<nil>')   as identity_number
        ,nvl(get_json_object(req,'$.Reason'),'<nil>')           as reason
        ,nvl(get_json_object(req,'$.PartnerTrxID'),'<nil>')     as partner_trx_id
        ,nvl(get_json_object(req,'$.Mobile'),'<nil>')           as mobile
        ,nvl(get_json_object(req,'$.Email'),'<nil>')            as email
        ,nvl(get_json_object(req,'$.FullName'),'<nil>')         as full_name
        ,nvl(get_json_object(req,'$.Dob'),'<nil>')              as dob
        ,nvl(get_json_object(req,'$.GovID'),'<nil>')            as gov_id
        ,nvl(get_json_object(req,'$.Pob'),'<nil>')              as pob
        ,nvl(get_json_object(req,'$.Address'),'<nil>')          as address
        ,nvl(get_json_object(req,'$.Village'),'<nil>')          as village
        ,nvl(get_json_object(req,'$.District'),'<nil>')         as district
        ,nvl(get_json_object(req,'$.City'),'<nil>')             as city
        ,nvl(get_json_object(req,'$.Province'),'<nil>')         as province
        ,nvl(get_json_object(req,'$.SelfiePhoto'),'<nil>')      as self_ie_photo
        ,nvl(get_json_object(req,'$.IDCardPhoto'),'<nil>')      as id_card_photo
        ,nvl(get_json_object(req,'$.ConsentedAt'),'<nil>')      as consented_at
        ,nvl(get_json_object(req,'$.CommentConsentAt'),'<nil>') as comment_consent_at
        ,nvl(get_json_object(req,'$.ConsentGiven'),'<nil>')     as consent_given
        ,nvl(get_json_object(req,'$.IdNumber'),'<nil>')         as id_number
        ,nvl(get_json_object(req,'$.NamaLengkap'),'<nil>')      as nama_lengkap
        ,nvl(get_json_object(req,'$.NomorIdentitas'),'<nil>')   as nomor_identitas
        ,nvl(get_json_object(req,'$.Aktif'),'<nil>')            as aktif
        ,nvl(get_json_object(req,'$.BlthUpah'),'<nil>')         as blth_upah
        ,nvl(get_json_object(req,'$.AlamatTK'),'<nil>')         as alamat_tk
        ,nvl(get_json_object(req,'$.Handphone'),'<nil>')        as hand_phone
        ,nvl(get_json_object(req,'$.TglDaftar'),'<nil>')        as tgl_daftar
        ,nvl(get_json_object(req,'$.NamaPerusahaan'),'<nil>')   as nama_perusahaan
        ,nvl(get_json_object(req,'$.Upah'),'<nil>')             as upah
        ,nvl(get_json_object(req,'$.JenisKelamin'),'<nil>')     as jenis_kelamin
        ,nvl(get_json_object(req,'$.KtpNo'),'<nil>')            as ktp_no
        ,nvl(get_json_object(req,'$.Nik'),'<nil>')              as nik
        ,nvl(get_json_object(req,'$.KTP'),'<nil>')              as ktp

        ,nvl(get_json_object(req,'$.CPF'),'<nil>')              as cpf 
        ,nvl(get_json_object(req,'$.SelfieUrl'),'<nil>')        as self_id_url
        ,nvl(get_json_object(req,'$.BirthDay'),'<nil>')         as birth_day 
        ,nvl(get_json_object(req,'$.Name'),'<nil>')             as name 
        ,nvl(get_json_object(req,'$.RgNumber'),'<nil>')         as rg_number 
        ,nvl(get_json_object(req,'$.CnhNumber'),'<nil>')        as cnh_number
        ,nvl(get_json_object(req,'$.Birthday'),'<nil>')         as birth_day_2
        ,nvl(get_json_object(req,'$.IncludeCreditLinesData'),'<nil>') as include_credit_lines_data
        ,nvl(get_json_object(req,'$.DocumentNumber'),'<nil>')   as document_number
        ,nvl(get_json_object(req,'$.IdKey'),'<nil>')            as id_key 
        ,nvl(get_json_object(req,'$.IdPerson'),'<nil>')         as id_person 

        ,nvl(get_json_object(req,'$.CustomerName'),'<nil>')     as custome_name
        ,nvl(get_json_object(req,'$.IdNo'),'<nil>')             as id_no
        ,nvl(get_json_object(req,'$.IdType'),'<nil>')           as id_type
        ,nvl(get_json_object(req,'$.Product'),'<nil>')          as product

        ,nvl(get_json_object(req,'$.IdNumberMd5'),'<nil>')      as id_number_md5
        ,nvl(get_json_object(req,'$.FirstName'),'<nil>')        as first_name 
        ,nvl(get_json_object(req,'$.LaserCode'),'<nil>')        as laser_code
        ,nvl(get_json_object(req,'$.LastName'),'<nil>')         as last_name 
        ,nvl(get_json_object(req,'$.PID'),'<nil>')              as pid
        ,nvl(get_json_object(req,'$.Identity'),'<nil>')         as identity

        ,nvl(get_json_object(req,'$.PlatformUserId'),'<nil>')   as platformuser_id

        ,nvl(get_json_object(req,'$.MobileNumber'),'<nil>')     as mobile_number 

        ,nvl(get_json_object(req,'$.CallCcrisDecision'),'<nil>')    as call_ccris_decision
        ,nvl(get_json_object(req,'$.CallConsentDecision'),'<nil>')  as call_consent_decision
        ,nvl(get_json_object(req,'$.CallCtosDecision'),'<nil>')     as call_ctos_decision
        ,nvl(get_json_object(req,'$.CallFicoDecision'),'<nil>')     as call_fico_decision
        ,nvl(get_json_object(req,'$.CallIeDecision'),'<nil>')       as call_ie_decision
        ,nvl(get_json_object(req,'$.CallTrexDecision'),'<nil>')     as call_trex_decision
        ,nvl(get_json_object(req,'$.ICLCNo'),'<nil>')               as iclc_no
        ,nvl(get_json_object(req,'$.MobileNo'),'<nil>')             as mobile_no
        ,nvl(get_json_object(req,'$.NICBRNo'),'<nil>')              as nicbr_no
        
        -- PH 
        ,case when get_json_object(req,'$.Subject.Indicidual') is not null 
                   and get_json_object(req,'$.Subject.Indicidual.IdentificationCode') is not null 
                   and length(get_json_object(req,'$.Subject.Indicidual.IdentificationCode.Number'))>1 
                   and length(get_json_object(req,'$.Subject.Indicidual.IdentificationCode.Type'))>1 
              then get_json_object(req,'$.Subject.Indicidual.IdentificationCode.Type') 
              when get_json_object(req,'$.Subject.Indicidual.ID') is not null 
              then get_json_object(req,'$.Subject.Indicidual.ID.Type') end as type 
        ,case when get_json_object(req,'$.Subject.Indicidual') is not null 
                   and get_json_object(req,'$.Subject.Indicidual.IdentificationCode') is not null 
                   and length(get_json_object(req,'$.Subject.Indicidual.IdentificationCode.Number'))>1 
                   and length(get_json_object(req,'$.Subject.Indicidual.IdentificationCode.Type'))>1 
              then get_json_object(req,'$.Subject.Indicidual.IdentificationCode.Number') 
              when get_json_object(req,'$.Subject.Indicidual.ID') is not null 
              then get_json_object(req,'$.Subject.Indicidual.ID.Number') end as number 

        from risk.ods__credit_risk_datafetch_${region}_db__identity_apply_tab__df as identity_apply_tab
-- added by wei.tao ref:https://docs.google.com/spreadsheets/d/1pvtivL96IXS1s9AertvFFkKvwaQrdyUnGFPV3WYwC8Y/edit?pli=1&gid=1377751460#gid=1377751460
            left join 
                (   select distinct trace_id
                    from risk.ods__credit_risk_datafetch_${region}_db__identity_fetch_tab__df
                    where grass_date ='${grass_date}'
                ) as identity_fetch_tab
            on 
                identity_apply_tab.trace_id = identity_fetch_tab.trace_id
        where grass_date ='${grass_date}'
        --and hit_cache=2 -- old logic changed 
            --修复主要逻辑：目前identity_apply_tab表中的数据表示外数请求数据，identity_fetch_tab中的数据代表了实际发起外调请求的数据。如果apply表中请求的数据，在fetch表中没找到，那么就代表命中了缓存，将identity表中的hit_cache字段设置为2，否则设置为1.
--     
    ) tt1 
) t1
left join (
    select 
    data_source_name 
    ,request_key
    ,trace_id
    ,update_date
    from (
        select 
        data_source_name 
        ,request_key
        ,trace_id
        ,update_date
        ,row_number() over(partition by request_key order by update_date asc) as rn 
        from  (
            select 
             data_source_name 
            ,request_key
            ,trace_id
            ,case when data_source_name in('TongdunIncome') then date_add(to_date(format_time(update_time,upper('${region}'))),36500)
                  when data_source_name in('VidaCfDemog','VidaCfFr','VidaCfFull','VidaLdnFull') then date_add(to_date(format_time(update_time,upper('${region}'))),18250)
                  when data_source_name in('QueryTaxInfo') then date_add(to_date(format_time(update_time,upper('${region}'))),1000)
                  when data_source_name in('IDWallDL','IDWallFaceLink') then date_add(to_date(format_time(update_time,upper('${region}'))),360)
                  when data_source_name in('IDWallIRS') then date_add(to_date(format_time(update_time,upper('${region}'))),180)
                  when data_source_name in('Dukcapil','IndosatTenure','FDCData','BPSData','BPSDataV11','CBI','NPWP','GetCreditReport','QitechSCR','FinScore','CrifData','NewFinScore','CreditBureau') then date_add(to_date(format_time(update_time,upper('${region}'))),90)
                  when data_source_name in('FDCDataV5.2','FDCDataV5') then date_add(to_date(format_time(update_time,upper('${region}'))),60)
                  when data_source_name in('IndosatCustom','TelcoScore','VidaData','BPJSData','VidaDemogData','VidaFRData','QuodPresumeIncome','QuodReport','QuodAuthRegistration','QuodIndicators','QuodScore','QuodFraudScore','SerasaInfo','SerasaReport','NewFinScoreV2','TelcoScore','ExperianBNPL','CTOSData','ThAdvanceAI') then date_add(to_date(format_time(update_time,upper('${region}'))),30)
                  when data_source_name in('MultiHead','DopaData','LedData') then date_add(to_date(format_time(update_time,upper('${region}'))),1)
                  else to_date(format_time(update_time,upper('${region}'))) end update_date
            from risk.ods__credit_risk_datafetch_${region}_db__identity_data_history_tab__df
            where grass_date ='${grass_date}'
        ) ttt2 
    ) tt2 
    where tt2.rn =1 
) t2 on t1.data_source_name = t2.data_source_name and t1.request_key = t2.request_key
-- where t2.update_date >=to_date(t1.update_time)
;

insert overwrite table risk.dwd_risk_${region}_identity_apply_df partition(grass_date='${grass_date}')
select 
    t1.id                          
    ,t1.request_key                
    ,t1.unique_key                 
    ,t1.data_source_name           
    ,t1.req_header                 
    ,t1.req                        
    ,case when to_date(t1.create_time)<='2024-09-30' and instr(extra_info,'trace_id')<=0 and extra_info <>'{}' and extra_info is not null  then  concat(substr(extra_info, 1, length(extra_info) - 1),concat(',"trace_id":','"',new_trace_id,'"'),'}')     
          when to_date(t1.create_time)<='2024-09-30' and extra_info ='{}' then concat('{"trace_id":','"',new_trace_id,'"}')
          when to_date(t1.create_time)<='2024-09-30' and extra_info is null then concat('{"trace_id":','"',new_trace_id,'"}')
          else extra_info end  as extra_info      
    ,t1.resp_code                  
    ,t1.hit_cache                  
    ,t1.trace_id                   
    ,t1.app_key                    
    ,t1.flow_no                    
    ,t1.data_year_month            
    ,t1.create_time                
    ,t1.update_time   
from identity_apply_trace_id_tab t1 

