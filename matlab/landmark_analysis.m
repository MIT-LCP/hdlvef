function [cell_demog,cell_outcome,cell_icd9,cell_elix,cell_scores,cell_treats,cell_labs] = ...
    landmark_analysis(data,outcome,landmark)

clc; close all; 

%% Constants
servtype = {'MICU','CCU','SICU','CSRU'};

pressors = {'DOBUTAMINE','DOPAMINE','EPINEPHRINE','LEVOPHED',...
    'VASOPRESSIN','EPINEPHRINE','LEVOPHED_K','MILRINONE',...
    'NEOSYNEPHRINE','NEOSYNEPHRINE_K'};

icd9 = {'CARDIOVASCULAR','RESPIRATORY','CANCER','ENDOCRINE_METABOLIC',...
        'GI','GU','TRAUMA','TREATMENT'};

elixhauser = {'DIABETES','CHF','ALCOHOL_ABUSE','ARRHYTHMIAS',...
    'VALVULAR_DISEASE','HYPERTENSION','RENAL_FAILURE','CHRONIC_PULMONARY',...
    'LIVER_DISEASE','CANCER','PSYCHOSIS','DEPRESSION'};

labs = {'LACTATE','WBC','CREATENIN'};

demog = {'AGE','GENDER','CARESERVICE'};

scores = {'SOFA_D1','SOFA_D2','SOFA_D3','SOFA_ECHO','SAPSI_D1','SAPSI_D2','SAPSI_D3','SAPSI_ECHO'};

treatments = {'RRT','VASOPRESSORS','VENTILATED',...
              'FLUIDS_IN','FLUIDS_OUT','MAX_PRESSOR_DOSE',...
              'MAX_PRESSOR_DURATION'};

outcomes = {'ICU_LOS','HOSP_LOS','MORTALITY_28D','ONE_YEAR_MORTALITY',...
    'ICUSTAY_MORTALITY','HOSPITAL_MORTALITY'};

%paramLabels_elix{j-24} = strcat('~~~',str1(1),lower(strrep(str1(2:end),'_',' ')));
%paramLabels_elix{j-24} = strcat('~~~',(strrep(str1(1:end),'_',' ')));
    

%% Extract data

% load cohort with IDs and demographics information
if ischar(data)
    data = csv2cell(data,'fromfile');
end

% extract header
header = data(1,:);

% remove header
data = data(2:end,:);
[N,L] = size(data);

% Find unique ids based on ICU ID
ids = -1;
idx = find_column(header,'ICUSTAY_ID');
for i = 2 : N
    ids = [ids; str2double(data{i,idx})];
end
[~,ind] = unique(ids); ind(1) = []; ind = ind(:)';

