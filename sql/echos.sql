drop materialized view mimic2v26_adult_echo_groups;
create materialized view mimic2v26_adult_echo_groups as

/*
with unclassified_text as (

  select lu.subject_id, 
    lu.icustay_id,
    round(ne.charttime - id.icustay_intime,4) echo_dt,
    replace(replace(ne.text, chr(13), ''), chr(10), '') text
    from tbrennan.hyperdynamic_unclassified lu
    join mimic2v25.icustay_detail id 
      on lu.subject_id = id.subject_id
      and id.subject_icustay_seq = 1
    join mimic2v25.noteevents ne 
      on lu.subject_id = ne.subject_id
      and ne.charttime + 7 > id.icustay_intime 
      and ne.charttime < id.hospital_disch_dt
    where ne.category like 'ECHO_REPORT'
)
select * from unclassified_text;
--select count(distinct icustay_id) from unclassified_text;
*/
    
with adults as (

  select distinct id.subject_id, 
      id.icustay_id, 
      id.subject_icustay_seq,
      id.icustay_intime,
      id.hospital_disch_dt
    from mimic2v25.icustay_detail id 
    where id.icustay_id is not null
        and id.icustay_age_group = 'adult'
)
--select * from adults;
--select count(distinct subject_id) from adults; -- 12,845 icustay_id, subjects

, echo_reports as (

  select fc.subject_id, 
    fc.icustay_id, 
    fc.subject_icustay_seq,
    fc.icustay_intime,
    ne.charttime echo_time,
    round(ne.charttime - fc.icustay_intime,4) echo_dt,
    substr(ne.text,regexp_instr(ne.text,'[[:digit:]]{2}\%')-1,4) lvef_range,
    replace(replace(ne.text, chr(13), ''), chr(10), '') text
    from adults fc
    join mimic2v25.noteevents ne 
      on fc.subject_id = ne.subject_id
      and ne.charttime - fc.icustay_intime > -7
      and ne.charttime < fc.hospital_disch_dt
    where ne.category like 'ECHO_REPORT'
      and ne.text is not null
)
--select * from echo_reports;
--select count(distinct icustay_id) from echo_reports; -- 4655 subject_id, 5063 icustay_id




