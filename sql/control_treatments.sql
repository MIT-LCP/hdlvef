drop table hdlvef_control_treatments;
create table hdlvef_control_treatments as

with ventilated as (
  select distinct 
    fc.icustay_id
    , 1 ventilated

  from 
    tbrennan.hyperdynamic_control fc

  left join 
    mimic2v26.chartevents ce
      on fc.icustay_id = ce.icustay_id

  where ce.itemid in (720, 722)
  and ce.charttime between fc.icustay_intime and fc.icustay_intime + 3
)
--select * from ventilated;

, vasopressors_raw as (

  select distinct 
    
    cd.icustay_id
    , m.charttime
    , m.dose
    , case 
        when m.itemid in (42) and m.dose >= 20 then 1
        when m.itemid in (42) and m.dose < 20 then m.dose/20
        when m.itemid in (43) and m.dose >= 15 then 1
        when m.itemid in (43) and m.dose < 15 then m.dose/15
        when m.itemid in (44, 119) and m.dose >= 0.125 then 1
        when m.itemid in (44, 119) and m.dose < 0.125 then m.dose/0.125
        when m.itemid in (47,120) and m.dose >= 3 then 1
        when m.itemid in (47,120) and m.dose < 3 then m.dose/3
        when m.itemid in (51) and m.dose >= 0.03 then 1
        when m.itemid in (51) and m.dose < 0.03 then m.dose/0.03
        when m.itemid in (125) and m.dose >= 0.75 then 1
        when m.itemid in (125) and m.dose < 0.75 then m.dose/0.75
        when m.itemid in (127, 128) and m.dose >= 9.1 then 1
        when m.itemid in (127, 128) and m.dose < 9.1 then m.dose/9.1
      end as adjusted_dose
    , case 
        when m.itemid in (42) then 'DOBUTAMINE'
        when m.itemid in (43) then 'DOPAMINE'
        when m.itemid in (44, 119) then 'EPINEPHRINE' 
        when m.itemid in (47,120) then 'LEVOPHED'
        when m.itemid in (51) then 'VASOPRESSIN'
        when m.itemid in (125) then 'MILRINONE'
        when m.itemid in (127, 128) then 'NEOSYNEPHRINE' 
      end as vasopressor
    , case when m.itemid in (42, 43, 44, 47, 51, 119, 120, 125, 127, 128) 
        then 1 else 0
      end as on_vasopressors
  
  from 
    tbrennan.hyperdynamic_control cd
  
  join 
    mimic2v26.medevents m on cd.icustay_id = m.icustay_id 
    
  where 
    m.itemid in (42, 43, 44, 47, 51, 119, 120, 125, 127, 128)
    and m.charttime between cd.icustay_intime and cd.icustay_intime + 3
    and m.dose<>0
)
--select count(*) from vasopressors group_by icustay_id; -- count icustay_id 3813
--select * from vasopressors_raw where icustay_id = 4;

, vasopressor_timings as (
  
  select distinct 
    icustay_id
    , vasopressor
    , first_value(charttime) over (partition by icustay_id, vasopressor order by charttime) first_pressortime
    , first_value(charttime) over (partition by icustay_id, vasopressor order by charttime desc) last_pressortime

  from 
    vasopressors_raw
  
)
--select * from vasopressor_timings; -- count icustay_id 2632

, vasopressor_dosing as (

  select distinct 
    icustay_id
    , vasopressor
    , max(adjusted_dose) max_dose
    , avg(adjusted_dose) avg_dose
    
  from
    vasopressors_raw
    
  group by 
    icustay_id
    , vasopressor

)
--select * from vasopressor_dosing;

, vasopressor_therapy as (

  select distinct 
    vt.icustay_id
    , vt.vasopressor
    , vt.first_pressortime
    , extract(day from vt.first_pressortime) start_day
    , vt.last_pressortime
    , extract(day from vt.last_pressortime) end_day
    , first_value(vt.first_pressortime) over (partition by vt.icustay_id order by vt.first_pressortime) start_pressors        
    , extract(day from vt.last_pressortime - vt.first_pressortime)*24
        + extract(hour from vt.last_pressortime - vt.first_pressortime) 
        + extract(minute from vt.last_pressortime - vt.first_pressortime)/60 dose_duration
    , vd.max_dose
    , vd.avg_dose
    
  from 
    vasopressor_timings vt
    
  join 
    vasopressor_dosing vd
      on vt.icustay_id = vd.icustay_id
      and vt.vasopressor = vd.vasopressor
)
--select * from vasopressor_therapy where icustay_id = 309;

