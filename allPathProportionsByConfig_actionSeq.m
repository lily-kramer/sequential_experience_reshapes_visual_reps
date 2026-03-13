function [p,routesEff]=allPathProportionsByConfig_actionSeq(plotfig)

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

infmprops=NaN(1,numnames);
fremprops=NaN(1,numnames);
infp=[];
frep=[];

for i=1:numnames
    filename=names{i};
    if i==1 && plotfig==1 % plot the example session (figure 4e)
        [propTrialsMainPath,familiarConfigs,unfamiliarConfigs]=plotPathsByConfiguration5x5(filename,1);
    else
        [propTrialsMainPath,familiarConfigs,unfamiliarConfigs]=plotPathsByConfiguration5x5(filename,0);
    end
    ip=infp;
    fp=frep;
    infp=[ip; propTrialsMainPath(unfamiliarConfigs)'];
    frep=[fp; propTrialsMainPath(familiarConfigs)'];
    infmprops(i)=mean(propTrialsMainPath(unfamiliarConfigs));
    fremprops(i)=mean(propTrialsMainPath(familiarConfigs));
    

end

%% test significance
[~,p]=ttest(fremprops,infmprops,'Tail','right');
    eff=meanEffectSize(fremprops,infmprops);
    routesEff=eff{1,1};

%% ========plot=============

if plotfig==1
    % plot figure 4f
    figure;
    hold on
    plot([0.2 1],[0.2 1],'k--','LineWidth',1.8);
    scatter(frep,infp,28,[0.5 0.5 0.5],"filled",'^');
    plot(fremprops,infmprops,'k^',...
        'MarkerFaceColor',[0.40 0.40 0.40],...
        'MarkerSize',12,...
        'LineWidth',1);
    xlim([0.2 1]);
    ylim([0.2 1]);
    xlabel({'mean proportion of trials on most used route','frequent'});
    ylabel('infrequent');
    axis square
    marleneaxes
    set(gca,'FontSize',14);


end

end