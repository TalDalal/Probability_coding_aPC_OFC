function [] = allSessionsLickPSTH(allMiceData, criterionLevel, plotMflag)

lickSmoothKernel = 0.07;
highLickRaster_Hit = [];lowLickRaster_Hit = [];
highLickRaster_FA = [];lowLickRaster_FA = [];

highColor = [0,169,137]./255;%green
lowColor = [171,62,143]./255;%purple
mediumColor = [150, 74, 0]./255;

% criterionLevel = 0.8;
naiveHighHit = [];naiveLowHit = [];
naiveHighFA = [];naiveLowFA = [];
expertHighHit = [];expertLowHit = [];
expertHighFA = [];expertLowFA = [];

naiveMediumHit = [];naiveMediumFA = [];
expertMediumHit = [];expertMediumFA = [];


for mouseInd = 1:size(allMiceData,2)
    
    allRecs = allMiceData(mouseInd).allRecs;
    
    for recInd = 1:size(allRecs,2)
        
        
        if allRecs(recInd).sessionNum > 0 %& ...
            %                 allRecs(recInd).data.successRate.A > .6 & ...
            %                 allRecs(recInd).data.successRate.C > .6 % ONLY experiment sessions and not pretraining
            
            %This session SR
            currSR = mean([allRecs(recInd).data.successRate.A allRecs(recInd).data.successRate.C]);
            
            if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                
                
                if currSR < criterionLevel %Naive
                    
                    if ~plotMflag
                    %Hit
                    naiveHighHit = [naiveHighHit allRecs(recInd).data.LickRaster.hit.A];
                    naiveLowHit = [naiveLowHit allRecs(recInd).data.LickRaster.hit.C];
                    %FA
                    naiveHighFA = [naiveHighFA allRecs(recInd).data.LickRaster.FA.A];
                    naiveLowFA = [naiveLowFA allRecs(recInd).data.LickRaster.FA.C];
                    end
                    
                    %Medium prob
                    if plotMflag & ~isempty(allRecs(recInd).data.LickRaster.hit.B)
                        %Hit
                        naiveHighHit = [naiveHighHit allRecs(recInd).data.LickRaster.hit.A];
                        naiveLowHit = [naiveLowHit allRecs(recInd).data.LickRaster.hit.C];
                        naiveMediumHit = [naiveMediumHit allRecs(recInd).data.LickRaster.hit.B];
                    end
                    if plotMflag & ~isempty(allRecs(recInd).data.LickRaster.FA.B)
                        %FA
                        naiveHighFA = [naiveHighFA allRecs(recInd).data.LickRaster.FA.A];
                        naiveLowFA = [naiveLowFA allRecs(recInd).data.LickRaster.FA.C];
                        naiveMediumFA = [naiveMediumFA allRecs(recInd).data.LickRaster.FA.B];
                    end
                else
                    if ~plotMflag
                    %Hit
                    expertHighHit = [expertHighHit allRecs(recInd).data.LickRaster.hit.A];
                    expertLowHit = [expertLowHit allRecs(recInd).data.LickRaster.hit.C];
                    %FA
                    expertHighFA = [expertHighFA allRecs(recInd).data.LickRaster.FA.A];
                    expertLowFA = [expertLowFA allRecs(recInd).data.LickRaster.FA.C];
                    end
                    %Medium prob
                    if plotMflag & ~isempty(allRecs(recInd).data.LickRaster.hit.B)
                        %Hit
                        expertHighHit = [expertHighHit allRecs(recInd).data.LickRaster.hit.A];
                        expertLowHit = [expertLowHit allRecs(recInd).data.LickRaster.hit.C];
                        expertMediumHit = [expertMediumHit allRecs(recInd).data.LickRaster.hit.B];
                    end
                    if plotMflag & ~isempty(allRecs(recInd).data.LickRaster.FA.B)
                        %FA
                        expertHighFA = [expertHighFA allRecs(recInd).data.LickRaster.FA.A];
                        expertLowFA = [expertLowFA allRecs(recInd).data.LickRaster.FA.C];
                        expertMediumFA = [expertMediumFA allRecs(recInd).data.LickRaster.FA.B];
                    end
                end
                
                
            else
                if currSR < criterionLevel %Naive
                    
                    if ~plotMflag
                    %Hit
                    naiveHighHit = [naiveHighHit allRecs(recInd).data.LickRaster.hit.C];
                    naiveLowHit = [naiveLowHit allRecs(recInd).data.LickRaster.hit.A];
                    %FA
                    naiveHighFA = [naiveHighFA allRecs(recInd).data.LickRaster.FA.C];
                    naiveLowFA = [naiveLowFA allRecs(recInd).data.LickRaster.FA.A];
                    end
                    
                    %Medium prob
                    if plotMflag & ~isempty(allRecs(recInd).data.LickRaster.hit.B)
                        %Hit
                        naiveHighHit = [naiveHighHit allRecs(recInd).data.LickRaster.hit.C];
                        naiveLowHit = [naiveLowHit allRecs(recInd).data.LickRaster.hit.A];
                        naiveMediumHit = [naiveMediumHit allRecs(recInd).data.LickRaster.hit.B];
                    end
                    if plotMflag & ~isempty(allRecs(recInd).data.LickRaster.FA.B)
                        %FA
                        naiveHighFA = [naiveHighFA allRecs(recInd).data.LickRaster.FA.C];
                        naiveLowFA = [naiveLowFA allRecs(recInd).data.LickRaster.FA.A];
                        naiveMediumFA = [naiveMediumFA allRecs(recInd).data.LickRaster.FA.B];
                    end
                    
                else%Expert
                    
                    if ~plotMflag
                    %Hit
                    expertHighHit = [expertHighHit allRecs(recInd).data.LickRaster.hit.C];
                    expertLowHit = [expertLowHit allRecs(recInd).data.LickRaster.hit.A];
                    %FA
                    expertHighFA = [expertHighFA allRecs(recInd).data.LickRaster.FA.C];
                    expertLowFA = [expertLowFA allRecs(recInd).data.LickRaster.FA.A];
                    end
                    
                    %Medium prob
                    if plotMflag & ~isempty(allRecs(recInd).data.LickRaster.hit.B)
                        %Hit
                        expertHighHit = [expertHighHit allRecs(recInd).data.LickRaster.hit.C];
                        expertLowHit = [expertLowHit allRecs(recInd).data.LickRaster.hit.A];
                        expertMediumHit = [expertMediumHit allRecs(recInd).data.LickRaster.hit.B];
                    end
                    if plotMflag & ~isempty(allRecs(recInd).data.LickRaster.FA.B)
                        %FA
                        expertHighFA = [expertHighFA allRecs(recInd).data.LickRaster.FA.C];
                        expertLowFA = [expertLowFA allRecs(recInd).data.LickRaster.FA.A];
                        expertMediumFA = [expertMediumFA allRecs(recInd).data.LickRaster.FA.B];
                    end
                end
            end
            
            
        end
    end
    
