function[earlyVlate]=allOrderDecode_imgSeqExp(plotfig)

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

% preallocate
ccgps=NaN(numnames,2);
varfirstdim=NaN(numnames,2);
popearly=[];
poplate=[];
splitacc=[];
popmeans=NaN(numnames,2); % [early late]
popste=NaN(numnames,2); % [early late]
mIDsess=[];
mID=[];

for i=1:numnames % step through files, get numbers
    if i<4
        monkey="XE";
    elseif i>3&&i<12
        monkey="ZI";
    else
        monkey="HE";
    end
    filename=names{i};
    [c,v,s,earlyr,later]=getOrderDecoding_imgSeqExp(filename,monkey,shortOrNovel_sess(i));
    ccgps(i,:)=c;
    varfirstdim(i,:)=v;
    splitacc=[splitacc;s];
    popearly=[popearly earlyr];
    poplate=[poplate later];
    popmeans(i,1)=mean(earlyr);
    popmeans(i,2)=mean(later);
    popste(i,1)=ste(earlyr);
    popste(i,2)=ste(later);
    mIDsess=[mIDsess monkey];
    mID=[mID; repmat(monkey,length(earlyr),1)];
end


%% =============significance tests===============

% population spike counts: two sample, one-sided (monkeys separate)
% H1: early resp > later resp
[~,spikesP_M3]=ttest2(popearly(matches(mID,"ZI")),poplate(matches(mID,"ZI")),"Tail","right");
effect=meanEffectSize(popearly(matches(mID,"ZI")),poplate(matches(mID,"ZI")),Paired=false);
ZpkEf=effect{1,1};
[~,spikesP_M4]=ttest2(popearly(matches(mID,"XE")),poplate(matches(mID,"XE")),"Tail","right");
effect=meanEffectSize(popearly(matches(mID,"XE")),poplate(matches(mID,"XE")),Paired=false);
XpkEf=effect{1,1};
[~,spikesP_M5]=ttest2(popearly(matches(mID,"HE")),poplate(matches(mID,"HE")),"Tail","right");
effect=meanEffectSize(popearly(matches(mID,"HE")),poplate(matches(mID,"HE")),Paired=false);
HpkEf=effect{1,1};

% sequence order decoding: paired, one-sided (monkeys together)
%H1: late > early
[~,decodeP]=ttest(ccgps(:,2),ccgps(:,1),'Tail','right');

% H1: early and late > chance
[~,pChanceLate]=ttest(ccgps(:,2),0.5,'Tail','right');
effect=meanEffectSize(ccgps(:,2),0.5);
chanceLateEff=effect{1,1};
[~,pChanceEarly]=ttest(ccgps(:,1),0.5,'Tail','right');
effect=meanEffectSize(ccgps(:,1),0.5);
chanceEarlyEff=effect{1,1};

% dimensionality: paired, one-sided (monkeys together)
% H1: early > late
[~,dimP]=ttest(varfirstdim(:,2),varfirstdim(:,1),'Tail','right');
effect=meanEffectSize(varfirstdim(:,2),varfirstdim(:,1));
dimEffect=effect{1,1};

%% put everything in an output structure
earlyVlate=struct("meanOrderDecoding",ccgps,"allSplitsOrderDecoding",splitacc,"dimensionality",...
    varfirstdim,"meanPopulationResp",popmeans,"stePopulationResp",popste,"sessionMonkeyID",mIDsess,...
    "pValsPopulationResp",[spikesP_M3 spikesP_M4 spikesP_M5],"effectPopulationResp",[ZpkEf XpkEf HpkEf],...
    "pVal_earlyVlateOrder",decodeP,"pVal_earlyVchanceOrder",pChanceEarly,"pVal_lateVchanceOrder",pChanceLate,...
    "effect_earlyVChanceOrder",chanceEarlyEff,"effect_lateVChanceOrder",chanceLateEff,...
    "pVal_dimensionality",dimP,"effect_dimensionality",dimEffect);


%% ===========plotting===================

if plotfig==1

    % figure 4f: sequence order decoding early vs. late
    figure;
    plot([.4 .9],[.4 .9],'k--')
    xline(0.5);
    yline(0.5);
    hold on
    % plot means over all train-test splits for each session
    for i=1:numnames
        if mIDsess(i)=="ZI"
            plot(ccgps(i,2),ccgps(i,1),'k^','markerfacecolor',[0.4 0.4 0.4],...
                'LineWidth',0.8,'MarkerSize',11);
        elseif mIDsess(i)=="XE"
            plot(ccgps(i,2),ccgps(i,1),'ks','markerfacecolor',[0.4 0.4 0.4],...
                'LineWidth',0.8,'MarkerSize',11);
        elseif mIDsess(i)=="HE"
            plot(ccgps(i,2),ccgps(i,1),'kpentagram','markerfacecolor',[0.4 0.4 0.4],...
                'LineWidth',0.8,'MarkerSize',14);
        end
    end
    marleneaxes
    axis square
    xlabel('late trials')
    ylabel('early trials')
    title('sequence order decoding')
    set(gca,'FontSize',14);


    % figure 4e: response dimensionality early vs. late
    figure;
    plot([.4 1],[.4 1],'k--')
    hold on
    for i=1:numnames

        if mIDsess(i)=="ZI"
            plot(varfirstdim(i,2),varfirstdim(i,1),'k^','markerfacecolor',[0.4 0.4 0.4],...
                'LineWidth',0.8,'MarkerSize',11);
        elseif mIDsess(i)=="XE"
            plot(varfirstdim(i,2),varfirstdim(i,1),'ks','markerfacecolor',[0.4 0.4 0.4],...
                'LineWidth',0.8,'MarkerSize',11);
        elseif mIDsess(i)=="HE"
            plot(varfirstdim(i,2),varfirstdim(i,1),'kpentagram','markerfacecolor',[0.4 0.4 0.4],...
                'LineWidth',0.8,'MarkerSize',14);
        end

    end
    marleneaxes
    axis square
    ylabel('early trials')
    xlabel('late trials')
    title('proportion variance in 1st PC')
    set(gca,'FontSize',14);

    % figure 3a: population responses to expected sequence early vs. late
    figure
    hold on
    errorbar(popmeans(:,2),popmeans(:,1),...
        popste(:,1),popste(:,1),...
        popste(:,2),popste(:,2),...
        'LineStyle','none',...
        'LineWidth',1.3,'Color',[0.5 0.5 0.5]);
    for i=1:numnames
        if mIDsess(i)=="ZI"
            plot(popmeans(i,2),popmeans(i,1),'k^','MarkerFaceColor',[0.4 0.4 0.4],...
                'MarkerSize',10,'linewidth',0.8);
        elseif mIDsess(i)=="XE"
            plot(popmeans(i,2),popmeans(i,1),'ks','MarkerFaceColor',[0.4 0.4 0.4],...
                'MarkerSize',10,'linewidth',0.8);
        elseif mIDsess(i)=="HE"
            plot(popmeans(i,2),popmeans(i,1),'kpentagram','MarkerFaceColor',[0.4 0.4 0.4],...
                'MarkerSize',14,'linewidth',0.8);
        end
    end
    xlim([5 40]);
    ylim([5 40]);
    plot([5 40],[5 40],'k--','LineWidth',1.3);
    ylabel('early trials');
    xlabel('late trials');
    title('average (over sequence) population response');
    marleneaxes
    axis square
    set(gca,'FontSize',14);
end

end
