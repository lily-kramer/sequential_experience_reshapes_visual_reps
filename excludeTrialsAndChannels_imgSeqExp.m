function [stimcounts,basecounts,trialNumberIDX,allStimIDs,includetrials]=excludeTrialsAndChannels_imgSeqExp(stimcounts,basecounts,trialNumberIDX,allStimIDs,monkey)
% do noisy trial and channel exclusion

     % exclude trials/presentations with large shared noise over population
    if 1
        avtmp = mean(stimcounts,1); % average over pop for each trial
        include = abs(zscore(avtmp)) < 3; % exclude if over 3 stds.
        includetrials = unique(trialNumberIDX(include));
        if length(includetrials)<max(trialNumberIDX)
            %disp('trial(s) excluded >3stds away from mean')
        end
        goodpres = find(ismember(trialNumberIDX,includetrials));
        stimcounts = stimcounts(:,goodpres); % trim
        basecounts = basecounts(:,includetrials);
        allStimIDs = allStimIDs(goodpres);
        trialNumberIDX = trialNumberIDX(goodpres);
    end
    % exclude channels with  mean stim resposonse < 10% greater than mean baseline
    if 1 
        thresh=1.10; 
        if monkey == "XE"     % ** change for M4 **
            % get half the spikes in stim counts to match the 100ms
            % basecount window (due to shortened prestimfix)
            goodunits=(mean(stimcounts./2,2)>thresh*mean(basecounts,2));
        else
            goodunits=(mean(stimcounts,2)>thresh*mean(basecounts,2));
        end
        stimcounts = stimcounts(goodunits,:);
        basecounts = basecounts(goodunits,:);
    end
    %exlclude channels with outlandishly different # spikes over first vs.
    %second half of session (e.g., V4chan 27 in ZI230913short_1to7trim)
    if 1
        thresh=2.5;% 2.5x more spikes in 1st half
        numPres = size(stimcounts,2);
        halfPres = floor(numPres/2);
        startHalf=halfPres+1;
        countsratio = NaN(1,size(stimcounts,1));
        for n = 1:size(stimcounts,1)
            countsratio(n) = sum(stimcounts(n,1:halfPres))/sum(stimcounts(n,startHalf:end));
            if countsratio(n) >= thresh
                %disp('WARNING: channel excluded due to weird noise (massive difference in 1st/2nd half spike count)')
            end
        end
        goodunits=countsratio<thresh;
        stimcounts = stimcounts(goodunits,:);
    end
    
% check for completely dead channels (those with no spikes: <10 spikes over all trials)
    allSpikesThisChan=sum(stimcounts,2);
    goodunits=allSpikesThisChan>10; % get those that have < 10 spikes over all fixations
    if any(goodunits==0)
        % disp('channel(s) excluded because they are (dead)')
        stimcounts=stimcounts(goodunits,:);
        basecounts=basecounts(goodunits,:);
    end

% numBad = length(channelstouse) - length(goodunits);
% sprintf('%d channel(s) excluded',numBad)

end
