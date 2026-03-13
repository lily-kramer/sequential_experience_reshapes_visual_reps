function[decodingNumbers,behaviorNumbers]=allDecodeAndBehavior_actionSeq(plotfig)

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

numnames=length(names);
% four task-variables (reward distance, reward location, X-position, Y-position)
numaxes=4; 

% preallocate
% top row = frequent; bottom row = infrequent
decodingNumbers.xpos=NaN(2,numnames);
decodingNumbers.ypos=NaN(2,numnames);
decodingNumbers.sxpos=NaN(2,numnames);
decodingNumbers.sypos=NaN(2,numnames);
decodingNumbers.rewdist=NaN(2,numnames);
decodingNumbers.srewdist=NaN(2,numnames);
decodingNumbers.crossLD=NaN(2,numnames);
decodingNumbers.config=NaN(2,numnames);
decodingNumbers.crossXY=NaN(2,numnames);
axcors=NaN(numaxes,numaxes,numnames);
decodingNumbers.meanAxCors=NaN(numaxes,numaxes);
decodingNumbers.pValSelf=NaN;
decodingNumbers.pValCross=NaN;
decodingNumbers.pValCrossThresh=NaN;
decodingNumbers.effectSelf=NaN;
decodingNumbers.effectCross=NaN;

behaviorNumbers.avTTC=NaN(2,numnames);
behaviorNumbers.sTTC=NaN(2,numnames);
behaviorNumbers.avMoves=NaN(2,numnames);
behaviorNumbers.sMoves=NaN(2,numnames);
behaviorNumbers.TTCdiff = NaN(1,numnames);
behaviorNumbers.movesdiff = NaN(1,numnames);
behaviorNumbers.pValTTC=NaN;
behaviorNumbers.pValnumMoves=NaN;
behaviorNumbers.effectTTC=NaN;
behaviorNumbers.effectnumMoves=NaN;
behaviorNumbers.pStereotyped=NaN;
behaviorNumbers.effectStereotyped=NaN;

for i=1:numnames % step through session files
    filename=names{i};
    %% get decoding performances
    [fcors,ncors,scors,crossLD,crossXY,acors]=getDecoding_actionSeq(filename);
    decodingNumbers.xpos(:,i)=[fcors(1);ncors(1)];
    decodingNumbers.ypos(:,i)=[fcors(2);ncors(2)];
    decodingNumbers.sxpos(:,i)=[scors(1);scors(1)];
    decodingNumbers.sypos(:,i)=[scors(2);scors(2)];
    decodingNumbers.rewdist(:,i)=[fcors(3);ncors(3)];
    decodingNumbers.srewdist(:,i)=[scors(3);scors(3)];
    decodingNumbers.config(:,i)=[fcors(4);ncors(4)];
    decodingNumbers.sconfig(:,i)=[scors(4);scors(4)];
    decodingNumbers.crossLD(:,i)=crossLD;
    decodingNumbers.crossXY(:,i)=crossXY;
    axcors(:,:,i)=acors;
    
    %% get behavioral measures (time to complete and number of moves)
    load(filename,"configByTrial","timeToComplete","numberOfMoves");
    [~,ind] = sort(histcounts(configByTrial));
    infreq = ind(1:2);
    freq = ind(3:4);
    % time to complete: means, errors and differences 
    behaviorNumbers.avTTC(1,i) = mean(timeToComplete(ismember(configByTrial,freq)));
    behaviorNumbers.sTTC(1,i) = ste(timeToComplete(ismember(configByTrial,freq)));
    behaviorNumbers.avTTC(2,i) = mean(timeToComplete(ismember(configByTrial,infreq)));
    behaviorNumbers.sTTC(2,i) = ste(timeToComplete(ismember(configByTrial,infreq)));
    behaviorNumbers.TTCdiff(i) = behaviorNumbers.avTTC(2,i) - behaviorNumbers.avTTC(1,i); % more positive means frequent faster
    % number of moves: means, errors and differences 
    behaviorNumbers.avMoves(1,i) = mean(numberOfMoves(ismember(configByTrial,freq)));
    behaviorNumbers.sMoves(1,i) = ste(numberOfMoves(ismember(configByTrial,freq)));
    behaviorNumbers.avMoves(2,i) = mean(numberOfMoves(ismember(configByTrial,infreq)));
    behaviorNumbers.sMoves(2,i) = ste(numberOfMoves(ismember(configByTrial,infreq)));
    behaviorNumbers.movesdiff(i) = behaviorNumbers.avMoves(2,i) - behaviorNumbers.avMoves(1,i);  % more positive means frequent fewer

end

%% get average task-variable axis correlations over all sessions
meanAxCors=mean(axcors,3);
decodingNumbers.meanAxCors=meanAxCors;

%% get path stereotypy behavioral data and plot Figures 4 e,f
[stereoP,stereoEff]=allPathProportionsByConfig_actionSeq(plotfig);
behaviorNumbers.pStereotyped=stereoP;
behaviorNumbers.effectStereotyped=stereoEff;

%% get differences in decoding (infrequent - frequent)
% top row = frequent, bottom row = infrequent
decDistDiff=decodingNumbers.rewdist(2,:)-decodingNumbers.rewdist(1,:);
decLocationDiff=decodingNumbers.config(2,:)-decodingNumbers.config(1,:);
decXDiff=decodingNumbers.xpos(2,:)-decodingNumbers.xpos(1,:);
decYDiff=decodingNumbers.ypos(2,:)-decodingNumbers.ypos(1,:);

