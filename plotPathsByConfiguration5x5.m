function [propTrialsMainPath,freqConfigs,infreqConfigs]=plotPathsByConfiguration5x5(filename,plotfig)
% for a given session, and for each configuration, visualize all the paths
% taken. Find the proportion of trials that the most commonly used path was
% taken. 

load(filename,"configByTrial","startLocation","rewardLocation","pathIDXByConfiguration","gridIDX","numConfigs");

%% figure out which configurations are frequent or infrequent
% find counts of each config, sort them, the first two are frequent
[~,ind]=sort([histcounts(configByTrial)],'descend');
freqConfigs = ind(1:2);
infreqConfigs = ind(3:4);

% preallocate
propTrialsMainPath = NaN(1,numConfigs);


% plotting stuff
m = 101;
[cmap]=viridis(m);

% set up frequency of usage index to pull colors
usageIDX=(0:0.01:1)'; % same length as color map
usageIDX=round(usageIDX,2);

for config = 1:numConfigs % step through configurations (4)
    theseTrials = find(configByTrial == config);
    % find start and stop locations for this config
    configStartLoc = startLocation(theseTrials(1));
    configRewardLoc = rewardLocation(theseTrials(1));
    % find number of unique paths used in this session for this config
    numUniquePaths = length(pathIDXByConfiguration(config).uniquePaths);

    pathProportions = NaN(1,numUniquePaths);

    for pathIDX = 1:numUniquePaths
        % calculate the proportion of trials this path was taken for this
        % configuration
        pathTrialCount = length(pathIDXByConfiguration(config).uniquePathTrials{1,pathIDX});

        % divide # trials this path by total # trials this configuration
        pathProportions(pathIDX) = pathTrialCount/length(theseTrials);
    end

    roundedPathProps = round(pathProportions,2); % round those proportions
    [sortedPathProps,sortedPathIndex]=sort(roundedPathProps,'descend'); % sort them

    % get prop. of trials this config. for most commonly used path
    propTrialsMainPath(1,config) = sortedPathProps(1);

    % set up x and y coordinates for plotting
    plottingCoordinatesY=[5 5 5 5 5; 4 4 4 4 4;3 3 3 3 3; 2 2 2 2 2; 1 1 1 1 1];
    plottingCoordinatesX=[1 2 3 4 5; 1 2 3 4 5; 1 2 3 4 5; 1 2 3 4 5; 1 2 3 4 5];

    numPathsToPlot = numUniquePaths;

    % set self position starting coordinate
    startX=plottingCoordinatesX(gridIDX==configStartLoc);
    startY=plottingCoordinatesY(gridIDX==configStartLoc);

    % set reward position coordinate
    rewardX=plottingCoordinatesX(gridIDX==configRewardLoc);
    rewardY=plottingCoordinatesY(gridIDX==configRewardLoc);

    if plotfig == 1

        % set up the figure before plotting trajectories...
        figure
        hold on
        xlim([0.5 5.5]);
        ylim([0.5 5.5]);

        % set up target positions
        gridIDs=1:25;
        waypointgridIDX=gridIDs(~ismember(gridIDs, [configStartLoc configRewardLoc])); % find the waypoint grid IDs
        waypointX=NaN(1,length(waypointgridIDX));
        waypointY=NaN(1,length(waypointgridIDX));

        for WPidx=1:length(waypointgridIDX)
            WP=waypointgridIDX(WPidx);
            waypointX(WPidx)=plottingCoordinatesX(gridIDX==WP);
            waypointY(WPidx)=plottingCoordinatesY(gridIDX==WP);
        end

        for p = 1:numPathsToPlot % step through paths this configuration
            pathIDX = sortedPathIndex(p); %plot most frequent path first
            thisPath = pathIDXByConfiguration(config).uniquePaths{1,pathIDX};
            numMoves=length(thisPath);
            x=startX;
            y=startY;

            for move=1:numMoves %step through moves this path
                endPointX=plottingCoordinatesX(gridIDX==thisPath(move));
                endPointY=plottingCoordinatesY(gridIDX==thisPath(move));
                x=[x endPointX]; % add the coordinates for all moves to this structure
                y=[y endPointY];
                clear endPointX endPointY
            end

            % add on the reward location
            x = [x rewardX];
            y = [y rewardY];

            % spacing for paths:
            xPad = [0.1 -0.1 0.2 -0.2 0.3 -0.3 0.4 -0.4];
            yPad = [-0.13 0.13 -0.23 0.23 -0.33 0.33 -0.43 0.43];

            % offset the lines slightly
            x = x + xPad(p);
            y = y + yPad(p);

            % set color based on proportion
            thisColorIDX=find(usageIDX==roundedPathProps(pathIDX));
            colorToUse(1)=cmap(thisColorIDX,1);
            colorToUse(2)=cmap(thisColorIDX,2);
            colorToUse(3)=cmap(thisColorIDX,3);

            % do actual plotting
            for plotThis=1:(length(x)-1) % step through x and y, pulling coordinate pairs and plotting lines
                gcf;
                hold on
                plot(x(plotThis:plotThis+1),y(plotThis:plotThis+1),...
                    'Color',[colorToUse(1), colorToUse(2), colorToUse(3), 1],...
                    'LineWidth',11);
                % add circle tat junctions to smooth edges
                plot(x(plotThis),y(plotThis),'Marker','o',...
                    'MarkerEdgeColor','none',...
                    'MarkerFaceColor',[colorToUse(1), colorToUse(2), colorToUse(3)],...
                    'MarkerSize',11);
            end

            clear thisPath numMoves
        end


        % plot self
        plot(startX,startY,'gs','MarkerSize',20,'LineWidth',2.7,'MarkerFaceColor','g');

        % plot reward
        plot(rewardX,rewardY,'bo','MarkerSize',20,'LineWidth',1.8,'MarkerFaceColor','b');

        % plot targets
        plot(waypointX,waypointY,'ko','MarkerSize',20,'LineWidth',1.8,'MarkerFaceColor','k');

        xlabel('screen position, x');
        ylabel('screen position, y');

        if ismember(config,freqConfigs)
            title('frequent configuration');
        elseif ismember(config,infreqConfigs)
            title('infrequent configuration');
        end

        colormap(cmap)
        if config==1
            colorbar('eastoutside')
        end
        set(gca,'FontSize',15);
        set(gca,'color',[0.5 0.5 0.5])
        xticklabels({' ',' ',' ',' ',' '})
        yticklabels({' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '});

    end

end


end