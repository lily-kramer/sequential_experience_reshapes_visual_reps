function [allExperiementNumbers]=allSeqeunceExperienceDataFigures(plotfig)
% master function to get data from all three experiments and plot all
% figures. Set plotfig=1 if you want to generate figures. 

if nargin<1
    plotfig=1;
end

% intialize the output structure
allExperiementNumbers.spikesAndMahals_imgExp=[];
allExperiementNumbers.spikesAndMahals_imgSeqExp=[];
allExperiementNumbers.spikesAndMahals_actionSeqExp=[];
allExperiementNumbers.linearity_imgSeqExp=[];
allExperiementNumbers.orderInfo_imgSeqExp=[];
allExperiementNumbers.behavior_actionSeqExp=[];
allExperiementNumbers.taskVariableDecoding_actionSeqExp=[];
allExperiementNumbers.orderInfo_actionSeqExp=[];

% set random number generator to default
rng('default');

%% Experiment 1: Image Experience
% figures 1b,c,e, supplemental figure 1
[allExperiementNumbers.spikesAndMahals_imgExp]=allSpikesAndMahals_imgExp(plotfig);


%% Experiment 2: Image Sequence Experience
% figures 2b-e
[allExperiementNumbers.spikesAndMahals_imgSeqExp]=allSpikesAndMahal_imgSeqExp(plotfig);
% figures 3a,c,d
[allExperiementNumbers.linearity_imgSeqExp]=alllinearseq_imgSeqExp(plotfig);
% figures 3e,f
[allExperiementNumbers.orderInfo_imgSeqExp]=allOrderDecode_imgSeqExp(plotfig);


%% Experiment 3: Action Sequence Experience
% figures 5a,b
[allExperiementNumbers.spikesAndMahals_actionSeqExp]=allSpikesMahal_actionSeq(plotfig);
% figures 4c-f and 6a,c, supplemental figure 2
[allExperiementNumbers.taskVariableDecoding_actionSeqExp,...
    allExperiementNumbers.behavior_actionSeqExp]=allDecodeAndBehavior_actionSeq(plotfig);
% figure 5c,d
[allExperiementNumbers.orderInfo_actionSeqExp]=allMoveOrderDecode_actionSeq(plotfig);


end