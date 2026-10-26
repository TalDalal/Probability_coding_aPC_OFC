highRaster = [params.PSTHsAndRasters.hit.A.rasterPlot  ...
    params.PSTHsAndRasters.miss.A.rasterPlot ...
    params.PSTHsAndRasters.CR.A.rasterPlot ...
    params.PSTHsAndRasters.FA.A.rasterPlot];

lowRaster = [params.PSTHsAndRasters.hit.C.rasterPlot  ...
    params.PSTHsAndRasters.miss.C.rasterPlot ...
    params.PSTHsAndRasters.CR.C.rasterPlot ...
    params.PSTHsAndRasters.FA.C.rasterPlot];



% ---------------PLOT-----------------
figure;
ISI = params.ISIbetweenOdors./1000;
odorDuration = params.odor_duration./1000;
waterDelay = odorDuration + params.delay_to_water./1000
firstOdorXpatch = [-ISI-odorDuration -ISI -ISI -ISI-odorDuration];
secondOdorXpatch = [0 odorDuration odorDuration 0];
yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
patchFaceAlpha = 0.1;

Acolor = [0,169,137]./255;%green
Ccolor = [171,62,143]./255;%purple;
patchColor = 'k';
rasterMarkerSize = 5;
psthKernel = 0.05;

yMaxLim = max(size(highRaster,2), size(lowRaster,2))+1;

figure;
subplot(4,1,1)
hold all;
patch(firstOdorXpatch, yPatch.*length(highRaster),patchColor, 'FaceAlpha', patchFaceAlpha)
patch(secondOdorXpatch, yPatch.*length(highRaster),patchColor, 'FaceAlpha', patchFaceAlpha)
for ind = 1:length(highRaster)
    scatter(highRaster(ind).times, ind.*ones(1,length(highRaster(ind).times)),rasterMarkerSize, ...
        'MarkerFaceColor',Acolor, 'MarkerEdgeColor', 'none');
end
plot([waterDelay waterDelay], [0 yMaxLim], 'b--')
hold off;
set(gca, 'fontSize', 14);
ylabel('Trial #');
ylim([0 yMaxLim])
xlim([-ISI-odorDuration-1 odorDuration+2])

subplot(4,1,2)
hold all;
patch(firstOdorXpatch, yPatch.*length(lowRaster),patchColor, 'FaceAlpha', patchFaceAlpha)
patch(secondOdorXpatch, yPatch.*length(lowRaster),patchColor, 'FaceAlpha', patchFaceAlpha)
for ind = 1:length(lowRaster)
    scatter(lowRaster(ind).times, ind.*ones(1,length(lowRaster(ind).times)),rasterMarkerSize, ...
        'MarkerFaceColor',Ccolor, 'MarkerEdgeColor', 'none');
end
plot([waterDelay waterDelay], [0 yMaxLim], 'b--')
hold off;
set(gca, 'fontSize', 14);
ylabel('Trial #')
ylim([0 yMaxLim])
xlim([-ISI-odorDuration-1 odorDuration+2])

subplot(4,1,3:4)
hold all;
patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)

mypsth(highRaster, psthKernel, Acolor);hold on;
mypsth(lowRaster, psthKernel, Ccolor);
hold off;
set(gca, 'fontSize', 14);box off;
ylabel('Firing rate (Hz)');xlabel('Time (sec)')
set(gcf, 'Renderer', 'painters')
xlim([-ISI-odorDuration-1 odorDuration+2])
