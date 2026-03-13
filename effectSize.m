function [effect]=effectSize(x,y)

diff=(x-y);
meanDiff=mean(diff);
stdDevDiff=std(diff);
effect=meanDiff/stdDevDiff;

end