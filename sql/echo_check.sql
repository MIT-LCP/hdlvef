
-- get all echos associated with icustay_id within a week either side of adm/dch

with all_echos as (

select distinct id.subject_id, 
  ne.hadm_id, 
  id.icustay_id,
  round(ne.charttime - id.icustay_intime,3) echo_dt,
  ne.charttime 
  from mimic2v25.icustay_detail id
  join mimic2v25.noteevents ne on id.subject_id = ne.subject_id 
    and ne.charttime - id.icustay_intime < 7 
    and id.icustay_intime - ne.charttime < 7
    and ne.charttime < id.icustay_outtime
    and id.subject_icustay_seq = 1
    and id.icustay_first_service <> 'CSRU'
    and id.icustay_first_service <> 'CCU'
  where category like 'ECHO_REPORT'

)
--select * from all_echos;

, echos as (
  select ae.subject_id,
    ae.hadm_id,
    ae.icustay_id,
    ae.echo_dt,
    substr(ne.text,regexp_instr(ne.text,'[[:digit:]]{2}\%')-1,4) lvef_range,
    replace(replace(ne.text, chr(13), ''), chr(10), '') text
    from all_echos ae
    join mimic2v25.noteevents ne 
      on ae.subject_id = ne.subject_id 
     and ae.charttime = ne.charttime
   where ne.category like 'ECHO_REPORT'
     and ae.echo_dt > -2
     
)
--select * from echos;

, lvef_group as (
  select er.subject_id, 
    --er.hadm_id,
    --er.icustay_id,
    er.echo_dt,
   case when er.lvef_range like '%10%'
          or er.lvef_range like '%15%'
          or er.lvef_range like '%20%'
          or er.lvef_range like '%25%'
          or er.lvef_range like '%30%'
          or er.lvef_range like '-35%'
          or er.lvef_range like '35%'
          or lower(er.text) like '%systolic function is severely depressed%'
          or lower(er.text) like '%systolic function appears severely depressed%'
          or lower(er.text) like '%severe%systolic dysfunction%'
          or lower(er.text) like '%severe%left ventricular hypokinesis%'
          or lower(er.text) like '%severe%LV hypokinesis%'
    then 1 
    when er.lvef_range like '>35'
          or er.lvef_range like '?35'
          or er.lvef_range like '%39%'
          or er.lvef_range like '%40%'
          or er.lvef_range like '%45%'
          or er.lvef_range like '%50%'
          or er.lvef_range like '-55%'
          or lower(er.text) like '%systolic function is midly depressed%'
          or lower(er.text) like '%systolic function appears midly depressed%'
          or lower(er.text) like '%systolic function is moderately depressed%'
          or lower(er.text) like '%systolic function appears moderately depressed%'
          or lower(er.text) like '%systolic function appears broadly depressed%'
          or lower(er.text) like '%mild%systolic dysfunction%'
          or lower(er.text) like '%moderate%systolic dysfunction%'
    then 2 
    when er.lvef_range like '%55%'
          or er.lvef_range like '50%'
          or er.lvef_range like '%60%'
          or er.lvef_range like '%65%'
          or er.lvef_range like '%-70'
          or lower(er.text) like '%systolic function is normal%'
          or lower(er.text) like '%systolic function appears normal%'
    then 3 
    when er.lvef_range like '>70%'
          or er.lvef_range like '%75%'
          or er.lvef_range like '%80%'
          or er.lvef_range like '%85%'
          or lower(er.text) like '%%hyperdynamic%'
          or lower(er.text) like '%%hypercontractile%'
          or lower(er.text) like '%hyperkinetic%'
    then 4 else 0 end as lvef_group,
    er.text
  from echos er 
)
select subject_id, echo_dt, text from lvef_group where lvef_group = 4 and rownum < 20;

, early_echos as (
  select ae.subject_id,
    ae.hadm_id,
    ae.icustay_id,
    ae.echo_dt,
    replace(replace(ne.text, chr(13), ''), chr(10), '') text
    from all_echos ae
    join mimic2v25.noteevents ne 
      on ae.subject_id = ne.subject_id 
     and ae.charttime = ne.charttime
   where ne.category like 'ECHO_REPORT'
     and ae.echo_dt < -2
     
)
--select * from early_echos;

, discharge as (
  select ee.subject_id, 
    echo_dt,
    concat(ee.text, replace(replace(ne.text, chr(13), ''), chr(10), '')) echo_discharge
  from early_echos ee
  join mimic2v25.noteevents ne 
    on ee.subject_id = ne.subject_id
   and ee.hadm_id = ne.hadm_id
   and ne.category like 'DISCHARGE_SUMMARY'
)
select * from discharge where rownum < 25;