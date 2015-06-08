--create materialized view echo_cohort as
drop table hyperdynamic_cohort;
create table hyperdynamic_cohort as

with adult_adm as (
  select distinct id.subject_id, 
    id.hadm_id, 
    id.icustay_id,
    case 
      when id.icustay_first_service = 'FICU' then 'MICU'
      else id.icustay_first_service
    end as careunit,
    id.icustay_intime
    from mimic2v26.icustay_detail id
    where subject_icustay_seq = 1
      --and icustay_first_service <> 'CCU'
      --and icustay_first_service <> 'CSRU'

)
--select * from adult_adm;
--select count(distinct icustay_id) from adult_adm; -- 23,467 subjects/admissions

, drgcodes as (
  select
    drg.subject_id
    , drg.hadm_id
    , dc.code drgcode
    , row_number() over (partition by hadm_id order by cost_weight desc) drgorder
  from mimic2v26.drgevents drg 
  join mimic2v26.d_codeditems dc
    on drg.itemid = dc.itemid
)
--select * from drgcodes;

, icu_echos as (
  select distinct subject_id, 
    icustay_id,
    first_value(echo_dt) over (partition by icustay_id order by lvef_group desc) echo_dt,
    first_value(lvef_group) over (partition by icustay_id order by lvef_group desc) lvef_group
    from tbrennan.mimic2v26_adult_echo_groups 
    where echo_dt > -1
    order by subject_id
)
--select * from icu_echos;

,  cohort as (
  select distinct aa.subject_id, 
    aa.hadm_id, 
    aa.icustay_id,
    aa.careunit,
    case when drgorder = 1 then drg.drgcode else '0' end as drgcode,
    ie.lvef_group,
    ie.echo_dt,
    case when ie.lvef_group = 4 then 1 
      else 0
    end as hdlvef,
    aa.icustay_intime
    from icu_echos ie
    join adult_adm aa 
       on aa.icustay_id = ie.icustay_id
    left join drgcodes drg
      on aa.subject_id = drg.subject_id and aa.hadm_id = drg.hadm_id
    where aa.careunit <> 'CCU'
      and aa.careunit <> 'CSRU'
    order by subject_id
)
--select * from cohort;
--select distinct subject_id, icustay_id from cohort where lvef_group = 0 order by subject_id;
--select count(distinct subject_id) from cohort; -- 7,253 subject_id
--select count(distinct subject_id) from cohort where careunit = 'CSRU' or careunit = 'CCU'; -- 3,402 subject_id
--select count(distinct subject_id) from cohort where careunit = 'MICU' or careunit = 'SICU'; -- 3,402 subject_id
--select count(distinct subject_id) from cohort where lvef_group = 0; -- 100 subjects
--select count(distinct subject_id) from cohort where lvef_group > 0; -- 3751 subjects
--select count(distinct subject_id) from cohort where lvef_group = 1 or lvef_group = 2; -- 884 subjects
--select count(distinct subject_id) from cohort where lvef_group = 3 or lvef_group = 4; -- 2,867 subjects
--select count(distinct icustay_id) from cohort where lvef_group = 4; -- 324 subjects

, elixhauser_pt as (
  select c.*,
      ep.twenty_eight_day_mort_pt elix_28d_pt,
      ep.one_year_survival_pt elix_1yr_pt
  from cohort c
  left join mimic2devel.elixhauser_points ep on c.hadm_id = ep.hadm_id
)
--select * from elixhauser_pt;

, sepsis as (
    select c.*,
    case when (c.subject_id = sp.subject_id and c.hadm_id = sp.hadm_id)
      then 1 else 0
    end as sepsis
    from cohort c
    left join tbrennan.angus_sepsis_cohort sp on c.subject_id = sp.subject_id and c.hadm_id = sp.hadm_id   
)
--select * from sepsis;

-- cohort demographic details  
, cohort_detail as (
    select distinct id.subject_id,
            id.icustay_id, 
            id.gender, 
            round(id.icustay_admit_age,2) age, 
            ce.drgcode,
            ce.lvef_group,
            ce.hdlvef,
            ce.echo_dt,
            id.icustay_intime,
            id.icustay_outtime,
            id.dod,
            case 
              when id.dod is null then 365 -- 1 years
              when extract(day from id.dod-id.icustay_intime) > 365 then 365
              else extract(day from id.dod-id.icustay_intime)
            end as survival_days,
            round(id.icustay_los/(60*24),2) icu_los, 
            round(id.hospital_los/(60*24),2) hosp_los,
            case when id.icustay_first_service = 'FICU' then 'MICU'
              else icustay_first_service
            end as careunit,
            id.height,
            id.weight_first weight,
            id.sapsi_first sapsi,
            id.sofa_first sofa,
            case when extract(day from id.dod - id.icustay_intime) < 29 then 1
              else 0
            end as mortality_28d,
            case when extract(day from id.dod - id.icustay_intime) < 366 then 1
              else 0
            end as one_year_mortality,
            case when hospital_expire_flg = 'Y' then 1 
              else 0
            end as hospital_mortality,
            case when icustay_expire_flg = 'Y' then 1 
              else 0
            end as icustay_mortality
      from cohort ce 
      join mimic2v26.icustay_detail id on ce.icustay_id = id.icustay_id
)
--select count(*) from cohort_detail; 

