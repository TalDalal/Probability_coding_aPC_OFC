function [pooledPSTHstructEXC,pooledPSTHstructInh, allTrialsActivity] = plotPSTHduringCSodor(allMiceData, bgPeriod, psthTimeWin, pValueTH, trialsIncluded, responseFlag)

%trialsIncluded = allTrials; CS+ ; CS-

% responseFlag = 'jointResponse'/'individualResponse'
%'jointResponse' Only neurons that responded in both conditions during the
%requested indow.
% 'individualResponse' = Neurons that responded in at least one condition
% during the time window.
srCriterion = 0.7;
equalizeTrialNum = 'non-equalize';
%% settings

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];
minMaxPatch = [-10 10];

%% Get the sessions nums 
[successRates] = getSuccessRatesForEachNeuron(allMiceData);

%% Get binary mat of active neurons
[activityMat_High, activityMat_Low, allTrialsActivity, auROCstruct] = responondingNeuronsWithinATimeWindow(allMiceData, pValueTH, bgPeriod, psthTimeWin, trialsIncluded, equalizeTrialNum, 'PC');

%% Get the PSTH from all neurons
[PSTHstruct] = getPSTHfromAllNeurons(allMiceData, trialsIncluded, equalizeTrialNum);

%% Find the relevant neurons - naive vs expert, responding and inh vs exc

% Neurons recorded in naive and expert performance

meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';
performaceTitles = {'naive', 'expert'};


responseDirectionHigh = activityMat_High;responseDirectionLow = activityMat_Low;
% Find the indices of the active neurons
switch responseFlag
    case 'jointResponse'
        
        activeNeuronsExc_High = find(activityMat_High > 0 & activityMat_Low > 0);
        activeNeuronsExc_Low = find(activityMat_High > 0 & activityMat_Low > 0);
        
        activeNeuronsInh_High = find(activityMat_High < 0 & activityMat_Low < 0);
        activeNeuronsInh_Low = find(activityMat_High < 0 & activityMat_Low < 0);
        
    case 'individualResponse'
        
        activeNeuronsExc_High = find(responseDirectionHigh(:) == 1);
        activeNeuronsExc_Low = find(responseDirectionLow(:) == 1);
        
        activeNeuronsInh_High = find(responseDirectionHigh(:) == -1);
        activeNeuronsInh_Low = find(responseDirectionLow(:) == -1);
    case 'HighResponse'
        
        activeNeuronsExc_High = find(activityMat_High > 0);
        activeNeuronsExc_Low = find(activityMat_High > 0 );
        
        activeNeuronsInh_High = find(activityMat_High < 0 );
        activeNeuronsInh_Low = find(activityMat_High < 0 );
    case 'LowResponse'
        
        activeNeuronsExc_High = find(activityMat_Low > 0);
        activeNeuronsExc_Low = find( activityMat_Low > 0);
        
        activeNeuronsInh_High = find( activityMat_Low < 0);
        activeNeuronsInh_Low = find(activityMat_Low < 0);
end

%% Response rate for naive and expert
%---Naive
%High
naiveHigh = activityMat_High(naiveInds);
naiveHighRate = length(find(naiveHigh~=0))./length(naiveHigh);
naiveHighSE = binoDistSE(naiveHighRate, length(naiveHigh));

%Low
naiveLow = activityMat_Low(naiveInds);
naiveLowRate = length(find(naiveLow~=0))./length(naiveLow);
naiveLowSE = binoDistSE(naiveLowRate, length(naiveLow));

%-naive stats
[~,p_Naive] = prop_test([naiveHighRate naiveLowRate].*length(naiveLow), ...
    [length(naiveHigh) length(naiveLow)], 'true');

%---Expert
%High
expertHigh = activityMat_High(expertInds);
expertHighRate = length(find(expertHigh~=0))./length(expertHigh);
expertHighSE = binoDistSE(expertHighRate, length(expertHigh));

%Low
expertLow = activityMat_Low(expertInds);
expertLowRate = length(find(expertLow~=0))./length(expertLow);
expertLowSE = binoDistSE(expertLowRate, length(expertLow));

%-naive stats
[~,p_Expert] = prop_test([expertHighRate expertLowRate].*length(expertLow), ...
    [length(expertHigh) length(expertLow)], 'true');

figure;
barwitherr([naiveHighSE naiveLowSE expertHighSE expertLowSE].*100, ...
    [naiveHighRate, naiveLowRate,expertHighRate, expertLowRate].*100)
set(gca, 'XTickLabel', {'naive_H', 'naive_L', 'expert_H', 'expert_L'})
xtickangle(45)
title(['P-naive = ' num2str(round(p_Naive,5)) ', P-expert = ' num2str(round(p_Expert, 5))])
ylabel('Active neurons (%)');set(gca, 'FontSize', 18);box off;
ylim([0 100])

