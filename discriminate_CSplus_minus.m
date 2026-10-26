function [allSRsAllTimeBin_High, allSRsAllTimeBin_Low, neuronsUsedVector] = discriminate_CSplus_minus(allMiceData, baselineTimeFrame, decodingTimeFrame, activeNeuronsInput)
%trialsType = either 'allTrials', 'CS+' or 'CS-' trials.

%labelsTyps = decode either the probaiblity(high or low) or the actual odor
%identity.
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

% Decode using the 'active' neurons or 'all' neurons
decodingMethod = 'leave-one-out'%'auROC';%'auROC' or 'leave-one-out'

%% Get the activity matrix per neuron
[allNeuronsActivityMat_CSplus, timeBins, minNumTrials] = getAllNeuronsActivityMatrix(allMiceData,'CS+');
[allNeuronsActivityMat_CSminus, timeBins, minNumTrials] = getAllNeuronsActivityMatrix(allMiceData,'CS-');
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
    jumpSize = round(size(allNeuronsActivityMat_CSplus,2))./jumpFactor;
    neuronsUsedVector = round(jumpSize:jumpSize:size(allNeuronsActivityMat_CSplus,2));
end



%Number of bootstrap reps.
bootstrapIterNum = 100;

%Rin over time
for neuronsUsedInd = 1:length(neuronsUsedVector)
    
    allSRsCurrTimeBin = nan(1,bootstrapIterNum);allSRsCurrTimeBinSHUFF = allSRsCurrTimeBin;

    
    % Ron over bootstrap reps
    for bootInd = 1:bootstrapIterNum
        
        allNeuronsMatrix = nan(minNumTrials*2, length(allNeuronsActivityMat_CSplus));
        
        for neuronInd = 1:length(allNeuronsActivityMat_CSplus)
            
            % Build the matrix either in respect to the probability label
            % (high or low) or in respect to the odor identity (A or C).
            
            CSplus_Mat = [allNeuronsActivityMat_CSplus(neuronInd).A;allNeuronsActivityMat_CSplus(neuronInd).C];
            CSminus_Mat =[allNeuronsActivityMat_CSminus(neuronInd).A;allNeuronsActivityMat_CSminus(neuronInd).C];

            
            %---- CS+ condition
            randtrials_CSplus = randsample(size(CSplus_Mat,1),minNumTrials, 'false');
            currIterMat_CSplus = CSplus_Mat(randtrials_CSplus, decoderTimeBins);%
            trialsActivity_CSplus = mean(currIterMat_CSplus,2) - mean(mean(CSplus_Mat(randtrials_CSplus, baselineInds)));
            
            %---- CS- condition
            randtrials_CSminus = randsample(size(CSminus_Mat,1),minNumTrials, 'false');
            currIterMat_CSminus = CSminus_Mat(randtrials_CSminus, decoderTimeBins);%
            trialsActivity_CSminus = mean(currIterMat_CSminus,2) - mean(mean(CSminus_Mat(randtrials_CSminus, baselineInds)));

            
            
            allNeuronsMatrix(:,neuronInd) = [trialsActivity_CSplus ; trialsActivity_CSminus];

        end
        
        % Restrict the analysis to active neurons only
        if ~isempty(activeNeuronsInput)
            currNeurons = randsample(activeNeuronsInput, neuronsUsedVector(neuronsUsedInd));
            allNeuronsMatrix_High = allNeuronsMatrix_High(:,currNeurons);
            allNeuronsMatrix_Low = allNeuronsMatrix_Low(:,currNeurons);
        else
            currNeurons = randsample(size(allNeuronsActivityMat_CSplus,2), neuronsUsedVector(neuronsUsedInd));
            allNeuronsMatrix = allNeuronsMatrix(:,currNeurons);
        end
        
        % insert the activity matrix to the decoder
        [finalSR, ~] = linearBinaryDecoder(allNeuronsMatrix);
        
        %prob
        allSRsCurrTimeBin(bootInd) = mean(finalSR(1));
        allSRsCurrTimeBinSHUFF(bootInd) = mean(finalSR(2));

        
    end
    
    
    allSRsAllTimeBin(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBin) ; std(allSRsCurrTimeBin)];
    allSRsAllTimeBinSHUFF(:,neuronsUsedInd) =  [mean(allSRsCurrTimeBinSHUFF) ; std(allSRsCurrTimeBinSHUFF)];

    
    
end
%% Plot
figure;
%High
errorbar_patch(neuronsUsedVector, allSRsAllTimeBin(1,:), allSRsAllTimeBin(2,:), highProbColor)
plot(neuronsUsedVector, allSRsAllTimeBinSHUFF(1,:),'Color', highProbColor,'LineStyle', '--');
box off;set(gca, 'FontSize', 18);
xlabel('Neurons');ylabel('Accuracy ');set(gcf, 'Renderer', 'painters');