end
%% plot

subplotNum = 2;
%Hit
figure;
subplot(1,subplotNum,1)
title('Naive - hit')
hold all;
mypsth(naiveHighHit, lickSmoothKernel, highColor);
mypsth(naiveLowHit, lickSmoothKernel, lowColor);
if plotMflag
    mypsth(naiveMediumHit, lickSmoothKernel, mediumColor);
end
set(gca, 'FontSize', 18);box off;xlabel('Time relative to CS+ (S)');ylabel('Lick rate (Hz)')

subplot(1,subplotNum,2)
title('Expert - hit')
hold all;
mypsth(expertHighHit, lickSmoothKernel, highColor);
mypsth(expertLowHit, lickSmoothKernel, lowColor);
if plotMflag
    mypsth(expertMediumHit, lickSmoothKernel, mediumColor);
end
set(gca, 'FontSize', 18);box off;xlabel('Time relative to CS+ (S)');ylabel('Lick rate (Hz)')


%FA
figure;
subplot(1,2,1)
title('Naive - FA')
hold all;
mypsth(naiveHighFA, lickSmoothKernel, highColor);
mypsth(naiveLowFA, lickSmoothKernel, lowColor);
set(gca, 'FontSize', 18);box off;xlabel('Time relative to CS+ (S)');ylabel('Lick rate (Hz)')

subplot(1,2,2)
title('Expert - FA')
hold all;
mypsth(expertHighFA, lickSmoothKernel, highColor);
mypsth(expertLowFA, lickSmoothKernel, lowColor);
set(gca, 'FontSize', 18);box off;xlabel('Time relative to CS+ (S)');ylabel('Lick rate (Hz)')


%%
% expertHigh_lickRate = computeLickRates(expertHighHit, [-1 0]);
% expertLow_lickRate = computeLickRates(expertLowHit, [-1 0]);
% 
% [accuracy, predictions] = leaveOneOutBinaryClassification(expertHigh_lickRate, expertLow_lickRate);
end
function [accuracy, predictions] = leaveOneOutBinaryClassification(vec1, vec2)
    % Assign labels
    label1 = ones(length(vec1), 1);
    label2 = -ones(length(vec2), 1);
    
    % Combine data
    data = [vec1(:); vec2(:)];
    labels = [label1; label2];

    % Balance classes by downsampling
    minClassSize = min(length(vec1), length(vec2));
    idx1 = randperm(length(vec1), minClassSize);
    idx2 = randperm(length(vec2), minClassSize);
    
    balancedData = [vec1(idx1); vec2(idx2)];
    balancedLabels = [ones(minClassSize, 1); -ones(minClassSize, 1)];

    % Leave-One-Out classification
    numSamples = length(balancedData);
    predictions = zeros(numSamples, 1);
    
    for i = 1:numSamples
        % Leave one out
        trainData = balancedData;
        trainLabels = balancedLabels;
        testSample = balancedData(i);
        
        % Remove the i-th sample from training data
        trainData(i) = [];
        trainLabels(i) = [];
        
        % Train SVM
        model = fitcsvm(trainData, trainLabels, 'KernelFunction', 'linear');
        
        % Predict test sample
        predictions(i) = predict(model, testSample);
    end
    
    % Compute accuracy
    accuracy = mean(predictions == balancedLabels);
    
    fprintf('Leave-One-Out Classification Accuracy: %.2f%%\n', accuracy * 100);
end

function lickRates = computeLickRates(data, timeRange)
    % Number of trials
    numTrials = length(data);
    
    % Extract start and end times
    tStart = timeRange(1);
    tEnd = timeRange(2);
    duration = tEnd - tStart;
    
    % Initialize output
    lickRates = zeros(numTrials, 1);
    
    for i = 1:numTrials
        % Get lick times for the current trial
        lickTimes = data(i).times;
        
        % Count licks within the specified range
        numLicks = sum(lickTimes >= tStart & lickTimes <= tEnd);
        
        % Compute lick rate (licks per second)
        lickRates(i) = numLicks / duration;
    end
end




