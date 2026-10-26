function [deltaRT] = compareSR_and_RT(allMiceData)

RT_lim = [-.2 1.2];
colors = [[171,62,143]; [0,169,137]]./255;

H_RT = [];L_RT = [];H_SR = [];L_SR = [];signifRTdiff = [];
for mouseInd = 1:size(allMiceData,2)
    
    allRecs = allMiceData(mouseInd).allRecs;
    for recInd = 1:size(allRecs,2)
        if allRecs(recInd).sessionNum > 0% ONLY experiment sessions and not pretraining
            
            if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                curr_H_RT = allRecs(recInd).data.firstLickLatency.A;
                curr_L_RT = allRecs(recInd).data.firstLickLatency.C;
                H_SR(end+1) = allRecs(recInd).data.successRate.A;
                L_SR(end+1) = allRecs(recInd).data.successRate.C;
            else
                curr_H_RT = allRecs(recInd).data.firstLickLatency.C;
                curr_L_RT = allRecs(recInd).data.firstLickLatency.A;
                H_SR(end+1) = allRecs(recInd).data.successRate.C;
                L_SR(end+1) = allRecs(recInd).data.successRate.A;
            end
            H_RT(end+1) = mean(curr_H_RT);
            L_RT(end+1) = mean(curr_L_RT);
            [h,~] = ttest2(curr_H_RT, curr_L_RT);
            signifRTdiff(end+1) = h;
            

            else
                
        end
    end
    
end
%% Plot
%%%% Filter out very beginning sessions < 60% SR %%%%
veryNaiveLocs=find(L_SR<.60 | H_SR<.60);
H_RT(veryNaiveLocs) = [];L_RT(veryNaiveLocs) = [];
H_SR(veryNaiveLocs) = [];


signifInds = find(signifRTdiff==1);
figure;
hold all;
% scatter(L_RT(signifInds), H_RT(signifInds), 80, 'filled')
% scatter(L_RT, H_RT, 80)
scatter(L_RT, H_RT, 80, H_SR, 'filled')

[~,p] = ttest(L_RT, H_RT)
plot(RT_lim, RT_lim, 'k--')
xlim(RT_lim)
ylim(RT_lim)
xlabel('Low (P = 0.25) (S)');
ylabel('High (P = 0.75) (S)');
title(['RT; ' num2str(size(allMiceData,2)) ' mice, N = ' num2str(length(H_RT)) ' sessions'])
set(gca, 'FontSize', 18);box off;
% crameri -roma
crameri oslo
hcb = colorbar;
hcb.Title.String = "Success rate";
caxis([0.5 1])

deltaRT = H_RT - L_RT;


%%
figure;
hold all;
patch([0.5 2.5 2.5 0.5], ...
    [0 0 ones(1,2)], ...
    [190, 190, 190]./255, 'EdgeColor','none', 'FaceAlpha', 0.5)
    
boxplot([H_RT;L_RT]', 'BoxStyle', 'outline');
set(gca, 'FontSize', 18);box off;
ylabel('Reaction time (s)');set(gca, 'XTickLabel', {'High (P = 0.75)', 'Low (P = 0.25)'})
xtickangle(45)
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors(j,:),'FaceAlpha',.8);
end