function [meanSRandSTD, meanSRandSTD_SHUFF, binsVec] = performDecodingUsingTrialsMatrix(allTrailsMatrix, neuronsBin, bootstrapIters, minNumTrials)

% Labels 
labels = [zeros(1,minNumTrials), ones(1,minNumTrials)]';
%Shuffled
shuffLabels = randsample(labels, length(labels));

%Bins for the decoder
numOfNeuronsbin = neuronsBin;
numOfBins = floor(size(allTrailsMatrix,2)/numOfNeuronsbin);
binsVec = (1:numOfBins).*numOfNeuronsbin;

%Number of bootstrap reps.
bootstrapIterNum = bootstrapIters;

meanSRandSTD_SHUFF = [];meanSRandSTD = [];
for populationInd = 1:numOfBins
    
    for bootInd = 1:bootstrapIterNum
        
        data = allTrailsMatrix(:,randsample(size(allTrailsMatrix,2),populationInd*numOfNeuronsbin));
        [successRate, ~] = leaveOneOut_cross_validation_high_or_low_odors(data, labels, 100);
        allSRs(bootInd) = successRate;
        
        %Shuffled
        [successRateSHUFF, ~] = leaveOneOut_cross_validation_high_or_low_odors(data, shuffLabels, 100);
        allSRsSHUFF(bootInd) = successRateSHUFF;
        

        
    end
    meanSRandSTD(:,populationInd) = [mean(allSRs);std(allSRs)];
    
    meanSRandSTD_SHUFF(:,populationInd) = [mean(allSRsSHUFF);std(allSRsSHUFF)];
    
end