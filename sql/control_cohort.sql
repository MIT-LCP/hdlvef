drop table hyperdynamic_control;
create table hyperdynamic_control as

with cohort as (
  select distinct id.subject_id,
        id.hadm_id,
        id.icustay_id, 
        id.gender, 
        round(id.icustay_admit_age,2) age, 
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
    from tbrennan.hyperdynamic_control_cohort hcc
    join mimic2v26.icustay_detail id
       on hcc.icustay_id = id.icustay_id
    order by subject_id
)
--select count(icustay_id) from cohort;
--select count(distinct subject_id) from cohort; -- 7,253 subject_id
--select count(distinct subject_id) from cohort where careunit = 'MICU' or careunit = 'SICU'; -- 3,402 subject_id

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
    from cohort cd
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
         fc.sofa,
         fc.sapsi,
         fc.icu_los,
         fc.hosp_los,
         fc.icustay_intime,
         fc.icustay_outtime,
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
    from cohort fc
     left join elix_comorb pc on pc.icustay_id = fc.icustay_id
     left join sepsis sp on sp.icustay_id = fc.icustay_id
     left join elixhauser_pt ep on ep.icustay_id = fc.icustay_id
)
select * from assemble;
--select count(distinct icustay_id) from assemble; -- 4,253

-- full cohort: 2481 patients, 1yr mort 942, 475 hosp mort
-- septic cohort: 1107 patients, 1 yr mort 548, 292 hosp mort

