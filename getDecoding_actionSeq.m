function[fcors,ncors,scors,orth,orthXY,axiscors]=getDecoding_actionSeq(filename)

load(filename,"baselineCounts","allSelfCounts","allFixationTrialNumbers","allSelfPositions","configByTrial",...
    "rewardLocation","gridIDX");
    
%% trial/channel denoising get already trimmed counts, included trials and fixations
[allSelfCounts,~,allFixationTrialNumbers,includefix,includetrials]=excludeTrialsAndChannels_actionSeq(baselineCounts,allSelfCounts,allFixationTrialNumbers);

% if there were any fixations excluded, trim other structures to exclude them
if any(includefix==0)
    allSelfPositions=allSelfPositions(includefix);
    configByTrial=configByTrial(includetrials);
    rewardLocation=rewardLocation(includetrials);
end

%% get number of trials per configuration 
configs=unique(configByTrial);
numConfigs=length(configs);
trialsperConfig=NaN(1,numConfigs);
for i=1:numConfigs
    trialsperConfig(i)=sum(configByTrial==configs(i));
end
freq=round(trialsperConfig/max(trialsperConfig));
numfix=length(allSelfPositions);

%% get the size of the grid (5x5)
gridsize=length(gridIDX); 
ypos=mod(allSelfPositions,gridsize);
xpos=ceil(allSelfPositions/gridsize);

%% make an index of frequent|infrequent and reward location for all fixations
allfreq=NaN(1,numfix);
configbyfix=NaN(1,numfix);
rewlocbyfix=NaN(1,numfix);
for i=1:numfix
    allfreq(i)=freq(configByTrial(allFixationTrialNumbers(i)));
    configbyfix(i)=configByTrial(allFixationTrialNumbers(i));
    rewlocbyfix(i)=rewardLocation(allFixationTrialNumbers(i));
end
numinfreq=sum(allfreq==0);% number of infrequent fixations

%% find the reward distance for each fixation
rewdistbyfix=abs(xpos-(ceil(rewlocbyfix/gridsize)))+abs(ypos-(mod(rewlocbyfix,gridsize)));

%% using infrequent trials, get decoding performance for all variables 
ncors=crossregress(allSelfCounts(:,allfreq==0),...
    [xpos(allfreq==0); ...
    ypos(allfreq==0); ...
    rewdistbyfix(allfreq==0); ...
    configbyfix(allfreq==0)],0);

%% using frequent trials, get decoding performance for all variables 
% method: subsample frequent trial fixations to match the number of
% infrequent fixations. repeat this process 100x. 
reps=100; 
fcors=NaN(4,4,reps);
% get all frequent trials
g=find(allfreq==1);

for i=1:reps % for 100 reps
these=g(randperm(length(g))); % randomize order
these=these(1:numinfreq); % match trial counts for conditions

fcors(:,:,i)=crossregress(allSelfCounts(:,these),...
    [xpos(these); ...
    ypos(these); ...
    rewdistbyfix(these); ...
    configbyfix(these)],0);

end

% compute stes across reps
scors=NaN(4,4);
for i=1:4
    for j=1:4
        scors(i,j)=nanstd(fcors(i,j,:));
    end
end

fcors=nanmean(fcors,3);

nc=NaN(4,1);
fc=NaN(4,1);
sc=NaN(4,1);
for i=1:4
    nc(i)=ncors(i,i);
    fc(i)=fcors(i,i);
    sc(i)=scors(i,i);
end
orth=[abs(fcors(3,4)); abs(ncors(3,4))];
orthXY = [abs(fcors(1,2)); abs(ncors(1,2))];

% find axis cors across groups on all trials this session
groups=[xpos; ...
    ypos; ...
    rewdistbyfix; ...
    configbyfix];
groups=nanzscore(groups);
axiscors=corrcoef(groups');
     
ncors=nc;
fcors=fc;
scors=sc;

end



