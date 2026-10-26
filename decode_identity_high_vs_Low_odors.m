function [] = decode_identity_high_vs_Low_odors(analysisTimeWin)
%Prepare the data
[allTrailsMatrix, minNumTrials] = prepareDataForHighLowDecoding(analysisTimeWin);

% Labels (High or low probaiblity odor)
labels = [zeros(1,minNumTrials), ones(1,minNumTrials)]';
%Shuffled
shuffLabels = randsample(labels, length(labels));

%Bins for the decoder
numOfNeuronsbin = 20;
numOfBins = floor(size(allTrailsMatrix,2)/numOfNeuronsbin);
binsVec = (1:numOfBins).*numOfNeuronsbin;

%Number of bootstrap reps.
bootstrapIterNum = 30;

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
%% Plot
classifColor = [2,0,121]./255;
shuffColor = 'k';
figure;
errorbar_patch(binsVec, meanSRandSTD(1,:), meanSRandSTD(2,:), classifColor)
hold all;
errorbar_patch(binsVec, meanSRandSTD_SHUFF(1,:), meanSRandSTD_SHUFF(2,:), shuffColor)
plot([0 binsVec(end)],[ 0.5 .5], 'k--')
ylim([0 1])
set(gcf, 'Renderer', 'painters');set(gca, 'FontSize', 14);box off;
xlabel('Number of neurons');ylabel('Accuracy');
xlim([0  binsVec(end)]);
legend('','High vs. Low', '', 'Shuffled')