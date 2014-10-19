sqlplus tbrennan/tbrennanmimic2 <<EOF
set feedback off
set echo off
set sqlprompt ''
set pagesize 0
set underline off
set termout on
set linesize 10000
set long 22000
set numw 10
select
  hc.subject_id
  ,replace(replace(ne.text, chr(13), ''), chr(10), '') text
from 
  tbrennan.hyperdynamic_cohort hc
join
  mimic2v26.noteevents ne
    on ne.subject_id = hc.subject_id
where 
  ne.category = 'DISCHARGE_SUMMARY'
  and length(ne.text) > 10
  and hc.sepsis = 1
  and rownum < 20;

exit;
EOF