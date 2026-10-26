function [] = plot_mouse_RT_across_sessions(mouseData)
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
            
            currH_RTs = mouseData.allRecs(recInd).data.firstLickLatency.A;
            currL_RTs = mouseData.allRecs(recInd).data.firstLickLatency.C;
            
            H_RT_mean(probExpCounter) = mean(currH_RTs);
            H_RT_SE(probExpCounter) = std(currH_RTs)./sqrt(length(currH_RTs));
            
            L_RT_mean(probExpCounter) = mean(currL_RTs);
            L_RT_SE(probExpCounter) = std(currL_RTs)./sqrt(length(currL_RTs));
            
        else
            currH_RTs = mouseData.allRecs(recInd).data.firstLickLatency.C;
            currL_RTs = mouseData.allRecs(recInd).data.firstLickLatency.A;
            
            H_RT_mean(probExpCounter) = mean(currH_RTs);
            H_RT_SE(probExpCounter) = std(currH_RTs)./sqrt(length(currH_RTs));
            
            L_RT_mean(probExpCounter) = mean(currL_RTs);
            L_RT_SE(probExpCounter) = std(currL_RTs)./sqrt(length(currL_RTs));
            
        end

        
        sessionNum(probExpCounter) = mouseData.allRecs(recInd).sessionNum;
        
    end
end


%------------ PLOT Prob. Exp DATA-------

%Sort the data by the session number (according to training days)
[~, sessNumInds] = sort(sessionNum);

%% Plot
figure;
% errorbar(cumNumATrials, H_SR(sessNumInds), H_SE(sessNumInds),'Color', AColor, 'LineWidth', 2);
%HIGH
errorbar(1:length(H_RT_mean(sessNumInds)), H_RT_mean(sessNumInds), H_RT_SE(sessNumInds),'Color', highColor);
hold all;
%LOW
errorbar(1:length(L_RT_mean(sessNumInds)), L_RT_mean(sessNumInds), L_RT_SE(sessNumInds),'Color', lowColor);



set(gca, 'FontSize', 18);box off;
ylabel('Reaction time (sec)');xlabel('Sessions')


