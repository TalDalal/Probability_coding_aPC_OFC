function [lickData] = correlation_RT_Performance(allMiceData)




H_RT = [];L_RT = [];H_SR = [];L_SR = [];signifRTdiff = [];SR = [];M_RT = [];
for mouseInd = 1:size(allMiceData,2)
    
    allRecs = allMiceData(mouseInd).allRecs;
    for recInd = 1:size(allRecs,2)
        if allRecs(recInd).sessionNum > 0% ONLY experiment sessions and not pretraining
            
            if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                curr_H_RT = allRecs(recInd).data.firstLickLatency.A;
                curr_L_RT = allRecs(recInd).data.firstLickLatency.C;

            else
                curr_H_RT = allRecs(recInd).data.firstLickLatency.C;
                curr_L_RT = allRecs(recInd).data.firstLickLatency.A;

            end

            %Mean RT
            H_RT(end+1) = mean(curr_H_RT);
            L_RT(end+1) = mean(curr_L_RT);
            %Mean SR
            SR(end+1) = mean([allRecs(recInd).data.successRate.A allRecs(recInd).data.successRate.C]);
            
      
        end
    end
    
end


%% Plot
figure;
scatter(SR, mean([H_RT ; L_RT]), 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k')
[r,p] = corrcoef(SR, mean([H_RT ; L_RT]));
lsline

title(['r = ' num2str(r(2,1)) ', P = ' num2str(p(2,1))])
