drop table hdlvef_control_final;
--create table hdlvef_control_final as


select ec.subject_id
    , ec.icustay_id
    , ec.age
    , ec.gender
    , ec.careunit
    , ec.sofa
    , ec.sapsi
    , ec.icu_los
    , ec.hosp_los
    , ec.sepsis
    , ec.cm_diabetes
    , ec.cm_chf
    , ec.cm_alcohol_abuse
    , ec.cm_arrhythmias
    , ec.cm_valvular_disease
    , ec.cm_hypertension
    , ec.cm_renal_failure
    , ec.cm_chronic_pulmonary
    , ec.cm_liver_disease
    , ec.cm_cancer
    , ec.cm_psychosis
    , ec.cm_depression
    , ec.elix_28d_pt
    , ec.elix_1yr_pt
    , ec.survival_days
    , ec.mortality_28d
    , ec.one_year_mortality
    , ec.icustay_mortality
    , ec.hospital_mortality
    , case 
        when et.num_vasopressors = 0 then 0
      else 1 
    end as vasopressor
    , case 
        when et.vasopressor_duration is null then 0
      else et.vasopressor_duration
    end as vasopressor_duration
    , case
        when et.num_vasopressors is null then 0
      else et.num_vasopressors 
    end as num_vasopressors
    , case
      when et.max_vasopressor_adjusteddose is null then 0
      else et.max_vasopressor_adjusteddose
    end as max_vasopressor_adjusteddose
    , round(extract(day from et.start_pressors - ec.icustay_intime) +
        extract(hour from et.start_pressors - ec.icustay_intime)/24 +
        extract(minute from et.start_pressors - ec.icustay_intime)/1440,4) vasopressor_dt
    , et.rrt
    , et.ventilated
    , et.fi_1d_ml
    , et.fi_3d_ml
    , et.fo_1d_ml
    , et.fo_3d_ml
    , lb.max_creatinine
    , lb.med_creatinine
    , lb.max_wbc
    , lb.med_wbc
    , lb.max_lactate
    , lb.med_lactate
    , vs.hr_1st
    , vs.hr_lowest
    , vs.hr_highest
    , vs.map_1st
    , vs.map_lowest
    , vs.map_highest
    , vs.temp_1st
    , vs.temp_lowest
    , vs.temp_highest
  
  from tbrennan.hyperdynamic_control ec
  left join tbrennan.hdlvef_control_treatments et on ec.icustay_id = et.icustay_id
  left join tbrennan.hdlvef_control_labs lb on lb.icustay_id = ec.icustay_id
  left join tbrennan.hdlvef_control_vitals vs on vs.icustay_id = ec.icustay_id

;