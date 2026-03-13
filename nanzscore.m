function[newx]=nanzscore(x)

x=x';

mu=nanmean(x);
sigma=nanstd(x);
sigma0 = sigma;
sigma0(sigma0==0) = 1;

z = bsxfun(@minus,x, mu);
newx = bsxfun(@rdivide, z, sigma0);
newx=newx';