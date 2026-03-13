function [includeTrials,goodunits] = excludeNoisyTrialsChan_imgExp(baselineCounts,stimCounts,shortCounts)

numUnits=size(baselineCounts,1);
 %% exclude trials/presentations with large shared noise over population
    if 1
        avtmp = mean(stimCounts,1); % average over pop for each trial
        includeTrials = logical(abs(zscore(avtmp)) < 3.5); % exclude if over 3 stds.
    end

%% exclude unresponsive/dead channels 
    if 1 
        stimCounts = stimCounts(:,includeTrials);
        shortCounts = shortCounts(:,includeTrials);
        baselineCounts = baselineCounts(:,includeTrials);
        % split trial count in half
        halfn = floor(size(stimCounts,2)/2);
        goodunits = [];

        % mark responsive channels (>%15 increased response to stimulus)
        thresh=1.15; 
        responsive=(mean(shortCounts,2)>thresh*mean(baselineCounts,2));
        
        % mark dead channels (average of < 5 spikes (during 800 ms stim on)
        dead = mean(stimCounts,2) < 5;

        % mark channels dying within a session
        activeDeath = zeros(numUnits,1);
        for u = 1:numUnits
            %unit = channels(u);
            halvedFirstHalfSum = 0.5*sum(stimCounts(u,1:halfn));
            secondHalfSum = sum(stimCounts(u,halfn+1:end));
            % mark dying if (sum of counts in first half)/2
            % is greater than sum all counts in second half
            if halvedFirstHalfSum > secondHalfSum
                activeDeath(u) = 1;
            end

        % update goodUnits based on all 3 labels (responsive,dead,dying)
            if activeDeath(u)==0 && dead(u)==0 % not dead or dying
                if responsive(u)==1 % passed threshold
                    goodunits = [goodunits u]; %mark it good
                end
            end
        end
        

    end

    % report how many units excluded:
    % numBad = length(channels) - length(goodunits);
    % sprintf('%d channel(s) excluded',numBad)

end