% Extract data into subgroup analysis
group = [];
sepsis = [];
data_demog = [];
data_outcomes = [];
data_icd9 = [];
data_elix = [];
data_scores = [];
data_treats = [];
data_pressors = [];
data_labs = [];
for i = ind
    
    % Group
    group = [group; str2double(data{i,find_column(header,upper(outcome))})];
    
    % Sepsis
    sepsis = [sepsis; str2double(data{i,find_column(header,'SEPSIS')})];
    
    % Patient demographics
    p_demog = [];
    demog_labels = {};
    demog_methods = {};
    for n = 1 : length(demog)
        switch demog{n}
            case 'AGE'
                p_demog = [p_demog, str2double(data{i,find_column(header,demog{n})})];
                str1 = demog{n};
                demog_labels = [demog_labels, strcat(str1(1),lower(str1(2:end)))];
                demog_methods = [demog_methods, which_method(demog{n})];
            case 'GENDER'
               p_demog = [p_demog, strcmp(data{i,find_column(header,demog{n})},'M')]; 
                demog_labels = [demog_labels, 'Male'];
                demog_methods = [demog_methods, which_method(demog{n})];
            case 'CARESERVICE'
               p_demog = [p_demog, servtype2id(data{i,find_column(header,'CARESERVICE')})];
               for m = 1 : length(servtype)
                   demog_labels = [demog_labels, ['~~~',servtype{m}]];
                   demog_methods = [demog_methods, which_method(servtype{m})];
               end

        end  
    end
    data_demog = [data_demog; p_demog];

    % Patient outcomes
    p_outcomes = [];
    outcomes_labels = {};
    outcomes_methods = {};
    for n = 1 : length(outcomes)
        if ~strcmp(upper(outcome),outcomes{n})
            p_outcomes = [p_outcomes, str2double(data{i,find_column(header,outcomes{n})})];
            outcomes_methods = [outcomes_methods, which_method(outcomes{n})];
            switch outcomes{n}
                case 'ICU_LOS'
                    outcomes_labels = [outcomes_labels, '~~~ICU Length of Stay'];
                case 'HOSP_LOS'
                    outcomes_labels = [outcomes_labels, '~~~Hosp. Length of Stay'];
                case 'MORTALITY_28D'
                    outcomes_labels = [outcomes_labels, '~~~28 Day'];
                case 'ONE_YEAR_MORTALITY'
                    outcomes_labels = [outcomes_labels, '~~~One Year'];
                case 'ICUSTAY_MORTALITY'
                    outcomes_labels = [outcomes_labels, '~~~ICU'];
                case 'HOSPITAL_MORTALITY'
                    outcomes_labels = [outcomes_labels, '~~~Hospital'];
            end
        end
    end
    data_outcomes = [data_outcomes; p_outcomes];

    % Patient labs
    p_labs = [];
    labs_methods = {};
    labs_labels = {};
    for n = 1 : length(labs)
        p_labs = [p_labs, str2double(data{i,find_column(header,['MAX_',labs{n}])})];
        labs_methods = [labs_methods, which_method(labs{n})];
        labs_labels = [labs_labels, ['~~~Max.~',lower(labs{n})]];

        p_labs = [p_labs, str2double(data{i,find_column(header,['AVG_',labs{n}])})];
        labs_methods = [labs_methods, which_method(labs{n})];
        labs_labels = [labs_labels, ['~~~Avg.~',lower(labs{n})]];
    end
    data_labs = [data_labs; p_labs];        
    
    % Patient ICD9 codes
    p_icd9 = [];
    icd9_labels = {};
    icd9_methods = {};
    for n = 1 : length(icd9)
        p_icd9 = [p_icd9, str2double(data{i,find_column(header,['ICD9_',icd9{n}])})];
        icd9_labels = [icd9_labels, strcat('~~~',(strrep(lower(icd9{n}),'_',' ')))];
        icd9_methods = [icd9_methods, which_method(icd9{n})];
    end
    data_icd9 = [data_icd9; p_icd9];
     
    % Patient EliXhauser co-morbidities
    p_elix = [];
    elix_labels = {};
    elix_methods = {};
    for n = 1 : length(elixhauser)
        p_elix = [p_elix, str2double(data{i,find_column(header,['CM_',elixhauser{n}])})];
        elix_labels = [elix_labels, strcat('~~~',(strrep(lower(elixhauser{n}),'_',' ')))];
        elix_methods = [elix_methods, which_method(elixhauser{n})];
    end
    data_elix = [data_elix; p_elix];
        
    % Patient Physiology Scores
    p_scores = [];
    scores_labels = {};
    scores_methods = {};
    for n = 1 : length(scores)
        p_scores = [p_scores, str2double(data{i,find_column(header,scores{n})})];
        scores_labels = [scores_labels, strcat('~~~',(strrep(scores{n},'_',' ')))];
        scores_methods = [scores_methods, which_method(scores{n})];
    end
    data_scores = [data_scores; p_scores];
        
    % Patient Treatments
    p_treats = [];
    treats_labels = {};
    treats_methods = {};
    for n = 1 : length(treatments)
        p_treats = [p_treats, str2double(data{i,find_column(header,treatments{n})})];
        treats_methods = [treats_methods, which_method(treatments{n})];
        switch treatments{n}
           case 'RRT'
               treats_labels = [treats_labels, ['~~~',treatments{n}]];
           case 'VASOPRESSORS'
               treats_labels = [treats_labels, '~~~Vasopressor Therapy'];
           case 'VENTILATED'
               treats_labels = [treats_labels, '~~~Ventilated'];
           case 'FLUIDS_IN'
               treats_labels = [treats_labels, '~~~Fluids In'];
           case 'FLUIDS_OUT'
               treats_labels = [treats_labels, '~~~Fluids Out'];
           case 'MAX_PRESSOR_DOSE'
               treats_labels = [treats_labels, '~~~Max. Vasopressor Dose'];
           case 'MAX_PRESSOR_DURATION'
               treats_labels = [treats_labels, '~~~Max. Vasopressor Duration'];
        end               
    end
    data_treats = [data_treats; p_treats];
          
