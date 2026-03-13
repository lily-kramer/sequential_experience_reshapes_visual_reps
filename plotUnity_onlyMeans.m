function []=plotUnity_onlyMeans(meanData,steData,limits)
% make a scatter plot with a unity line that shows individual paired values
% from each zippy session as well as session means/stes
% inputs: 
% meanData and steData are lists of values [expected unexpected]
% limits is the [lower upper] bound of the axes

    if nargin < 3 % if no axes limits given
        maxall=max(meanData,[],"all")+5;
        minall=min(meanData,[],"all")-5;
    else
        maxall=limits(2);
        minall=limits(1);
    end

    %% x-axis is expected condition, y-axis is unexpected condition

    figure;
    hold on
    % set axes limits
    xlim([minall maxall]);
    ylim([minall maxall]);
    % plot unity line
    plot([minall maxall],[minall maxall],'k--','LineWidth',1.8);
    % error bars for each session
    errorbar(meanData(1,:),meanData(2,:),steData(2,:),steData(2,:),steData(1,:),steData(1,:),...
        'LineWidth',1.8,...
        'LineStyle','none',...
        'Color',[0.5 0.5 0.5]);
    plot(meanData(1,:),meanData(2,:),'k^',...
        'MarkerFaceColor',[0.40 0.40 0.40],...
        'MarkerSize',12,...
        'LineWidth',1);
    axis square
    set(gca,'FontSize',17);


end