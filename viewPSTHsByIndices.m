function [] = viewPSTHsByIndices(pooledPSTHstructEXC)
%%
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green
patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];
rasterMarkerSize = 6;
rampPlotXLIM = [-3 3];
yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
patchFaceAlpha = 0.1;
psthKernel = 0.07;
psthPatchYlim = [0 5];
%%
high_exc_inds = [pooledPSTHstructEXC(1).High_responding_exc_inds ; pooledPSTHstructEXC(2).High_responding_exc_inds];
low_exc = [pooledPSTHstructEXC(1).Low_responding_exc_inds ; pooledPSTHstructEXC(2).Low_responding_exc_inds];
high_exc_rasterPlots = pooledPSTHstructEXC(1).PSTHstruct(high_exc_inds);
%% 
for rasterInd = 1:size(high_exc_rasterPlots,2)
    currRasterHigh = high_exc_rasterPlots(rasterInd).rasterHigh;
    currRasterLow = high_exc_rasterPlots(rasterInd).rasterLow;
    
    minMaxPatch = [0 max(length(currRasterHigh), length(currRasterLow))+1];

    figure;
    subplot(4,1,1)
    hold all;
    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

    for ind = 1:length(currRasterHigh)
        scatter(currRasterHigh(ind).times, ind.*ones(1,length(currRasterHigh(ind).times)),rasterMarkerSize, ...
            'MarkerFaceColor',highProbColor, 'MarkerEdgeColor', 'none');
    end
    hold off;
    set(gca, 'fontSize', 14);
    ylabel('Trial #');
    ylim([0 max(length(currRasterHigh), length(currRasterLow))+1])
    xlim(rampPlotXLIM)
    
        subplot(4,1,2)
    hold all;
    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    for ind = 1:length(currRasterLow)
        scatter(currRasterLow(ind).times, ind.*ones(1,length(currRasterLow(ind).times)),rasterMarkerSize, ...
            'MarkerFaceColor',lowProbColor, 'MarkerEdgeColor', 'none');
    end
    hold off;
    set(gca, 'fontSize', 14);
    ylabel('Trial #');
    ylim([0 max(length(currRasterHigh), length(currRasterLow))+1])
    xlim(rampPlotXLIM)
    
    subplot(4,1,3:4)
    hold all;
    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[psthPatchYlim(1) psthPatchYlim(1) psthPatchYlim(2) psthPatchYlim(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[psthPatchYlim(1) psthPatchYlim(1) psthPatchYlim(2) psthPatchYlim(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

    mypsth(currRasterHigh, psthKernel, highProbColor);hold on;
    mypsth(currRasterLow, psthKernel, lowProbColor);
    hold off;
    set(gca, 'fontSize', 14);box off;
    ylabel('Firing rate (Hz)');xlabel('Time (sec)')
    set(gcf, 'Renderer', 'painters')
    xlim(rampPlotXLIM)
    
    close all;
end
    
