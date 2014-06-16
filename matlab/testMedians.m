function [pval, CI1, CI2] = testMedians(x,y)

% Conduct Wilcoxon rank sum test
pval = ranksum(x,y);
CI1 = prctile(x,[50 2.5 97.5]);
CI2 = prctile(y,[50 2.5 97.5]);

end