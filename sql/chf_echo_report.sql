with chf_echo_cohort as (
  select icustay_id  from echo_cohort where cm_chf = 1
)

, assemble as (
  select ec.icustay_id,
    ne.text
  from chf_echo_cohort ec
  left join mimic2v25.noteevents ne
    on ec.icustay_id = ne.icustay_id
      and ne.category like 'ECHO_REPORT'
)
select sum(hyperdynamic) from assemble where icustay_id < 1000;