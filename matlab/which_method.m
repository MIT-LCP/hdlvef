function method = which_method(label)

method = '';
switch label
    case {'GENDER','SEPSIS','MICU','CCU','SICU','CSRU','FICU',...
          'HYPERDYNAMIC','MORTALITY_28D','ONE_YEAR_MORTALITY',...
          'ICUSTAY_MORTALITY','HOSPITAL_MORTALITY',...
          'ICD9_CARDIOVASCULAR','ICD9_RESPIRATORY','ICD9_CANCER',...
          'ICD9_ENDOCRINE_METABOLIC','ICD9_TRAUMA','ICD9_TREATMENT',...
          'ICD9_GI','ICD9_GU',...
          'CM_DIABETES','CM_CHF','CM_ALCOHOL_ABUSE','CM_ARRHYTHMIAS',...
          'CM_VALVULAR_DISEASE','CM_HYPERTENSION','CM_RENAL_FAILURE','CM_CHRONIC_PULMONARY',...
          'CM_LIVER_DISEASE','CM_CANCER','CM_PSYCHOSIS','CM_DEPRESSION',...
          'RRT','VASOPRESSOR','VENTILATED'}
        method = 'prop';
    case {'ELIX_28D_PT','ELIX_1YR_PT','ELIX_2YR_PT','ELIX_SURV_PT',...
          'AGE','ICU_LOS','HOSP_LOS','SOFA','SAPS','SOFA_ECHO','SAPS_ECHO',...
          'SOFA_D1','SOFA_D2','SOFA_D3','SAPS_D1','SAPS_D2','SAPS_D3',...
          'DOBUTAMINE','DOPAMINE','EPINEPHRINE','LEVOPHED',...
          'VASOPRESSIN','EPINEPHRINE','LEVOPHED_K','MILRINONE',...
          'NEOSYNEPHRINE','NEOSYNEPHRINE_K',...
          'FLUIDS_IN','FLUIDS_OUT','MAX_PRESSOR_DOSE',...
          'MAX_PRESSOR_DURATION','LACTATE','WBC','CREATENIN',...
          'MAX_LACTATE','MAX_WBC','MAX_CREATENIN',...
          'AVG_LACTATE','AVG_WBC','AVG_CREATENIN'}
        method = 'median';
end

