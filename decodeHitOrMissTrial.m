function [allSR, signifDecoding] = decodeHitOrMissTrial(correctTrials, incorrectTrials)
% correctTrials = [hit_A];
% incorrectTrials = [miss_A ];

%% ------ Compute the per-trial firing rate for correct trials --------
bgWin = [-2 -1];fgWin = [-1 0];
evokedTrialFRHIT = [];
for trialInd = 1:size(correctTrials,2)
    currTrial = correctTrials(trialInd).times;
    bgFR = length(find(currTrial >= bgWin(1) & currTrial < bgWin(2)))./diff(bgWin);
    fgFR = length(find(currTrial >= fgWin(1) & currTrial < fgWin(2)))./diff(fgWin);
    evokedTrialFRHIT(trialInd) = fgFR - bgFR;
    
    bgFR = [];fgFR = [];currTrial = [];
end
%% ------ Same for incorrect trials --------
evokedTrialFRMISS = [];
for trialInd = 1:size(incorrectTrials,2)
    
    currTrial = incorrectTrials(trialInd).times;
    bgFR = length(find(currTrial >= bgWin(1) & currTrial < bgWin(2)))./diff(bgWin);
    fgFR = length(find(currTrial >= fgWin(1) & currTrial < fgWin(2)))./diff(fgWin);
    evokedTrialFRMISS(trialInd) = fgFR - bgFR;
    bgFR = [];fgFR = [];currTrial = [];
    
end
%% Build data for the decoder
data = [evokedTrialFRMISS evokedTrialFRHIT];
labels = [zeros(1,size(evokedTrialFRMISS,2)) ones(1,size(evokedTrialFRHIT,2))];

%% decode
numBottstrapIterations = 100;
allSR = [];allSR_SHUFF = [];

for bootInds = 1:numBottstrapIterations
    partDataInds = randsample(length(data), length(data), 'true');
    partData = data(partDataInds);
    partLabels = labels(partDataInds);
    %decode
    [successRate, ~] = leaveOneOutBinaryClassification(partData, partLabels, 100);
    partDataSR(bootInds) = successRate;
    %Shuffle
    partLabelsSHUFF = randsample(partLabels, length(partLabels));
    [successRateSHUFF, ~] = leaveOneOutBinaryClassification(partData, partLabelsSHUFF, 100);
    partDataSR_SHUFFLE(bootInds) = successRateSHUFF;
end
%% SR
allSR = [mean(partDataSR) std(partDataSR)];
allSR_SHUFF = [mean(partDataSR_SHUFFLE) std(partDataSR)];

sortedShuff = sort(partDataSR_SHUFFLE);
CI_shuff = sortedShuff(0.95*numBottstrapIterations);
% CI_shuff = mean(partDataSR_SHUFFLE) + 2*std(partDataSR_SHUFFLE);

signifDecoding = 0;
if allSR(1) >= CI_shuff
    signifDecoding = 1;
end



