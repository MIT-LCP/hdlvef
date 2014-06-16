with population as (

  select subject_id, icustay_id, hadm_id,
    case when text like '%hyperdynamic%' then 1 else 0 end as hyperdynamic
    from mimic2v25.noteevents
      where category like 'ECHO_REPORT'
      and text like '%hyperdynamic%'

)
--select count(distinct hadm_id) from population; --648 rows

-- patient information
, population_detail as (
  select p.*, id.gender, id.icustay_admit_age, id.icustay_first_service, id.icustay_intime, round(id.icustay_los/(60*24),2) as days_in_ICU
    from population p
    join mimic2v26.icustay_detail id
      on p.hadm_id = id.hadm_id

)
--select * from population_detail;

-- patient mortality at 28d, 1yr, 2yr
, mortality as (
  select p.*, extract(day from id.dod - id.icustay_intime) death_after_icustay,
         case when extract(day from id.dod - id.icustay_intime) < 29 then '1'
              else '0'
         end as twenty_eight_day_mortality,
         case when extract(day from id.dod - id.icustay_intime) < 365 then '1'
              else'0'
         end as one_year_mortality,
         case when extract(day from id.dod - id.icustay_intime) < 730 then '1'
              else '0'
         end as two_year_mortality,
         hospital_expire_flg hospital_mortality,
         icustay_expire_flg icustay_mortality
    from population p
    join mimic2v26.icustay_detail id
      on p.hadm_id = id.hadm_id
)
--select * from mortality;

--patient SOFA scores
, patient_sofa as (
    select distinct cd.icustay_id, cd.hadm_id, FIRST_VALUE(value1num) over (partition by cd.icustay_id order by charttime) sofa_score
    from population cd
    left join mimic2v26.chartevents ce
         on cd.icustay_id = ce.icustay_id
   where itemid = '20009'
)
--select * from patient_sofa; 


--patient SAPS scores
, patient_saps as (
    select distinct cd.icustay_id, cd.hadm_id, FIRST_VALUE(value1num) over (partition by cd.icustay_id order by charttime) saps_score
    from population cd
    left join mimic2v26.chartevents ce
         on cd.icustay_id = ce.icustay_id
   where itemid = '20001'
)
--select * from patient_saps;

--get elixhauser score 
, elixhauser as (
  select p.*,
         ep.twenty_eight_day_mort_pt,
         ep.one_year_survival_pt
  from population p
  left join mimic2devel.elixhauser_points ep 
       on p.hadm_id = ep.hadm_id
)
--select * from elixhauser;



, final_cohort as (

  select p.subject_id,
         p.icustay_id,
         pd.hadm_id,
         pd.gender,
         pd.icustay_admit_age,
         pd.icustay_first_service,
         pd.icustay_intime,
         pd.days_in_icu,
         m.hospital_mortality,
         m.icustay_mortality,
         m.twenty_eight_day_mortality,
         m.one_year_mortality,
         m.two_year_mortality,
         psf.sofa_score,
         psp.saps_score,
         ep.twenty_eight_day_mort_pt,
         ep.one_year_survival_pt
    from population p 
    left join population_detail pd on p.hadm_id = pd.hadm_id
    left join mortality m on p.hadm_id = m.hadm_id
    left join patient_sofa psf on p.hadm_id = psf.hadm_id
    left join patient_saps psp on p.hadm_id = psp.hadm_id
    left join elixhauser ep on p.hadm_id = ep.hadm_id
)
select * from final_cohort; --625 subject_id, 331 icustay_id, 634 hadm_id
       



      