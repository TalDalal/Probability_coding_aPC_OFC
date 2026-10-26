function [evokedFR, p] = frWithinTimeFrame(params, bgTimeWin, fgTimeWin, trials)

bgWinIndices = find(params.firingRateAnalysisBins >= bgTimeWin(1) & params.firingRateAnalysisBins < bgTimeWin(2));
fgWinIndices = find(params.firingRateAnalysisBins >= fgTimeWin(1) & params.firingRateAnalysisBins < fgTimeWin(2));

bgFR = mean(params.firingRates(params.clusNum).firingRateByBIn(trials , bgWinIndices),2);
fgFR = mean(params.firingRates(params.clusNum).firingRateByBIn(trials , fgWinIndices),2);

evokedFR = mean(fgFR-bgFR);
[~,p] = ttest(fgFR, bgFR);