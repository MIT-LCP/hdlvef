function [cell_demog,cell_outcome,cell_icd9,cell_elix,cell_scores,cell_treats,cell_labs] = ...
    explore_data(data,outcome,subgroup,landmark,sensitivity)

clc; close all; 

if nargin < 3
    subgroup = 0;
    landmark = 0;
    sensitivity = 0;
elseif nargin < 4
    landmark = 0;
    sensitivity = 0;
elseif nargin < 5
    sensitivity = 0;
end

%% Constants
pressors = {'DOBUTAMINE','DOPAMINE','EPINEPHRINE','LEVOPHED',...
    'VASOPRESSIN','EPINEPHRINE','LEVOPHED_K','MILRINONE',...
    'NEOSYNEPHRINE','NEOSYNEPHRINE_K'};

icd9 = {'ICD9_CARDIOVASCULAR','ICD9_RESPIRATORY','ICD9_CANCER','ICD9_ENDOCRINE_METABOLIC',...
        'ICD9_GI','ICD9_GU','ICD9_TRAUMA','ICD9_TREATMENT'};
    
elix_pt = {'ELIX_28D_PT','ELIX_1YR_PT','ELIX_2YR_PT'};

elixhauser = {'CM_DIABETES','CM_CHF','CM_ALCOHOL_ABUSE','CM_ARRHYTHMIAS',...
    'CM_VALVULAR_DISEASE','CM_HYPERTENSION','CM_RENAL_FAILURE','CM_CHRONIC_PULMONARY',...
    'CM_LIVER_DISEASE','CM_CANCER','CM_PSYCHOSIS','CM_DEPRESSION'};

labs = {'MAX_LACTATE','MAX_WBC','MAX_CREATENIN','AVG_LACTATE','AVG_WBC','AVG_CREATENIN'};

demog = {'AGE','GENDER','MICU','CCU','SICU','CSRU'};

scores = {'SOFA','SOFA_D1','SOFA_D2','SOFA_D3','SAPS','SAPS_D1','SAPS_D2','SAPS_D3'};

treatments = {'RRT','VASOPRESSOR','VENTILATED',...
              'FLUIDS_IN','FLUIDS_OUT','MAX_PRESSOR_DOSE',...
              'MAX_PRESSOR_DURATION'};

outcomes = {'SEPSIS','ICU_LOS','HOSP_LOS','MORTALITY_28D','ONE_YEAR_MORTALITY',...
            'ICUSTAY_MORTALITY','HOSPITAL_MORTALITY'};
    
%% Load data and extract header

% load cohort with IDs and demographics information
if ischar(data)
    data = csv2cell(data,'fromfile');
end

% extract header
header = data(1,:);

% remove header
data = data(2:end,:);
[N,L] = size(data);

%% Data analysis
group = extract_data(data,header,upper(outcome));
sepsis = extract_data(data,header,'SEPSIS');
data_demog = extract_data(data,header,demog);
data_outcomes = extract_data(data,header,outcomes);
data_icd9 = extract_data(data,header,icd9);
data_elix = extract_data(data,header,elixhauser);
data_elix_pt = extract_data(data,header,elix_pt);
data_scores = extract_data(data,header,scores);
data_treats = extract_data(data,header,treatments);
data_labs = extract_data(data,header,labs);

% Get 2 distinct groups based on one of the outcomes
N1 = sum(group == 0);
N2 = sum(group == 1);

% Compare groups based on demographic variables
fprintf('Demographics\n');
[cell_demog] = comparegroups(data_demog,group,demog);

% TODO - make sure secondary outcomes are for hospital survivors
fprintf('Outcomes\n');
[cell_outcome] = comparegroups(data_outcomes,group,outcomes);

fprintf('ICD9\n');
[cell_icd9] = comparegroups(data_icd9,group,icd9);

fprintf('Elixhauser Co-morbidities\n');
[cell_elix] = comparegroups(data_elix,group,elixhauser);

