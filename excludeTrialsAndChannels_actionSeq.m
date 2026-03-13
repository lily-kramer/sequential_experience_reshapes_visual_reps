function [allSelfCounts,baselineCounts,allFixationTrialNumbers,includefix,includetrials]=excludeTrialsAndChannels_actionSeq(baselineCounts,allSelfCounts,allFixationTrialNumbers)
%% find noisy channels and trials. exclude them. 

% get the intial number of fixations (before exclusions)
initialnumfix=size(allSelfCounts,2);
% get the initial number of channels
numchannels=size(allSelfCounts,1);

%% exclude fixations with large shared noise over the population (>3stds away from pop. mean)
if 1
    avtmp=mean(allSelfCounts,1); % average over the population for each trial
    includefix=abs(zscore(avtmp)) < 3; % mark those over 3stds away from average population response
    includetrials=unique(allFixationTrialNumbers(includefix));
    if sum(includefix)<initialnumfix
        %disp('fixation(s) excluded > stds away from mean population resp');
        % trim allSelfCounts and baselineCounts to include only good fixations
        allSelfCounts=allSelfCounts(:,includefix);
        allFixationTrialNumbers=allFixationTrialNumbers(includefix);
    end
end

%% exclude channels with mean stimulus response < 10% greater than mean baseline
if 1
    thresh=1.10;
    trialAveragedResp=mean(allSelfCounts,2); %mean stimulus resp. for each unit over all fixations
    baselineAveragedResp=mean(baselineCounts,2); %mean baseline resp. for each unit over all trials
    goodunits=trialAveragedResp>thresh*baselineAveragedResp;
    if sum(goodunits)<numchannels
        %disp('channel(s) excluded due to < 10% greater stimulus evoked response');
        allSelfCounts=allSelfCounts(goodunits,:); % trim to goodunits
        baselineCounts=baselineCounts(goodunits,:); % trim to goodunits
    end
end

%% exclude channels with outlandishly different spike counts over first and
% second half of session (channel died)
if 1
    thresh=2.5; % 2.5x more spikes in first half...
    numfix=size(allSelfCounts,2);
    halffix=floor(numfix/2);
    starthalf=halffix+1;
    countsratio=NaN(1,size(allSelfCounts,1));
    for u=1:size(allSelfCounts,1) % step through remaining channels
        countsratio(u)=sum(allSelfCounts(u,1:halffix))/sum(allSelfCounts(u,starthalf:end));
        if countsratio(u) >= thresh
            %disp('channel excluded due to channel dying during session...');
        end
    end
    goodunits=countsratio<thresh; % trim to good channels
    allSelfCounts=allSelfCounts(goodunits,:);
    baselineCounts=baselineCounts(goodunits,:);
    %% check for completely dead channels (those with no spikes: <10 spikes over all trials)
    allSpikesThisChan=sum(allSelfCounts,2);
    goodunits=allSpikesThisChan>10; % get those that have < 10 spikes over all fixations
    if any(goodunits==0)
        %disp('channel(s) excluded because they have 0 spikes ever (dead)');
        allSelfCounts=allSelfCounts(goodunits,:);
        baselineCounts=baselineCounts(goodunits,:);
    end
end

end
