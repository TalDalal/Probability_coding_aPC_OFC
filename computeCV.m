function [CVdata] = computeCV(allMiceData, bgPeriod, psthTimeWin, pValueTH, trialsIncluded, responseFlag)

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green


%% Get the sessions nums 
[successRates] = getSuccessRatesForEachNeuron(allMiceData);

%% Get binary mat of active neurons
[activityMat_High, activityMat_Low, allTrialsActivity, ~, highFlag] = responondingNeuronsWithinATimeWindow(allMiceData, pValueTH, bgPeriod, psthTimeWin, trialsIncluded);
close;

%% Find the relevant neurons - naive vs expert, responding and inh vs exc

% Neurons recorded in naive and expert performance
srCriterion = 0.8;
meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';
performaceTitles = {'naive', 'expert'};


responseDirectionHigh = activityMat_High;responseDirectionLow = activityMat_Low;
% Find the indices of the active neurons
switch responseFlag
    case 'jointResponse'
        
        activeNeuronsExc_High = find(activityMat_High > 0 & activityMat_Low > 0);
        activeNeuronsExc_Low = find(activityMat_High > 0 & activityMat_Low > 0);
        
        activeNeuronsInh_High = find(activityMat_High < 0 & activityMat_Low < 0);
        activeNeuronsInh_Low = find(activityMat_High < 0 & activityMat_Low < 0);
        
    case 'individualResponse'
        
        activeNeuronsExc_High = find(responseDirectionHigh(:) == 1);
        activeNeuronsExc_Low = find(responseDirectionLow(:) == 1);
        
        activeNeuronsInh_High = find(responseDirectionHigh(:) == -1);
        activeNeuronsInh_Low = find(responseDirectionLow(:) == -1);
end

for performanceInd = 1:length(performaceTitles)
    naiveOrExpert = performaceTitles{performanceInd};
    
    switch naiveOrExpert
        case 'naive'
            performanceInds = naiveInds;
        case 'expert'
            performanceInds = expertInds;
    end
    
    
    % Neurons that responded in excitation
    %------HIGH---------
    High_responding_exc_inds = intersect(activeNeuronsExc_High ,performanceInds);
    High_responding_inh_inds = intersect(activeNeuronsInh_High ,performanceInds);
    pooledHighIndices = [High_responding_exc_inds];%;High_responding_inh_inds];
    
    for cvInd = 1:length(pooledHighIndices)
        if strcmpi(highFlag{pooledHighIndices(cvInd)}, 'A')
            currNeuron = allTrialsActivity(pooledHighIndices(cvInd)).A;
        else
            currNeuron = allTrialsActivity(pooledHighIndices(cvInd)).C;
        end
        cvHigh(cvInd) = std(currNeuron)./mean(currNeuron);
    end
        
    %------LOW---------
    Low_responding_exc_inds = intersect(activeNeuronsExc_Low ,performanceInds);
    Low_responding_inh_inds = intersect(activeNeuronsInh_Low ,performanceInds);
    pooledLowIndices = [Low_responding_exc_inds];%;Low_responding_inh_inds];
    
    cvInd = [];currNeuron = [];
    for cvInd = 1:length(pooledLowIndices)
        if strcmpi(highFlag{pooledHighIndices(cvInd)}, 'C')
            currNeuron = allTrialsActivity(pooledHighIndices(cvInd)).C;
        else
            currNeuron = allTrialsActivity(pooledHighIndices(cvInd)).A;
        end
        cvLow(cvInd) = std(currNeuron)./mean(currNeuron);
    end

    CVdata(performanceInd).High = cvHigh;
    CVdata(performanceInd).Low = cvLow;
    cvHigh = [];cvLow = [];
end
%% Plot
dataForScatter{1} = CVdata(1).High;
dataForScatter{2} = CVdata(1).Low;
dataForScatter{3} = CVdata(2).High;
dataForScatter{4} = CVdata(2).Low;

[~,pNaive] = ttest2(CVdata(1).High, CVdata(1).Low);
[~,pExpert] = ttest2(CVdata(2).High, CVdata(2).Low);

figure;
plotSpread(dataForScatter, 'xNames', {'H_naive', 'L_naive', 'H_expert', 'L_expert'}, ...
            'distributionMarkers', {'o', 'o','o', 'o'}, 'distributionColors', repmat([highProbColor ; lowProbColor ],2,1), 'showMM', 1)
        title(['P naive = ' num2str(pNaive) ', P expert = ' num2str(pExpert)])