, lvef_group as (
  select er.subject_id, er.icustay_id,
    er.subject_icustay_seq,
    er.icustay_intime,
    er.echo_time,
    er.echo_dt,
   case 
    when er.lvef_range like '%10%'
          or er.lvef_range like '%15%'
          or er.lvef_range like '%20%'
          or er.lvef_range like '%25%'
          or er.lvef_range like '%30%'
          or er.lvef_range like '-35%'
          or er.lvef_range like '35%'
          or lower(er.text) like '%contractile function is%severely reduced%'
          or lower(er.text) like '%systolic function is severely depressed%'
          or lower(er.text) like '%systolic function appears severely depressed%'
          or lower(er.text) like '%systolic function appears depressed%'
          or lower(er.text) like '%systolic function is severely impaired%'
          or lower(er.text) like '%left ventricle is moderately-to-severely reduced%'
          or lower(er.text) like '%severe%systolic dysfunction%'
          or lower(er.text) like '%severe%left ventricular hypokinesis%'
          or lower(er.text) like '%severe%LV hypokinesis%'
          or lower(er.text) like '%depressed lvef%'
      then 1 else 0
    end as lvef1,
    case 
      when er.lvef_range like '>35'
          or er.lvef_range like '?35'
          or er.lvef_range like '%39%'
          or er.lvef_range like '%40%'
          or er.lvef_range like '%45%'
          or er.lvef_range like '%50%'
          or er.lvef_range like '-55%'
          or lower(er.text) like '%systolic function is mildly depressed%'
          or lower(er.text) like '%systolic function appears mildly depressed%'
          or lower(er.text) like '%systolic function is moderately depressed%'
          or lower(er.text) like '%systolic function is moderately%impaired%'
          or lower(er.text) like '%systolic function appears moderately depressed%'
          or lower(er.text) like '%systolic function appears broadly depressed%'
          or lower(er.text) like '%mild-moderate global left ventricular hypokinesis%'
          or lower(er.text) like '%moderate%left ventricular hypokinesis%'
          or lower(er.text) like '%moderate%lv hypokinesis%'
          or lower(er.text) like '%mild global lv hypokinesis%'
          or lower(er.text) like '%mild global left ventricular hypokinesis%'
          or lower(er.text) like '%mild%systolic dysfunction%'
          or lower(er.text) like '%moderate%systolic dysfunction%'
          or lower(er.text) like '%mildy depressed lvef%'

      then 1 else 0
    end as lvef2,
    case 
      when er.lvef_range like '%55%'
          or er.lvef_range like '50%'
          or er.lvef_range like '%60%'
          or er.lvef_range like '%65%'
          or er.lvef_range like '%-70'
          or lower(er.text) like '%lv segments contract normally%'
          or lower(er.text) like '%lv contracts normally%'
          or lower(er.text) like '%systolic function is good%'
          or lower(er.text) like '%systolic function is normal%'
          or lower(er.text) like '%systolic function is grossly normal%'
          or lower(er.text) like '%systolic function is probably normal%'
          or lower(er.text) like '%systolic function are normal%'
          or lower(er.text) like '%systolic function appears normal%'
          or lower(er.text) like '%systolic function appears preserved%'
          or lower(er.text) like '%systolic function appears grossly preserved%'
          or lower(er.text) like '%systolic function appears grossly normal%'
          or lower(er.text) like '%systolic function appear normal%'
          or lower(er.text) like '%contractile funciton are grossly preserved%'
      then 1 else 0
    end as lvef3,
    case 
      when er.lvef_range like '>70%'
          or er.lvef_range like '%75%'
          or er.lvef_range like '%80%'
          or er.lvef_range like '%85%'
          or lower(er.text) like '%%hyperdynamic%'
          or lower(er.text) like '%%hypercontractile%'
          or lower(er.text) like '%hyperkinetic%'
          or lower(er.text) like '%ejection fraction is increased%'
      then 1 else 0 
    end as lvef4,
    er.text
  from echo_reports er 
  order by icustay_id
)
--select * from lvef_group;
--select count(distinct icustay_id) from lvef_group where lvef_group = 0; --742 icustay_id
--select count(distinct icustay_id) from lvef_group where lvef_group = 1 or lvef_group = 2; -- 1568 icustay_id
--select count(distinct icustay_id) from lvef_group where lvef_group = 3 or lvef_group = 4; -- 2109 icustay_id

, lvef_class as (
  select subject_id, icustay_id, 
    subject_icustay_seq,
    icustay_intime,
    echo_time,
    echo_dt,
    case 
      when lvef4=1 then 4
      when lvef3=1 or subject_id in (1335, 4461, 6550, 11950, 16174, 17745, 18195, 19484, 20805, 21099, 26619) then 3
      when lvef2=1 or subject_id in (4897, 8623, 15474, 15876, 16013, 20827, 23172, 26568, 26619) then 2
      when lvef1=1 then 1
      when (lvef4=0 and lvef3=0 and lvef2=0 and lvef1=0) then 0
    end as lvef_group
    from lvef_group
    order by subject_id
)
--select * from lvef_class;

, lvef as (
  select distinct subject_id, 
    icustay_id,
    subject_icustay_seq,
    --first_value(icustay_intime) over (partition by icustay_id, echo_dt) icustay_intime,
    --first_value(echo_time) over (partition by icustay_id, echo_dt) echo_time,
    first_value(echo_dt) over (partition by icustay_id, echo_dt) echo_dt,
    max(lvef_group) over (partition by icustay_id, echo_dt) lvef_group
    from lvef_class
    where lvef_group is not null
    order by icustay_id
)
select * from lvef;
--select count(distinct icustay_id) from lvef where lvef_group is null; --749




