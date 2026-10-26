%%
timeVec = pooledPSTHstructEXC(1).psthTimeVecForPlot;
highExcPSTHs = pooledPSTHstructEXC(2).High_responding_exc;
lowExcPSTHs = size(pooledPSTHstructEXC(2).Low_responding_exc);

%% Correlation within ramping neurons during ramping
rampingDuration = find(timeVec >= -1 & timeVec < 0);
highExcPSTHsDuartion = highExcPSTHs(:,rampingDuration);

D_ramping = pdist2(highExcPSTHsDuartion, highExcPSTHsDuartion, 'correlation');
aboveDiaonalVals = triu(1-D_ramping,1);
aboveDiaonalVals(aboveDiaonalVals==0) = nan;
meanRampingCorr = nanmean(nanmean(aboveDiaonalVals))

%% Correlation within ramping neurons during target
targetDuration = find(timeVec >= 0 & timeVec < 1);
highExcPSTHs_target = highExcPSTHs(:,targetDuration);


D_target = pdist2(highExcPSTHs_target, highExcPSTHs_target, 'correlation');
aboveDiaonalVals = []; 
aboveDiaonalVals = triu(1-D_target,1);
aboveDiaonalVals(aboveDiaonalVals==0) = nan;
meanTargetCorr = nanmean(nanmean(aboveDiaonalVals))
%% Corr between ramping and target activity

D_ramping_vs_target = pdist2(highExcPSTHsDuartion, highExcPSTHs_target, 'correlation');

aboveDiaonalVals = []; 
aboveDiaonalVals = triu(1-D_ramping_vs_target,1);
aboveDiaonalVals(aboveDiaonalVals==0) = nan;
meanRamping_vs_target_Corr = nanmean(nanmean(aboveDiaonalVals))


%% Plot
figure;
% barwitherr