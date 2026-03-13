function [mahals,spikes,Bmahals,Bspikes]=getSpikesMahal_imgSeqExp(filename,plotSessExample,monkey)

load(filename,"allStimCounts","baselineCounts","unexpected","allStimIDs");

if nargin==2
    disp("warning: monkey id not assigned")
end


%% establish trialNumberIDX
trialNumberIDX=[];
tnum = 1; % start at 1
for i=1:length(unexpected) % step through trials
    if unexpected(i)==1 % violation, 3
        tmp=[tnum tnum tnum];
        trialNumberIDX=[trialNumberIDX tmp];
    elseif unexpected(i)==0
        tmp=[tnum tnum tnum tnum]; % expected, 4
        trialNumberIDX=[trialNumberIDX tmp];
    end
    tnum=tnum+1;
end

%% exclude noisy trials and dead units
% stimcounts is [#goodunits x #presentations]
[stimcounts,~,trialNumberIDX,allStimIDs,includetrials]=excludeTrialsAndChannels_imgSeqExp(allStimCounts,baselineCounts,trialNumberIDX,allStimIDs,monkey);
unexpected=unexpected(includetrials); % trim to denoised trials

%% find where the sequence violations occured
unexpectedTrials = find(unexpected==1);

%% isolate stimulus presentations for: D, D', B, B prior D'
B_Presentations = find(allStimIDs == 2);
D_Presentations = find(allStimIDs == 4 & ~ismember(trialNumberIDX,unexpectedTrials));
Dunex_Presentations = find(allStimIDs == 4 & ismember(trialNumberIDX,unexpectedTrials));
Bunex_Presentations = Dunex_Presentations-1; % B in unexpected is just before D'
B_Presentations=B_Presentations(~ismember(B_Presentations,Bunex_Presentations));

%% z-score counts 
% (normalize for EACH UNIT INDEPENDENTLY over ALL presenations (ABCDD')
zcounts = zscore(stimcounts,0,2); 

%% get population repsonse on all trials (not normalized)
popresp=mean(stimcounts,1);

%% Mahalanbobis distance over all trials
normMahal = mahal(zcounts',zcounts'); 

%% Find pairs of D/D' presentations
backward=-20:-1;
forward=1:20;
D_PresToUse=NaN(1,length(Dunex_Presentations)); % preallocate
for j=1:length(Dunex_Presentations)
    this=Dunex_Presentations(j);
    diff=D_Presentations-this; % find how far back/forward closest expected D to this D'
    backMatch=find(ismember(diff,backward));
    forMatch=find(ismember(diff,forward));
    if any(backMatch) % prioritize matching previous
        D_PresToUse(j)=D_Presentations(backMatch(end));
    else % if no previous, use the closest following D
        D_PresToUse(j)=D_Presentations(forMatch(1));
    end

end
%% Find pairs ofB/B prior D' presentations
B_PresToUse=NaN(1,length(Bunex_Presentations)); % preallocate
for j=1:length(Bunex_Presentations)
    this=Bunex_Presentations(j);
    diff=B_Presentations-this;
    backMatch=find(ismember(diff,backward));
    forMatch=find(ismember(diff,forward));
    if any(backMatch) % prioritize matching previous
        B_PresToUse(j)=B_Presentations(backMatch(end));
    else % if no previous, use the closest following B
        B_PresToUse(j)=B_Presentations(forMatch(1));
    end
end

%% put together all spikes and distances for [D D']
mahals=[normMahal(D_PresToUse) normMahal(Dunex_Presentations)];
spikes=[popresp(D_PresToUse)' popresp(Dunex_Presentations)'];
%% put together all spikes and distances for [B B prior D']
Bmahals=[normMahal(B_PresToUse) normMahal(Bunex_Presentations)];
Bspikes=[popresp(B_PresToUse)' popresp(Bunex_Presentations)'];

%% ---------------plotting session example -----------------------

if plotSessExample==1
    % compare spikes for each pair of presentations (D/D')
    ymax = max(spikes,[],"all")+5;
    ymin = min(spikes,[],"all")-5;
    figure
    hold on
    plot([ymin ymax],[ymin ymax],'k--','LineWidth',1.7);
    if monkey == "ZI"
        plot(spikes(:,1),spikes(:,2),'k^','MarkerSize',12,'MarkerFaceColor',[0.50 0.50 0.50],'LineWidth',1.1);
    elseif monkey == "XE"
        plot(spikes(:,1),spikes(:,2),'ksquare','MarkerSize',12,'MarkerFaceColor',[0.50 0.50 0.50],'LineWidth',1.1);
    end

    ylim([ymin ymax]);
    xlim([ymin ymax]);
    xlabel('D # of spikes');
    ylabel('D'' # of spikes');
    set(gca,'FontSize',15);
    legend('','one D/D'' pair','FontSize',15);
    marleneaxes
    axis square

    % mahal distance for each pair of presentations (D/D')
    ymax = max(mahals,[],"all")+5;
    ymin = min(mahals,[],"all")-5;
    figure
    hold on
    plot([ymin ymax],[ymin ymax],'k--','LineWidth',1.7);
    if monkey == "ZI"
        plot(mahals(:,1),mahals(:,2),'k^','MarkerSize',12,'MarkerFaceColor',[0.50 0.50 0.50],'LineWidth',1.1);
    elseif monkey == "XE"
        plot(mahals(:,1),mahals(:,2),'ksquare','MarkerSize',12,'MarkerFaceColor',[0.50 0.50 0.50],'LineWidth',1.1);
    end

    ylim([ymin ymax]);
    xlim([ymin ymax]);
    xlabel('D distance');
    ylabel('D'' distance');
    set(gca,'FontSize',15);
    legend('','one D/D'' pair','FontSize',15);
    marleneaxes
    axis square

end

end


