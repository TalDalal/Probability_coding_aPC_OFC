function [] = getLearningCurveForMouse(mouseData)
% Plot the learning curve per mouse
probExpCounter = 0;pretrainCounter = 0;sessionNumPretrain = [];
analyzeBodor = 0;% include B (50%) trials
successRateCriterion = 0.7;


highColor = [0,169,137]./255;%green
BColor = [2,0,121]./255;%blue
lowColor = [171,62,143]./255;%purple

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
        
    else% For pretraining sessions
        
        pretrainCounter = pretrainCounter + 1;
        %-------- Success rate---------
        pretrain_SR(pretrainCounter) = mouseData.allRecs(recInd).data.successRate.T;
        %SE
        pretrain_numTrials(pretrainCounter) = length(mouseData.allRecs(recInd).data.Ttrials);
        pretrain_SE(pretrainCounter) = sqrt(pretrain_numTrials(pretrainCounter)*pretrain_SR(pretrainCounter)*(1-pretrain_SR(pretrainCounter)))./100;
        
        sessionNumPretrain(pretrainCounter) = mouseData.allRecs(recInd).sessionNum;
    end
end

%------------ PLOT PRETRAINING DATA-------
if ~isempty(sessionNumPretrain)
    %Sort the data by the session number (according to training days)
    [~, sessNumIndsPretrain] = sort(sessionNumPretrain);
    cumNumTrials_PRETRAIN = cumsum(pretrain_numTrials);
    %% Plot
    figure;
    errorbar(cumNumTrials_PRETRAIN, pretrain_SR(sessNumIndsPretrain), pretrain_SE(sessNumIndsPretrain), 'k', 'LineWidth', 2);
    hold all;
    plot([0 cumNumTrials_PRETRAIN(end)], [.5 .5], 'k--')
    ylim([0 1]);set(gca, 'FontSize', 14');box off;
    ylabel('Success rate');xlabel('Trials')
    title('Pre train')
    
end

%------------ PLOT Prob. Exp DATA-------

%Sort the data by the session number (according to training days)
[~, sessNumInds] = sort(sessionNum);
cumNumATrials = cumsum(H_numTrials);

%% Plot
figure;
% errorbar(cumNumATrials, H_SR(sessNumInds), H_SE(sessNumInds),'Color', AColor, 'LineWidth', 2);
%HIGH
errorbar_patch(1:length(H_SR(sessNumInds)), H_SR(sessNumInds).*100, H_SE(sessNumInds).*100, highColor);
hold all;
if analyzeBodor
    errorbar(cumNumATrials, B_SR(sessNumInds), B_SE(sessNumInds),'Color', BColor, 'LineWidth', 2);
end
%LOW
errorbar_patch(1:length(L_SR(sessNumInds)), L_SR(sessNumInds).*100, L_SE(sessNumInds).*100, lowColor);




plot([1 length(H_SR(sessNumInds))], [5 5], 'k--')
plot([1 length(H_SR(sessNumInds))], [successRateCriterion successRateCriterion].*100, 'k--')
ylim([0 100]);set(gca, 'FontSize', 18);box off;


ylabel('Performance (%)');xlabel('Sessions')
if analyzeBodor
    legend(['H (' num2str(mouseData.allRecs(1).data.probability.A) '%)'], ...
        ['M (' num2str(mouseData.allRecs(1).data.probability.B) '%)'], ...
        ['L (' num2str(mouseData.allRecs(1).data.probability.C) '%)'])
else
    legend(['H (P = '  num2str(mouseData.allRecs(1).data.probability.A) ')'], ['L (P = ' num2str(mouseData.allRecs(1).data.probability.C) ')'])
end
% title('Probability experiment')

figure;
plot(cumNumATrials, H_HIT_FA(1,sessNumInds)','--s','Color', highColor, 'LineWidth', 2, 'MarkerFaceColor',highColor );
hold all;
plot(cumNumATrials, L_HIT_FA(1,sessNumInds)','--s','Color', lowColor, 'LineWidth', 2, 'MarkerFaceColor',lowColor );
%Plot the FAs
plot(cumNumATrials, H_HIT_FA(2,sessNumInds)','-.d','Color', highColor, 'LineWidth', 2, 'MarkerFaceColor',highColor );
plot(cumNumATrials, L_HIT_FA(2,sessNumInds)','-.d','Color', lowColor, 'LineWidth', 2, 'MarkerFaceColor',lowColor );

plot([0 cumNumATrials(end)], [.5 .5], 'k--')

ylim([0 1]);set(gca, 'FontSize', 14');box off;
ylabel('Success rate');xlabel('Trials')
legend(['H (P = ' num2str(mouseData.allRecs(1).data.probability.A) ')'], ['L (P = ' num2str(mouseData.allRecs(1).data.probability.C) ')'])
title('Hit & FA analysis')
hold off;


