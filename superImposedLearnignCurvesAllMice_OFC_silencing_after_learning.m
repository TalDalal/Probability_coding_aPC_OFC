function [] = superImposedLearnignCurvesAllMice_OFC_silencing_after_learning(allMiceData)
% Plot the learning curve per mouse
maxSessionNum = [];
suppressionColor = [231 122 43]./255;

chanceLevel = 50;
criterionLevel = 70;

figure;
hold all;

for mouseInd = 1:size(allMiceData,2)
    mouseData = allMiceData(mouseInd);
    
    beforeInjSR = [];afterInjSR = [];
    sessionNum_Before = [];sessionNum_after = [];
    
    for recInd = 1:size(mouseData.allRecs,2)
        
        if mouseData.allRecs(recInd).sessionNum > 0
            
            if strcmpi(mouseData.allRecs(recInd).beforeAfterInjection, 'Before')
                beforeInjSR(end+1) = mean([mouseData.allRecs(recInd).data.successRate.A mouseData.allRecs(recInd).data.successRate.C]).*100;

                sessionNum_Before(end+1) = mouseData.allRecs(recInd).sessionNum;
            else
                afterInjSR(end+1) = mean([mouseData.allRecs(recInd).data.successRate.A mouseData.allRecs(recInd).data.successRate.C]).*100;

                sessionNum_after(end+1) = mouseData.allRecs(recInd).sessionNum;
                
            end
        end
        
    end

    
    [~, sessNumInds_before] = sort(sessionNum_Before);
    [~, sessNumInds_after] = sort(sessionNum_after);

    
    sortedBeforeSessions = sessionNum_Before(sessNumInds_before);
    sortedBeforeSessions = [sortedBeforeSessions sortedBeforeSessions(end)+1];
    
    sortedBeforeSR = beforeInjSR(sessNumInds_before);
    sortedBeforeSR = [sortedBeforeSR afterInjSR(sessNumInds_after(1))];
    
    plot(sortedBeforeSessions, sortedBeforeSR,'-s', 'Color', [.5 .5 .5], 'LineWidth', 2, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', [.5 .5 .5])
    plot(sessionNum_after(sessNumInds_after), afterInjSR(sessNumInds_after),'-s', 'Color', suppressionColor, 'LineWidth', 2, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', suppressionColor)
    
    maxSessionNum(end+1) = length([sortedBeforeSessions sessionNum_after]);
    
   
end
% 
plot([1 max(maxSessionNum)], [chanceLevel chanceLevel], 'k--')
plot([1 max(maxSessionNum)], [criterionLevel criterionLevel], 'k--')

set(gca, 'FontSize', 18);box off;
ylim([0 100]);ylabel('Performance (%)');xlabel('Sessions')





