function [pval, CI1, CI2] = testMeans(x,y)

% Conduct Wilcoxon rank sum test
[~,pval] = ttest2(x,y);
[~,~,CI1,~] = ttest(x);
CI1 = [nanmean(x) CI1'];
[~,~,CI2,~] = ttest(y);
CI2 = [nanmean(y) CI2'];

end