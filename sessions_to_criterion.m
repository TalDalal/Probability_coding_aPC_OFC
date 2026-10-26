function [H_L_first_criterion_session] = sessions_to_criterion(allMiceData, srCriterion)
% Plot the learning curve per mouse
pretrainCounter = 0;sessionNumPretrain = [];

lowColor = [171,62,143]./255;%purple
highColor = [0,169,137]./255;%green

learningCurvesMat = [];learningCurvesMatHigh = [];learningCurvesMatLow = [];
H_L_first_criterion_session = [];
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
    
    H_L_first_criterion_session(end+1,:) = [find(H_SR(sessNumInds) > srCriterion, 1) find(L_SR(sessNumInds) > srCriterion, 1)];
    
    
end

figure;
barwitherr(std(H_L_first_criterion_session)./sqrt(size(H_L_first_criterion_session,1)), mean(H_L_first_criterion_session))
set(gca, 'XTickLabel', {'A', 'B'});   ylabel('Sessions to expert criterion');box off
[~,p] = ttest(H_L_first_criterion_session(:,1), H_L_first_criterion_session(:,2))


