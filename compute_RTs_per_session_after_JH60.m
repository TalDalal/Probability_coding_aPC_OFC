function [] = compute_RTs_per_session_after_JH60(allMiceData, srCriterion)

lickSmoothKernel = 0.07;sessionsCounter = 0;beforeCounter = 0;afterCounter = 0;
lowLickRasterAfter = [];highLickRasterAfter = [];highLickRasterBefore = [];lowLickRasterBefore = [];
L_RT_after = [];H_RT_after = [];
L_RT_before = [];H_RT_before = [];

rt_mat_after_injection_H = nan(size(allMiceData,2), 10);
rt_mat_after_injection_L = rt_mat_after_injection_H;

for mouseInd = 1:size(allMiceData,2)
    sessionNum_after = [];
    allRecs = allMiceData(mouseInd).allRecs;
    
    for recInd = 1:size(allRecs,2)
        
        
        if allRecs(recInd).sessionNum > 0 & ... % not pretraining
                allRecs(recInd).data.successRate.A > srCriterion & ...
                allRecs(recInd).data.successRate.C > srCriterion; % ONLY experiment sessions above criterion
            
            if strcmpi(allRecs(recInd).beforeAfterInjection, 'Before')
                if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                    H_RT_before(end+1) = mean(allRecs(recInd).data.firstLickLatency.A);
                    L_RT_before(end+1) = mean(allRecs(recInd).data.firstLickLatency.C);
                else
                    H_RT_before(end+1) = mean(allRecs(recInd).data.firstLickLatency.C);
                    L_RT_before(end+1) = mean(allRecs(recInd).data.firstLickLatency.A);
                end

            else %after
                sessionNum_after(end+1) = allRecs(recInd).sessionNum;
                if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                    H_RT_after(end+1) = mean(allRecs(recInd).data.firstLickLatency.A);
                    L_RT_after(end+1) = mean(allRecs(recInd).data.firstLickLatency.C);
                else
                    H_RT_after(end+1) = mean(allRecs(recInd).data.firstLickLatency.C);
                    L_RT_after(end+1) = mean(allRecs(recInd).data.firstLickLatency.A);
                end

            end
            

        end
    end
    [~, sessNumInds_after] = sort(sessionNum_after);
    rt_mat_after_injection_H(mouseInd,1:length(H_RT_after)) = H_RT_after(sessNumInds_after);
    rt_mat_after_injection_L(mouseInd,1:length(L_RT_after)) = L_RT_after(sessNumInds_after);
    H_RT_after = [];L_RT_after = [];
end

%Pool all sessions above number 5
maxTrialToPool = 4;
rt_mat_after_injection_H(:,maxTrialToPool) = nanmean(rt_mat_after_injection_H(:,maxTrialToPool:end),2);
rt_mat_after_injection_H(:,maxTrialToPool+1:end) = [];

rt_mat_after_injection_L(:,maxTrialToPool) = nanmean(rt_mat_after_injection_L(:,maxTrialToPool:end),2);
rt_mat_after_injection_L(:,maxTrialToPool+1:end) = [];

%% plot
highColor = [0,169,137]./255;%green
lowColor = [171,62,143]./255;%purple


figure;
hold all
errorbar(0, nanmean(H_RT_before), std(H_RT_before)./sqrt(length(H_RT_before)), 'Color', highColor, 'LineWidth', 2, 'Marker', 'o')
errorbar(0, nanmean(L_RT_before), std(L_RT_before)./sqrt(length(L_RT_before)), 'Color', lowColor, 'LineWidth', 2, 'Marker', 'o')

errorbar(1:size(rt_mat_after_injection_H,2), nanmean(rt_mat_after_injection_H), nanstd(rt_mat_after_injection_H)./sqrt(size(rt_mat_after_injection_H,1)), 'Color', highColor, 'LineWidth', 2, 'Marker', 'o')
errorbar(1:size(rt_mat_after_injection_L,2), nanmean(rt_mat_after_injection_L), nanstd(rt_mat_after_injection_L)./sqrt(size(rt_mat_after_injection_L,1)), 'Color', lowColor, 'LineWidth', 2, 'Marker', 'o')