, num_vasopressors as (
  
  select distinct 
    icustay_id
    , max(num_vasopressors) num_vasopressors
  from 
  (
    select distinct
      icustay_id
      , start_day
      , count(*) num_vasopressors
      
    from 
      vasopressor_therapy
    
    group by 
      icustay_id
      , start_day
  )

  group by 
    icustay_id

)
--select * from num_vasopressors;

, vasopressors as (
  
  select distinct
    vt.icustay_id
    , max(start_pressors) start_pressors
    , sum(vt.dose_duration) vasopressor_duration
    , round(sum(vt.max_dose),4) max_adjusteddose
  
  from vasopressor_therapy vt
  
  group by 
    icustay_id
)
--select * from vasopressors;

-- fluids in
, fluids_in_72 as (
  select distinct fc.icustay_id,
    round(sum(tb.cumvolume) over (partition by fc.icustay_id),2) fi_3d_ml
  from tbrennan.hyperdynamic_control fc
  left join mimic2v26.totalbalevents tb
    on fc.icustay_id = tb.icustay_id
    and tb.itemid = 1
    and extract(day from tb.charttime - fc.icustay_intime) < 3
)
--select * from fluids_in; count icustay_id 2632

, fluids_in_24 as (
  select distinct fc.icustay_id,
    round(sum(tb.cumvolume) over (partition by fc.icustay_id),2) fi_1d_ml
  from tbrennan.hyperdynamic_control fc
  left join mimic2v26.totalbalevents tb
    on fc.icustay_id = tb.icustay_id
    and tb.itemid = 1
    and extract(day from tb.charttime - fc.icustay_intime) < 1
)

-- fluids out
, fluids_out_72 as (
  select distinct fc.icustay_id,
    round(sum(tb.cumvolume) over (partition by fc.icustay_id),2) fo_3d_ml
  from tbrennan.hyperdynamic_control fc
  left join mimic2v26.totalbalevents tb
    on fc.icustay_id = tb.icustay_id
    and tb.itemid = 2
    and extract(day from tb.charttime - fc.icustay_intime) < 3
)
--select * from fluids_out; -- count icustay_id 2632

, fluids_out_24 as (
  select distinct fc.icustay_id,
    round(sum(tb.cumvolume) over (partition by fc.icustay_id),2) fo_1d_ml
  from tbrennan.hyperdynamic_control fc
  left join mimic2v26.totalbalevents tb
    on fc.icustay_id = tb.icustay_id
    and tb.itemid = 2
    and extract(day from tb.charttime - fc.icustay_intime) < 1
)
--select * from fluids_out; -- count icustay_id 2632


, assemble as (

  select distinct 

      ec.icustay_id
      , case 
        when rc.rrt = '1' then '1' else '0'
      end as rrt
      , case 
          when vt.ventilated is null then 0 else 1
      end as ventilated
      , fi.fi_1d_ml
      , fi.fi_3d_ml
      , fo.fo_1d_ml
      , fo.fo_3d_ml
      , case 
          when nv.num_vasopressors is null then 0 else nv.num_vasopressors 
      end as num_vasopressors
      , case 
          when vp.max_adjusteddose is null then 0 else vp.max_adjusteddose
      end as max_vasopressor_adjusteddose
      , case 
          when vp.vasopressor_duration is null then 0 else vp.vasopressor_duration
      end as vasopressor_duration
      , vp.start_pressors
      
      
    from tbrennan.hyperdynamic_control ec

    left join tbrennan.rrt_cohort rc on rc.icustay_id = ec.icustay_id

    left join ventilated vt on vt.icustay_id = ec.icustay_id

    left join fluids_in_24 fi on fi.icustay_id = ec.icustay_id

    left join fluids_in_72 fi on fi.icustay_id = ec.icustay_id

    left join fluids_out_24 fo on fo.icustay_id = ec.icustay_id

    left join fluids_out_72 fo on fo.icustay_id = ec.icustay_id

    left join vasopressors vp on vp.icustay_id = ec.icustay_id

    left join num_vasopressors nv on nv.icustay_id = ec.icustay_id

)
--select icustay_id, count(*) from assemble group by icustay_id having count(*) > 1;
select * from assemble; -- rows 2632
