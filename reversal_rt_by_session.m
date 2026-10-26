function [] = reversal_rt_by_session(allMiceData)

lickSmoothKernel = 0.07;sessionsCounter = 0;beforeCounter = 0;afterCounter = 0;
lowLickRasterAfter = [];highLickRasterAfter = [];highLickRasterBefore = [];lowLickRasterBefore = [];
L_RT_after = [];H_RT_after = [];
L_RT = [];H_RT = [];

A_prob = [];sessionNum = [];

for mouseInd = 1:size(allMiceData,2)
    sessionNum = [];
    allRecs = allMiceData(mouseInd).allRecs;
    
    for recInd = 1:size(allRecs,2)
        
        
        if allRecs(recInd).sessionNum > 0  % not pretraining
            

                if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                    H_RT(end+1) = mean(allRecs(recInd).data.firstLickLatency.A);
                    L_RT(end+1) = mean(allRecs(recInd).data.firstLickLatency.C);
                else
                    H_RT(end+1) = mean(allRecs(recInd).data.firstLickLatency.C);
                    L_RT(end+1) = mean(allRecs(recInd).data.firstLickLatency.A);
                end
            A_prob(end+1) = allRecs(recInd).data.probability.A;
            sessionNum(end+1) = allRecs(recInd).sessionNum;

        end
    end
    
    detectRevresal = find(diff(A_prob) ~= 0);
    if ~isempty(detectRevresal)
        [~, sessNumInds] = sort(sessionNum);
        rt_mat_after_injection_H(mouseInd,1:length(H_RT_after)) = H_RT_after(sessNumInds);
        rt_mat_after_injection_L(mouseInd,1:length(L_RT_after)) = L_RT_after(sessNumInds);
        H_RT_after = [];L_RT_after = [];
    end
end

%Pool all sessions above number 5
rt_mat_after_injection_H(:,5) = nanmean(rt_mat_after_injection_H(:,5:end),2);
rt_mat_after_injection_H(:,6:end) = [];

rt_mat_after_injection_L(:,5) = nanmean(rt_mat_after_injection_L(:,5:end),2);
rt_mat_after_injection_L(:,6:end) = [];

%% plot
highColor = [0,169,137]./255;%green
lowColor = [171,62,143]./255;%purple


figure;
hold all
errorbar(0, nanmean(H_RT), std(H_RT)./sqrt(length(H_RT)), 'Color', highColor, 'LineWidth', 2, 'Marker', 'o')
errorbar(0, nanmean(L_RT), std(L_RT)./sqrt(length(L_RT)), 'Color', lowColor, 'LineWidth', 2, 'Marker', 'o')

errorbar(1:size(rt_mat_after_injection_H,2), nanmean(rt_mat_after_injection_H), nanstd(rt_mat_after_injection_H)./sqrt(size(rt_mat_after_injection_H,1)), 'Color', highColor, 'LineWidth', 2, 'Marker', 'o')
errorbar(1:size(rt_mat_after_injection_L,2), nanmean(rt_mat_after_injection_L), nanstd(rt_mat_after_injection_L)./sqrt(size(rt_mat_after_injection_L,1)), 'Color', lowColor, 'LineWidth', 2, 'Marker', 'o')
