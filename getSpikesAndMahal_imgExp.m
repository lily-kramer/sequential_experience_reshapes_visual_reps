function [spikes,mahals,popcor,repsup,mahaldiff] = getSpikesAndMahal_imgExp(filename,plotExample)

load(filename,"allbasecounts","alltrialcounts","allshortcounts","alltrialsnormal","alltrialimgIDs");

%% noisy trial exclusion 
% (average across population, exclude trials > |3.5 stds|)
[goodTrialList,goodunits] = excludeNoisyTrialsChan_imgExp(allbasecounts,alltrialcounts,allshortcounts);% visualize spike counts
V4chan = goodunits; % ammend unit list to responsive/not dead ones

%% trim structs
% isolate denoised trials
alltrialsnormal = alltrialsnormal(goodTrialList);
alltrialcounts = alltrialcounts(:,goodTrialList);
alltrialimgIDs = alltrialimgIDs(goodTrialList);
% isolate unaltered image trials
alltrialsnormal = logical(alltrialsnormal);
alltrialcounts = alltrialcounts(:,alltrialsnormal);
alltrialimgIDs = alltrialimgIDs(alltrialsnormal);

%% z-score spike counts of each unit over all unaltered image trials
zcounts = zscore(alltrialcounts(V4chan,:),0,2);

%% get mahal. distance for each trial 
M=mahal(zcounts',zcounts'); 

%% get population correlation for all pairs of trials
popcors=corrcoef(zcounts,'rows','pairwise'); 

%% for each image, isolate back-to-back presentations and get:
% [numimagesx2]: spikes, mahals for first and second
% [numimagesx1]: population correlations b/w first and second

imageid=alltrialimgIDs;
numpairs=sum(diff(imageid)==0); % # of images with back-to-back pairs
images=unique(imageid);
images=images(isfinite(images));
numimages=length(images);
popcor=NaN(1,numpairs);
spikes=NaN(2,numpairs);
mahals=NaN(2,numpairs);
pairimg=NaN(1,numpairs);


pindx = 1;
for i=1:numimages
    these=find(imageid==images(i)); % find trial numbers for this image
    these=these(isfinite(these));
    d=diff(these); % get difference in trial # for these trials
    p=find(d==1); % get index (in these) for first of back-to-back pair trial
    if any(p) % if any back-to-back unaltered
        pairimg(1,pindx)=images(i);
        spikes(:,pindx)=mean(alltrialcounts(V4chan,these(p:p+1)),1,'omitnan')';         
        mahals(:,pindx)=M(these(p:p+1));
        popcor(pindx)=popcors(these(p),these(p+1)); % correlation b/w 1st and 2nd
        pindx = pindx+1;
    end

end


%% find difference in single trial measures (spike counts, mahal)
% (first presentation - second presentation)
repsup=spikes(1,:)-spikes(2,:);
mahaldiff=mahals(1,:)-mahals(2,:);

%% plot example session population spikes counts for all images

if plotExample==1

    figure
    hold on
    xlim([50 115]);
    ylim([50 115]);
    plot([50 115],[50 115],'k--','LineWidth',1.8); % unity line
    plot(spikes(2,:),spikes(1,:),'ko','MarkerSize',12,...
        'MarkerFaceColor',[0.55 0.55 0.55],'LineWidth',0.8);
    axis square
    set(gca,'FontSize',17);
    xlabel('second population spike count');
    ylabel('first population spike count');
    legend('','one image','Fontsize',14);

end


end