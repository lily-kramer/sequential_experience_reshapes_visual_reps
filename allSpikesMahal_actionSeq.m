function [spikesMahal_actionSeq] = allSpikesMahal_actionSeq(plotfig)

names={'230906_actionSeq.mat';...
    '230918_1_actionSeq.mat';...
    '230926_2_actionSeq.mat';...
    '230927_1_actionSeq.mat';...
    '230927_2_actionSeq.mat';...
    '230928_1_actionSeq.mat';...
    '230928_2_actionSeq.mat';...
    '231007_actionSeq.mat';...
    '231013_2_actionSeq.mat';...
    '250327_actionSeq.mat';...
    '250328_1_actionSeq.mat'};

numnames = length(names);

%% frequent=top row, infrequent=bottom row
% preallocate
meanMahals=NaN(2,numnames);
steMahals=NaN(2,numnames);
meanSpikes=NaN(2,numnames);
steSpikes=NaN(2,numnames);
infSpikes=[];
freqSpikes=[];
infMahals=[];
freqMahals=[];

for i = 1:numnames % step through files and get spikes and distances
    filename=names{i};
    
    [infspikes,infmahals,freqspikes,freqmahals] = getSpikesMahal_actionSeq(filename);
    is=infSpikes;
    im=infMahals;
    fs=freqSpikes;
    fm=freqMahals;
    
    % put all values in big list for stats...
    infSpikes=[is infspikes];
    freqSpikes=[fs freqspikes];
    infMahals=[im; infmahals];
    freqMahals=[fm; freqmahals];

    % get means and errors for this session
    meanMahals(2,i) = mean(infmahals);
    meanMahals(1,i) = mean(freqmahals);
    steMahals(2,i) = ste(infmahals);
    steMahals(1,i) = ste(freqmahals);
    meanSpikes(2,i) = mean(infspikes);
    meanSpikes(1,i) = mean(freqspikes);
    steSpikes(2,i) = ste(infspikes);
    steSpikes(1,i) = ste(freqspikes);

end

%% get p-values and effect sizes (if significant). Two sample t-tests
% population spike counts
% [~,spikesp_right]=ttest2(infSpikes,freqSpikes,"tail","right"); % H1: inf > freq
% [~,spikesp_left]=ttest2(infSpikes,freqSpikes,"tail","left");% H1: freq > inf
[~,spikesp_both]=ttest2(infSpikes,freqSpikes,"tail","both"); % H1: inf =/= freq

% mahal distanaces
[~,mahalsp]=ttest2(infMahals,freqMahals,"tail","right"); % H1: inf > freq
effect=meanEffectSize(infMahals,freqMahals);
mahEffect=effect{1,1};

%% save all data to one output structure
spikesMahal_actionSeq=struct("allFreqSpikes",freqSpikes,"allInfreqSpikes",infSpikes,"allFreqMahal",freqMahals,...
    "allInfreqMahals",infMahals,"meanMahals",meanMahals,"steMahals",steMahals,"meanCounts",meanSpikes,...
    "steSpikes",steSpikes,"pValueSpikes_both",spikesp_both,"pValueMahal",mahalsp,"EffectMahal",mahEffect);

%% -------------plotting-------------------------------

if plotfig==1   
   
  % figure 5a: mean population spike count for all sessions
    plotUnity_onlyMeans(meanSpikes,steSpikes,[9 16]);
    xlabel({'mean population spike count','frequent'});
    ylabel('infrequent');
    title('mean population spike count, all sessions');
   
    %figure 5b: mean mahal distance for all sessions
    plotUnity_onlyMeans(meanMahals,steMahals,[30 70]);
    xlabel({'mean distance','frequent'});
    ylabel('infrequent');
    title('mean Mahalanobis distance, all sessions');   

end


end