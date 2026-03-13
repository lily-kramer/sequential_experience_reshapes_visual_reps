function []=plotUnity_withPairs(pairsData,meanData,steData,monkID,fileID,limits)
% make a scatter plot with a unity line that shows individual paired values
% from each session as well as session means/stes
% inputs: 
% pairsData,meanData and steData are lists of values [expected unexpected]
% limits is the [lower upper] bound of the axes
% monkID is the monkey index for all pairs data
% fileID is the monkey index for session means 

% NOTE: for experiment 1, axis ordering has to be flipped because of how
% data was saved ([first(unexpected) second(expected)]

    if nargin < 6 % if no axes limits given
        maxall=max(pairsData,[],"all")+5;
        minall=min(pairsData,[],"all")-5;
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
    
    % plot data from all pairs with monkey specific markers
    for pair=1:size(pairsData,1) 
        if monkID(pair)=="BA" % circle
            scatter(pairsData(pair,2),pairsData(pair,1),14,[0.5 0.5 0.5],...
                "filled","o","MarkerFaceAlpha",0.3);
        elseif monkID(pair)=="WA" % diamond
            scatter(pairsData(pair,2),pairsData(pair,1),14,[0.5 0.5 0.5],...
                "filled","d","MarkerFaceAlpha",0.3);
        elseif monkID(pair)=="ZI" % triangle
            scatter(pairsData(pair,1),pairsData(pair,2),28,[0.5 0.5 0.5],...
                "filled","^","MarkerFaceAlpha",0.5);
        elseif monkID(pair)=="XE"% square
            scatter(pairsData(pair,1),pairsData(pair,2),28,[0.5 0.5 0.5],...
                "filled","s","MarkerFaceAlpha",0.5);
        elseif monkID(pair)=="HE"% star
            scatter(pairsData(pair,1),pairsData(pair,2),45,[0.5 0.5 0.5],...
                "filled","pentagram","MarkerFaceAlpha",0.5);
        end
    end
    
    % plot error bars for all monkeys
    if any(matches(fileID,"BA")) % it's the first experiment
        errorbar(meanData(2,:),meanData(1,:),...
            steData(1,:),steData(1,:),...
            steData(2,:),steData(2,:),...
            'LineStyle','none','LineWidth',1.1,'Color','k');
    else
        errorbar(meanData(:,1),meanData(:,2),...
            steData(:,2),steData(:,2),...
            steData(:,1),steData(:,1),...
            'LineStyle','none','LineWidth',1.1,'Color','k');
    end

    % plot means with monkey specific markers
    for f = 1:length(fileID) % step through session files
        if fileID(f)=="BA" % circle
            plot(meanData(2,f),meanData(1,f),'ko','MarkerSize',12,...
                'MarkerFaceColor',[0.55 0.55 0.55],'LineWidth',0.8);
        elseif fileID(f)=="WA" % diamond
            plot(meanData(2,f),meanData(1,f),'kd','MarkerSize',12,...
                'MarkerFaceColor',[0.55 0.55 0.55],'LineWidth',0.8);            
        elseif fileID(f)=="ZI" % (triangle)
            plot(meanData(f,1),meanData(f,2),'k^','MarkerSize',15,...
                'MarkerFaceColor',[0.55 0.55 0.55],'LineWidth',0.8);
        elseif fileID(f)=="XE" % (square)
            plot(meanData(f,1),meanData(f,2),'ks','MarkerSize',15,...
                'MarkerFaceColor',[0.55 0.55 0.55],'LineWidth',0.8);
        elseif fileID(f)=="HE" %(star)
            plot(meanData(f,1),meanData(f,2),'kpentagram','MarkerSize',16,...
                'MarkerFaceColor',[0.55 0.55 0.55],'LineWidth',0.8);
        end
    end
    axis square
    set(gca,'FontSize',17);


end