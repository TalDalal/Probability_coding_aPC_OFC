[allMiceData] = concateMiceData([2 3 13]);% the number marks the mouse number
[pooledPSTHstructEXC_PE] = plotPSTHduringCSodor(allMiceData, [-4 -3], [0 1], 0.01, 'CS+', 'individualResponse');

expertData = pooledPSTHstructEXC_PE(2);
%Find neurons that responded in high and low conditions
bothCondActive = (intersect(expertData.High_responding_exc_inds, expertData.Low_responding_exc_inds));

%Find thier indices
bothResponsing_indices_high = find(ismember(expertData.High_responding_exc_inds, bothCondActive));
bothResponsing_indices_Low = find(ismember(expertData.Low_responding_exc_inds, bothCondActive));

%Extract thier amplitudes
bothRespondingAmplitudes_High = expertData.expertHighExcAmplitudes(bothResponsing_indices_high);
bothRespondingAmplitudes_Low = expertData.expertLowExcAmplitudes(bothResponsing_indices_Low);

plotArray{1} = bothRespondingAmplitudes_High;
plotArray{2} = bothRespondingAmplitudes_Low;

figure;
plotSpread(plotArray)


%% Ex
tVec = pooledPSTHstructEXC_PE(1).psthTimeVecForPlot;
expertData = pooledPSTHstructEXC_PE(2);
%Find neurons that responded in high and low conditions
bothCondActive = (intersect(expertData.High_responding_exc_inds, expertData.Low_responding_exc_inds));

%High responding
onlyHighRespondingNeurons = setdiff(expertData.High_responding_exc_inds, bothCondActive);
onlyHighRespondingNeurons_inds = find(ismember(expertData.High_responding_exc_inds, onlyHighRespondingNeurons))';
onlyHigh_amps = expertData.expertHighExcAmplitudes(onlyHighRespondingNeurons_inds);
onlyHigh_PSTH = expertData.High_responding_exc(onlyHighRespondingNeurons_inds,:);

%Low responding
onlyLowRespondingNeurons = setdiff(expertData.Low_responding_exc_inds, bothCondActive);
onlyLowRespondingNeurons_inds = find(ismember(expertData.Low_responding_exc_inds, onlyLowRespondingNeurons))';
onlyLow_amps = expertData.expertLowExcAmplitudes(onlyLowRespondingNeurons_inds);
onlyLow_PSTH = expertData.Low_responding_exc(onlyLowRespondingNeurons_inds,:);

%Both
%Find thier indices
bothResponsing_indices_high = find(ismember(expertData.High_responding_exc_inds, bothCondActive));
bothResponsing_indices_Low = find(ismember(expertData.Low_responding_exc_inds, bothCondActive));

%Extract thier amplitudes
bothRespondingAmplitudes_High = expertData.expertHighExcAmplitudes(bothResponsing_indices_high);
bothRespondingAmplitudes_Low = expertData.expertLowExcAmplitudes(bothResponsing_indices_Low);

plotArray{1} = onlyHigh_amps;
plotArray{2} = onlyLow_amps;
plotArray{3} = bothRespondingAmplitudes_High;
plotArray{4} = bothRespondingAmplitudes_Low;

figure;
plotSpread(plotArray, 'xNames', {'Only H responding', 'Only L responding', 'Both conditions - H', 'Respond in both conditions - L'}, ...
            'distributionMarkers', {'o', 'o','o','o'}, 'showMM', 1)
        set(gca, 'FontSize', 18);box off;
        title('CS+ - expert')
        

%%
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];
minMaxPatch = [-10 10];

tVec = pooledPSTHstructEXC_PE(1).psthTimeVecForPlot;
expertData = pooledPSTHstructEXC_PE(2);
PSTHstruct = pooledPSTHstructEXC_PE(1).PSTHstruct;
bgPeriod = [-4 -3];
psthTimeWin = [-2 2];

bothCondActive = (intersect(expertData.High_responding_exc_inds, expertData.Low_responding_exc_inds));

