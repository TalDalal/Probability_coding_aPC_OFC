function [allSRsAllTimeBin_High, allSRsAllTimeBin_Low, neuronsUsedVector] = odorDetectionAsAfunctionOfNeuronsUsed(allMiceData, baselineTimeFrame, decodingTimeFrame, trialsType, labelsTyps, activeNeuronsInput)
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

decoderTimeBins = find(timeBins >= decodingTimeFrame(1) & timeBins < decodingTimeFrame(end));
baselineInds = find(timeBins >= baselineTimeFrame(1) & timeBins < baselineTimeFrame(end));


%% Decode
jumpFactor = 20;
if ~isempty(activeNeuronsInput)
    jumpSize = round(length(activeNeuronsInput)./jumpFactor);
    neuronsUsedVector = round(jumpSize:jumpSize:length(activeNeuronsInput));
else
    jumpSize = round(size(allNeuronsActivityMat,2))./jumpFactor;
    neuronsUsedVector = round(jumpSize:jumpSize:size(allNeuronsActivityMat,2));
end
    


%Number of bootstrap reps.
bootstrapIterNum = 100;

%Rin over time
for neuronsUsedInd = 1:length(neuronsUsedVector)
    
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
            
            currIterHighMat = highMat(randtrialsHigh, decoderTimeBins);
            currIterHighMat_BG = highMat(randtrialsHigh, baselineInds);
            
            
            %---- Low condition
            randtrialsLow = randsample(size(lowMat,1),minNumTrials, 'false');
            currIterLowMat = lowMat(randtrialsLow, decoderTimeBins);
            currIterLowMat_BG = lowMat(randtrialsLow, baselineInds);
            
            
            allNeuronsMatrix_High(:,neuronInd) = [mean(currIterHighMat,2) ; mean(currIterHighMat_BG,2)];
            allNeuronsMatrix_Low(:,neuronInd) = [mean(currIterLowMat,2) ; mean(currIterLowMat_BG,2)];
        end
        
        % Restrict the analysis to active neurons only
        if ~isempty(activeNeuronsInput)
            currNeurons = randsample(activeNeuronsInput, neuronsUsedVector(neuronsUsedInd));
            allNeuronsMatrix_High = allNeuronsMatrix_High(:,currNeurons);
            allNeuronsMatrix_Low = allNeuronsMatrix_Low(:,currNeurons);
        else
            currNeurons = randsample(size(allNeuronsActivityMat,2), neuronsUsedVector(neuronsUsedInd));
            allNeuronsMatrix_High = allNeuronsMatrix_High(:,currNeurons);
            allNeuronsMatrix_Low = allNeuronsMatrix_Low(:,currNeurons); 
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
    
    
    allSRsAllTimeBin_High(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBin_High) ; std(allSRsCurrTimeBin_High)];
    allSRsAllTimeBinSHUFF_High(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBinSHUFF_High) ; std(allSRsCurrTimeBinSHUFF_High)];
    
    allSRsAllTimeBin_Low(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBin_Low) ; std(allSRsCurrTimeBin_Low)];
    allSRsAllTimeBinSHUFF_Low(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBinSHUFF_Low) ; std(allSRsCurrTimeBinSHUFF_Low)];

    
end
%% Plot
figure;
%High
errorbar_patch(neuronsUsedVector, allSRsAllTimeBin_High(1,:), allSRsAllTimeBin_High(2,:), highProbColor)
plot(neuronsUsedVector, allSRsAllTimeBinSHUFF_High(1,:),'Color', highProbColor,'LineStyle', '--');
%Low
errorbar_patch(neuronsUsedVector, allSRsAllTimeBin_Low(1,:), allSRsAllTimeBin_Low(2,:), lowProbColor)
plot(neuronsUsedVector, allSRsAllTimeBinSHUFF_Low(1,:),'Color', lowProbColor,'LineStyle', '--');
box off;set(gca, 'FontSize', 18);
xlabel('Neurons');ylabel('Accuracy ');set(gcf, 'Renderer', 'painters');

