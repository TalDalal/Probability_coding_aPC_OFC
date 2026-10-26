function [] = lickLatencyVSsessionsNum(allMiceData)


sessionNum = [];meanRT = [];meanSR = [];
for mouseInd = 1:size(allMiceData,2)
    
    allRecs = allMiceData(mouseInd).allRecs;
    for recInd = 1:size(allRecs,2)
        if allRecs(recInd).sessionNum > 0% ONLY experiment sessions and not pretraining
            
            
            curr_H_RT = allRecs(recInd).data.firstLickLatency.A;
            curr_L_RT = allRecs(recInd).data.firstLickLatency.C;
            
            meanRT(end+1) = mean([curr_H_RT curr_L_RT]);
            sessionNum(end+1) = allRecs(recInd).sessionNum;
            meanSR(end+1) = mean([allRecs(recInd).data.successRate.A allRecs(recInd).data.successRate.C]);
            
            
        end
    end
    
end
%% Plot
% above12 = find(sessionNum >= 12);
% meanRT(above12) = [];
% sessionNum(above12) = [];

figure;
scatter(sessionNum, meanRT)
ylim([-1 1.5])
[r,p] = corr(sessionNum', meanRT');
set(gca, 'FontSize', 18);box off;
ylabel(' Reaction time (S)');xlabel('Session number');
title(['r = ' num2str(r) ', p = ' num2str(p)])

figure;
scatter(meanSR, meanRT)
ylim([-1 1.5])
[r,p] = corr(meanSR', meanRT');
set(gca, 'FontSize', 18);box off;
ylabel(' Reaction time (S)');xlabel('Performance');
title(['r = ' num2str(r) ', p = ' num2str(p)])
lsline



