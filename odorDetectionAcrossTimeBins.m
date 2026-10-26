function [allSRs_High, allSRs_Low, all_SE_High, all_SE_Low, neuronsUsedVector] = odorDetectionAcrossTimeBins(allMiceData, activeNeurons, detectorTimeBins, winSize)
% detectorTimeBins = -2:.2:-1;
for timeInd = 1:length(detectorTimeBins)-(winSize./mean(diff(detectorTimeBins)))
    
    [allSRsAllTimeBin_High, allSRsAllTimeBin_Low, neuronsUsedVector] = ...
        odorDetectionAsAfunctionOfNeuronsUsed(allMiceData, [-4 -3], [detectorTimeBins(timeInd) detectorTimeBins(timeInd)+winSize], 'allTrials', 'Probability', activeNeurons);
    
    allSRs_High(timeInd, :) = allSRsAllTimeBin_High(1,:);
    allSRs_Low(timeInd, :) = allSRsAllTimeBin_Low(1,:);
    
    all_SE_High(timeInd, :) = allSRsAllTimeBin_High(2,:);
    all_SE_Low(timeInd, :) = allSRsAllTimeBin_Low(2,:);
end

figure;
imagesc(detectorTimeBins, (neuronsUsedVector./neuronsUsedVector(end)).*100,(allSRs_High - allSRs_Low)'.*100)
xlabel('Time (S)');ylabel('Neurons used (%)')
set(gca, 'FontSize', 18);box off;
colorbar;crameri vik