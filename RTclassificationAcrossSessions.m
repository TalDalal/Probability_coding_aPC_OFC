function [] = RTclassificationAcrossSessions(mouseData, bootstrapIterNum, lickWindow)
% Plot the learning curve per mouse
probExpCounter = 0;pretrainCounter = 0;sessionNumPretrain = [];
analyzeBodor = 0;% include B (50%) trials
successRateCriterion = 0.8;


AColor = [0,169,137]./255;%green
BColor = [2,0,121]./255;%blue
CColor = [171,62,143]./255;%purple

allHighLickRates = [];allLowLickRates = [];

for recInd = 1:size(mouseData.allRecs,2)
    
    if mouseData.allRecs(recInd).sessionNum > 0
        probExpCounter = probExpCounter + 1;
        
        if mouseData.allRecs(recInd).data.probability.A > mouseData.allRecs(recInd).data.probability.C
            
            %-------- HIGH P success rate
            H_SR(probExpCounter) = mouseData.allRecs(recInd).data.successRate.A;
            
            %HITs and FA
            H_HIT_FA(:,probExpCounter) = [mouseData.allRecs(recInd).data.hitRate.A;mouseData.allRecs(recInd).data.FA.A];
            %SE
            H_numTrials(probExpCounter) = length(find((abs(mouseData.allRecs(recInd).data.trialsIndex)==1)));
            H_SE(probExpCounter) = sqrt(H_numTrials(probExpCounter)*H_SR(probExpCounter)*(1-H_SR(probExpCounter)))./100;
            
            %-------LOW P success rate
            L_SR(probExpCounter) = mouseData.allRecs(recInd).data.successRate.C;
            %HIT anf FA
            L_HIT_FA(:,probExpCounter) = [mouseData.allRecs(recInd).data.hitRate.C;mouseData.allRecs(recInd).data.FA.C];
            %SE
            L_numTrials(recInd) = length(find((abs(mouseData.allRecs(recInd).data.trialsIndex)==3)));
            L_SE(probExpCounter) = sqrt(L_numTrials(probExpCounter)*L_SR(probExpCounter)*(1-L_SR(probExpCounter)))./100;
            
            
            RT_High = mouseData.allRecs(recInd).data.firstLickLatency.A;
            RT_Low = mouseData.allRecs(recInd).data.firstLickLatency.C;
            
            % Extract lick rate
            currLicks = [];
            for trialInd = 1:size(mouseData.allRecs(recInd).data.LickRaster.hit.A,2)
                currLicks = mouseData.allRecs(recInd).data.LickRaster.hit.A(trialInd).times;
                highLickRate(trialInd) = length(find(currLicks >= lickWindow(1) & currLicks < lickWindow(2)));
            end
            currLicks = [];
            for trialInd = 1:size(mouseData.allRecs(recInd).data.LickRaster.hit.C,2)
                currLicks = mouseData.allRecs(recInd).data.LickRaster.hit.C(trialInd).times;
                lowLickRate(trialInd) = length(find(currLicks >= lickWindow(1) & currLicks < lickWindow(2)));
            end
        else
            %-------- HIGH P success rate
            H_SR(probExpCounter) = mouseData.allRecs(recInd).data.successRate.C;
            %HITs and FA
            H_HIT_FA(:,probExpCounter) = [mouseData.allRecs(recInd).data.hitRate.C;mouseData.allRecs(recInd).data.FA.C];
            %SE
            H_numTrials(probExpCounter) = length(find((abs(mouseData.allRecs(recInd).data.trialsIndex)==3)));
            H_SE(probExpCounter) = sqrt(H_numTrials(probExpCounter)*H_SR(probExpCounter)*(1-H_SR(probExpCounter)))./100;
            
            %-------LOW P success rate
            L_SR(probExpCounter) = mouseData.allRecs(recInd).data.successRate.A;
            %HIT anf FA
            L_HIT_FA(:,probExpCounter) = [mouseData.allRecs(recInd).data.hitRate.A;mouseData.allRecs(recInd).data.FA.A];
            %SE
            L_numTrials(recInd) = length(find((abs(mouseData.allRecs(recInd).data.trialsIndex)==1)));
            L_SE(probExpCounter) = sqrt(L_numTrials(probExpCounter)*L_SR(probExpCounter)*(1-L_SR(probExpCounter)))./100;
            
            RT_High = mouseData.allRecs(recInd).data.firstLickLatency.C;
            RT_Low = mouseData.allRecs(recInd).data.firstLickLatency.A;
            
            % Extract lick rate
            currLicks = [];
            for trialInd = 1:size(mouseData.allRecs(recInd).data.LickRaster.hit.C,2)
                currLicks = mouseData.allRecs(recInd).data.LickRaster.hit.C(trialInd).times;
                highLickRate(trialInd) = length(find(currLicks >= lickWindow(1) & currLicks < lickWindow(2)));
            end
            currLicks = [];
            for trialInd = 1:size(mouseData.allRecs(recInd).data.LickRaster.hit.A,2)
                currLicks = mouseData.allRecs(recInd).data.LickRaster.hit.A(trialInd).times;
                lowLickRate(trialInd) = length(find(currLicks >= lickWindow(1) & currLicks < lickWindow(2)));
            end
        end
        
        if analyzeBodor %50%
            %--------B success rate
            B_SR(probExpCounter) = mouseData.allRecs(recInd).data.successRate.B;
            
            %HITs and FA
            B_HIT_FA(:,probExpCounter) = [mouseData.allRecs(recInd).data.hitRate.B;mouseData.allRecs(recInd).data.FA.B];
            %SE
            B_numTrials(probExpCounter) = length(find((abs(mouseData.allRecs(recInd).data.trialsIndex)==2)));
            B_SE(probExpCounter) = sqrt(B_numTrials(probExpCounter)*B_SR(probExpCounter)*(1-B_SR(probExpCounter)))./100;
        end
        
        sessionNum(probExpCounter) = mouseData.allRecs(recInd).sessionNum;
        
        allHighLickRates = [allHighLickRates highLickRate(find(highLickRate ~= 0))];
        allLowLickRates = [allLowLickRates lowLickRate(find(lowLickRate ~= 0))];
        
        
        for bootInd = 1:bootstrapIterNum
            
            minTrialNum = min(length(highLickRate), length(lowLickRate));
            highRand = randsample(highLickRate, minTrialNum);
            
            data = [highRand' ; lowLickRate'];
            labels = [ones(minTrialNum,1) ; zeros(minTrialNum,1)];
            data = [highLickRate' ; lowLickRate'];
            labels = [ones(length(highLickRate),1) ; zeros(length(lowLickRate),1)];
            %
            %Decode
            [successRate, ~] = leaveOneOut_cross_validation_high_or_low_odors(data, labels, 100);
            allSRs(bootInd) = successRate;
        end
        
        meanDecodingRatePerSession(:,probExpCounter) = [mean(allSRs) std(allSRs)];
    end
    lowLickRate = [];highLickRate = [];
