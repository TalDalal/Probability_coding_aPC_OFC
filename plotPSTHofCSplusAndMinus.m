function [] = plotPSTHofCSplusAndMinus(allMiceData, bgPeriod, psthTimeWin, pValueTH, srCriterion, brainRegion)

%trialsIncluded = allTrials; CS+ ; CS-

% responseFlag = 'jointResponse'/'individualResponse'
%'jointResponse' Only neurons that responded in both conditions during the
%requested indow.
% 'individualResponse' = Neurons that responded in at least one condition
% during the time window.
% srCriterion = 0.8;
%% settings

CSplusColor = [154,52,52]./255;%purple
CSminusColor = [153,102,51]./255;%green

patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];
minMaxPatch = [-10 10];
psthKernel = 0.05;

%% Get the success rates
[successRates] = getSuccessRatesForEachNeuron(allMiceData, brainRegion);

%% Get binary mat of active neurons
%CS+
[~, ~, allTrialsActivity_CSplus] = responondingNeuronsWithinATimeWindow(allMiceData, pValueTH, bgPeriod, psthTimeWin, 'CS+', 'no', brainRegion);close
%CS-
[~, ~, allTrialsActivity_CSminus] = responondingNeuronsWithinATimeWindow(allMiceData, pValueTH, bgPeriod, psthTimeWin, 'CS-', 'no', brainRegion);close;

%% Extract response for CS+\- into binary matrix
for trialInd = 1:size(allTrialsActivity_CSplus,2)
    currTrialEvokeFR_CSplus = [allTrialsActivity_CSplus(trialInd).A ; allTrialsActivity_CSplus(trialInd).C];
    [h_CSplus, ~] = ttest(currTrialEvokeFR_CSplus, zeros(length(currTrialEvokeFR_CSplus),1),  'alpha', pValueTH);
    if mean(currTrialEvokeFR_CSplus) < 0
        h_CSplus = h_CSplus.*-1;
    end
    ResponseVecCSplus(trialInd) = h_CSplus;
    
    currTrialEvokeFR_CSminus = [allTrialsActivity_CSminus(trialInd).A ; allTrialsActivity_CSminus(trialInd).C];
    [h_CSminus, ~] = ttest(currTrialEvokeFR_CSminus, zeros(length(currTrialEvokeFR_CSminus),1),  'alpha', pValueTH);
    if mean(currTrialEvokeFR_CSminus) < 0
        h_CSminus = h_CSminus.*-1;
    end
    ResponseVecCSminus(trialInd) = h_CSminus;
    
end
%% Get the PSTH from all neurons
[PSTHstruct_CSplus] = getPSTHfromAllNeurons(allMiceData, 'CS+', 'no', brainRegion);
[PSTHstruct_CSminus] = getPSTHfromAllNeurons(allMiceData, 'CS-', 'no', brainRegion);

%% Find the relevant neurons - naive vs expert, responding and inh vs exc

% Neurons recorded in naive and expert performance
meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';
performaceTitles = {'naive', 'expert'};

%---- Active neurons CS+\- -------------
activeNeuronsCSplus_EXC = find(ResponseVecCSplus > 0);
activeNeuronsCSplus_INH = find(ResponseVecCSplus < 0);

activeNeuronsCSminus_EXC = find(ResponseVecCSminus > 0);
activeNeuronsCSminus_INH = find(ResponseVecCSminus < 0);

%% Response rate for naive and expert
[p_Naive, p_Expert] = computeResponseRateCSplusAndMinus(naiveInds, expertInds, ResponseVecCSplus, ResponseVecCSminus);

%% --------- mean PSTHs ----------
fig = figure;

