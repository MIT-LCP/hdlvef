function dolatextable_sens(filename,Ni,cell_demog,cell_outcome,cell_icd9,cell_elix,...
        cell_elix_pt,cell_scores,cell_treats,cell_labs,...
        cell_acute_demog,cell_acute_outcome,cell_acute_icd9,cell_acute_elix,...
        cell_acute_elix_pt,cell_acute_scores,cell_acute_treats,cell_acute_labs)

FID = fopen(filename, 'w');
fprintf(FID, '\\caption{Sensitivity anlysis showing p-values of proportional characteristics with and without chronic hyperdynamic patients.}\n');
fprintf(FID, '\\centerline{\\small \n');
fprintf(FID, '\\begin{tabular}{l c c}\n');
fprintf(FID, '\\toprule\n');
fprintf(FID, '& All Patients & Without Chronic Hyperdynamic \\\\ \n');
fprintf(FID, '& (n=%d) & (n=%d) \\\\ \n',Ni(1),Ni(2));
fprintf(FID, '\\hline\n');

%demog_labels = {'AGE', 'MALE', 'MICU', 'CCU', 'SICU', 'CSRU','FICU'};
fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_demog{2,1}, ...
        cell_demog{2,4}, cell_acute_demog{2,4});
fprintf(FID, 'Service type: & & \\\\ \n');
for i = 1 : 4
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_demog{2+i,1}, ...
        cell_demog{2+i,4}, cell_acute_demog{2+i,4});
end


%outcomes = {'ICU_LOS','HOSP_LOS','MORTALITY_28D','ONE_YEAR_MORTALITY',...
%    'ICUSTAY_MORTALITY','HOSPITAL_MORTALITY'};
fprintf(FID, 'Primary outcomes: & & \\\\ \n');
for i = 3 : 6
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_outcome{i,1}, ...
        cell_outcome{i,4}, cell_acute_outcome{i,4});
end

%treatments = {'RRT','VASOPRESSORS','VENTILATED','FLUIDS_IN','FLUIDS_OUT',...
%              'MAX_PRESSOR_DOSE','MAX_PRESSOR_DURATION'};
fprintf(FID, 'Treatments: & & \\\\ \n');
for i = 1:3
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_treats{i,1}, ...
        cell_treats{i,4}, cell_acute_treats{i,4});
end

fprintf(FID, '\\bottomrule\n');
fprintf(FID, '\\end{tabular}\n');
fprintf(FID, '}\n');
fclose(FID);

%% File 2
FID = fopen(strcat(filename(1:end-4),'_median.tex'), 'w');
fprintf(FID, '\\caption{Sensitivity analysis showing p-value of continuous characteristics with and without patients.}\n');
fprintf(FID, '\\centerline{\\small \n');
fprintf(FID, '\\begin{tabular}{l c c}\n');
fprintf(FID, '\\toprule\n');
fprintf(FID, '& All Patients & Without Chronic Hyperdynamic \\\\ \n');
fprintf(FID, '& (n=%d) & (n=%d) \\\\ \n',Ni(1),Ni(2));
fprintf(FID, '\\hline\n');

%demog_labels = {'AGE', 'MALE', 'MICU', 'CCU', 'SICU', 'CSRU','FICU'};
if cell_demog{1,4} < 0.001
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_demog{1,1}, ...
        cell_demog{1,4}, cell_acute_demog{1,4});
end

%outcomes = {'ICU_LOS','HOSP_LOS','MORTALITY_28D','ONE_YEAR_MORTALITY',...
%    'ICUSTAY_MORTALITY','HOSPITAL_MORTALITY'};
fprintf(FID, 'Secondary outcomes: & & \\\\ \n');
for i = 1 : 2
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_outcome{i,1}, ...
        cell_outcome{i,4}, cell_acute_outcome{i,4});
end

%scores = {'SOFA','SOFA_D1','SOFA_D2','SOFA_D3','SAPS','SAPS_D1','SAPS_D2','SAPS_D3'};
fprintf(FID, 'SOFA Scores: & & \\\\ \n');
for i = 1 : 4
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_scores{i,1}, ...
        cell_scores{i,4}, cell_acute_scores{i,4});
end
fprintf(FID, 'SAPS-I Scores: & & \\\\ \n');
for i = 5 : 8
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_scores{i,1}, ...
        cell_scores{i,4}, cell_acute_scores{i,4});
end

% labs = {'LACTATE','WBC','CREATENIN'};
fprintf(FID, 'Lab Tests (first 3 days): & & \\\\ \n');
for i = 1 : size(cell_labs,1)
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_labs{i,1}, ...
        cell_labs{i,4}, cell_acute_labs{i,4});
end

% elix_pt = {'ELIX_28D_PT','ELIX_1YR_PT','ELIX_2YR_PT'};
fprintf(FID, 'Elixhauser Points: & & \\\\ \n');
for i = 1 : size(cell_elix_pt,1)
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_elix_pt{i,1}, ...
        cell_elix_pt{i,4}, cell_acute_elix_pt{i,4});
end

%treatments = {'RRT','VASOPRESSORS','VENTILATED','FLUIDS_IN','FLUIDS_OUT',...
%              'MAX_PRESSOR_DOSE','MAX_PRESSOR_DURATION'};
fprintf(FID, 'Treatments (first 3 days): & & \\\\ \n');
for i = 4 : 7
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_treats{i,1}, ...
        cell_treats{i,4}, cell_acute_treats{i,4});
end

fprintf(FID, '\\bottomrule\n');
fprintf(FID, '\\end{tabular}\n');
fprintf(FID, '}\n');
fclose(FID);

%% File 3

FID = fopen(strcat(filename(1:end-4),'_icd9.tex'), 'w');
fprintf(FID, '\\caption{Sensitivity analysis showing P-values for ICD9 Group and Elixhauser comorbidities with and without chronic hyperdynamic patients.}\n');
fprintf(FID, '\\centerline{\\small \n');
fprintf(FID, '\\begin{tabular}{l c c}\n');
fprintf(FID, '& All Patients & Without Chronic Hyperdynamic \\\\ \n');
fprintf(FID, '& (n=%d) & (n=%d) \\\\ \n',Ni(1),Ni(2));
fprintf(FID, '\\toprule\n');
fprintf(FID, '\\hline\n');

%icd9 = {'CARDIOVASCULAR','RESPIRATORY','CANCER','ENDOCRINE_METABOLIC',...
%        'GI','GU','TRAUMA','TREATMENT'};
fprintf(FID, 'ICD9 Group: & & \\\\ \n');
for i = 1 : size(cell_icd9)
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_icd9{i,1}, ...
        cell_icd9{i,4}, cell_acute_icd9{i,4});
end

fprintf(FID, '\\hline\n');

%elixhauser = {'DIABETES','CHF','ALCOHOL_ABUSE','ARRHYTHMIAS',...
%    'VALVULAR_DISEASE','HYPERTENSION','RENAL_FAILURE','CHRONIC_PULMONARY',...
%    'LIVER_DISEASE','CANCER','PSYCHOSIS','DEPRESSION'};
fprintf(FID, 'Elixhauser Comorbidity: & & \\\\ \n');
for i = 1 : size(cell_elix)
    fprintf(FID, '%s & %.3f & %.3f \\\\ \n',cell_elix{i,1}, ...
        cell_elix{i,4}, cell_acute_elix{i,4});
end

fprintf(FID, '\\bottomrule\n');
fprintf(FID, '\\end{tabular}\n');
fprintf(FID, '}\n');
fclose(FID);
