function[slope,pslope,zresiduals]=getlinearseq_imgSeqExp(filename,shortOrNov,monkey,plotfig)


load(filename,"allStimCounts","baselineCounts","unexpected","allStimIDs");

% double check that channel assignments are correct for this monkey.
% if 1
%     if monkey == "ZI" || monkey == "HE"
%         chans=33:96;
%     elseif monkey == "XE"
%         chans = 65:128;
%     end
% end

stimcounts=allStimCounts;
basecounts=baselineCounts;

%create trial number index
clear trialNumberIDX
trialNumberIDX=[];
tnum = 1;
if shortOrNov==0 % it's a short violation session
    for i=1:length(unexpected) % step through trials
        if unexpected(i)==1 % violation, 3 pres
            tmp=[tnum tnum tnum];
            trialNumberIDX=[trialNumberIDX tmp];
        elseif unexpected(i)==0
            tmp=[tnum tnum tnum tnum]; % expected, 4 pres
            trialNumberIDX=[trialNumberIDX tmp];
        end
        tnum=tnum+1;
    end
end

if shortOrNov==1 % it's a novel seq. session
    for i=1:length(unexpected) % step through trials
        tmp=[tnum tnum tnum tnum]; % it's always a 4 image sequence
        trialNumberIDX=[trialNumberIDX tmp];
        tnum=tnum+1;
    end
end

[stimcounts,~,trialNumberIDX,allStimIDs,includetrials]=excludeTrialsAndChannels_imgSeqExp(stimcounts,basecounts,trialNumberIDX,allStimIDs,monkey);

unexpected=unexpected(includetrials); % trim unexpected to match good trial list

%% get only expected trials
%trialnums=1:length(unexpected);
good=find(unexpected==0); % expected trials
goodidx=ismember(trialNumberIDX,good); % expected presentations

thesestimids=allStimIDs(goodidx);

A=stimcounts(:,thesestimids==1);
B=stimcounts(:,thesestimids==2);
C=stimcounts(:,thesestimids==3);
D=stimcounts(:,thesestimids==4);
numtrials=length(unexpected);

%% normalize counts for expected trials
ztot=zscore([A B C D]')';

A=ztot(:,1:size(A,2));
B=ztot(:,size(A,2)+1:size(A,2)+size(B,2));
C=ztot(:,size(A,2)+size(B,2)+1:size(A,2)+size(B,2)+size(C,2));
D=ztot(:,size(A,2)+size(B,2)+size(C,2):end);

%% pass to linearseq to get slopes, intercepts, and residuals
[SSE,slope,pslope,intercept] = linearseq(A, B, C, D);

%% normalize SSEs: divide by mean over first ten trials
zresiduals=SSE./mean(SSE(1:10));

%% plot example session residuals
if plotfig==1
    figure;
    hold on
    plot(SSE,'kpentagram','markerfacecolor',[0.4 0.4 0.4],'MarkerSize',15);
    xval=0:.01:numtrials+1;
    plot(xval,slope*xval+intercept,'k-')
    marleneaxes
    xlabel('trial number')
    ylabel('sum of squared errors for linear fit')
    title('example session')
    set(gca,'FontSize',14);
end

end