end
%------------ PLOT Prob. Exp DATA-------

%Sort the data by the session number (according to training days)
[~, sessNumInds] = sort(sessionNum);
cumNumATrials = cumsum(H_numTrials);

%% Plot
figure;
errorbar(cumNumATrials, H_SR(sessNumInds), H_SE(sessNumInds),'Color', AColor, 'LineWidth', 2);
hold all;
if analyzeBodor
    errorbar(cumNumATrials, B_SR(sessNumInds), B_SE(sessNumInds),'Color', BColor, 'LineWidth', 2);
end
errorbar(cumNumATrials, L_SR(sessNumInds), L_SE(sessNumInds),'Color', CColor, 'LineWidth', 2);
errorbar(cumNumATrials, meanDecodingRatePerSession(1,sessNumInds), meanDecodingRatePerSession(2, sessNumInds), 'LineWidth', 2);
plot([0 cumNumATrials(end)], [.5 .5], 'k--')
plot([0 cumNumATrials(end)], [successRateCriterion successRateCriterion], 'k--')
ylim([0 1]);set(gca, 'FontSize', 14');box off;

%% Decode using all sessions
allSRs = [];
for bootInd = 1:bootstrapIterNum
    
    minTrialNum = min(length(allHighLickRates), length(allLowLickRates));
    highRand = randsample(allHighLickRates, minTrialNum);
    
    data = [highRand' ; allLowLickRates'];
    labels = [ones(minTrialNum,1) ; zeros(minTrialNum,1)];
    %
    %Decode
    [successRate, ~] = leaveOneOut_cross_validation_high_or_low_odors(data, labels, 100);
    allSRs(bootInd) = successRate;
end
figure;
hist(allSRs)
mean(allSRs)



