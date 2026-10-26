clear;clc;allReactionTimes = [];
dataArray = {'allRecs_M1_PC_tetrodes', 'allRecs_M2_PC_tetrodes'};
mouseNumArray = {'M1_PC_tetrodes', 'M2_PC_tetrodes'};
for mouseInd = 1:length(dataArray)
    
    %% load the xls
    mouseNum = 'M1_PC_tetrodes';
    if ismac
        workingDir = '/Volumes/My Passport/Tal/Experiments/2022/Behavior_Probability/head_fixed/data/';
    else
        workingDir = 'F:\Tal\Experiments\2022\Behavior_Probability\head_fixed\data\';
    end
    
    cd([workingDir mouseNumArray{mouseInd}])
    [successRateMat,reactionTimeMat, numTrials] = successRatesAcrossRecordings(dataArray{mouseInd});
    close;
    if strcmpi(dataArray{mouseInd}, 'allRecs_M1_PC_tetrodes')
        reactionTimeMat = reactionTimeMat';
        reactionTimeMat = reactionTimeMat(:,find(sum(isnan(reactionTimeMat)) == 1))';
    elseif strcmpi(dataArray{mouseInd}, 'allRecs_M2_PC_tetrodes')
        reactionTimeMat(2:6,:) = [];
    end
    
    allReactionTimes = [allReactionTimes ; reactionTimeMat];
end
%%
figure;
plot(1:size(allReactionTimes,2), allReactionTimes,'s-', 'MarkerFaceColor', [0.5 .5 .5])
xlim([0 4])
hold on;
box off;set(gca, 'FontSize', 14')
ylabel('Mean reaction time (S)')
errorbar([0.5 2 3.5], nanmean(allReactionTimes), nanstd(allReactionTimes)./sqrt(size(allReactionTimes,1)), '-sk', 'LineWidth', 3)