-- elixhauser comorbidities
, comorbidities as (
  select distinct cd.icustay_id,
         CASE WHEN DIABETES_UNCOMPLICATED = 1 or DIABETES_COMPLICATED = 1 THEN 1
              ELSE 0
         END AS CM_DIABETES,
         CASE WHEN CONGESTIVE_HEART_FAILURE = 1 THEN 1
              ELSE 0
         END AS CM_CHF,
         CASE WHEN ALCOHOL_ABUSE = 1 THEN 1
              ELSE 0
         END AS CM_ALCOHOL_ABUSE,
         CASE WHEN CARDIAC_ARRHYTHMIAS = 1 THEN 1
              ELSE 0
         END AS CM_ARRHYTHMIAS,
         CASE WHEN VALVULAR_DISEASE = 1 THEN 1
              ELSE 0
         END AS CM_VALVULAR_DISEASE,
         CASE WHEN HYPERTENSION = 1 THEN 1
              ELSE 0
         END AS CM_HYPERTENSION,
         CASE WHEN RENAL_FAILURE = 1 THEN 1
              ELSE 0
         END AS CM_RENAL_FAILURE,
         CASE WHEN CHRONIC_PULMONARY = 1 THEN 1
              ELSE 0
         END AS CM_CHRONIC_PULMONARY,
         CASE WHEN LIVER_DISEASE = 1 THEN 1
              ELSE 0
         END AS CM_LIVER_DISEASE,
         CASE WHEN METASTATIC_CANCER = 1 THEN 1
              ELSE 0
         END AS CM_CANCER,
         CASE WHEN PSYCHOSES = 1 THEN 1
              ELSE 0
         END AS CM_PSYCHOSIS,
         CASE WHEN DEPRESSION = 1 THEN 1
              ELSE 0
         END AS CM_DEPRESSION
    from cohort_detail cd
    left join mimic2devel.elixhauser_revised er 
        on cd.subject_id = er.subject_id
)
--select * from comorbidities order by icustay_id;



, elix_comorb as (
  select distinct icustay_id,
      first_value(cm_diabetes) over (partition by icustay_id order by cm_diabetes desc) cm_diabetes,
      first_value(cm_chf) over (partition by icustay_id order by cm_chf desc) cm_chf,
      first_value(cm_alcohol_abuse) over (partition by icustay_id order by cm_alcohol_abuse desc) cm_alcohol_abuse,
      first_value(cm_arrhythmias) over (partition by icustay_id order by cm_arrhythmias desc) cm_arrhythmias,
      first_value(cm_valvular_disease) over (partition by icustay_id order by cm_valvular_disease desc) cm_valvular_disease,
      first_value(cm_hypertension) over (partition by icustay_id order by cm_hypertension desc) cm_hypertension,
      first_value(cm_renal_failure) over (partition by icustay_id order by cm_renal_failure desc) cm_renal_failure,
      first_value(cm_chronic_pulmonary) over (partition by icustay_id order by cm_chronic_pulmonary desc) cm_chronic_pulmonary,
      first_value(cm_liver_disease) over (partition by icustay_id order by cm_liver_disease desc) cm_liver_disease,
      first_value(cm_cancer) over (partition by icustay_id order by cm_cancer desc) cm_cancer,
      first_value(cm_psychosis) over (partition by icustay_id order by cm_psychosis desc) cm_psychosis,
      first_value(cm_depression) over (partition by icustay_id order by cm_depression desc) cm_depression
      from comorbidities
)
--select count(icustay_id) from elix_comorb;


, assemble as (
  select distinct fc.subject_id,
         fc.icustay_id,
         fc.age,
         fc.gender,
         fc.height,
         fc.weight,
         fc.careunit,
         fc.drgcode,
         fc.sofa,
         fc.sapsi,
         fc.icu_los,
         fc.hosp_los,
         fc.icustay_intime,
         fc.icustay_outtime,
         fc.lvef_group,
         fc.hdlvef,
         fc.echo_dt,
         sp.sepsis,
         pc.CM_DIABETES,
         pc.CM_CHF,
         pc.CM_ALCOHOL_ABUSE,
         pc.CM_ARRHYTHMIAS,
         pc.CM_VALVULAR_DISEASE,
         pc.CM_HYPERTENSION,
         pc.CM_RENAL_FAILURE,
         pc.CM_CHRONIC_PULMONARY,
         pc.CM_LIVER_DISEASE,
         pc.CM_CANCER,
         pc.CM_PSYCHOSIS,
         pc.CM_DEPRESSION,
         ep.elix_28d_pt,
         ep.elix_1yr_pt,
         fc.survival_days,
         fc.mortality_28d,
         fc.one_year_mortality,
         fc.icustay_mortality,
         fc.hospital_mortality
    from cohort_detail fc
     left join elix_comorb pc on pc.icustay_id = fc.icustay_id
     left join sepsis sp on sp.icustay_id = fc.icustay_id
     left join elixhauser_pt ep on ep.icustay_id = fc.icustay_id
)
select * from assemble;
--select count(distinct icustay_id) from assemble; -- 4,253

-- full cohort: 2481 patients, 1yr mort 942, 475 hosp mort
-- septic cohort: 1107 patients, 1 yr mort 548, 292 hosp mort

