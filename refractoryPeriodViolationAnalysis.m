load('allRecs_M2_PC_tetrodes.mat')
refPeriodValue = [];
for recordInd = 1:size(allRecs,2)
    for ttInd = 1:size(allRecs(recordInd).data.NeuralData.Spikes,2)
        refPeriodValue = [refPeriodValue ... 
            allRecs(recordInd).data.NeuralData.Spikes{ttInd}.percentRefPeriodViolation];
    end
end
figure;
hist(refPeriodValue,100)
xlabel(['% refractory period (' num2str(allRecs(1).data.refPeriodTH*1000) ' violation'])
ylabel('Count')
title(['Median: ' num2str(median(refPeriodValue)) '%']);