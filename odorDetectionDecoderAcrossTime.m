function [] = odorDetectionDecoderAcrossTime(allMiceData, baselineTimeFrame, decodingTimeFrame, trialsType, labelsTyps, activeNeuronsInput)
%trialsType = either 'allTrials', 'CS+' or 'CS-' trials.

%labelsTyps = decode either the probaiblity(high or low) or the actual odor
%identity.
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

% Decode using the 'active' neurons or 'all' neurons
decodingMethod = 'leave-one-out'%'auROC';%'auROC' or 'leave-one-out'
%% Get the activity matrix per neuron
[allNeuronsActivityMat, timeBins, minNumTrials] = getAllNeuronsActivityMatrix(allMiceData,trialsType);
timeBins = timeBins(1:end-1);
minNumTrials = min(minNumTrials);


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
    
    allSRsCurrTimeBin_High = nan(1,bootstrapIterNum);allSRsCurrTimeBinSHUFF_High = allSRsCurrTimeBin_High;
    
    % Ron over bootstrap reps
    for bootInd = 1:bootstrapIterNum
        
        allNeuronsMatrix_High = nan(minNumTrials*2, length(allNeuronsActivityMat));
        
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
            
            
            allNeuronsMatrix_High(:,neuronInd) = [mean(currIterHighMat,2) ; mean(currIterHighMat_BG,2)];
            allNeuronsMatrix_Low(:,neuronInd) = [mean(currIterLowMat,2) ; mean(currIterLowMat_BG,2)];
        end
        
        % Restrict the analysis to active neurons only
        if ~isempty(activeNeuronsInput)
            allNeuronsMatrix_High = allNeuronsMatrix_High(:,activeNeuronsInput);
            allNeuronsMatrix_Low = allNeuronsMatrix_Low(:,activeNeuronsInput);
        end

        % insert the activity matrix to the decoder
        %High
        [finalSR_High, ~] = linearBinaryDecoder(allNeuronsMatrix_High);
        [finalSR_Low, ~] = linearBinaryDecoder(allNeuronsMatrix_Low);
        
        %High
        allSRsCurrTimeBin_High(bootInd) = mean(finalSR_High(1));
        allSRsCurrTimeBinSHUFF_High(bootInd) = mean(finalSR_High(2));
        %Low
        allSRsCurrTimeBin_Low(bootInd) = mean(finalSR_Low(1));
        allSRsCurrTimeBinSHUFF_Low(bootInd) = mean(finalSR_Low(2));

    end
    
    
    allSRsAllTimeBin_High(:,timeBinInd) =  [mean(allSRsCurrTimeBin_High) ; std(allSRsCurrTimeBin_High)];
    allSRsAllTimeBinSHUFF_High(:,timeBinInd) =  [mean(allSRsCurrTimeBinSHUFF_High) ; std(allSRsCurrTimeBinSHUFF_High)];
    
    allSRsAllTimeBin_Low(:,timeBinInd) =  [mean(allSRsCurrTimeBin_Low) ; std(allSRsCurrTimeBin_Low)];
    allSRsAllTimeBinSHUFF_Low(:,timeBinInd) =  [mean(allSRsCurrTimeBinSHUFF_Low) ; std(allSRsCurrTimeBinSHUFF_Low)];

    
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
%High
errorbar_patch(timeVecForPlot, allSRsAllTimeBin_High(1,:), allSRsAllTimeBin_High(2,:), highProbColor)
plot(timeVecForPlot, allSRsAllTimeBinSHUFF_High(1,:),'Color', highProbColor,'LineStyle', '--');
%Low
errorbar_patch(timeVecForPlot, allSRsAllTimeBin_Low(1,:), allSRsAllTimeBin_Low(2,:), lowProbColor)
plot(timeVecForPlot, allSRsAllTimeBinSHUFF_Low(1,:),'Color', lowProbColor,'LineStyle', '--');


box off;set(gca, 'FontSize', 18);
xlabel('Time (sec)');ylabel('Accuracy ');set(gcf, 'Renderer', 'painters');
ylim(minMaxPatch);xlim(decodingTimeFrame)
plot([timeVecForPlot(1) timeVecForPlot(end)], [.5 .5], 'k--')
title(['N = ' num2str(size(allNeuronsMatrix_High,2)) ' neurons'])