%     % Vasopressors
%     p_pressors = [];
%     pressors_labels = {};
%     pressors_methods = {};
%     for n = 1 : length(pressors)
%        p_pressors = [p_pressors, str2double(data{i,find_column(header,[pressors{n},'_DOSE'])})];
%        pressors_labels = [pressors_labels, ['~~~Dose ',lower(pressors{n})]];
%        pressors_methods = [pressors_methods, which_method(pressors{n})];
%        
%        p_pressors = [p_pressors, str2double(data{i,find_column(header,[pressors{n},'_DURATION'])})];
%        pressors_labels = [pressors_labels, ['~~~Duration ',lower(pressors{n})]];
%        pressors_methods = [pressors_methods, which_method(pressors{n})];
%        
%     end
%     data_pressors = [data_pressors; p_treats];
    
end

%% Get 2 distinct groups based on one of the outcomes

group_nonsepsis = sepsis == 0;
    group = group(group_nonsepsis);
    data_treats(group_nonsepsis,:) = [];
    data_scores(group_nonsepsis,:) = [];
    data_elix(group_nonsepsis,:) = [];
    data_icd9(group_nonsepsis,:) = [];
    data_labs(group_nonsepsis,:) = [];
    data_outcomes(group_nonsepsis,:) = [];
    data_demog(group_nonsepsis,:) = [];
    %data_pressors(group_nonsepsis,:) = [];
end
N1 = sum(group == 0);
N2 = sum(group == 1);

%% Compare groups based on demographic variables
fprintf('Demographics\n');
[cell_demog] = comparegroups(data_demog,group,demog_labels,demog_methods);

fprintf('Outcomes\n');
[cell_outcome] = comparegroups(data_outcomes,group,outcomes_labels,outcomes_methods);

fprintf('ICD9\n');
[cell_icd9] = comparegroups(data_icd9,group,icd9_labels,icd9_methods);

fprintf('Elixhauser\n');
[cell_elix] = comparegroups(data_elix,group,elix_labels,elix_methods);

fprintf('Labs\n');
[cell_labs] = comparegroups(data_labs,group,labs_labels,labs_methods);

fprintf('Scores\n');
[cell_scores] = comparegroups(data_scores,group,scores_labels,scores_methods);

fprintf('Treatments\n');
[cell_treats] = comparegroups(data_treats,group,treats_labels,treats_methods);

% fprintf('Vasopressors\n');
% pressors_labels
% pressors_methods
% [cell_pressors] = comparegroups(data_treats,group,pressors_labels,pressors_methods);

%% Compare groups based on scores and Elixhauser components
if strcmp(upper(cohort),'SEPSIS')
    filename = '../report/table_sepsis_hyperdynamic_vs_normal.tex';
    labelname = sprintf('Characteristics of septic patients (n = %d).',length(group));
else
    filename = '../report/table_hyperdynamic_vs_normal.tex';
    labelname = sprintf('Characteristics of all study patients (n = %d).',length(group));
end


dolatextable(filename,labelname,[N1 N2],cell_demog,cell_outcome,cell_icd9,cell_elix,cell_scores,cell_treats,cell_labs);
