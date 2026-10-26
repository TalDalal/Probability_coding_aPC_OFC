%% runAllMice.m
% Top-level driver: fits all 5 behavioral models for every mouse in
% allMiceBehavior, runs the learning-curve / trial-history-GLM analyses,
% and produces group-level comparison plots.
%
% USAGE: have allMiceBehavior loaded in the workspace, then just run
% this script. Requires loadMouseData.m, fitBehaviorModels.m,
% analyzeLearning.m to be on the MATLAB path (same folder is fine).

nMice = numel(allMiceBehavior);
allResults  = cell(nMice,1);
allLearning = cell(nMice,1);
allT        = cell(nMice,1);

for m = 1:nMice
    fprintf('Mouse %d/%d...\n', m, nMice);
    T = loadMouseData(allMiceBehavior, m);
    allT{m}        = T;
    allResults{m}  = fitBehaviorModels(T);
    allLearning{m} = analyzeLearning(T);
end

%% ---- Group-level model comparison table ----
modelNames = {allResults{1}.name};
nModels = numel(modelNames);
AICmat = nan(nMice, nModels);
BICmat = nan(nMice, nModels);
for m = 1:nMice
    AICmat(m,:) = [allResults{m}.aic];
    BICmat(m,:) = [allResults{m}.bic];
end

fprintf('\nMean AIC across mice (lower = better fit):\n');
for k = 1:nModels
    fprintf('  %-10s %.1f\n', modelNames{k}, mean(AICmat(:,k)));
end

% Hybrid model-based weight per mouse (individual-differences metric)
hybIdx = find(strcmp(modelNames,'Hybrid'));
wMB = nan(nMice,1);
for m = 1:nMice
    wMB(m) = allResults{m}(hybIdx).paramsFit.valuePars(3);
end

%% ---- Plots ----
figure('Name','Model comparison (delta AIC vs best model per mouse)');
dAIC = AICmat - min(AICmat,[],2);
bar(mean(dAIC,1)); hold on;
errorbar(1:nModels, mean(dAIC,1), std(dAIC,[],1)/sqrt(nMice), 'k.', 'LineWidth',1.5);
set(gca,'XTick',1:nModels,'XTickLabel',modelNames);
ylabel('\Delta AIC (mean \pm SEM across mice)');
title('Group model comparison');

figure('Name','Learning curves (A-B lick-probability difference)');
hold on;
maxSess = max(cellfun(@(L) numel(L.sessList), allLearning));
diffMat = nan(nMice, maxSess);
for m = 1:nMice
    plot(allLearning{m}.sessList, allLearning{m}.diffAB, '-', 'Color',[0.8 0.8 0.8]);
    diffMat(m, 1:numel(allLearning{m}.diffAB)) = allLearning{m}.diffAB(:)';
end
muDiff = mean(diffMat,1,'omitnan');
seDiff = std(diffMat,0,1,'omitnan') ./ sqrt(sum(~isnan(diffMat),1));
errorbar(1:maxSess, muDiff, seDiff, '-o', 'Color','k','LineWidth',2,'MarkerFaceColor','k');
xlabel('Session'); ylabel('P(lick|A) - P(lick|B)  [post-CS, sufficientLicks]');
title('Acquisition curve (post-CS DV -- confounded with CS discrimination, see README)');
yline(0,'k--');

% --- confound-free version: pre-CS context-epoch licking ---
allLearning_preCS = cell(nMice,1);
for m = 1:nMice
    allLearning_preCS{m} = analyzeLearning(allT{m}, 'dvColumn', 'nLicks_context');
end
figure('Name','Learning curves (pre-CS context-epoch licking, confound-free)');
hold on;
diffMat2 = nan(nMice, maxSess);
for m = 1:nMice
    plot(allLearning_preCS{m}.sessList, allLearning_preCS{m}.diffAB, '-', 'Color',[0.8 0.8 0.8]);
    diffMat2(m, 1:numel(allLearning_preCS{m}.diffAB)) = allLearning_preCS{m}.diffAB(:)';
