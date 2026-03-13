function [spikeMahal_imgSeqExp] = allSpikesAndMahal_imgSeqExp(plotfig)
% Get population spike and mahalanbois distance data for each session.
% Plot if desired (plotfig=1). Save data to output structure.

names={'230913_ZI_short.mat';...   %M3
    '230927_ZI_short.mat';...
    '231002_ZI_short.mat';...
    '250509_ZI_short.mat';...
    '241218_XE_short.mat';... %M4
    '250107_XE_1short.mat';...
    '250107_XE_2short.mat';...
    '250318_HE_short.mat';... %M5
    '250325_HE_short.mat';...
    '250319_HE_short.mat'};

numnames=length(names);
numMonks=3;
monkList=["ZI","XE","HE"];
fileID=["ZI" "ZI" "ZI" "ZI" "XE" "XE" "XE" "HE" "HE" "HE"];

%% preallocate
monkID=[];
allMahals=[];
allSpikes=[];
allBMahals=[];
allBSpikes=[];
% session summary stats are [expected(D) unexpected(D')]
allMeanCounts=NaN(numnames,2);
allSteCounts=NaN(numnames,2);
allMeanMahal=NaN(numnames,2);
allSteMahal=NaN(numnames,2);


%% get info for each session
for i = 1:numnames
    filename=names{i};
    monkey=fileID(i);
    if plotfig==1&&i==2
        % plot figures 2b,d
        [mahals,spikes,Bmahals,Bspikes]=getSpikesMahal_imgSeqExp(filename,1,monkey);
    else
        [mahals,spikes,Bmahals,Bspikes]=getSpikesMahal_imgSeqExp(filename,0,monkey);
    end    

    % data from all pairs this session
    allMahals=[allMahals; mahals];
    allSpikes=[allSpikes; spikes];
    allBMahals=[allBMahals; Bmahals];
    allBSpikes=[allBSpikes; Bspikes];
    monkID=[monkID; repmat(monkey,size(mahals,1),1)];
    
    %means and error over all pairs this session...
    allMeanCounts(i,1)=mean(spikes(:,1));
    allMeanCounts(i,2)=mean(spikes(:,2));
    allMeanMahal(i,1)=mean(mahals(:,1));
    allMeanMahal(i,2)=mean(mahals(:,2));
    allSteCounts(i,1)=ste(spikes(:,1));
    allSteCounts(i,2)=ste(spikes(:,2));
    allSteMahal(i,1)=ste(mahals(:,1));
    allSteMahal(i,2)=ste(mahals(:,2));  

end


%% significance tests and effect sizes for all spikes, mahal distances

% preallocate
Dspikes_pValue=NaN(1,numMonks); 
Dspikes_effect=NaN(1,numMonks);
Dmahal_pValue=NaN(1,numMonks); 
Dmahal_effect=NaN(1,numMonks);
Bspikes_pValue=NaN(1,numMonks); 
Bmahal_pValue=NaN(1,numMonks);

for m=1:numMonks % step through monkeys
    monk=monkList(m);

    %% D vs D'
    % get p values, H1: unexpected > expected
    [~,pSp]=ttest(allSpikes(matches(monkID,monk),2),allSpikes(matches(monkID,monk),1),'Tail','right');
    Dspikes_pValue(1,m)=pSp;
    [~,pMa]=ttest(allMahals(matches(monkID,monk),2),allMahals(matches(monkID,monk),1),'Tail','right');
    Dmahal_pValue(1,m)=pMa;
    % get effect sizes
    effSp=meanEffectSize(allSpikes(matches(monkID,monk),2),allSpikes(matches(monkID,monk),1),Paired=true,Effect="robustcohen");
    Dspikes_effect(1,m)=effSp.Effect;
    effMa=meanEffectSize(allMahals(matches(monkID,monk),2),allMahals(matches(monkID,monk),1),Paired=true,Effect="robustcohen");
    Dmahal_effect(1,m)=effMa.Effect;

    %% B vs B prior D'
    % get p values, H1: unexpected > expected
    [~,pSp]=ttest(allBSpikes(matches(monkID,monk),2),allBSpikes(matches(monkID,monk),1),'Tail','right');
    Bspikes_pValue(1,m)=pSp;
    [~,pMa]=ttest(allBMahals(matches(monkID,monk),2),allBMahals(matches(monkID,monk),1),'Tail','right');
    Bmahal_pValue(1,m)=pMa;
   
end

%% save data to output structure
spikeMahal_imgSeqExp=struct('allMahals_D',allMahals,'allSpikes_D',allSpikes,'allMahals_B',allBMahals,'allSpikes_B',...
    allBSpikes,'mIDpairs',monkID,'meanSpikeCounts',allMeanCounts,'meanMahalDist',allMeanMahal,...
    'steSpikeCounts',allSteCounts,'steMahalDist',allSteMahal,'pValsSpikes_D',Dspikes_pValue,...
    'pValsSpikes_B',Bspikes_pValue,'pValsMahals_D',Dmahal_pValue,'pValsMahals_B',Bmahal_pValue,...
    'effectSpikes',Dspikes_effect,'effectMahal',Dmahal_effect);

%% ---------------------------plotting------------------------
if plotfig==1

    % figure 2c: population spike counts plots
    plotUnity_withPairs(allSpikes,allMeanCounts,allSteCounts,monkID,fileID,[5 40]);
    xlabel('D mean spike count');
    ylabel('D'' mean spike count');
    title('mean population spike count, all sessions');

    % figure 2e: mahalanobis distance
    plotUnity_withPairs(allMahals,allMeanMahal,allSteMahal,monkID,fileID,[10 85]);
    xlabel('D mean distance');
    ylabel('D'' mean distance');
    title('mean mahalanobis distance, all sessions');

end


end