fprintf('Elixhauser Points\n');
[cell_elix_pt] = comparegroups(data_elix_pt,group,elix_pt);

fprintf('Labs\n');
[cell_labs] = comparegroups(data_labs,group,labs);

fprintf('Scores\n');
[cell_scores] = comparegroups(data_scores,group,scores);

fprintf('Treatments\n');
[cell_treats] = comparegroups(data_treats,group,treatments);

% Convert to LaTeX
filename = '../report/table_hyperdynamic_vs_normal.tex';
dolatextable(filename,'all',[N1 N2],cell_demog,cell_outcome,cell_icd9,cell_elix,cell_elix_pt,cell_scores,cell_treats,cell_labs);


%% Subgroup analysis
if subgroup,
    
    fprintf('\nSepsis: subgroup analysis\n');
    
    % Identify cohort
    septic = sepsis == 1;
    
    % Extract septic data
    septic_group = group(septic);
    septic_treats = data_treats(septic,:);
    septic_scores = data_scores(septic,:);
    septic_elix = data_elix(septic,:);
    septic_elix_pt = data_elix_pt(septic,:);
    septic_icd9 = data_icd9(septic,:);
    septic_labs = data_labs(septic,:);
    septic_outcomes = data_outcomes(septic,:);
    septic_demog = data_demog(septic,:);
    
    % Get 2 distinct groups based on one of the outcomes
    N1 = sum(septic_group == 0);
    N2 = sum(septic_group == 1);

    % Compare groups based on demographic variables
    fprintf('Demographics\n');
    [cell_demog] = comparegroups(septic_demog,septic_group,demog);

    fprintf('Outcomes\n');
    [cell_outcome] = comparegroups(septic_outcomes,septic_group,outcomes);

    fprintf('ICD9\n');
    [cell_icd9] = comparegroups(septic_icd9,septic_group,icd9);

    fprintf('Elixhauser Co-morbidities\n');
    [cell_elix] = comparegroups(septic_elix,septic_group,elixhauser);

    fprintf('Elixhauser Points\n');
    [cell_elix_pt] = comparegroups(septic_elix_pt,septic_group,elix_pt);

    fprintf('Labs\n');
    [cell_labs] = comparegroups(septic_labs,septic_group,labs);

    fprintf('Scores\n');
    [cell_scores] = comparegroups(septic_scores,septic_group,scores);

    fprintf('Treatments\n');
    [cell_treats] = comparegroups(septic_treats,septic_group,treatments);
    
    % Convert to LaTeX
    filename = '../report/table_sepsis_hyperdynamic_vs_normal.tex';
    dolatextable(filename,'sepsis',[N1 N2],...
        cell_demog,cell_outcome,cell_icd9,cell_elix,cell_elix_pt,...
        cell_scores,cell_treats,cell_labs);

end

