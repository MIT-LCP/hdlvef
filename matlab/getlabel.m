function label = getlabel(header)

label = '';
withspace = 1;

switch header
    case 'GENDER'
        label = 'Male'; withspace = 0;
    case 'AGE'
        label = 'Age'; withspace = 0;
    case {'DOBUTAMINE','DOPAMINE','EPINEPHRINE','LEVOPHED',...
    'VASOPRESSIN','EPINEPHRINE','LEVOPHED_K','MILRINONE',...
    'NEOSYNEPHRINE','NEOSYNEPHRINE_K','LACTATE','CREATENIN',...
    'VASOPRESSOR','VENTILATED','FLUIDS_IN','FLUIDS_OUT',...
    'MAX_PRESSOR_DOSE','MAX_PRESSOR_DURATION',...
    'MAX_LACTATE','MAX_WBC','MAX_CREATENIN',...
    'AVG_LACTATE','AVG_WBC','AVG_CREATENIN'}
        label = strcat(header(1),lower(strrep(header(2:end),'_',' ')));
    case {'ICD9_CARDIOVASCULAR','ICD9_RESPIRATORY','ICD9_CANCER',...
            'ICD9_ENDOCRINE_METABOLIC','ICD9_TRAUMA','ICD9_TREATMENT'}
        label = strcat(header(6),lower(strrep(header(7:end),'_',' ')));
    case 'ICD9_GI'
        label = 'Gastrointestinal';
    case 'ICD9_GU'
        label = 'Genitourinary';
    case {'CM_DIABETES','CM_ALCOHOL_ABUSE','CM_ARRHYTHMIAS',...
        'CM_VALVULAR_DISEASE','CM_HYPERTENSION','CM_RENAL_FAILURE','CM_CHRONIC_PULMONARY',...
        'CM_LIVER_DISEASE','CM_CANCER','CM_PSYCHOSIS','CM_DEPRESSION'}
        label = strcat(header(4),lower(strrep(header(5:end),'_',' ')));
    case 'CM_CHF'
        label = 'CHF'
    case {'ELIX_28D_PT','MORTALITY_28D'}
        label = 'Twenty-eight day mortality';
    case {'ELIX_1YR_PT','ONE_YEAR_MORTALITY'}
        label = 'One-year mortality';
    case 'ELIX_2YR_PT'
        label = 'Two-year mortality';
    case 'ELIX_SURV_PT'
        label = 'Survival mortality';
    case {'WBC','SAPSI','RRT'}
        label = header;
    case {'MICU','CCU','SICU','CSRU'}
        label = header;
    case {'SOFA','SAPS'}
        label = 'First';
    case 'SOFA_D1'
        label = 'Day 1';
    case 'SOFA_D2'
        label = 'Day 2';
    case 'SOFA_D3'
        label = 'Day 3';
    case 'SOFA_ECHO'
        label = 'Day of Echo';
    case 'SAPS_D1'
        label = 'Day 1';
    case 'SAPS_D2'
        label = 'Day 2';
    case 'SAPS_D3'
        label = 'Day 3';
    case 'SAPS_ECHO'
        label = 'Day of Echo';
    case 'ICU_LOS'
        label = 'ICU Length of Stay';
    case 'HOSP_LOS'
        label = 'Hosp. Length of Stay';
    case 'ICUSTAY_MORTALITY'
        label = 'ICU Mortality';
    case 'HOSPITAL_MORTALITY'
        label = 'Hospital Mortality';
end

if withspace,
    label = strcat('~~~',label);
end