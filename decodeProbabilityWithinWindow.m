function [realDecoderResult, shuffleDecoderResult] = decodeProbabilityWithinWindow(allMiceData, baselineTimeFrame, decodingTimeFrame, trialsType, labelsTyps)
%trialsType = either 'allTrials', 'CS+' or 'CS-' trials.

%labelsTyps = decode either the probaiblity(high or low) or the actual odor
%identity.

% Decode using the 'active' neurons or 'all' neurons
decodingMethod = 'leave-one-out'%'auROC';%'auROC' or 'leave-one-out'
%% Get the activity matrix per neuron
[allNeuronsActivityMat, timeBins, minNumTrials] = getAllNeuronsActivityMatrix(allMiceData,trialsType);
timeBins = timeBins(1:end-1);
minNumTrials = min(minNumTrials);



%% Decode

decoderTimeBins = find(timeBins >= decodingTimeFrame(1) & timeBins < decodingTimeFrame(end));
baselineInds = find(timeBins >= baselineTimeFrame(1) & timeBins < baselineTimeFrame(end));


%Number of bootstrap reps.
bootstrapIterNum = 100;

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
        
        currIterHighMat = highMat(randtrialsHigh, decoderTimeBins);
        currIterHighMat_BG = highMat(randtrialsHigh, baselineInds);
        
        
        %---- Low condition
        randtrialsLow = randsample(size(lowMat,1),minNumTrials, 'false');
        currIterLowMat = lowMat(randtrialsLow, decoderTimeBins);
        currIterLowMat_BG = lowMat(randtrialsLow, baselineInds);
        
        %Evoked FR
        %             pooledBG = mean([mean(currIterLowMat_BG,2) mean(currIterHighMat_BG,2)], 2);
        evokedFRLow = mean(currIterLowMat,2) - mean(currIterLowMat_BG,2);
        evokedFRHigh = mean(currIterHighMat,2) - mean(currIterHighMat_BG,2);
        
        BG_High = mean(currIterHighMat_BG,2);
        BG_Low = mean(currIterLowMat_BG,2);
        
        allNeuronsMatrix(:,neuronInd) = [evokedFRHigh ; evokedFRLow];
        allNeuronsMatrix_BG(:,neuronInd) = [BG_High ; BG_Low];
    end
    
    
    
    switch decodingMethod
        case 'auROC'
            % Generate two example distributions
            dist0 = allNeuronsMatrix(1:minNumTrials,:);dist0 = dist0(:);
            dist1 = allNeuronsMatrix(minNumTrials+1:end,:);dist1 = dist1(:);
            
            if decoderTimeBins(timeBinInd)==26
                disp('stop')
            end
            
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
            [finalSR_BG, ~] = linearBinaryDecoder(allNeuronsMatrix_BG);
            
            allSRsCurrTimeBin(bootInd) = mean(finalSR(1));
            allSRsCurrTimeBinSHUFF(bootInd) = mean(finalSR(2));
            
            allSRsCurrTimeBin_BG(bootInd) = mean(finalSR_BG(1));
            allSRsCurrTimeBinSHUFF_BG(bootInd) = mean(finalSR_BG(2));
            
    end
    
    
end
%
%
%     allSRsAllTimeBin(:,timeBinInd) =  [mean(allSRsCurrTimeBin) ; std(allSRsCurrTimeBin)];
%     allSRsAllTimeBinSHUFF(:,timeBinInd) =  [mean(allSRsCurrTimeBinSHUFF) ; std(allSRsCurrTimeBinSHUFF)];

%% Plot

figure;
bar([mean(allSRsCurrTimeBin) mean(allSRsCurrTimeBinSHUFF) mean(allSRsCurrTimeBin_BG) mean(allSRsCurrTimeBinSHUFF_BG)])
