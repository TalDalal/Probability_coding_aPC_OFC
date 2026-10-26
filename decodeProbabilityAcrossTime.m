function [realDecoderResult, shuffleDecoderResult] = decodeProbabilityAcrossTime(allMiceData, baselineTimeFrame, decodingTimeFrame, trialsType, labelsTyps, activeNeuronsInput, learningState)
%trialsType = either 'allTrials', 'CS+' or 'CS-' trials.

%labelsTyps = decode either the probaiblity(high or low) or the actual odor
%identity.
clrArray = [155,41,72 ; 255,114,81 ; 255,205,116 ; 85,51,17 ; 153,102,51]./255;
% Decode using the 'active' neurons or 'all' neurons
decodingMethod = 'leave-one-out'%'auROC';%'auROC' or 'leave-one-out'
srCriterion = 0.75;
%% Get the activity matrix per neuron
[allNeuronsActivityMat, timeBins, minNumTrials] = getAllNeuronsActivityMatrix(allMiceData,trialsType);
timeBins = timeBins(1:end-1);
minNumTrials = min(minNumTrials);


%% Get the sessions nums 
[successRates] = getSuccessRatesForEachNeuron(allMiceData);
meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';

switch learningState
    case 'naive'
        allNeuronsActivityMat = allNeuronsActivityMat(naiveInds);
    case 'expert'
        allNeuronsActivityMat = allNeuronsActivityMat(expertInds);
end

%% Decode
%Time frames
winSize = .1;%Sec
timeJump = mean(diff(timeBins));
winSizeIndex = round((winSize/timeJump));


decoderTimeBins = find(timeBins >= decodingTimeFrame(1) & timeBins < decodingTimeFrame(end)+winSize);
baselineInds = find(timeBins >= baselineTimeFrame(1) & timeBins < baselineTimeFrame(end));


%Number of bootstrap reps.
bootstrapIterNum = 30;
allConfusionMats = zeros(2,2);allMeanCurrTimeBin = [];

%Rin over time
for timeBinInd = 1:length(decoderTimeBins)-winSizeIndex
    
    allSRsCurrTimeBin = nan(1,bootstrapIterNum);allSRsCurrTimeBinSHUFF = allSRsCurrTimeBin;
    
    % Ron over bootstrap reps
    for bootInd = 1:bootstrapIterNum
        
        allNeuronsMatrix = nan(minNumTrials*2, length(allNeuronsActivityMat));
        
        for neuronInd = 1:length(allNeuronsActivityMat)
            
            % Build the matrix either in respect to the probability label
            % (high or low) or in respect to the odor identity (A or C).
            switch labelsTyps
                case 'Probability'
                    highMat = allNeuronsActivityMat(neuronInd).High;
                    lowMat = allNeuronsActivityMat(neuronInd).Low;
                case 'Identity'
                    highMat = allNeuronsActivityMat(neuronInd).A;
                    lowMat = allNeuronsActivityMat(neuronInd).C;
            end
            
            %---- High condition
            randtrialsHigh = randsample(size(highMat,1),minNumTrials, 'false');
            
            currIterHighMat = highMat(randtrialsHigh, decoderTimeBins(timeBinInd:timeBinInd + winSizeIndex-1));
            currIterHighMat_BG = highMat(randtrialsHigh, baselineInds);
            
            
            %---- Low condition
            randtrialsLow = randsample(size(lowMat,1),minNumTrials, 'false');
            currIterLowMat = lowMat(randtrialsLow, decoderTimeBins(timeBinInd:timeBinInd + winSizeIndex-1));
            currIterLowMat_BG = lowMat(randtrialsLow, baselineInds);
            
            %Evoked FR
            %             pooledBG = mean([mean(currIterLowMat_BG,2) mean(currIterHighMat_BG,2)], 2);
            evokedFRLow = mean(currIterLowMat,2) - mean(currIterLowMat_BG,2);
            evokedFRHigh = mean(currIterHighMat,2) - mean(currIterHighMat_BG,2);
            
            allNeuronsMatrix(:,neuronInd) = [evokedFRHigh ; evokedFRLow];
        end
        
        % Restrict the analysis to active neurons only
        if ~isempty(activeNeuronsInput)
            allNeuronsMatrix = allNeuronsMatrix(:,activeNeuronsInput);
        end

        switch decodingMethod
            case 'auROC'
                % Generate two example distributions
                dist0 = allNeuronsMatrix(1:minNumTrials,:);dist0 = dist0(:);
                dist1 = allNeuronsMatrix(minNumTrials+1:end,:);dist1 = dist1(:);
                
                
                [AUC] = auROC_TwoDistributions(dist0, dist1, 0);
                allSRsCurrTimeBin(bootInd) = AUC;
                
                %-SHUFFLE
                r0 = randsample(size(allNeuronsMatrix,1), minNumTrials);
                dist0SHUFF = allNeuronsMatrix(r0,:);dist0SHUFF = dist0SHUFF(:);
                
                r1 = setdiff(1:size(allNeuronsMatrix,1), r0);
                dist1SHUFF = allNeuronsMatrix(r1,:);dist1SHUFF = dist1SHUFF(:);
                [AUC_SHUFF] = auROC_TwoDistributions(dist0SHUFF, dist1SHUFF, 0);
                allSRsCurrTimeBinSHUFF(bootInd) = AUC_SHUFF;
                
            case 'leave-one-out'

                % insert the activity matrix to the decoder
                [finalSR, ~] = linearBinaryDecoder(allNeuronsMatrix);
                
                allSRsCurrTimeBin(bootInd) = mean(finalSR(1));
                allSRsCurrTimeBinSHUFF(bootInd) = mean(finalSR(2));
                
                %         allConfusionMats = allConfusionMats + confusionMatrix;
                %         allMeanCurrTimeBin(end+1,:) = [mean(allNeuronsMatrix,2)'];
        end
        
        
    end
    
    
    allSRsAllTimeBin(:,timeBinInd) =  [mean(allSRsCurrTimeBin) ; std(allSRsCurrTimeBin)];
    allSRsAllTimeBinSHUFF(:,timeBinInd) =  [mean(allSRsCurrTimeBinSHUFF) ; std(allSRsCurrTimeBinSHUFF)];
    
    
    %For debug
    %     allConfusionMats = allConfusionMats./bootstrapIterNum;
    
end
%% Plot
patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];csOdorsTimeWin = [0 1];
minMaxPatch = [0.3 1.05];
figure;
hold all;

patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

timeVecForPlot = timeBins(decoderTimeBins(1:end-winSizeIndex));
errorbar_patch(timeVecForPlot, allSRsAllTimeBin(1,:), allSRsAllTimeBin(2,:), clrArray(1,:))
plot(timeVecForPlot, allSRsAllTimeBinSHUFF(1,:), 'k--');

box off;set(gca, 'FontSize', 18);
xlabel('Time (sec)');ylabel('Accuracy ');set(gcf, 'Renderer', 'painters');
ylim(minMaxPatch);xlim(decodingTimeFrame)
plot([timeVecForPlot(1) timeVecForPlot(end)], [.5 .5], 'k--')
title(['N = ' num2str(size(allNeuronsMatrix,2)) ' neurons'])

%% Output
realDecoderResult = [timeVecForPlot ; allSRsAllTimeBin(1,:) ; allSRsAllTimeBin(2,:)];
shuffleDecoderResult = [timeVecForPlot ; allSRsAllTimeBinSHUFF(1,:) ; allSRsAllTimeBinSHUFF(2,:)];