%% Landmark Analysis
if landmark,
    
    fprintf('\nLandmark Analysis:\n');
    
    % Identify cohort
    survivors = data_outcomes(:,find_column(outcomes,'HOSPITAL_MORTALITY')) == 0;
    
    whos survivors
    
    % Excluded Extract data
    survivor_group = group(survivors);
    survivor_treats = data_treats(survivors,:);
    survivor_scores = data_scores(survivors,:);
    survivor_elix = data_elix(survivors,:);
    survivor_elix_pt = data_elix_pt(survivors,:);
    survivor_icd9 = data_icd9(survivors,:);
    survivor_labs = data_labs(survivors,:);
    survivor_outcomes = data_outcomes(survivors,:);
    survivor_demog = data_demog(survivors,:);
    
    % Get 2 distinct groups based on one of the outcomes
    N1 = sum(survivor_group == 0);
    N2 = sum(survivor_group == 1);

    % Compare groups based on demographic variables
    fprintf('Demographics\n');
    [cell_survivor_demog] = comparegroups(survivor_demog,survivor_group,demog);

    fprintf('Outcomes\n');
    [cell_survivor_outcome] = comparegroups(survivor_outcomes,survivor_group,outcomes);

    fprintf('ICD9\n');
    [cell_survivor_icd9] = comparegroups(survivor_icd9,survivor_group,icd9);

    fprintf('Elixhauser Co-morbidities\n');
    [cell_survivor_elix] = comparegroups(survivor_elix,survivor_group,elixhauser);

    fprintf('Elixhauser Points\n');
    [cell_survivor_elix_pt] = comparegroups(survivor_elix_pt,survivor_group,elix_pt);

    fprintf('Labs\n');
    [cell_survivor_labs] = comparegroups(survivor_labs,survivor_group,labs);

    fprintf('Scores\n');
    [cell_survivor_scores] = comparegroups(survivor_scores,survivor_group,scores);

    fprintf('Treatments\n');
    [cell_survivor_treats] = comparegroups(survivor_treats,survivor_group,treatments);
    
    % Convert to LaTeX
    filename = '../report/table_landmark_hyperdynamic_vs_normal.tex';
    dolatextable(filename,'hospital survivors',[N1 N2],...
        cell_survivor_demog,cell_survivor_outcome,cell_survivor_icd9,cell_survivor_elix,...
        cell_survivor_elix_pt,cell_survivor_scores,cell_survivor_treats,cell_survivor_labs);

end

%% Sensitivity Analysis
if sensitivity,
    
    fprintf('\nSensitivity Analysis:\n');
    
    % Identify cohort
    acute = extract_data(data,header,'CHRONIC_HYPERDYNAMIC') == 0;

    % Extract acute from data
    acute_group = group(acute);
    acute_treats = data_treats(acute,:);
    acute_scores = data_scores(acute,:);
    acute_elix = data_elix(acute,:);
    acute_elix_pt = data_elix_pt(acute,:);
    acute_icd9 = data_icd9(acute,:);
    acute_labs = data_labs(acute,:);
    acute_outcomes = data_outcomes(acute,:);
    acute_demog = data_demog(acute,:);
    
    % Get 2 distinct groups based on one of the outcomes
    N1 = sum(acute_group == 0);
    N2 = sum(acute_group == 1);

    % Compare groups based on demographic variables
    fprintf('Demographics\n');
    [cell_acute_demog] = comparegroups(acute_demog,acute_group,demog);

    fprintf('Outcomes\n');
    [cell_acute_outcome] = comparegroups(acute_outcomes,acute_group,outcomes);

    fprintf('ICD9\n');
    [cell_acute_icd9] = comparegroups(acute_icd9,acute_group,icd9);

    fprintf('Elixhauser Co-morbidities\n');
    [cell_acute_elix] = comparegroups(acute_elix,acute_group,elixhauser);

    fprintf('Elixhauser Points\n');
    [cell_acute_elix_pt] = comparegroups(acute_elix_pt,acute_group,elix_pt);

    fprintf('Labs\n');
    [cell_acute_labs] = comparegroups(acute_labs,acute_group,labs);

    fprintf('Scores\n');
    [cell_acute_scores] = comparegroups(acute_scores,acute_group,scores);

    fprintf('Treatments\n');
    [cell_acute_treats] = comparegroups(acute_treats,acute_group,treatments);
    
    % Convert to LaTeX
    filename = '../report/table_sens_hyperdynamic_vs_normal.tex';
    dolatextable_sens(filename,[length(group) length(acute_group)],...
        cell_demog,cell_outcome,cell_icd9,cell_elix,cell_elix_pt,...
        cell_scores,cell_treats,cell_labs,...
        cell_acute_demog,cell_acute_outcome,cell_acute_icd9,cell_acute_elix,...
        cell_acute_elix_pt,cell_acute_scores,cell_acute_treats,cell_acute_labs);

end