%% --- auROC mat of active neurons only
auROC_activeNeurons_High = auROCstruct.High([activeNeuronsExc_High],:);
auROC_activeNeurons_Low = auROCstruct.Low([activeNeuronsExc_Low],:);
%-norm to 1
auROC_activeNeurons_High = auROC_activeNeurons_High./max(auROC_activeNeurons_High,[],2);
auROC_activeNeurons_Low = auROC_activeNeurons_Low./max(auROC_activeNeurons_Low,[],2);

rocVals_ActiveNeurons_High = auROCstruct.ROCvaluesForSorting_High(activeNeuronsExc_High);
rocVals_ActiveNeurons_Low = auROCstruct.ROCvaluesForSorting_Low(activeNeuronsExc_Low);
%Sort the auROC responses
[~,rocValsSorted_High] = sort(rocVals_ActiveNeurons_High, 'descend');
[~,rocValsSorted_Low] = sort(rocVals_ActiveNeurons_Low, 'descend');

figure;
subplot(1,2,1)
imagesc(auROCstruct.timeBins,1:size(auROC_activeNeurons_High,1),auROC_activeNeurons_High(rocValsSorted_High,:));
crameri oslo
subplot(1,2,2)
imagesc(auROCstruct.timeBins,1:size(auROC_activeNeurons_Low,1),auROC_activeNeurons_Low(rocValsSorted_Low,:));
crameri oslo

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
    %--------- High ------
    %     A_responding_exc_inds = intersect(intersect(activeNeurons ,performanceInds),find(responseDirectionHigh(:)==1));
    High_responding_exc_inds = intersect(activeNeuronsExc_High ,performanceInds);
    High_responding_exc = [];
    if ~isempty(High_responding_exc_inds)
        High_responding_exc_struct = PSTHstruct(High_responding_exc_inds);
        % Normalize psths
        [High_responding_exc, psthTimeVecForPlot, deletedNeurons_High_responding_exc] = normalizePSTHsAndSortToExcorInh(High_responding_exc_struct,bgPeriod, psthTimeWin, 'High');
        High_responding_exc_inds(deletedNeurons_High_responding_exc) = [];
    end
    
    High_responding_inh_inds = intersect(activeNeuronsInh_High ,performanceInds);
    High_responding_inh = [];
    if ~isempty(High_responding_inh_inds)
        High_responding_inh_struct = PSTHstruct(High_responding_inh_inds);
        % Normalize psths
        [High_responding_inh, ~, deletedNeurons_High_responding_inh] = normalizePSTHsAndSortToExcorInh(High_responding_inh_struct, bgPeriod, psthTimeWin, 'High');
        High_responding_inh_inds(deletedNeurons_High_responding_inh) = [];
    end
    
    %------LOW---------
    
    Low_responding_exc_inds = intersect(activeNeuronsExc_Low ,performanceInds);
    Low_responding_exc = [];
    if ~isempty(Low_responding_exc_inds)
        Low_responding_exc_struct = PSTHstruct(Low_responding_exc_inds);
        % Normalize psths
        [Low_responding_exc, ~, deletedNeurons_Low_responding_exc] = normalizePSTHsAndSortToExcorInh(Low_responding_exc_struct, bgPeriod, psthTimeWin, 'Low');
        Low_responding_exc_inds(deletedNeurons_Low_responding_exc) = [];
    end
    
    Low_responding_inh_inds = intersect(activeNeuronsInh_Low ,performanceInds);
    Low_responding_inh = [];
    if ~isempty(Low_responding_inh_inds)
        Low_responding_inh_struct = PSTHstruct(Low_responding_inh_inds);
        % Normalize psths
        [Low_responding_inh, ~, deletedNeurons_Low_responding_inh] = normalizePSTHsAndSortToExcorInh(Low_responding_inh_struct, bgPeriod, psthTimeWin, 'Low');
        Low_responding_inh_inds(deletedNeurons_Low_responding_inh) = [];
    end
    
    
    
    subplot(1,2,performanceInd)
    hold all;
    
    %Odor markers
    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
    %Plot high inhibition and excitation
    errorbar_patch(psthTimeVecForPlot, mean(High_responding_exc),std(High_responding_exc)./sqrt(size(High_responding_exc,1)), highProbColor);
    errorbar_patch(psthTimeVecForPlot, mean(High_responding_inh),std(High_responding_inh)./sqrt(size(High_responding_inh,1)), highProbColor, '--');
    
    %Plot low inhibition and excitation
    errorbar_patch(psthTimeVecForPlot, mean(Low_responding_exc),std(Low_responding_exc)./sqrt(size(Low_responding_exc,1)), lowProbColor);
    errorbar_patch(psthTimeVecForPlot, mean(Low_responding_inh),std(Low_responding_inh)./sqrt(size(Low_responding_inh,1)), lowProbColor, '--');
    
    %Excitation - PSTHs and indices of neurons
    pooledPSTHstructEXC(performanceInd).High_responding_exc = High_responding_exc;
    pooledPSTHstructEXC(performanceInd).High_responding_exc_inds = High_responding_exc_inds;
    pooledPSTHstructEXC(performanceInd).Low_responding_exc = Low_responding_exc;
    pooledPSTHstructEXC(performanceInd).Low_responding_exc_inds = Low_responding_exc_inds;
    
    %Inhibition - PSTHs and indices of neurons
    pooledPSTHstructInh(performanceInd).High_responding_inh = High_responding_inh;
    pooledPSTHstructInh(performanceInd).High_responding_inh_inds = High_responding_inh_inds;
    pooledPSTHstructInh(performanceInd).Low_responding_inh = Low_responding_inh;
    pooledPSTHstructInh(performanceInd).Low_responding_inh_inds = Low_responding_inh_inds;
    
    set(gcf, 'Renderer', 'painters');
    set(gca, 'FontSize', 18);box off;
    title([naiveOrExpert ' N: High exc., ' num2str(length(High_responding_exc_inds)), ...
        ' High inh., ' num2str(length(High_responding_inh_inds)), ...
        ' Low exc., ' num2str(length(Low_responding_exc_inds)), ...
        ' Low inh., ' num2str(length(Low_responding_inh_inds))])
    xlim([psthTimeVecForPlot(1) psthTimeVecForPlot(end)])
    
    
