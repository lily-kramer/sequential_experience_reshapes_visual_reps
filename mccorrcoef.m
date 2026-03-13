function[r,p]=mccorrcoef(a,b,outlierthresh)

if nargin==2
    outlierthresh= 3; %100; % number of standard devs. away
end

a(abs(nanzscore(a))>outlierthresh)=nan;
b(abs(nanzscore(b))>outlierthresh)=nan;

[tmp,ptmp]=corrcoef(a,b,'rows','pairwise');
if length(tmp)==2
    r=tmp(1,2);
    p=ptmp(1,2);
else
    r=nan;
    p=nan;
end