%High responding
onlyHighRespondingNeurons = setdiff(expertData.High_responding_exc_inds, bothCondActive);
onlyHighRespondingNeurons_exc_struct = PSTHstruct(onlyHighRespondingNeurons);

[onlyHighRespondingNeurons_H_PSTH, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(onlyHighRespondingNeurons_exc_struct,bgPeriod, psthTimeWin, 'High');
[onlyHighRespondingNeurons_L_PSTH, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(onlyHighRespondingNeurons_exc_struct,bgPeriod, psthTimeWin, 'Low');

%Low responding
onlyLowRespondingNeurons = setdiff(expertData.Low_responding_exc_inds, bothCondActive);
onlyLowRespondingNeurons_exc_struct = PSTHstruct(onlyLowRespondingNeurons);

[onlyLowRespondingNeurons_H_PSTH, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(onlyLowRespondingNeurons_exc_struct,bgPeriod, psthTimeWin, 'High');
[onlyLowRespondingNeurons_L_PSTH, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(onlyLowRespondingNeurons_exc_struct,bgPeriod, psthTimeWin, 'Low');

% Both
%Find neurons that responded in high and low conditions
bothRespondingNeurons_exc_struct = PSTHstruct(bothCondActive);
[bothRespondingNeurons_H_PSTH, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(bothRespondingNeurons_exc_struct,bgPeriod, psthTimeWin, 'High');
[bothRespondingNeurons_L_PSTH, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(bothRespondingNeurons_exc_struct,bgPeriod, psthTimeWin, 'Low');


figure;
subplot(1,3,1)
errorbar_patch(psthTimeVecForPlot, mean(onlyHighRespondingNeurons_H_PSTH), std(onlyHighRespondingNeurons_H_PSTH)./sqrt(size(onlyHighRespondingNeurons_H_PSTH,1)), highProbColor)
hold all;
errorbar_patch(psthTimeVecForPlot, mean(onlyHighRespondingNeurons_L_PSTH), std(onlyHighRespondingNeurons_L_PSTH)./sqrt(size(onlyHighRespondingNeurons_L_PSTH,1)), lowProbColor)
patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

set(gca, 'FontSize', 18);box off;
title(['Only H responding neurons, N = ' num2str(size(onlyHighRespondingNeurons_H_PSTH,1))])

subplot(1,3,2)
errorbar_patch(psthTimeVecForPlot, mean(onlyLowRespondingNeurons_H_PSTH), std(onlyLowRespondingNeurons_H_PSTH)./sqrt(size(onlyLowRespondingNeurons_H_PSTH,1)), highProbColor)
hold all;
errorbar_patch(psthTimeVecForPlot, mean(onlyLowRespondingNeurons_L_PSTH), std(onlyLowRespondingNeurons_L_PSTH)./sqrt(size(onlyLowRespondingNeurons_L_PSTH,1)), lowProbColor)
patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

set(gca, 'FontSize', 18);box off;
title(['Only L responding neurons, N = ' num2str(size(onlyLowRespondingNeurons_H_PSTH,1))])

subplot(1,3,3)
errorbar_patch(psthTimeVecForPlot, mean(bothRespondingNeurons_H_PSTH), std(bothRespondingNeurons_H_PSTH)./sqrt(size(bothRespondingNeurons_H_PSTH,1)), highProbColor)
hold all;
errorbar_patch(psthTimeVecForPlot, mean(bothRespondingNeurons_L_PSTH), std(bothRespondingNeurons_L_PSTH)./sqrt(size(bothRespondingNeurons_L_PSTH,1)), lowProbColor)
patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

set(gca, 'FontSize', 18);box off;
title(['Both responding neurons, N = ' num2str(size(bothRespondingNeurons_L_PSTH,1))])


figure;
k=7;
mypsth(onlyLowRespondingNeurons_exc_struct(k).rasterHigh, 0.07, highProbColor);
clc
hold all
mypsth(onlyLowRespondingNeurons_exc_struct(k).rasterLow, 0.07, lowProbColor);