for performanceInd = 1:length(performaceTitles)
    naiveOrExpert = performaceTitles{performanceInd};
    
    switch naiveOrExpert
        case 'naive'
            performanceInds = naiveInds;
        case 'expert'
            performanceInds = expertInds;
    end
    
    
    % Neurons that responded in excitation
    %--------- CS+ ------
    CSplus_responding_exc_inds = intersect(activeNeuronsCSplus_EXC ,performanceInds);

    if ~isempty(CSplus_responding_exc_inds)
        CSplus_responding_exc_struct = PSTHstruct_CSplus(CSplus_responding_exc_inds);
        % Normalize psths
        [CSplus_psth_exc, psthTimeVecForPlot] = normalizeCSplusAndMinusPSTHs(CSplus_responding_exc_struct, psthKernel, bgPeriod, psthTimeWin);
    end
    
    CSplus_responding_inh_inds = intersect(activeNeuronsCSplus_INH ,performanceInds);
    
    if ~isempty(CSplus_responding_inh_inds)
        CSplus_responding_inh_struct = PSTHstruct_CSplus(CSplus_responding_inh_inds);
        % Normalize psths
        [CSplus_psth_inh] = normalizeCSplusAndMinusPSTHs(CSplus_responding_inh_struct, psthKernel, bgPeriod, psthTimeWin);
    end
    
    %------ CS- ---------
    CSminus_responding_exc_inds = intersect(activeNeuronsCSminus_EXC ,performanceInds);
    
    if ~isempty(CSminus_responding_exc_inds)
        CSminus_responding_exc_struct = PSTHstruct_CSminus(CSminus_responding_exc_inds);
        % Normalize psths
        [CSminus_psth_exc] = normalizeCSplusAndMinusPSTHs(CSminus_responding_exc_struct, psthKernel, bgPeriod, psthTimeWin);
    end
    
    CSminus_responding_inh_inds = intersect(activeNeuronsCSminus_INH ,performanceInds);
    if ~isempty(CSminus_responding_inh_inds)
        CSminus_responding_inh_struct = PSTHstruct_CSminus(CSminus_responding_inh_inds);
        % Normalize psths
        [CSminus_psth_inh] = normalizeCSplusAndMinusPSTHs(CSminus_responding_inh_struct, psthKernel, bgPeriod, psthTimeWin);
    end
    
    
    
    subplot(1,2,performanceInd)
    hold all;
    
    %Odor markers
    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
    %Plot CS+ inhibition and excitation
    errorbar_patch(psthTimeVecForPlot, mean(CSminus_psth_exc),std(CSminus_psth_exc)./sqrt(size(CSminus_psth_exc,1)), CSminusColor);
    errorbar_patch(psthTimeVecForPlot, mean(CSminus_psth_inh),std(CSminus_psth_inh)./sqrt(size(CSminus_psth_inh,1)), CSminusColor, '--');
    
    %Plot CS- inhibition and excitation
    errorbar_patch(psthTimeVecForPlot, mean(CSplus_psth_exc),std(CSplus_psth_exc)./sqrt(size(CSplus_psth_exc,1)), CSplusColor);
    errorbar_patch(psthTimeVecForPlot, mean(CSplus_psth_inh),std(CSplus_psth_inh)./sqrt(size(CSplus_psth_inh,1)), CSplusColor, '--');
    
    %CS+ - PSTHs and indices of neurons
    naiveExpertData(performanceInd).CSplus_responding_exc = CSplus_psth_exc;
    naiveExpertData(performanceInd).CSplus_responding_exc_inds = CSplus_responding_exc_inds;
    naiveExpertData(performanceInd).CSplus_responding_inh = CSplus_psth_inh;
    naiveExpertData(performanceInd).CSplus_responding_inh_inds = CSplus_responding_inh_inds;
    
    %CS- - PSTHs and indices of neurons
    naiveExpertData(performanceInd).CSminus_responding_exc = CSminus_psth_exc;
    naiveExpertData(performanceInd).CSminus_responding_exc_inds = CSminus_responding_exc_inds;
    naiveExpertData(performanceInd).CSminus_responding_inh = CSminus_psth_inh;
    naiveExpertData(performanceInd).CSminus_responding_inh_inds = CSminus_responding_inh_inds;
    
    
    set(gcf, 'Renderer', 'painters');
    set(gca, 'FontSize', 18);box off;
    title([naiveOrExpert ' N: CS+ exc., ' num2str(length(CSplus_responding_exc_inds)), ...
        ' CS+ inh., ' num2str(length(CSplus_responding_inh_inds)), ...
        ' CS- exc., ' num2str(length(CSminus_responding_exc_inds)), ...
        ' CS- inh., ' num2str(length(CSminus_responding_inh_inds))])
%     xlim([psthTimeVecForPlot(1) psthTimeVecForPlot(end)])
    
    
end

han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
set(gca, 'FontSize', 15);
han.YLabel.Visible='on';
ylabel(han,'Firing rate (Hz)');
xlabel(han,'Time relative to CS (S)');




