function [successRateMat,reactionTimeMat, numTrials] = successRatesAcrossRecordings(mouseDataFile)
load(mouseDataFile)

numTrials = nan(1,size(allRecs,2));BnumTrials = numTrials;CnumTrials = numTrials;
Arate = numTrials;Brate = numTrials;Crate = numTrials;
RT_A = numTrials;RT_B = numTrials;RT_C = numTrials;
HitRateA = numTrials;FArateA = numTrials;FArateC = numTrials;HitRateC = numTrials;

%Sort the experiments by date
for ind = 1:size(allRecs,2)
    sessNum(ind) = allRecs(ind).sessionNum;
end
[~,locs] = sort(sessNum);
allRecs = allRecs(locs);
%Run over the data
for ind = 1:size(allRecs,2)
    currRates = allRecs(ind).data.successRate;
    if isfield(currRates, 'A')
        %Sucess rate in a session
        Arate(ind) = currRates.A;
        %Number of trials
        numTrials(ind) =  length(allRecs(ind).data.Atrials);
        %reaction time
        RT_A(ind) = mean(allRecs(ind).data.firstLickLatency.A);
    end
    if isfield(currRates, 'B')
        %Success rate in a session
       Brate(ind) = currRates.B;
       %Number of trials
       BnumTrials(ind) =  length(allRecs(ind).data.Btrials);
       %reaction time
       RT_B(ind) = mean(allRecs(ind).data.firstLickLatency.B);
    end
    if isfield(currRates, 'C')
        %Success rate in a session
        Crate(ind) = currRates.C;
        %Number of trials
        CnumTrials(ind) =  length(allRecs(ind).data.Ctrials);
        %Reaction time
        RT_C(ind) = mean(allRecs(ind).data.firstLickLatency.C);
    end
end

numTrials = cumsum(numTrials);
BnumTrials = cumsum(BnumTrials);
CnumTrials = cumsum(CnumTrials);

successRateMat = [Arate' Brate' Crate'];

figure;
plot(numTrials, Arate, '-sr', 'LineWidth', 2, 'MarkerFaceColor', 'r')
ylim([0 1])
hold all
plot(numTrials, Brate, '-sb', 'LineWidth', 2, 'MarkerFaceColor', 'b')
plot(numTrials, Crate, '-sm', 'LineWidth', 2, 'MarkerFaceColor', 'm')
plot([0 max([numTrials(end) BnumTrials(end) CnumTrials(end)])], [0.5 .5], 'k--')
box off;set(gca, 'FontSize', 14')
xlabel('Trials');ylabel('Percent correct')
title('Success rates curve')
%%
reactionTimeMat = [RT_A' RT_B' RT_C'];
% reactionTimeMat = [RT_A;RT_B;RT_C];
% %analyze only session with A + B trials at least
% reactionTimeMat = reactionTimeMat(:,find(sum(isnan(reactionTimeMat)) <= 1));
% % rt_mat(2:6,:) = [];
% figure;
% plot(reactionTimeMat, 'k-s')
% xlim([0 4])
% hold on;
% errorbar([0.5 2 3.5], nanmean(reactionTimeMat'), nanstd(reactionTimeMat')./sqrt(size(reactionTimeMat,2)), '-sr')
