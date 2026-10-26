function [allSRsAllTimeBin_High, allSRsAllTimeBin_Low, neuronsUsedVector] = odorDiscriminationAsAfunctionOfNeuronsUsed(allMiceData, baselineTimeFrame, decodingTimeFrame, trialsType, activeNeuronsInput)
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
    
    allSRsCurrTimeBin_prob = nan(1,bootstrapIterNum);allSRsCurrTimeBinSHUFF_High = allSRsCurrTimeBin_prob;
    allSRsCurrTimeBin_identity = nan(1,bootstrapIterNum);allSRsCurrTimeBinSHUFF_Low = allSRsCurrTimeBin_identity;
    
    % Ron over bootstrap reps
    for bootInd = 1:bootstrapIterNum
        
        allNeuronsMatrix_High = nan(minNumTrials*2, length(allNeuronsActivityMat));
        
        for neuronInd = 1:length(allNeuronsActivityMat)
            
            % Build the matrix either in respect to the probability label
            % (high or low) or in respect to the odor identity (A or C).
            
            highMat = allNeuronsActivityMat(neuronInd).High;
            lowMat = allNeuronsActivityMat(neuronInd).Low;
            
            A_odor_Mat = allNeuronsActivityMat(neuronInd).A;
            C_odor_Mat = allNeuronsActivityMat(neuronInd).C;
            
            
            %---- High condition
            randtrialsHigh = randsample(size(highMat,1),minNumTrials, 'false');
            currIterHighMat = highMat(randtrialsHigh, decoderTimeBins);%
            trialsActivity_high = mean(currIterHighMat,2) - mean(mean(highMat(randtrialsHigh, baselineInds)));
            
            
            %---- Low condition
            randtrialsLow = randsample(size(lowMat,1),minNumTrials, 'false');
            currIterLowMat = lowMat(randtrialsLow, decoderTimeBins);% - mean(mean(lowMat(randtrialsLow, baselineInds)));
            trialsActivity_low = mean(currIterLowMat,2) - mean(mean(lowMat(randtrialsLow, baselineInds)));
            
            
            randtrials_A = randsample(size(A_odor_Mat,1),minNumTrials, 'false');
            currIterA_odor_Mat = A_odor_Mat(randtrials_A, decoderTimeBins);
            trialsActivity_A = mean(currIterA_odor_Mat,2) - mean(mean(A_odor_Mat(randtrials_A, baselineInds)));
            
            randtrials_C = randsample(size(C_odor_Mat,1),minNumTrials, 'false');
            currIterC_odor_Mat = C_odor_Mat(randtrials_C, decoderTimeBins);
            trialsActivity_C = mean(currIterC_odor_Mat,2) - mean(mean(C_odor_Mat(randtrials_C, baselineInds)));
            
            
            allNeuronsMatrix_prob(:,neuronInd) = [trialsActivity_high ; trialsActivity_low];
            allNeuronsMatrix_identity(:,neuronInd) = [trialsActivity_A ; trialsActivity_C];
        end
        
        % Restrict the analysis to active neurons only
        if ~isempty(activeNeuronsInput)
            currNeurons = randsample(activeNeuronsInput, neuronsUsedVector(neuronsUsedInd));
            allNeuronsMatrix_High = allNeuronsMatrix_High(:,currNeurons);
            allNeuronsMatrix_Low = allNeuronsMatrix_Low(:,currNeurons);
        else
            currNeurons = randsample(size(allNeuronsActivityMat,2), neuronsUsedVector(neuronsUsedInd));
            allNeuronsMatrix_prob = allNeuronsMatrix_prob(:,currNeurons);
            allNeuronsMatrix_identity = allNeuronsMatrix_identity(:,currNeurons);
        end
        
        % insert the activity matrix to the decoder
        [finalSR_prob, ~] = linearBinaryDecoder(allNeuronsMatrix_prob);
        [finalSR_identity, ~] = linearBinaryDecoder(allNeuronsMatrix_identity);
        
        %prob
        allSRsCurrTimeBin_prob(bootInd) = mean(finalSR_prob(1));
        allSRsCurrTimeBinSHUFF_prob(bootInd) = mean(finalSR_prob(2));
        %identity
        allSRsCurrTimeBin_identity(bootInd) = mean(finalSR_identity(1));
        allSRsCurrTimeBinSHUFF_identity(bootInd) = mean(finalSR_identity(2));
        
    end
    
    
    allSRsAllTimeBin_prob(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBin_prob) ; std(allSRsCurrTimeBin_prob)];
    allSRsAllTimeBinSHUFF_prob(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBinSHUFF_prob) ; std(allSRsCurrTimeBinSHUFF_prob)];
    
    allSRsAllTimeBin_identity(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBin_identity) ; std(allSRsCurrTimeBin_identity)];
    allSRsAllTimeBinSHUFF_identity(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBinSHUFF_identity) ; std(allSRsCurrTimeBinSHUFF_identity)];
    
    
end
%% Plot
figure;
%High
errorbar_patch(neuronsUsedVector, allSRsAllTimeBin_prob(1,:), allSRsAllTimeBin_prob(2,:), highProbColor)
plot(neuronsUsedVector, allSRsAllTimeBinSHUFF_prob(1,:),'Color', highProbColor,'LineStyle', '--');
%Low
errorbar_patch(neuronsUsedVector, allSRsAllTimeBin_identity(1,:), allSRsAllTimeBin_identity(2,:), lowProbColor)
plot(neuronsUsedVector, allSRsAllTimeBinSHUFF_identity(1,:),'Color', lowProbColor,'LineStyle', '--');
box off;set(gca, 'FontSize', 18);
xlabel('Neurons');ylabel('Accuracy ');set(gcf, 'Renderer', 'painters');

