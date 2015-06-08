drop table hdlvef_control_vitals;
create table hdlvef_control_vitals as 

-------- HR --------
with hr_data as (
	select 
		ec.icustay_id
		, ch.charttime
		, ch.value1num as hr

	 from 
	 	tbrennan.hyperdynamic_control ec 
	 
	 left join 
	 	mimic2v26.chartevents ch on ec.icustay_id = ch.icustay_id 

	 where
	 	ch.itemid = 211 
	 	and ch.charttime <= ec.icustay_intime + 3
    and ch.value1num is not null

)

, hr_final as (
 	select distinct 
 		icustay_id
 		, first_value(hr) over (partition by icustay_id order by charttime asc) as hr_1st
 		, first_value(hr) over (partition by icustay_id order by hr asc) as hr_lowest
 		, first_value(hr) over (partition by icustay_id order by hr desc) as hr_highest
 	
 	from 
 		hr_data
 )

-------- MAP --------
, bp_data as (
	select 
		ec.icustay_id
		, ch.charttime
		, ch.value1num as mbp

	 from 
	 	tbrennan.hyperdynamic_control ec 
	 
	 left join 
	 	mimic2v26.chartevents ch on ec.icustay_id = ch.icustay_id 

	 where
	 	ch.itemid in (52,456)
	 	and ch.charttime <= ec.icustay_intime + 3
    and ch.value1num is not null
)

, bp_final as (
 	select distinct 
 		icustay_id
 		, first_value(mbp) over (partition by icustay_id order by charttime asc) as map_1st
 		, first_value(mbp) over (partition by icustay_id order by mbp asc) as map_lowest
 		, first_value(mbp) over (partition by icustay_id order by mbp desc) as map_highest
 	
 	from 
 		bp_data
 )

-------- TEMP --------
, temp_data as (
	select 
		ec.icustay_id
		, ch.charttime
		, case 
        when ch.itemid in (678,679) then round((ch.value1num-32)*5/9,2) 
        when ch.itemid in (676,677) then round(ch.value1num,2) 
      end as temp

	 from 
	 	tbrennan.hyperdynamic_control ec 
	 
	 left join 
	 	mimic2v26.chartevents ch on ec.icustay_id = ch.icustay_id 

	 where
	 	ch.itemid in (678,679,676,677)  
	 	and ch.charttime <= ec.icustay_intime + 3
    and ch.value1num is not null

)

, temp_final as (
 	select distinct 
 		icustay_id
 		, first_value(temp) over (partition by icustay_id order by charttime asc) as temp_1st
 		, first_value(temp) over (partition by icustay_id order by temp asc) as temp_lowest
 		, first_value(temp) over (partition by icustay_id order by temp desc) as temp_highest
 	
 	from 
 		temp_data
 )
 

------------------------
select distinct
	ec.icustay_id
	, hr.hr_1st
	, hr.hr_lowest
	, hr.hr_highest
	, bp.map_1st
	, bp.map_lowest
	, bp.map_highest
	, t.temp_1st
	, t.temp_lowest
	, t.temp_highest

from 
	tbrennan.hyperdynamic_control ec

left join 
	hr_final hr on hr.icustay_id = ec.icustay_id

left join 
	bp_final bp on bp.icustay_id = ec.icustay_id

left join 
	temp_final t on t.icustay_id = ec.icustay_id

order by icustay_id
;