%% get correlations between time to complete and decoding for each session
r_decLocttc=corrcoef(decLocationDiff,behaviorNumbers.TTCdiff);
r_decLocttc=r_decLocttc(2,1);
r_decDisttc=corrcoef(decDistDiff,behaviorNumbers.TTCdiff);
r_decDisttc=r_decDisttc(2,1);
r_decXttc=corrcoef(decXDiff,behaviorNumbers.TTCdiff);
r_decXttc=r_decXttc(2,1);
r_decYttc=corrcoef(decYDiff,behaviorNumbers.TTCdiff);
r_decYttc=r_decYttc(2,1);

%% get p-values and effect sizes (paired t-tests)

% mean time to complete; H1: infreq>freq
[~,behaviorNumbers.pValTTC]=ttest(behaviorNumbers.avTTC(2,:),behaviorNumbers.avTTC(1,:),'tail','right');
effect = meanEffectSize(behaviorNumbers.avTTC(2,:),behaviorNumbers.avTTC(1,:));
behaviorNumbers.effectTTC=effect{1,1};

% mean # moves; H1: infreuq>freq
[~,behaviorNumbers.pValnumMoves]=ttest(behaviorNumbers.avMoves(2,:),behaviorNumbers.avMoves(1,:),'tail','right');
effect = meanEffectSize(behaviorNumbers.avMoves(2,:),behaviorNumbers.avMoves(1,:));
behaviorNumbers.effectnumMoves=effect{1,1};

% self-decoding for all task variables; H1: freq>infreq
freq_decAll=[decodingNumbers.xpos(1,:) decodingNumbers.ypos(1,:) decodingNumbers.rewdist(1,:) decodingNumbers.config(1,:)]; % combine 
infreq_decAll=[decodingNumbers.xpos(2,:) decodingNumbers.ypos(2,:) decodingNumbers.rewdist(2,:) decodingNumbers.config(2,:)];% combine
[~,decodingNumbers.pValSelf]=ttest(freq_decAll,infreq_decAll,"Tail",'right');
effect=meanEffectSize(freq_decAll,infreq_decAll);
decodingNumbers.effectSelf=effect{1,1};

% cross-decoding, both task-variable pairs; H1: infreq>freq
% using all sessions
freqCross=[decodingNumbers.crossLD(1,:) decodingNumbers.crossXY(1,:)];% combine 
infreqCross=[decodingNumbers.crossLD(2,:) decodingNumbers.crossXY(2,:)];% combine 
[~,decodingNumbers.pValCross]=ttest(infreqCross,freqCross,"tail",'right');

% cross-decoding, excluding sessions w/ self decoding perf <0.2; H1: infreq>freq
freqCross=[decodingNumbers.crossLD(1,[4 5 6 8 9 10 11]) decodingNumbers.crossXY(1,[4 6 8 9 11])];
infreqCross=[decodingNumbers.crossLD(2,[4 5 6 8 9 10 11]) decodingNumbers.crossXY(2,[4 6 8 9 11])];
[~,decodingNumbers.pValCrossThresh]=ttest(infreqCross,freqCross,"tail",'right');
effect=meanEffectSize(infreqCross,freqCross);
decodingNumbers.effectCross=effect{1,1};

%% -----------------------------plotting-------------------------------

if plotfig==1

    %% figure 4c: average ttc for all sessions
    plotUnity_onlyMeans(behaviorNumbers.avTTC,behaviorNumbers.sTTC,[3 9]);
    xlabel({'mean time to complete trial (s)', 'frequent'});
    ylabel('infrequent');
    title('mean time to complete, all sessions');

    %% figure 4d: average number of moves for all sessions
    plotUnity_onlyMeans(behaviorNumbers.avMoves,behaviorNumbers.sMoves,[2 5]);
    xticks(2:5);
    yticks(2:5);
    xlabel({'mean number of moves per trial', 'frequent'});
    ylabel('infrequent');
    title('mean number of moves, all sessions');

    %% figure 6a: self-decoding for all task variables
    plotDecodingPerformance(decodingNumbers,1);

    %% figure 6c: cross decoding, both task-variable pairs
    plotDecodingPerformance(decodingNumbers,2);

    %% supplemental figure 2: correlation b/w difference in reward location
    % decoding and time to complete a trial. 
    plotBehaviorDecodingCorrelations(decLocationDiff,behaviorNumbers.TTCdiff,r_decLocttc);
    title({'TTC & reward location decoding','(infreq-freq)'});

    %% supplemental figure 2: correlation b/w differnce in reward distance decoding
    % and time to complete a trial. 
    plotBehaviorDecodingCorrelations(decDistDiff,behaviorNumbers.TTCdiff,r_decDisttc);
    title({'TTC & reward distance decoding','(infreq-freq)'});
    legend('off');

    %% supplemental figure 2: correlation b/w differnce in X-postition decoding
    % and time to complete a trial. 
    plotBehaviorDecodingCorrelations(decXDiff,behaviorNumbers.TTCdiff,r_decXttc);
    title({'TTC & X-position decoding','(infreq-freq)'});
    legend('off');

    %% supplemental figure 2: correlation b/w differnce in Y-postition decoding
    % and time to complete a trial. 
    plotBehaviorDecodingCorrelations(decYDiff,behaviorNumbers.TTCdiff,r_decYttc);
    title({'TTC & X-position decoding','(infreq-freq)'});
    legend('off');

end

end


