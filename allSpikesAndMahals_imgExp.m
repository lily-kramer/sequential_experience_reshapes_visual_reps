function[spikeMahal_imgExp]=allSpikesAndMahals_imgExp(plotfig)

names={'1120_BA.mat',...% M1
    '1122_BA.mat',...
    '1204_BA.mat',...
    '1205_BA.mat',...
    '1206_BA.mat',...
    '1022_WA.mat',... %M2
    '1026_WA.mat',...
    '1027_WA.mat',...
    '1028_WA.mat'};

numMonks=2;
monkList=["BA","WA"];
fileID=["BA" "BA" "BA" "BA" "BA" "WA" "WA" "WA" "WA"];
numnames=length(names);

% preallocate
s=[];
m=[];
pc=[];
sp=[];
msp=[];
ssp=[];
ma=[];
mma=[];
sma=[];
monkID=[];

%% step through files, get info for each session
for i=1:numnames
    filename=names{i};
    if plotfig==1&&i==2 % plot example session, figure 1b
        [spikes,mahals,fspopcor,repsup,mahaldiff] = getSpikesAndMahal_imgExp(filename,1); 
    else
        [spikes,mahals,fspopcor,repsup,mahaldiff] = getSpikesAndMahal_imgExp(filename,0); 
    end
    monkID=[monkID; repmat(fileID(i),size(mahals,2),1)];
    s=[s repsup]; % difference between first and second counts
    m=[m mahaldiff]; % difference between first and second distances
    pc=[pc fspopcor]; % correlation between first and second population response
    sp=[sp spikes]; % population spike counts for all images
    msp=[msp mean(spikes,2)]; % mean population counts over all images
    ssp=[ssp; ste(spikes')]; % SEM of population counts over all images
    ma=[ma mahals]; % distances for all images
    mma=[mma mean(mahals,2)]; % mean distance over all images
    sma=[sma; ste(mahals')]; % SEM of distances over all images

end


%% effect and p-values (paired, two-sample) for spikes, mahal; correlation b/w spikes & mahal
% preallocate
spikes_pValue=NaN(1,numMonks); 
spikes_effect=NaN(1,numMonks);
mahal_pValue=NaN(1,numMonks); 
mahal_effect=NaN(1,numMonks);
spikeMahCorr=NaN(1,numMonks);

for mo=1:numMonks % step through monkeys
    
    monk=monkList(mo);

    % population spike counts, H1: first spikes > second spikes
    [~,spkP]=ttest(sp(1,matches(monkID,monk)),sp(2,matches(monkID,monk)),"Tail","right"); 
    spikes_pValue(mo)=spkP;
    spikes_effect(mo)=effectSize(sp(2,matches(monkID,monk)),sp(1,matches(monkID,monk)));

    % mahal distance, H1: first distance > second distance
    [~,mahP]=ttest(ma(1,matches(monkID,monk)),ma(2,matches(monkID,monk)),"Tail","right"); 
    mahal_pValue(mo)=mahP;
    mahal_effect(mo)=effectSize(ma(2,matches(monkID,monk)),ma(1,matches(monkID,monk)));

    % img by img correlation b/w rate and mahal differences
    spikeMahCorr(mo) = mccorrcoef(m(matches(monkID,monk)),s(matches(monkID,monk)));

end


%% save full list of values to an output structure
spikeMahal_imgExp=struct("fs_spikes",sp,"fs_distances",ma,"fs_popcor",pc,...
    "fs_meanSpikes",msp,"fs_meanDist",mma,...
    "fs_steSpikes",ssp,"fs_steDist",sma,...
    "repetitionSup",s,"distDiff",m,"monkeyID",monkID,...
    "spikeP",spikes_pValue,"spikeEffect",spikes_effect,...
    "distP",mahal_pValue,"distEffect",mahal_effect,...
    "spikeDistCorrelation",spikeMahCorr);

%% ==================plotting====================

if plotfig==1

    %% figure 1c: plot population spike counts
    plotUnity_withPairs(sp',msp,ssp',monkID,fileID,[30 95]);
    xlabel('second mean spike count');
    ylabel('first mean spike count');
    title('mean population spike count, all sessions');


    %% figure 1e: plot mahalanobis distances 
    plotUnity_withPairs(ma',mma,sma',monkID,fileID,[10 65]);
    xlabel('second mean distance');
    ylabel('first mean distance');
    title('mean mahalanobis distance, all sessions');

    %% Supplemental figure 1: distributions of population correlations for all images
    figure;
    hold on
    edges=-0.15:0.05:1;
    histogram(pc(matches(monkID,"BA")),edges,'FaceColor',[0.5 0.5 0.5]);
    histogram(pc(matches(monkID,"WA")),edges,'FaceColor',[0.15 0.15 0.15]);
    ylim([0 60]);
    xlabel('correlation coeffecient, first and second presentations');
    ylabel('number of images');
    legend('M1','M2','location','northwest','FontSize',15);
    set(gca,'FontSize',15);

end


end