end

han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
set(gca, 'FontSize', 15);
han.YLabel.Visible='on';
ylabel(han,'Firing rate (Hz)');
xlabel(han,'Time relative to CS (S)');
title(trialsIncluded);


pooledPSTHstructEXC(1).psthTimeVecForPlot = psthTimeVecForPlot;
pooledPSTHstructEXC(1).PSTHstruct = PSTHstruct;
%% plot the PSTH of the niave and expert superimposed
figure;
hold all;

patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

excHighExpert = pooledPSTHstructEXC(2).High_responding_exc;
excLowExpert = pooledPSTHstructEXC(2).Low_responding_exc;
errorbar_patch(psthTimeVecForPlot, mean(excHighExpert),std(excHighExpert)./sqrt(size(excHighExpert,1)), highProbColor);
errorbar_patch(psthTimeVecForPlot, mean(excLowExpert),std(excLowExpert)./sqrt(size(excLowExpert,1)), lowProbColor);


plot(psthTimeVecForPlot, mean(pooledPSTHstructEXC(1).High_responding_exc), '--','Color',  highProbColor)
plot(psthTimeVecForPlot, mean(pooledPSTHstructEXC(1).Low_responding_exc),'--', 'Color',  lowProbColor)

legend('High expert', 'Low expert', 'High naive', 'Low naive')
set(gca, 'FontSize', 18);
ylabel('Firing rate (Hz)');
xlabel('Time from CS (S)');
set(gcf, 'Renderer', 'painters');

%-Output
neuronIndices.high_exc = High_responding_exc_inds;
neuronIndices.high_inh = High_responding_inh_inds;
neuronIndices.low_exc = Low_responding_exc_inds;
neuronIndices.low_inh = Low_responding_inh_inds;

%% plot the data pooled across naive and expert
%-Excitation
pooledHighExc = [pooledPSTHstructEXC(1).High_responding_exc ;pooledPSTHstructEXC(2).High_responding_exc];
pooledLowExc = [pooledPSTHstructEXC(1).Low_responding_exc ;pooledPSTHstructEXC(2).Low_responding_exc];


%-Inhibition
pooledHighInh = [pooledPSTHstructInh(1).High_responding_inh ;pooledPSTHstructInh(2).High_responding_inh];
pooledLowInh = [pooledPSTHstructInh(1).Low_responding_inh ;pooledPSTHstructInh(2).Low_responding_inh];

figure;
hold all;

patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

%-Excitation
errorbar_patch(psthTimeVecForPlot, mean(pooledHighExc),std(pooledHighExc)./sqrt(size(pooledHighExc,1)), highProbColor);
errorbar_patch(psthTimeVecForPlot, mean(pooledLowExc),std(pooledLowExc)./sqrt(size(pooledLowExc,1)), lowProbColor);
% %-Inhibition
errorbar_patch(psthTimeVecForPlot, mean(pooledHighInh),std(pooledHighInh)./sqrt(size(pooledHighInh,1)), highProbColor);
errorbar_patch(psthTimeVecForPlot, mean(pooledLowInh),std(pooledLowInh)./sqrt(size(pooledLowInh,1)), lowProbColor);

