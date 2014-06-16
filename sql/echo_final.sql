drop table hyperdynamic_final;
create table hyperdynamic_final as

with creatinine as (
  select distinct eo.icustay_id, 
    max(value) max_creatinine,
    --round(avg(value),2) avg_createnin
    median(value) creatinine
  from tbrennan.hyperdynamic_outcomes eo
    where eo.data_type = '1'
    group by icustay_id
)
--select * from createnin;

, wbc as (
  select distinct eo.icustay_id, 
    max(value) max_wbc,
    --round(avg(value),2) avg_wbc
    median(value) wbc
  from tbrennan.hyperdynamic_outcomes eo
    where eo.data_type = '2'
    group by icustay_id
)
--select * from wbc;

, lactate as (
  select distinct eo.icustay_id, 
    max(value) max_lactate,
    --round(avg(value),2) avg_lactate
    median(value) lactate
  from tbrennan.hyperdynamic_outcomes eo
    where eo.data_type = '3'
    group by icustay_id
)
--select * from lactate;

, heartrate as (
  select distinct eo.icustay_id, 
    max(value) max_hr,
    --round(avg(value),2) avg_hr
    median(value) hr
  from tbrennan.hyperdynamic_outcomes eo
    where eo.data_type = '4'
    group by icustay_id
)
--select * from heartrate;

, assemble as (
  select ec.*,
    et.rrt,
    et.vasopressor,
    et.dobutamine,
    et.dopamine,
    et.epinephrine,
    et.vasopressin,
    et.levophed,
    et.milrinone,
    et.neosynephrine,
    et.ventilated,
    et.fi_1d_ml,
    et.fo_1d_ml,
    ct.max_creatinine,
    ct.creatinine,
    wt.max_wbc,
    wt.wbc,
    lt.max_lactate,
    lt.lactate,
    hr.max_hr,
    hr.hr
  from tbrennan.hyperdynamic_cohort ec
  left join tbrennan.hyperdynamic_treatments et on ec.icustay_id = et.icustay_id
  left join creatinine ct on ct.icustay_id = ec.icustay_id
  left join wbc wt on wt.icustay_id = ec.icustay_id
  left join lactate lt on lt.icustay_id = ec.icustay_id
  left join heartrate hr on hr.icustay_id = ec.icustay_id

)
select * from assemble;