%% Plot mean+-SEM
%Naive
%----Exc
naive_CSplus_Exc = [naiveExpertData(1).CSplus_responding_exc ];
naive_CSminus_Exc = [naiveExpertData(1).CSminus_responding_exc ];
naive_CSplus_Exc_Amplitudes = mean(naive_CSplus_Exc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),2);
naive_CSminus_Exc_Amplitudes = mean(naive_CSminus_Exc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))), 2);

%----Inh
naive_CSplus_Inh = [naiveExpertData(1).CSplus_responding_inh ];
naive_CSminus_Inh = [naiveExpertData(1).CSminus_responding_inh ];
naive_CSplus_Inh_Amplitudes = mean(naive_CSplus_Inh(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),2);
naive_CSminus_Inh_Amplitudes = mean(naive_CSminus_Inh(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))), 2);


%Expert
%----Exc
expert_CSplus_Exc = [naiveExpertData(2).CSplus_responding_exc ];
expert_CSminus_Exc = [naiveExpertData(2).CSminus_responding_exc ];
expert_CSplus_Exc_Amplitudes = mean(expert_CSplus_Exc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),2);
expert_CSminus_Exc_Amplitudes = mean(expert_CSminus_Exc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))), 2);

%----Inh
expert_CSplus_Inh = [naiveExpertData(2).CSplus_responding_inh ];
expert_CSminus_Inh = [naiveExpertData(2).CSminus_responding_inh ];
expert_CSplus_Inh_Amplitudes = mean(expert_CSplus_Inh(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),2);
expert_CSminus_Inh_Amplitudes = mean(expert_CSminus_Inh(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))), 2);



%STAT
[~,pNaive_exc] = ttest2(naive_CSplus_Exc_Amplitudes, naive_CSminus_Exc_Amplitudes);
[~,pNaive_inh] = ttest2(naive_CSplus_Inh_Amplitudes, naive_CSminus_Inh_Amplitudes);

[~,pExpert_exc] = ttest2(expert_CSplus_Exc_Amplitudes, expert_CSminus_Exc_Amplitudes);
[~,pExpert_inh] = ttest2(expert_CSplus_Inh_Amplitudes, expert_CSminus_Inh_Amplitudes);

%naive
amplitudesData{1} = naive_CSplus_Exc_Amplitudes;
amplitudesData{2} = naive_CSminus_Exc_Amplitudes;
amplitudesData{3} = naive_CSplus_Inh_Amplitudes;
amplitudesData{4} = naive_CSminus_Inh_Amplitudes;
%expert
amplitudesData{5} = expert_CSplus_Exc_Amplitudes;
amplitudesData{6} = expert_CSminus_Exc_Amplitudes;
amplitudesData{7} = expert_CSplus_Inh_Amplitudes;
amplitudesData{8} = expert_CSminus_Inh_Amplitudes;


figure;
plotSpread(amplitudesData, 'xNames', {'CS+', 'CS-', 'CS+', 'CS-', 'CS+', 'CS-',  'CS+', 'CS-'}, ...
    'distributionMarkers', {'o', 'o','o', 'o','o', 'o','o', 'o'}, 'showMM', 1)
title(['P naive exc = ' num2str(pNaive_exc) ', P naive inh = ' num2str(pNaive_inh) ', P expert exc = ' num2str(pExpert_exc), 'P expert inh = ' num2str(pExpert_inh)])