end
mu2 = mean(diffMat2,1,'omitnan');
se2 = std(diffMat2,0,1,'omitnan') ./ sqrt(sum(~isnan(diffMat2),1));
errorbar(1:maxSess, mu2, se2, '-o', 'Color',[0.1 0.4 0.8],'LineWidth',2,'MarkerFaceColor',[0.1 0.4 0.8]);
xlabel('Session'); ylabel('nLicks(context=A) - nLicks(context=B), pre-CS window');
title('Acquisition curve (pre-CS DV -- true context-driven expectation, no CS-discrimination confound)');
yline(0,'k--');

figure('Name','Model-based weight (Hybrid model)');
histogram(wMB, 10);
xlabel('w_{MB}  (0 = pure model-free, 1 = pure model-based)');
ylabel('# mice');
title('Individual differences in model-based weighting');

%% ---- RT-based modeling + variance-shrinkage test (if lickRaster data available) ----
haveRT = any(~isnan(allT{1}.RT));
if haveRT
    allRTResults = cell(nMice,1);
    allRTVar     = cell(nMice,1);
    allContextLickResults = cell(nMice,1);
    for m = 1:nMice
        allRTResults{m} = fitRTModels(allT{m});         % default DV: RT (context-odor-onset latency)
        allRTVar{m}     = analyzeRTVariance(allT{m});
        % well-powered complement: no missing data, uses ALL context trials
        allContextLickResults{m} = fitBehaviorModels(allT{m}, 'dvColumn', 'nLicks_context');
    end

    rtModelNames = {allRTResults{1}.name};
    AICmat_RT = nan(nMice, numel(rtModelNames));
    AICmat_ctxLick = nan(nMice, numel(rtModelNames));
    for m = 1:nMice
        AICmat_RT(m,:)      = [allRTResults{m}.aic];
        AICmat_ctxLick(m,:) = [allContextLickResults{m}.aic];
    end
    fprintf('\nMean AIC (RT/promptness models, missing-data-limited):\n');
    for k = 1:numel(rtModelNames)
        fprintf('  %-10s %.1f\n', rtModelNames{k}, mean(AICmat_RT(:,k)));
    end
    fprintf('\nMean AIC (context-epoch any-lick models, ALL trials, no missingness):\n');
    for k = 1:numel(rtModelNames)
        fprintf('  %-10s %.1f\n', rtModelNames{k}, mean(AICmat_ctxLick(:,k)));
    end
    fprintf(['\nIf dynamic models beat Null here but not for RT above, the RT null result\n' ...
             'is most likely a missing-data/power issue (RT undefined on no-lick trials),\n' ...
             'not evidence that context-driven learning is absent.\n']);

    figure('Name','RT-model comparison (delta AIC vs best model per mouse)');
    dAIC_RT = AICmat_RT - min(AICmat_RT,[],2);
    bar(mean(dAIC_RT,1)); hold on;
    errorbar(1:numel(rtModelNames), mean(dAIC_RT,1), std(dAIC_RT,[],1)/sqrt(nMice), 'k.', 'LineWidth',1.5);
    set(gca,'XTick',1:numel(rtModelNames),'XTickLabel',rtModelNames);
    ylabel('\Delta AIC (mean \pm SEM across mice)');
    title('Group model comparison -- RT/promptness DV');

    figure('Name','Variance-shrinkage test');
    hold on;
    for m = 1:nMice
        plot(allRTVar{m}.sessList, allRTVar{m}.varPooled, '-o', 'Color',[0.75 0.75 0.75]);
    end
    xlabel('Session'); ylabel('Var(promptness), pooled A & B');
    title('Behavioral variance vs. session (shrinkage = Bayesian signature)');

    save('groupResults.mat','allResults','allLearning','allT','AICmat','BICmat','wMB', ...
         'allRTResults','allRTVar','AICmat_RT');
else
    fprintf('\nNo RT/lick-raster data detected for mouse 1 -- skipping RT-based modeling.\n');
    save('groupResults.mat','allResults','allLearning','allT','AICmat','BICmat','wMB');
end