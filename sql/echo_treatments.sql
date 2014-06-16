drop table hyperdynamic_treatments;
create table hyperdynamic_treatments as

with ventilated as (
  select distinct fc.icustay_id,
    case 
      when ce.charttime is null then 0 else 1
    end as ventilated 
  from tbrennan.hyperdynamic_cohort fc
  left join mimic2v26.chartevents ce
    on fc.icustay_id = ce.icustay_id
    and ce.itemid in (720, 722)
)
--select count(*) from ventilation;

-- vasopressor therapy
, vasopressors as (
  select distinct cd.icustay_id,
    case when m.itemid in (42, 43, 44, 47, 51, 119, 120, 125, 127, 128) and m.dose<>0
      then 1 else 0
    end as vasopressors
    from tbrennan.hyperdynamic_cohort cd
    left join mimic2v26.medevents m on cd.icustay_id = m.icustay_id 
)
--select count(*) from vasopressors group_by icustay_id; -- count icustay_id 3813

, vasopressor_therapy as (
  select distinct icustay_id,
    first_value(vasopressors) over (partition by icustay_id order by vasopressors desc) vasopressor
    from vasopressors
)
--select count(*) from vasopressor_therapy; -- count icustay_id 2632

, vasopressor_all as (
  select distinct cd.icustay_id,
  case when m.itemid in (42) and m.dose<>0
      then 1 else 0 end as Dobutamine,
  case when m.itemid in (43) and m.dose<>0
      then 1 else 0 end as Dopamine,
  case when m.itemid in (44, 119) and m.dose<>0
      then 1 else 0 end as Epinephrine, 
  case when m.itemid in (47,120) and m.dose<>0
      then 1 else 0 end as Levophed, 
  case when m.itemid in (51) and m.dose<>0
      then 1 else 0 end as Vasopressin, 
  case when m.itemid in (125) and m.dose<>0
      then 1 else 0 end as Milrinone, 
  case when m.itemid in (127, 128) and m.dose<>0
      then 1 else 0 end as Neosynephrine  
    from tbrennan.hyperdynamic_cohort cd
    left join mimic2v26.medevents m on cd.icustay_id = m.icustay_id
    where extract(day from (m.charttime)) + extract(hour from (m.charttime))/24 + extract(minute from (m.charttime))/60/24
      between extract(day from (cd.icustay_intime)) + extract(hour from (cd.icustay_intime))/24 + extract(minute from (cd.icustay_intime))/60/24 + cd.echo_dt -1 
      and  extract(day from (cd.icustay_intime)) + extract(hour from (cd.icustay_intime))/24 + extract(minute from (cd.icustay_intime))/60/24 + cd.echo_dt
)
--select count(distinct icustay_id) from vasopressor_all; -- count icustay_id 2,632

, vasopressor_detail as (
  select distinct icustay_id,
    max(dobutamine) over (partition by icustay_id) Dobutamine,
    max(dopamine) over (partition by icustay_id) Dopamine,
    max(epinephrine) over (partition by icustay_id) Epinephrine,
    max(vasopressin) over (partition by icustay_id) Vasopressin,
    max(levophed) over (partition by icustay_id) Levophed,
    max(milrinone) over (partition by icustay_id) Milrinone,
    max(neosynephrine) over (partition by icustay_id) Neosynephrine
    from vasopressor_all
)
--select * from vasopressor_detail;

-- fluids in
, fluids_in as (
  select distinct fc.icustay_id,
    round(sum(tb.cumvolume) over (partition by fc.icustay_id),2) fi_1d_ml
  from tbrennan.echo_cohort fc
  left join mimic2v26.totalbalevents tb
    on fc.icustay_id = tb.icustay_id
    and tb.itemid = 1
    and extract(day from tb.charttime - fc.icustay_intime) < 1
)
--select * from fluids_in; count icustay_id 2632

-- fluids out
, fluids_out as (
  select distinct fc.icustay_id,
    round(sum(tb.cumvolume) over (partition by fc.icustay_id),2) fo_1d_ml
  from tbrennan.hyperdynamic_cohort fc
  left join mimic2v26.totalbalevents tb
    on fc.icustay_id = tb.icustay_id
    and tb.itemid = 2
    and extract(day from tb.charttime - fc.icustay_intime) < 1
)
--select * from fluids_out; -- count icustay_id 2632

, assemble as (
  select distinct ec.icustay_id,
      case 
        when rc.rrt = '1' then '1' else '0'
      end as rrt,
      vt.ventilated,
      fi.fi_1d_ml,
      fo.fo_1d_ml,
      vp.vasopressor,
      pw.dobutamine,
      pw.dopamine,
      pw.epinephrine,
      pw.vasopressin,
      pw.levophed,
      pw.milrinone,
      pw.neosynephrine
    from tbrennan.hyperdynamic_cohort ec
    left join tbrennan.rrt_cohort rc on rc.icustay_id = ec.icustay_id
    left join ventilated vt on vt.icustay_id = ec.icustay_id
    left join fluids_in fi on fi.icustay_id = ec.icustay_id
    left join fluids_out fo on fo.icustay_id = ec.icustay_id
    left join vasopressor_therapy vp on vp.icustay_id = ec.icustay_id
    left join vasopressor_detail pw on pw.icustay_id = ec.icustay_id
)
--select icustay_id, count(*) from assemble group by icustay_id having count(*) > 1;
select * from assemble; -- rows 2632
