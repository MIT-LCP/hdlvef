drop table hdlvef_control_labs;
create table hdlvef_control_labs as 

-- createnin
with creatinine_raw as (
  select distinct fc.icustay_id,
    --min(lb.valuenum) over (partition by fc.icustay_id) creat_min,
    --max(lb.valuenum) over (partition by fc.icustay_id) creat_max,
    --round(avg(lb.valuenum) over (partition by fc.icustay_id),2) creat_avg,
    --count(lb.valuenum) over (partition by fc.icustay_id) no_creat_tests
    extract(day from lb.charttime - fc.icustay_intime)*1440 + 
      extract(hour from lb.charttime - fc.icustay_intime)*60 + 
        extract(minute from lb.charttime - fc.icustay_intime) dt,
    lb.valuenum 
    
  from tbrennan.hyperdynamic_control fc
  
  join mimic2v26.labevents lb
    on fc.icustay_id = lb.icustay_id
    and lb.itemid = 50090
    and lb.valuenum is not null
    and lb.charttime between fc.icustay_intime and fc.icustay_intime + 3
  
  order by fc.icustay_id, dt
)
--select * from createnine_raw;

, creatinine as (
  select distinct 
    icustay_id, 
    max(valuenum) max_creatinine,
    --round(avg(value),2) avg_createnin
    median(valuenum) med_creatinine
    
  from creatinine_raw eo
  
  group by icustay_id
)
--select * from createnine;

-- white bloodcell count
, wbc_raw as (
  select distinct 
    fc.icustay_id,
    --min(lb.valuenum) over (partition by fc.icustay_id) wbc_min,
    --max(lb.valuenum) over (partition by fc.icustay_id) wbc_max,
    --round(avg(lb.valuenum) over (partition by fc.icustay_id),2) wbc_avg,
    --count(lb.valuenum) over (partition by fc.icustay_id) no_wbc_tests
    extract(day from lb.charttime - fc.icustay_intime)*1440 + 
      extract(hour from lb.charttime - fc.icustay_intime)*60 + 
      extract(minute from lb.charttime - fc.icustay_intime) dt,
    lb.valuenum
    
  from tbrennan.hyperdynamic_control fc
  
  join mimic2v26.labevents lb
    on fc.icustay_id = lb.icustay_id
    and lb.itemid in (50468,50316)
    and lb.valuenum is not null
    and lb.charttime between fc.icustay_intime and fc.icustay_intime + 3
  
  order by fc.icustay_id, dt  
)
--select * from wbc;

, wbc as (
  select distinct eo.icustay_id, 
    max(valuenum) max_wbc,
    --round(avg(value),2) avg_wbc
    median(valuenum) med_wbc
    
  from wbc_raw eo
  
  group by icustay_id
)
--select * from wbc;

-- lactate
, lactate_raw as (
  select distinct fc.icustay_id,
    --min(lb.valuenum) over (partition by fc.icustay_id) lactate_min,
    --max(lb.valuenum) over (partition by fc.icustay_id) lactate_max,
    --round(avg(lb.valuenum) over (partition by fc.icustay_id),2) lactate_avg,
    --count(lb.valuenum) over (partition by fc.icustay_id) no_lactate_tests
    extract(day from lb.charttime - fc.icustay_intime)*1440 + 
      extract(hour from lb.charttime - fc.icustay_intime)*60 + 
      extract(minute from lb.charttime - fc.icustay_intime) dt,
    lb.valuenum 

  from tbrennan.hyperdynamic_control fc

  join mimic2v26.labevents lb
    on fc.icustay_id = lb.icustay_id
    and lb.itemid = 50010
    and lb.valuenum is not null
    and lb.charttime between fc.icustay_intime and fc.icustay_intime + 3

  order by fc.icustay_id, dt
)
--select * from lactate;

, lactate as (
  select distinct eo.icustay_id, 
    max(valuenum) max_lactate,
    --round(avg(value),2) avg_lactate
    median(valuenum) med_lactate
  from lactate_raw eo
  
  group by icustay_id
)
--select * from lactate;

select
  hc.icustay_id
  , ct.max_creatinine
  , ct.med_creatinine
  , wbc.max_wbc
  , wbc.med_wbc
  , ll.max_lactate
  , ll.med_lactate
  
from 
  tbrennan.hyperdynamic_control hc
  
left join 
  creatinine ct
    on ct.icustay_id = hc.icustay_id
  
left join 
  wbc 
    on wbc.icustay_id = hc.icustay_id

left join 
  lactate ll
    on ll.icustay_id = hc.icustay_id
    
;
