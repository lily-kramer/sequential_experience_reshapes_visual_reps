function[orderDecodingVarianceExp]=allMoveOrderDecode_actionSeq(plotfig)

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
orderPerf=[];
varfirstdim=[];
freq=[];
numexp=[];

for i=1:numnames
    filename=names{i};
    [o, v, f, n]=getMoveOrderDecoding(filename);
    orderPerf=[orderPerf o];
    varfirstdim=[varfirstdim v];
    freq=[freq f'];
    numexp=[numexp n];
end

% for each session get, 1) all pairwise combinations of decoding/variance
% and 2) mean decoding/variance over frequent|infrequent configurations
P=orderPerf;
V=varfirstdim;
C=freq;
meanPerf=NaN(numnames,2); % [frequent infrequent]
meanVar=NaN(numnames,2);% [frequent infrequent]
combosPerf=[];% [frequent infrequent]
combosVar=[];% [frequent infrequent]
for s = 1:numnames % step through sessions
    % decoding
    x = P(C(:,s) == 0, s);   % values for infrequent
    y = P(C(:,s) == 1, s);   % values for frequent
    % Create all pairwise combinations (4 points)
    [dX,dY] = meshgrid(x,y);
    combosPerf=[combosPerf; [reshape(dY,[4 1]) reshape(dX,[4 1])]];
    % mean decoding perf 
    meanPerf(s,2)=mean(x);
    meanPerf(s,1)=mean(y);

    % variance explained
    x = V(C(:,s) == 0, s);   % values for infrequent
    y = V(C(:,s) == 1, s);   % values for frequent
    % Create all pairwise combinations (4 points)
    [vX,vY] = meshgrid(x,y);  
    combosVar=[combosVar; [reshape(vY,[4 1]) reshape(vX,[4 1])]];
    % mean prop. variance explained
    meanVar(s,2)=mean(x);
    meanVar(s,1)=mean(y);
end

%% ============significance tests===============
% variance. H1: from distributions with different means (two-sided)
[~,dimp]=ttest(meanVar(:,1),meanVar(:,2)); 

% decoding. H1: freq>infreq (one-sided)
[~,decp]=ttest(meanPerf(:,1),meanPerf(:,2),"Tail","right");
effect=meanEffectSize(meanPerf(:,1),meanPerf(:,2));
decEff=effect{1,1};

% decoding. H1: freq>chance (one-sided)
[~,pfreqD_chance]=ttest(meanPerf(:,1),0.5,"Tail",'right'); 
effect=meanEffectSize(meanPerf(:,1),0.5);
cfreqEff=effect{1,1};

% decoding. H1: infreq>chance (one-sided)
[~,pinfreqD_chance]=ttest(meanPerf(:,2),0.5,"Tail",'right');
effect=meanEffectSize(meanPerf(:,2),0.5);
cinfreqEff=effect{1,1};

% put all values in output structure
orderDecodingVarianceExp=struct("meanOrderDecoding",meanPerf,"meanVarExp",meanVar,...
    "pValVarianceExp",dimp,"pValDecodeFreqInf",decp,"pValDecodeFreqChance",pfreqD_chance,...
    "pValDecodeInfreqChance",pinfreqD_chance,"effDecodeInfreqChance",cinfreqEff,...
    "effDecodeFreqChance",cfreqEff,"effDecodeFreqInfreq",decEff);

%% ===========plotting===============

if plotfig==1
    %% figure 5d: mean move order deocoding for all sessions

    figure;
    hold on;
    % plot all combinations
    scatter(combosPerf(:,1),combosPerf(:,2),40, 'filled','^','MarkerFaceColor',[0.7 0.7 0.7]);
    % plot mean (over configurations) order decoding for each session
    plot(meanPerf(:,1),meanPerf(:,2),'k^','LineWidth',0.8,'MarkerFaceColor',[0.4 0.4 0.4],...
        'MarkerSize',12);
    ylabel('infrequent');
    xlabel('frequent');
    axis square;
    marleneaxes
    plot([.4 1],[.4 1],'k--')
    xline(0.5);
    yline(0.5);
    title('move order decoding')
    set(gca,'FontSize',14);


    %% figure 5c: proportion of variance explained by 1st PC, all sessions
    figure;
    hold on;
    % plot all combinations
    scatter(combosVar(:,1),combosVar(:,2),40, 'filled','^','MarkerFaceColor',[0.7 0.7 0.7]);
    % plot means for each session
    plot(meanVar(:,1),meanVar(:,2),'k^','LineWidth',0.8,'MarkerFaceColor',...
        [0.4 0.4 0.4],'MarkerSize',12);
    ylabel('infrequent');
    xlabel('frequent');
    axis square;
    marleneaxes
    plot([.4 1],[.4 1],'k--')
    title('proportion variance in first PC')
    set(gca,'FontSize',14);

end

end


