create table hyperdynamic_control_cohort as 

with adult_adm as (
  select distinct subject_id, 
    hadm_id, 
    icustay_id,
    case 
      when icustay_first_service = 'FICU' then 'MICU'
      else icustay_first_service
    end as careunit,
    icustay_intime
    from mimic2v26.icustay_detail 
    where subject_icustay_seq = 1
      and icustay_first_service <> 'CCU'
      and icustay_first_service <> 'CSRU'
)
--select count(icustay_id) from adult_adm;

select distinct icustay_id from adult_adm 
    where not exists 
      (select icustay_id from tbrennan.hyperdynamic_cohort hc
        where adult_adm.icustay_id = hc.icustay_id);
        