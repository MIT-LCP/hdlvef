function [cell_name] = comparegroups(data,group,columns)

data0 = data(group==0,:); N0 = size(data0,1);
data1 = data(group==1,:);  N1 = size(data1,1);

D = length(columns);

fprintf('\nN1 = %d, N2 = %d\n\n',N0,N1);
for i = 1 : D
    method = which_method(columns{i});
    label = getlabel(columns{i});
    switch method
        case 'prop'
            n0 = sum(data0(~isnan(data0(:,i)),i));
            n1 = sum(data1(~isnan(data1(:,i)),i));
            [pval, CI0, CI1] = testProportions(n0,N0,n1,N1);
            fprintf('%s: (%s)\nGroup 0: %d, (%.1f)\nGroup 1: %d, (%.1f)\np-val = %.5f\n\n', ...
                label,method,CI0(1),CI0(2),CI1(1),CI1(2),pval);
            cell_name{i,1} = label;
            cell_name{i,2} = CI0;
            cell_name{i,3} = CI1;
            cell_name{i,4} = pval;

        case 'median'
            n0 = data0(~isnan(data0(:,i)),i);
            n1 = data1(~isnan(data1(:,i)),i);
            [pval, CI0, CI1] = testMedians(n0,n1);
            fprintf('%s: (%s)\nGroup 0: %.1f (%.1f-%.1f)\nGroup 1: %.1f (%.1f-%.1f)\np-val = %.5f\n\n', ...
                label,method,CI0(1),CI0(2),CI0(3),CI1(1),CI1(2),CI1(3),pval);
            cell_name{i,1} = label;
            cell_name{i,2} = CI0;
            cell_name{i,3} = CI1;
            cell_name{i,4} = pval;
            
        case 'mean'
            [pval, CI0, CI1] = testMeans(data0(:,i),data1(:,i));
            fprintf('%s: (%s)\nGroup 0: %.1f (%.1f-%.1f)\nGroup 1: %.1f (%.1f-%.1f)\np-val = %.5f\n\n', ...
                label,method,CI0(1),CI0(2),CI0(3),CI1(1),CI1(2),CI1(3),pval);
            cell_name{i,1} = label;
            cell_name{i,2} = CI0;
            cell_name{i,3} = CI1;
            cell_name{i,4} = pval;
    end
end
