function [deltaRT] = getRTcurveForMouse(mouseData)


A_RT = [];C_RT = [];C_RT_SE = [];signifRTdiff = [];
probExpCounter = 0;


for recInd = 1:size(mouseData.allRecs,2)
    if mouseData.allRecs(recInd).sessionNum > 0% ONLY experiment sessions and not pretraining
        
        probExpCounter = probExpCounter + 1;
        
%         if mouseData.allRecs(recInd).data.probability.A > mouseData.allRecs(recInd).data.probability.C
            curr_A_RT = mouseData.allRecs(recInd).data.firstLickLatency.A;
            curr_C_RT = mouseData.allRecs(recInd).data.firstLickLatency.C;
%         else
%             curr_H_RT = mouseData.allRecs(recInd).data.firstLickLatency.C;
%             curr_L_RT = mouseData.allRecs(recInd).data.firstLickLatency.A;
% 
%         end
        A_RT(end+1) = mean(curr_A_RT);
        C_RT(end+1) = mean(curr_C_RT);
        C_RT_SE(end+1) = std(curr_C_RT)./sqrt(length(curr_C_RT));
        [h,~] = ttest2(curr_A_RT, curr_C_RT);
        signifRTdiff(end+1) = h;
        
        sessionNum(probExpCounter) = mouseData.allRecs(recInd).sessionNum;
        
    end
end
[~, sessNumInds] = sort(sessionNum);
A_RT = A_RT(sessNumInds);
C_RT = C_RT(sessNumInds);
%% Plot
%%%% Filter out very beginning sessions < 60% SR %%%%
figure;
plot((A_RT - C_RT)./C_RT_SE, '-sk', 'MarkerFaceColor', 'k')