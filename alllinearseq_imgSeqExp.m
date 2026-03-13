function[assessLinearity]=alllinearseq_imgSeqExp(plotfig)

names={'241218_XE_short.mat';...% M4
    '250107_XE_1short.mat';...
    '250107_XE_2short.mat';...
    '230830_ZI_novel.mat';...% M3
    '230902_ZI_novel.mat';...
    '230904_ZI_novel.mat';...
    '230918_ZI_1novel.mat';...
    '230918_ZI_2novel.mat';...
    '230927_ZI_short.mat';...
    '231002_ZI_short.mat';...
    '250509_ZI_short.mat';...
    '250318_HE_short.mat';...% M5
    '250319_HE_short.mat'};

numnames=length(names);

% short violation sessions=0, novel seq. sessions=1
shortOrNovel_sess=[0 0 0 1 1 1 1 1 0 0 0 0 0];
slopes=NaN(1,numnames);
pslopes=NaN(1,numnames);
trialidx=[];
zresiduals=[];

for i=1:numnames % step through files, get numbers
     if i<4
        monkey="XE";
    elseif i>3&&i<12
        monkey="ZI";
    else
        monkey="HE";
    end
    filename=names{i};
    if i==13 && plotfig==1
        [slope,pslope,zresidual]=getlinearseq_imgSeqExp(filename,shortOrNovel_sess(i),monkey,1);
    else
        [slope,pslope,zresidual]=getlinearseq_imgSeqExp(filename,shortOrNovel_sess(i),monkey,0);
    end
    slopes(i)=slope;
    pslopes(i)=pslope;
    ti=trialidx;
    zr=zresiduals;
    trialidx=[ti 1:length(zresidual)];
    zresiduals=[zr; zresidual];
end

mslope=mean(slopes);
sslope=ste(slopes);

%% plot figure 3d
if plotfig==1
    figure;
    edges=-.3:.05:.3;
    histogram(slopes,edges,'Normalization','percentage','FaceColor',[0.4 0.4 0.4]);
    xline(mslope,'k--','LineWidth',1.8);
    marleneaxes
    xlabel('slope');
    ylabel('percent of sessions');
    set(gca,'FontSize',14);
end


%% significance test: H1: slopes < significantly less than 0
[~,slopeP]=ttest(slopes,0,"Tail",'left');

%% put in output structure
assessLinearity=struct("distributionOfSlopes",slopes,"meanOfSlopes",mslope,...
    "steOfSlopes",sslope,"pValueSlopesBelowZero",slopeP);



