--drop table hyperdynamic_vasopressors;
--create table hyperdynamic_vasopressors as

with vasopressor_all as (

  select distinct 

    cd.icustay_id
    ,m.dose
    ,case 
      when m.itemid in (42) then 'DOBUTAMINE'
      when m.itemid in (43) then 'DOPAMINE'
      when m.itemid in (44, 119) then 'EPINEPHRINE' 
      when m.itemid in (47,120) then 'LEVOPHED'
      when m.itemid in (51) then 'VASOPRESSIN'
      when m.itemid in (125) then 'MILRINONE'
      when m.itemid in (127, 128) then 'NEOSYNEPHRINE' 
    end as vasopressor
  
  from tbrennan.hyperdynamic_cohort cd
  
  join mimic2v26.medevents m on cd.icustay_id = m.icustay_id
  
  where 
      m.itemid in (42,43,44,47,51,119,120,125,127,128) 
      and m.dose <> 0 
      and extract(day from (m.charttime)) + extract(hour from (m.charttime))/24 + extract(minute from (m.charttime))/60/24
        between extract(day from (cd.icustay_intime)) + extract(hour from (cd.icustay_intime))/24 + extract(minute from (cd.icustay_intime))/60/24 + cd.echo_dt -1 
        and  extract(day from (cd.icustay_intime)) + extract(hour from (cd.icustay_intime))/24 + extract(minute from (cd.icustay_intime))/60/24 + cd.echo_dt
)
--select * from vasopressor_all where rownum < 20; -- count icustay_id 2,632

, vasopressor_count as (
  select 
    icustay_id,
    count(*) no_vasopressors
  from
    (
    select distinct
      icustay_id
      ,vasopressor
    from vasopressor_all
    )
  group by 
    icustay_id
)
--select * from vasopressor_count where rownum < 20;

, vasopressor_max as (

  select *
  
  from 
      (select * from vasopressor_all) 
        pivot (
        max(dose)
            for vasopressor in ('DOBUTAMINE' as DOBUTAMINE,
                                'DOPAMINE' as DOPAMINE,
                                'EPINEPHRINE' as EPHINEPHRINE,
                                'LEVOPHED' as LEVOPHED,
                                'VASOPRESSIN' as VASOPRESSIN,
                                'MILRINONE' as MILRINONE,
                                'NEOSYNEPHRINE' as NEOSYNEPHRINE)
        )
)
--select max(milrinone) from vasopressor_max;

, vasopressor_maxadjusted as (
  select distinct icustay_id,
  
  case 
    when dobutamine is null then 0 
    when dobutamine > 20 then 1
    else dobutamine/20
  end as dobutamine,
  case 
    when dopamine is null then 0 
    when dopamine > 15 then 1
    else dopamine/15
  end as dopamine,
  case 
    when ephinephrine is null then 0 
    when ephinephrine > 0.125 then 1
    else ephinephrine/0.125
  end as ephinephrine,
  case 
    when vasopressin is null then 0 
    when vasopressin > 0.03 then 1
    else vasopressin/0.03
  end as vasopressin,
  case 
    when levophed is null then 0 
    when levophed > 3 then 1
    else levophed/3
  end as levophed,
  case 
    when milrinone is null then 0 
    when milrinone > 0.5 then 1
    else milrinone/0.5
  end as milrinone,
  case 
    when neosynephrine is null then 0 
    when neosynephrine > 9.1 then 0 
    else neosynephrine/9.1
  end as neosynephrine
  
  from vasopressor_max
  
)

select ma.icustay_id
  ,round(ma.dobutamine+ma.dopamine+ma.ephinephrine+ma.vasopressin+ma.levophed+ma.milrinone+ma.neosynephrine,5) vassopressor_adjusteddose
  ,vc.no_vasopressors
from vasopressor_maxadjusted ma
join vasopressor_count vc on vc.icustay_id = ma.icustay_id;