%% create a matrix of all  excitatory PSTHs sorted
%-High
%Find the max of each PSTH
% [maxVal, maxLoc] = max(pooledHighExc(:,find(psthTimeVecForPlot > psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),[],2);
[maxVal, maxLoc] = max(pooledHighExc,[],2);
%Norm each PSTH by the max
normHigh_Exc = pooledHighExc./maxVal;
% Sort the max locastions and apply the sorting
[~,sortedMaxTimePoints] = sort(psthTimeVecForPlot(maxLoc), 'descend');
normHigh_Exc = normHigh_Exc(sortedMaxTimePoints,:);
figure;
subplot(2,2,1)
imagesc(psthTimeVecForPlot, 1:size(normHigh_Exc,1), normHigh_Exc)
hold all;
plot([cueOdorsTimeWin(1) cueOdorsTimeWin(1)], [1 size(normHigh_Exc,1)], 'y--')
plot([cueOdorsTimeWin(2) cueOdorsTimeWin(2)], [1 size(normHigh_Exc,1)], 'y--')
plot([csOdorsTimeWin(1) csOdorsTimeWin(1)], [1 size(normHigh_Exc,1)], 'y--')
plot([csOdorsTimeWin(2) csOdorsTimeWin(2)], [1 size(normHigh_Exc,1)], 'y--')
crameri oslo;%caxis([0 1])
title('High', 'Color', highProbColor)
set(gca, 'FontSize', 18);
ylabel('Neurons');
xlabel('Time from CS (S)');
box off;set(gcf, 'Renderer', 'painters');


%-Low
%Find the max of each PSTH
% [maxVal, maxLoc] = max(pooledLowExc(:,find(psthTimeVecForPlot > psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),[],2);
[maxVal, maxLoc] = max(pooledLowExc,[],2);
%Norm each PSTH by the max
normLow_Exc = pooledLowExc./maxVal;
% Sort the max locastions and apply the sorting
[~,sortedMaxTimePoints] = sort(psthTimeVecForPlot(maxLoc), 'descend');
normLow_Exc = normLow_Exc(sortedMaxTimePoints,:);


subplot(2,2,2)
imagesc(psthTimeVecForPlot, 1:size(normLow_Exc,1), normLow_Exc)
hold all;
plot([cueOdorsTimeWin(1) cueOdorsTimeWin(1)], [1 size(normLow_Exc,1)], 'y--')
plot([cueOdorsTimeWin(2) cueOdorsTimeWin(2)], [1 size(normLow_Exc,1)], 'y--')
plot([csOdorsTimeWin(1) csOdorsTimeWin(1)], [1 size(normLow_Exc,1)], 'y--')
plot([csOdorsTimeWin(2) csOdorsTimeWin(2)], [1 size(normLow_Exc,1)], 'y--')
crameri oslo;%caxis([0 1])
title('Low', 'Color', lowProbColor)
set(gca, 'FontSize', 18);
% ylabel('Norm. firing rate (Hz)');
xlabel('Time from CS (S)');
box off;set(gcf, 'Renderer', 'painters');

subplot(2,2,3:4)
hold all;

patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

%-Excitation
errorbar_patch(psthTimeVecForPlot, mean(pooledHighExc),std(pooledHighExc)./sqrt(size(pooledHighExc,1)), highProbColor);
errorbar_patch(psthTimeVecForPlot, mean(pooledLowExc),std(pooledLowExc)./sqrt(size(pooledLowExc,1)), lowProbColor);
set(gca, 'FontSize', 18);
ylabel('Firing rate (Hz)');
xlabel('Time from CS (S)');
box off;set(gcf, 'Renderer', 'painters');

%% create a matrix of all  inhibitory PSTHs sorted
%-High
%Find the max of each PSTH
[maxVal, maxLoc] = max(pooledHighInh,[],2);
%Norm each PSTH by the max
normHigh_Inh = pooledHighInh./maxVal;
% Sort the max locastions and apply the sorting
[~,sortedMaxTimePoints] = sort(psthTimeVecForPlot(maxLoc), 'descend');
normHigh_Inh = normHigh_Inh(sortedMaxTimePoints,:);
figure;
subplot(2,2,1)
imagesc(psthTimeVecForPlot, 1:size(normHigh_Inh,1), normHigh_Inh)
crameri oslo;%caxis([0 1])
title('High', 'Color', highProbColor)
set(gca, 'FontSize', 18);
ylabel('Neurons');
xlabel('Time from CS (S)');
box off;set(gcf, 'Renderer', 'painters');


%-Low
%Find the max of each PSTH
[maxVal, maxLoc] = max(pooledLowInh,[],2);
%Norm each PSTH by the max
normLow_Inh = pooledLowInh./maxVal;
% Sort the max locastions and apply the sorting
[~,sortedMaxTimePoints] = sort(psthTimeVecForPlot(maxLoc), 'descend');
normLow_Inh = normLow_Inh(sortedMaxTimePoints,:);


subplot(2,2,2)
imagesc(psthTimeVecForPlot, 1:size(normLow_Inh,1), normLow_Inh)
crameri oslo;%caxis([0 1])
title('Low', 'Color', lowProbColor)
set(gca, 'FontSize', 18);
% ylabel('Norm. firing rate (Hz)');
xlabel('Time from CS (S)');
box off;set(gcf, 'Renderer', 'painters');

subplot(2,2,3:4)
hold all;

patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

% %-Inhibition
errorbar_patch(psthTimeVecForPlot, mean(pooledHighInh),std(pooledHighInh)./sqrt(size(pooledHighInh,1)), highProbColor);
errorbar_patch(psthTimeVecForPlot, mean(pooledLowInh),std(pooledLowInh)./sqrt(size(pooledLowInh,1)), lowProbColor);
set(gca, 'FontSize', 18);
ylabel('Firing rate (Hz)');
xlabel('Time from CS (S)');
box off;set(gcf, 'Renderer', 'painters');
end

function [p_Naive, p_Expert] = computeResponseRateCSplusAndMinus(naiveInds, expertInds, ResponseVecCSplus, ResponseVecCSminus)
%---Naive
%CS+
naiveCSplus = ResponseVecCSplus(naiveInds);
naiveCSplusRate = length(find(naiveCSplus~=0))./length(naiveCSplus);
naiveCSplusSE = binoDistSE(naiveCSplusRate, length(naiveCSplus));

%CS-
naiveCSminus = ResponseVecCSminus(naiveInds);
naiveCSminusRate = length(find(naiveCSminus~=0))./length(naiveCSminus);
naivCSminusSE = binoDistSE(naiveCSminusRate, length(naiveCSminus));

%-naive stats
[~,p_Naive] = prop_test([naiveCSplusRate naiveCSminusRate].*length(naiveCSplus), ...
    [length(naiveCSplus) length(naiveCSminus)], 'true');

%---Expert
%CS+
expertCSplus = ResponseVecCSplus(expertInds);
expertCSplusRate = length(find(expertCSplus~=0))./length(expertCSplus);
expertCSplusSE = binoDistSE(expertCSplusRate, length(expertCSplus));

%CS-
expertCSminus = ResponseVecCSminus(expertInds);
expertCSminusRate = length(find(expertCSminus~=0))./length(expertCSminus);
expertCSminusSE = binoDistSE(expertCSminusRate, length(expertCSminus));

%-naive stats
[~,p_Expert] = prop_test([expertCSplusRate expertCSminusRate].*length(expertCSplus), ...
    [length(expertCSplus) length(expertCSminus)], 'true');

figure;
barwitherr([naiveCSplusSE naivCSminusSE expertCSplusSE expertCSminusSE].*100, ...
    [naiveCSplusRate, naiveCSminusRate,expertCSplusRate, expertCSminusRate].*100)
set(gca, 'XTickLabel', {'Naive CS+', 'Naive CS-', 'Expert CS+', 'Expert CS-'})
xtickangle(45)
title(['P-naive = ' num2str(round(p_Naive,5)) ', P-expert = ' num2str(round(p_Expert, 5))])
ylabel('Active neurons (%)');set(gca, 'FontSize', 18);box off;
ylim([0 100])
end

function [allPSTHs, cutTimeBins] = normalizeCSplusAndMinusPSTHs(PSTHtoNarmalize, psthKernel, bgPeriod, psthTimeWin)
allPSTHs = [];
firstLastPSTHvalue = [bgPeriod(1) psthTimeWin(2) + 1];

for ind = 1:size(PSTHtoNarmalize,2)
    
    currRaster = [PSTHtoNarmalize(ind).rasterHigh PSTHtoNarmalize(ind).rasterLow];
    
    if isempty(currRaster)
        continue;
    end
    
    % Compute the PSTH
    [R,t] = mypsth(currRaster, psthKernel, 'n');
    
    %Current PSTH and time vector
    currPSTH = R;
    currTime = t;
    
    %Compute the bins of the time vector
    currTimeBin = round(median(diff(currTime)),3);
    
    %Find the first index
    firstInd = find(currTime >= firstLastPSTHvalue(1),1);
    finalPSTHlength = diff(firstLastPSTHvalue)/currTimeBin;
    
    if currTime(1) < bgPeriod(2) & (firstInd + finalPSTHlength) < length(currPSTH)
        
        cutPSTH_High = currPSTH(firstInd: firstInd + finalPSTHlength);
        
        % normalize
        baseline_High = currPSTH(find(currTime >= bgPeriod(1) & currTime < bgPeriod(2)));
        meanBaseline_High = mean(baseline_High);
        meanBaseline_High(isnan(meanBaseline_High)) = 0;
        Z_cutPSTH_High = cutPSTH_High - meanBaseline_High;
        
        allPSTHs(end+1,:) = Z_cutPSTH_High;
    end
end
cutTimeBins = firstLastPSTHvalue(1):currTimeBin:firstLastPSTHvalue(2);
end

