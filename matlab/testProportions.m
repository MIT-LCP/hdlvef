function [pval, CI1, CI2] = testProportions(n1,N1,n2,N2)

p1 = n1/N1*100;
p2 = n2/N2*100;

p1_ = (n1+2)/(N1+4);
p2_ = (n2+2)/(N2+4);
CI1 = [p1_-1.96*sqrt(p1_*(1-p1_)/(N1+4)) p1_+1.96*sqrt(p1_*(1-p1_)/(N1+4))];
CI2 = [p2_-1.96*sqrt(p2_*(1-p2_)/(N2+4)) p2_+1.96*sqrt(p2_*(1-p2_)/(N2+4))];
if CI1(1) < 0, CI1(1) = 0; end
if CI1(2) > 1, CI1(2) = 1; end
if CI2(1) < 0, CI2(1) = 0; end
if CI2(2) > 1, CI2(2) = 1; end

% Conduct Chi-squared test to compare proportions
x1 = [repmat('a',N1,1); repmat('b',N2,1)];
x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];
[tbl,chi2stat,pval] = crosstab(x1,x2);

CI1 = [n1, p1, CI1*100];
CI2 = [n2, p2, CI2*100];

end