function [meanCurve, seCurve, learningCurvesMat] = superImposedLearnignCurvesAllMice(allMiceData, srCriterion)
% Plot the learning curve per mouse
pretrainCounter = 0;sessionNumPretrain = [];

lowColor = [171,62,143]./255;%purple
highColor = [0,169,137]./255;%green

learningCurvesMat = [];learningCurvesMatHigh = [];learningCurvesMatLow = [];

figure;
hold all;

for mouseInd = 1:size(allMiceData,2)
    mouseData = allMiceData(mouseInd);probExpCounter = 0;
    for recInd = 1:size(mouseData.allRecs,2)
        
        if mouseData.allRecs(recInd).sessionNum > 0
            probExpCounter = probExpCounter + 1;
            
            if mouseData.allRecs(recInd).data.probability.A > mouseData.allRecs(recInd).data.probability.C
                %--------A success rate
                H_SR(probExpCounter) = mouseData.allRecs(recInd).data.successRate.A;
                
                H_numTrials(probExpCounter) = length(find((abs(mouseData.allRecs(recInd).data.trialsIndex)==1)));
                
                %-------C success rate
                L_SR(probExpCounter) = mouseData.allRecs(recInd).data.successRate.C;
                
                L_numTrials(probExpCounter) = length(find((abs(mouseData.allRecs(recInd).data.trialsIndex)==3)));
            else
                %--------A success rate
                L_SR(probExpCounter) = mouseData.allRecs(recInd).data.successRate.A;
                
                L_numTrials(probExpCounter) = length(find((abs(mouseData.allRecs(recInd).data.trialsIndex)==1)));
                
                %-------C success rate
                H_SR(probExpCounter) = mouseData.allRecs(recInd).data.successRate.C;
                
                H_numTrials(probExpCounter) = length(find((abs(mouseData.allRecs(recInd).data.trialsIndex)==3)));
            end
            
            sessionNum(probExpCounter) = mouseData.allRecs(recInd).sessionNum;
        end
        
    end

    %Sort the data by the session number (according to training days)
    [~, sessNumInds] = sort(sessionNum);
    cumNumHTrials = cumsum(H_numTrials);
    allSessionsTrialsSum(mouseInd) = cumNumHTrials(end);

    %% Plot
    chanceMarker = 50;
    criterionMarker = srCriterion.*100;
    
    %The mean learning curve
    learningCurvesMat(end+1,1:length(cumNumHTrials)) = mean([H_SR(sessNumInds);L_SR(sessNumInds)]).*100;
    %The mean learning curve divided for high and low
    learningCurvesMatHigh(end+1,1:length(cumNumHTrials)) = (H_SR(sessNumInds)).*100;
    learningCurvesMatLow(end+1,1:length(cumNumHTrials)) = (L_SR(sessNumInds)).*100;
    
    H_numTrials = [];L_numTrials = [];H_SR = [];L_SR = [];sessionNum = [];cumNumHTrials = [];
end


%% Plot all curves and thier mean
learningCurvesMat(find(learningCurvesMat(:)==0)) = NaN;
meanCurve = nanmean(learningCurvesMat);
seCurve = nanstd(learningCurvesMat)./sqrt(size(learningCurvesMat, 1));
figure;
plot(learningCurvesMat', 'Color', [.5 .5 .5])
hold all;
errorbar_patch(1:size(learningCurvesMat,2), meanCurve, seCurve, [0, 71, 171]./255)

plot([0 size(learningCurvesMat,2)], [chanceMarker chanceMarker], 'k--')
plot([0 size(learningCurvesMat,2)], [criterionMarker criterionMarker], 'k--')
set(gca, 'FontSize', 18);box off;
ylim([0 100]);ylabel('Performance (%)');xlabel('Sessions')


%% Plot all curves and thier mean divided to high and low
learningCurvesMatHigh(find(learningCurvesMatHigh(:)==0)) = NaN;
learningCurvesMatLow(find(learningCurvesMatLow(:)==0)) = NaN;

meanCurveHigh = nanmean(learningCurvesMatHigh);
seCurveHigh = nanstd(learningCurvesMatHigh)./sqrt(size(learningCurvesMatHigh, 1));

meanCurveLow = nanmean(learningCurvesMatLow);
seCurveLow = nanstd(learningCurvesMatLow)./sqrt(size(learningCurvesMatLow, 1));

figure;
%Plot individual curves
plot(learningCurvesMatHigh', 'Color', highColor, 'LineWidth', 0.5)
hold all;
plot(learningCurvesMatLow', 'Color', lowColor, 'LineWidth', 0.5)
% Plot the mean
errorbar_patch(1:size(learningCurvesMatHigh,2), meanCurveHigh, seCurveHigh, highColor)
errorbar_patch(1:size(learningCurvesMatLow,2), meanCurveLow, seCurveLow, lowColor)

plot([0 size(learningCurvesMatHigh,2)], [chanceMarker chanceMarker], 'k--')
plot([0 size(learningCurvesMatHigh,2)], [criterionMarker criterionMarker], 'k--')
set(gca, 'FontSize', 18);box off;
ylim([0 100]);ylabel('Performance (%)');xlabel('Sessions')



