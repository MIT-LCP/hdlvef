select u.subject_id,
    replace(replace(ne.text, chr(13), ''), chr(10), '') text
  from tbrennan.hyperdynamic_unclassified u
  left join mimic2v25.noteevents ne
    on u.icustay_id = ne.icustay_id
      and ne.category like 'ECHO_REPORT'
  where ne.text is not null;