function [] = plotRasterPlot(params, spikeTimes, clr, currTitle)
%% PARAMS
smoothKernel = 0.05;
patchFaceAlpha = 0.2;
rasterMarkerSize = 10;
patchColor = 'k';
secondOdorXpatch = [0 params.odor_duration params.odor_duration 0]./1000;
yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
xlimParams = [-1.5 3];
%% Rater plot
hold all;
for trialInd = 1:size(spikeTimes,2)
    scatter(spikeTimes(trialInd).times,  trialInd.*ones(1, length(spikeTimes(trialInd).times)), rasterMarkerSize, clr, 'filled')
end
set(gca, 'FontSize', 14')
box off;
xlim(xlimParams)
%% PSTH
hold all
patch(secondOdorXpatch, yPatch.*2,patchColor, 'FaceAlpha', patchFaceAlpha)
mypsth(spikeTimes, smoothKernel, clr);
xlabel('Time (sec)');ylabel('Firing rate (Hz)')
set(gcf, 'Renderer', 'painters')
set(gca, 'FontSize', 14')
box off;
set(gcf, 'Renderer', 'painters')
xlim(xlimParams)
title(currTitle)
