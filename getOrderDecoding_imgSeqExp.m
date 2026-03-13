function[order_p,rank1Frac,perSplitAcc,earlyResp,lateResp]=getOrderDecoding_imgSeqExp(filename,monkey,shortOrNov)

load(filename,"allStimCounts","baselineCounts","unexpected","allStimIDs");

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

%% exclude noisy trials and channels
[stimcounts,~,trialNumberIDX,allStimIDs,includetrials]=excludeTrialsAndChannels_imgSeqExp(stimcounts,basecounts,trialNumberIDX,allStimIDs,monkey);
unexpected=unexpected(includetrials); % trim unexpected to match good trial list

%% get only expected trials
good=find(unexpected==0); % expected trials
goodidx=ismember(trialNumberIDX,good); % expected presentations
thesestimids=allStimIDs(goodidx);

A=stimcounts(:,thesestimids==1);
B=stimcounts(:,thesestimids==2);
C=stimcounts(:,thesestimids==3);
D=stimcounts(:,thesestimids==4);
ls=[size(A,2) size(B,2) size(C,2) size(D,2)];

if numel(unique(ls))==1 % check if all the images have the same # presenations

    % take mean (over images in sequence and neurons) population response for
    % this trial
    trialMeans=NaN(1,unique(ls));
    for i=1:unique(ls)
        trialSumPopResp=mean(A(:,i))+mean(B(:,i))+mean(C(:,i))+mean(D(:,i));
        trialMeans(i)=trialSumPopResp/4;
    end

    m=25; % set number of trials to use in early and late comparison
    earlytrials=1:m; % get first m trials
    latetrials=size(A,2)-m+1:size(A,2); % get next m trials

    % compile population responses for early and late trials
    earlyResp=trialMeans(earlytrials);
    lateResp=trialMeans(latetrials);

    early{1}=A(:,earlytrials)';
    early{2}=B(:,earlytrials)';
    early{3}=C(:,earlytrials)';
    early{4}=D(:,earlytrials)';

    late{1}=A(:,latetrials)';
    late{2}=B(:,latetrials)';
    late{3}=C(:,latetrials)';
    late{4}=D(:,latetrials)';

    %% get decoding performance for each set of trials
    early4 = orderedCCGP_ABCD(early(1:4));
    late4 = orderedCCGP_ABCD(late(1:4));

    order_p=[early4.orderedCCGP late4.orderedCCGP];
    rank1Frac=[early4.rank1Frac late4.rank1Frac];
    perSplitAcc=[early4.perSplitAcc late4.perSplitAcc];

else

    disp('issue: mismatch in length of in sequences across trials')
end
end

