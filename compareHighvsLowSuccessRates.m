function [] = compareHighvsLowSuccessRates(allMiceData, analyzeM)

if nargin < 2
    analyzeM = [];
end
    
criterionLevel = 0.7;

for mouseInd = 1:size(allMiceData,2)
    H_SR = [];L_SR = [];M_SR = [];
    allRecs = allMiceData(mouseInd).allRecs;
    
    for recInd = 1:size(allRecs,2)
        if allRecs(recInd).sessionNum > 0% ONLY experiment sessions and not pretraining
            
            if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                
                H_SR(end+1) = allRecs(recInd).data.successRate.A;
                L_SR(end+1) = allRecs(recInd).data.successRate.C;
            else
                
                H_SR(end+1) = allRecs(recInd).data.successRate.C;
                L_SR(end+1) = allRecs(recInd).data.successRate.A;
            end
            if ~isempty(analyzeM) & ~isempty(allRecs(recInd).data.successRate.B)
                M_SR(end+1) = allRecs(recInd).data.successRate.B;
            elseif ~isempty(analyzeM)
                M_SR(end+1) = nan;
            end
        end
    end

    aboveCriterionSessions_H = find(H_SR >= criterionLevel);
    aboveCriterionSessions_L = find(L_SR >= criterionLevel);
     if ~isempty(analyzeM)
             aboveCriterionSessions_M = find(M_SR >= criterionLevel);
             bestSessions_M(mouseInd) = mean(H_SR(aboveCriterionSessions_M)).*100;
     end
    bestSessions_High(mouseInd) = max(H_SR(aboveCriterionSessions_H)).*100;
    bestSessions_Low(mouseInd) = max(L_SR(aboveCriterionSessions_L)).*100;
end
%% Plot
figure;
if ~isempty(analyzeM)
    figXLim = [.5 3.5];
    plot([bestSessions_High ; bestSessions_M; bestSessions_Low], 'k-o', 'MarkerFaceColor', 'k')
else
    figXLim = [.5 2.5];
    plot([bestSessions_High ; bestSessions_Low], 'k-o', 'MarkerFaceColor', 'k')
end
xlim(figXLim)
ylim([0 100]);
hold all;
plot(figXLim, [50 50], 'k--');
plot(figXLim, [criterionLevel criterionLevel].*100, 'k--');
set(gca, 'FontSize', 18);box off;
ylabel('Performance (%)');
