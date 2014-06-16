select count(*) from tbrennan.mimic2v26_echo_groups where echo_during_icustay = 0;

select count(distinct subject_id) from tbrennan.mimic2v26_echo_groups; -- 4672
select count(distinct icustay_id) from tbrennan.mimic2v26_echo_groups; -- 5070

-- supressed lvef
select count(distinct subject_id) from tbrennan.mimic2v26_echo_groups where lvef = 1 or lvef = 2; -- 1790
select count(distinct icustay_id) from tbrennan.mimic2v26_echo_groups where lvef = 1 or lvef = 2; -- 1887

-- normal and hyperdynamic lvef
select count(distinct subject_id) from tbrennan.mimic2v26_echo_groups where lvef = 3 or lvef = 4; -- 2435
select count(distinct icustay_id) from tbrennan.mimic2v26_echo_groups where lvef = 3 or lvef = 4; -- 2583

-- can't determine lvef
select count(distinct subject_id) from tbrennan.mimic2v26_echo_groups where lvef = 0; -- 911
select count(distinct icustay_id) from tbrennan.mimic2v26_echo_groups where lvef = 0; -- 939
