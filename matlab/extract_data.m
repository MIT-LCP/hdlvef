function extract = extract_data(data,header,labels)

extract = [];

if ischar(labels)
    labels = {labels};
end

% iterate over all patients
for i = 1 : size(data,1)
    idd = [];
    
    % iterate over all labels
    for n = 1 : length(labels)
        x = [];
        
        % switch through data types
        switch labels{n}
            case 'GENDER'
               x = strcmp(data{i,find_column(header,labels{n})},'M');
            otherwise
               x = str2double(data{i,find_column(header,labels{n})}); 
        end
        idd = [idd, x]; 
    end
    
    extract = [extract; idd];
end