set(gca, 'FontSize', 18);
ylabel('Firing rate (Hz)');
xlabel('Time from CS (S)');
box off;set(gcf, 'Renderer', 'painters');

%% Plot mean+-SEM
%Naive
%----Exc
naiveHighExc = [pooledPSTHstructEXC(1).High_responding_exc ];
naiveLowExc = [pooledPSTHstructEXC(1).Low_responding_exc ];
naiveHighExcAmplitudes = mean(naiveHighExc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),2);
naiveLowExcAmplitudes = mean(naiveLowExc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))), 2);

%Excitation amplitudes
pooledPSTHstructEXC(1).naiveHighExcAmplitudes = naiveHighExcAmplitudes;
pooledPSTHstructEXC(1).naiveLowExcAmplitudes = naiveLowExcAmplitudes;

%----Inh
naiveHighInh = [pooledPSTHstructInh(1).High_responding_inh ];
naiveLowInh = [pooledPSTHstructInh(1).Low_responding_inh ];
naiveHighInhAmplitudes = mean(naiveHighInh(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),2);
naiveLowInhAmplitudes = mean(naiveLowInh(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))), 2);

%inhibition amplitudes
pooledPSTHstructEXC(1).naiveHighInhAmplitudes = naiveHighInhAmplitudes;
pooledPSTHstructEXC(1).naiveLowInhAmplitudes = naiveLowInhAmplitudes;


%Expert
%----Exc
expertHighExc = [pooledPSTHstructEXC(2).High_responding_exc];
expertLowExc = [pooledPSTHstructEXC(2).Low_responding_exc];
expertHighExcAmplitudes = mean(expertHighExc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),2);
expertLowExcAmplitudes = mean(expertLowExc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))), 2);

%Excitation amplitudes
pooledPSTHstructEXC(2).expertHighExcAmplitudes = expertHighExcAmplitudes;
pooledPSTHstructEXC(2).expertLowExcAmplitudes = expertLowExcAmplitudes;


%----Inh
expertHighInh = [pooledPSTHstructInh(2).High_responding_inh ];
expertLowInh = [pooledPSTHstructInh(2).Low_responding_inh ];
expertHighInhAmplitudes = mean(expertHighInh(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),2);
expertLowInhAmplitudes = mean(expertLowInh(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))), 2);

%inhibition amplitudes
pooledPSTHstructEXC(2).expertHighInhAmplitudes = expertLowInhAmplitudes;
pooledPSTHstructEXC(2).expertLowInhAmplitudes = expertLowInhAmplitudes;


highExcAmplitudes = mean(pooledHighExc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))),2);
lowExcAmplitudes = mean(pooledLowExc(:,find(psthTimeVecForPlot >=psthTimeWin(1) & psthTimeVecForPlot < psthTimeWin(2))), 2);


%STAT
[~,pNaive] = ttest2(naiveHighExcAmplitudes, naiveLowExcAmplitudes);
[~,pExpert] = ttest2(expertHighExcAmplitudes, expertLowExcAmplitudes);
[~,pPooled] = ttest2(highExcAmplitudes, lowExcAmplitudes);

amplitudesData{1} = highExcAmplitudes;
amplitudesData{2} = lowExcAmplitudes;
amplitudesData{3} = naiveHighExcAmplitudes;
amplitudesData{4} = naiveLowExcAmplitudes;
amplitudesData{5} = expertHighExcAmplitudes;
amplitudesData{6} = expertLowExcAmplitudes;

amplitudesData{7} = naiveHighInhAmplitudes;
amplitudesData{8} = naiveLowInhAmplitudes;
amplitudesData{9} = expertHighInhAmplitudes;
amplitudesData{10} = expertLowInhAmplitudes;

figure;
plotSpread(amplitudesData, 'xNames', {'H pooled', 'L pooled', 'H naive exc', 'L naive exc', 'H expert exc', 'L expert exc', 'H naive inh', 'L naive inh', 'H expert inh', 'L expert inh'}, ...
            'distributionMarkers', {'o', 'o','o', 'o','o', 'o','o', 'o','o', 'o'}, 'distributionColors', repmat([highProbColor ; lowProbColor ],5,1), 'showMM', 1)
        title(['P pooled = ' num2str(pPooled) ', P naive = ' num2str(pNaive) ', P expert = ' num2str(pExpert)])
        
        
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

