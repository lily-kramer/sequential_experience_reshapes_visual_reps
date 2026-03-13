function [infspikes,infmahals,freqspikes,freqmahals] = getSpikesMahal_actionSeq(filename)

load(filename,"baselineCounts","allSelfCounts","allFixationTrialNumbers","allSelfPositions","configByTrial");

%% exlcude noisy trials and channels. pass in full (128 channel) spikes
% baselinecounts and allSelfCounts come back trimmed to good fixations/V4 channels
[allSelfCounts,~,allFixationTrialNumbers,includefix,includetrials]=excludeTrialsAndChannels_actionSeq(baselineCounts,allSelfCounts,allFixationTrialNumbers);

%% if there were any fixations excluded, trim other structures to exclude them
if any(includefix==0)
    allSelfPositions=allSelfPositions(includefix);
    configByTrial=configByTrial(includetrials);
end

%% make list of configs and index of frequent/infrequent for all fixations
configs=unique(configByTrial);
numConfigs=length(configs);
trialsperconfig=NaN(1,numConfigs);
for i=1:numConfigs
    trialsperconfig(i)=sum(configByTrial==configs(i));
end
freq=round(trialsperconfig/max(trialsperconfig));
numfix=length(allSelfPositions);
allfreq=NaN(1,numfix);
configbyfix=NaN(1,numfix);
for i=1:numfix
    allfreq(i)=freq(configByTrial(allFixationTrialNumbers(i)));
    configbyfix(i)=configByTrial(allFixationTrialNumbers(i));
end

%% get all frequent and infrequent fixation spikes and mahal distances

% normalize for mahal distance
zcounts=zscore(allSelfCounts(:,:),0,2);

% get mahal distance
normMahal=mahal(zcounts',zcounts');

% isolate distances for frequent, infrequent
infmahals=normMahal(allfreq==0);
freqmahals=normMahal(allfreq==1);

%isolat population spike counts for all frequent, infrequent
infspikes=mean(allSelfCounts(:,allfreq==0),1); 
freqspikes=mean(allSelfCounts(:,allfreq==1),1);

end
