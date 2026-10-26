function [] = movingResponseRate(allMiceData, bgPeriod, fgPeriod,interval, pValueTH, trialsIncluded)

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

%% Get the sessions vals
[successRates] = getSuccessRatesForEachNeuron(allMiceData);
% Neurons recorded in naive and expert performance
srCriterion = 0.8;
meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';

%% Compute moving response rate
winSize = 0.2;
timeVec = fgPeriod(1):interval:fgPeriod(2);
for timeInd = 1:length(timeVec)-(winSize./interval)
    
    currFG = [timeVec(timeInd) timeVec(timeInd)+winSize];
    [activityMat_High, activityMat_Low] = responondingNeuronsWithinATimeWindow(allMiceData, pValueTH, bgPeriod, currFG, trialsIncluded, 'no');
    close;
    
    naiveHigh = activityMat_High(naiveInds);
    naiveHighRate(timeInd) = length(find(naiveHigh~=0))./length(naiveHigh);
    naiveHighSE(timeInd) = binoDistSE(naiveHighRate(timeInd), length(naiveHigh));
    
    %Low
    naiveLow = activityMat_Low(naiveInds);
    naiveLowRate(timeInd) = length(find(naiveLow~=0))./length(naiveLow);
    naiveLowSE(timeInd) = binoDistSE(naiveLowRate(timeInd), length(naiveLow));
    
    %-naive stats
    [~,p_Naive] = prop_test([naiveHighRate(timeInd) naiveLowRate(timeInd)].*length(naiveLow), ...
        [length(naiveHigh) length(naiveLow)], 'true');
    allPnaive(timeInd) = p_Naive;
    
    %---Expert
    %High
    expertHigh = activityMat_High(expertInds);
    expertHighRate(timeInd) = length(find(expertHigh~=0))./length(expertHigh);
    expertHighSE(timeInd) = binoDistSE(expertHighRate(timeInd), length(expertHigh));
    
    %Low
    expertLow = activityMat_Low(expertInds);
    expertLowRate(timeInd) = length(find(expertLow~=0))./length(expertLow);
    expertLowSE(timeInd) = binoDistSE(expertLowRate(timeInd), length(expertLow));
    
    %-naive stats
    [~,p_Expert] = prop_test([expertHighRate(timeInd) expertLowRate(timeInd)].*length(expertLow), ...
        [length(expertHigh) length(expertLow)], 'true');
    allPexpert(timeInd) = p_Expert;
end

%% 
shortenTimeVec = timeVec(1:end-(winSize./interval));
figure;
errorbar_patch(shortenTimeVec, expertHighRate, expertHighSE, highProbColor);
hold all;
errorbar_patch(shortenTimeVec, expertLowRate, expertLowSE, lowProbColor);

signLocs = find(allPexpert < 0.05);
text(shortenTimeVec(signLocs), max(expertLowRate(signLocs), expertHighRate(signLocs))+.1, '*', 'FontSize', 50)
set(gca, 'FontSize', 18);box off;xlabel('Time relative to CS+ (S)');ylabel('% Active neurons')