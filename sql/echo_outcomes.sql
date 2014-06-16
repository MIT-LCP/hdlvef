drop table hyperdynamic_outcomes;
create table hyperdynamic_outcomes as 

-- createnin
with creatinin as (
  select distinct fc.icustay_id,
    --min(lb.valuenum) over (partition by fc.icustay_id) creat_min,
    --max(lb.valuenum) over (partition by fc.icustay_id) creat_max,
    --round(avg(lb.valuenum) over (partition by fc.icustay_id),2) creat_avg,
    --count(lb.valuenum) over (partition by fc.icustay_id) no_creat_tests
    extract(day from lb.charttime - fc.icustay_intime)*1440 + extract(hour from lb.charttime - fc.icustay_intime)*60 + extract(minute from lb.charttime - fc.icustay_intime) dt,
    lb.valuenum value,
    1 as data_type
  from tbrennan.hyperdynamic_cohort fc
  join mimic2v26.labevents lb
    on fc.icustay_id = lb.icustay_id
    and lb.itemid = 50090
    and lb.charttime between fc.icustay_intime and fc.icustay_intime + 3
  order by fc.icustay_id, dt
)
--select * from createnin;


-- white bloodcell count
, wbc as (
  select distinct fc.icustay_id,
    --min(lb.valuenum) over (partition by fc.icustay_id) wbc_min,
    --max(lb.valuenum) over (partition by fc.icustay_id) wbc_max,
    --round(avg(lb.valuenum) over (partition by fc.icustay_id),2) wbc_avg,
    --count(lb.valuenum) over (partition by fc.icustay_id) no_wbc_tests
    extract(day from lb.charttime - fc.icustay_intime)*1440 + extract(hour from lb.charttime - fc.icustay_intime)*60 + extract(minute from lb.charttime - fc.icustay_intime) dt,
    lb.valuenum value,
    2 as data_type
  from tbrennan.hyperdynamic_cohort fc
  join mimic2v26.labevents lb
    on fc.icustay_id = lb.icustay_id
    and lb.itemid in (50468,50316)
    and lb.charttime between fc.icustay_intime and fc.icustay_intime + 3
  order by fc.icustay_id, dt  
)
--select * from wbc;

-- lactate
, lactate as (
  select distinct fc.icustay_id,
    --min(lb.valuenum) over (partition by fc.icustay_id) lactate_min,
    --max(lb.valuenum) over (partition by fc.icustay_id) lactate_max,
    --round(avg(lb.valuenum) over (partition by fc.icustay_id),2) lactate_avg,
    --count(lb.valuenum) over (partition by fc.icustay_id) no_lactate_tests
    extract(day from lb.charttime - fc.icustay_intime)*1440 + extract(hour from lb.charttime - fc.icustay_intime)*60 + extract(minute from lb.charttime - fc.icustay_intime) dt,
    lb.valuenum value,
    3 as data_type
  from tbrennan.hyperdynamic_cohort fc
  join mimic2v26.labevents lb
    on fc.icustay_id = lb.icustay_id
    and lb.itemid = 50010
    and lb.charttime between fc.icustay_intime and fc.icustay_intime + 3
  order by fc.icustay_id, dt
)
--select * from lactate;


-- %%%%%%%%%%%%%% HEART RATE
, heartrate as (
  select fc.icustay_id,
      extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) dt,
      ce.value1num value,
      4 as data_type
    from tbrennan.hyperdynamic_cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (211)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 3
)
--select * from heartrate;


, assemble as (
  select * from creatinin
    union
  select * from wbc
    union
  select * from lactate
    union
  select * from heartrate
    
)
select * from assemble;
