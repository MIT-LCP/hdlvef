drop table hyperdynamic_final;
--create table hyperdynamic_final as

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
  select ec.subject_id,
    ec.icustay_id,
    ec.age,
    ec.gender,
    ec.careunit,
    ec.sofa,
    ec.sapsi,
    ec.icu_los,
    ec.hosp_los,
    ec.lvef_group,
    ec.hdlvef,
    ec.echo_dt,
    ec.sepsis,
    ec.cm_diabetes,
    ec.cm_chf,
    ec.cm_alcohol_abuse,
    ec.cm_arrhythmias,
    ec.cm_valvular_disease,
    ec.cm_hypertension,
    ec.cm_renal_failure,
    ec.cm_chronic_pulmonary,
    ec.cm_liver_disease,
    ec.cm_cancer,
    ec.cm_psychosis,
    ec.cm_depression,
    ec.elix_28d_pt,
    ec.elix_1yr_pt,
    ec.survival_days,
    ec.mortality_28d,
    ec.one_year_mortality,
    ec.icustay_mortality,
    ec.hospital_mortality,
    case 
      when vs.no_vasopressors is null then 0
      else 1 
    end as vasopressor,
    case 
      when vs.vasopressor_adjusteddose is null then 0
      else vs.vasopressor_adjusteddose 
    end as vasopressor_adjusteddose,
    case
      when vs.no_vasopressors is null then 0
      else vs.no_vasopressors 
    end as no_vasopressors,
    et.rrt,
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
  left join tbrennan.hyperdynamic_vasopressors vs on vs.icustay_id = ec.icustay_id
  left join creatinine ct on ct.icustay_id = ec.icustay_id
  left join wbc wt on wt.icustay_id = ec.icustay_id
  left join lactate lt on lt.icustay_id = ec.icustay_id
  left join heartrate hr on hr.icustay_id = ec.icustay_id

)
select * from assemble;