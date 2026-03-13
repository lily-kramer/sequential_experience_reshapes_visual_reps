function[orderPerf, varfirstdim, freq, numexp]=getMoveOrderDecoding(filename)

% load(filename,"allSelfPositions","allChoiceCounts","allFixationTrialNumbers",...
%     "configByTrial","startLocation","rewardLocation","fixTime");
load(filename,"allChoiceCounts","baselineCounts","allFixationTrialNumbers","configByTrial","fixTime");


% get already trimmed counts, included trials and fixations
[allChoiceCounts,~,allFixationTrialNumbers,includefix,includetrials]=excludeTrialsAndChannels_actionSeq(baselineCounts,allChoiceCounts,allFixationTrialNumbers);

%% if there were any fixations excluded, trim other structures to exclude them
if any(includefix==0)
    %allSelfPositions=allSelfPositions(includefix);
    configByTrial=configByTrial(includetrials);
    %startLocation=startLocation(includetrials);
    %rewardLocation=rewardLocation(includetrials);
    fixTime=fixTime(includetrials);
end

configs=unique(configByTrial);
numroutes=length(configs);
trialsperroute=NaN(1,numroutes);
for i=1:numroutes
    trialsperroute(i)=sum(configByTrial==configs(i));
end
freq=round(trialsperroute/max(trialsperroute));
numtrials=length(fixTime);
exposurenum=NaN(1,numtrials);
numexp=ones(4,1);
numfix=length(allFixationTrialNumbers);
stimnum=NaN(1,numfix);
configbyfix=NaN(1,numfix);
for i=1:numtrials
    these=find(allFixationTrialNumbers==i);
    exposurenum(i)=numexp(configByTrial(i));
    numexp(configByTrial(i))=numexp(configByTrial(i))+1;
    stimnum(these)=1:length(these);
    configbyfix(these)=configByTrial(i);
end

resps=cell(4,3); %rows = config, 
orderPerf=NaN(4,1);
varfirstdim=NaN(4,1);
for i=1:4
    for j=1:3
        resps{i,j}=allChoiceCounts(:,configbyfix==i&stimnum==j)';
    end
    result = orderedCCGP_ABC(resps(i,:));
    orderPerf(i)=result.orderedCCGP;
    varfirstdim(i)=result.rank1Frac;
    
end




