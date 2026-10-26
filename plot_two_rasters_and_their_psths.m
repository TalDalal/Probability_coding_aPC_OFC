function [] = plot_two_rasters_and_their_psths(raster1, raster2, color1, color2)

patchColor = 'k';
smoothKernel = 0.07;

ISIbetweenOdors = 1000;
odor_duration = 1000;


patchFaceAlpha = 0.2;
rasterMarkerSize = 3;
firstOdorXpatch = [-ISIbetweenOdors-odor_duration -ISIbetweenOdors -ISIbetweenOdors -ISIbetweenOdors-odor_duration]./1000;
secondOdorXpatch = [0 odor_duration odor_duration 0]./1000;
yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
summaryGraphXLim = [-ISIbetweenOdors-odor_duration-2000 odor_duration + 3000]./1000;



figure;
maxRasterLength = max(size(raster1,2), size(raster2,2));
subplot(4,1,1)
hold all;

for ind = 1:length(raster1)
    scatter(raster1(ind).times, ind.*ones(1,length(raster1(ind).times)), rasterMarkerSize, color1, 'filled');
end
set(gca, 'fontSize', 14);
hold off;
xlim(summaryGraphXLim)
axis off
ylim([0 maxRasterLength])

subplot(4,1,2)
hold all;

for ind = 1:length(raster2)
    scatter(raster2(ind).times, ind.*ones(1,length(raster2(ind).times)), rasterMarkerSize, color2, 'filled');
end
set(gca, 'fontSize', 14);
hold off;
xlim(summaryGraphXLim)
ylim([0 maxRasterLength])
axis off


subplot(4,1,3:4)
hold all
p = patch(firstOdorXpatch, yPatch.*2,patchColor, 'FaceAlpha', patchFaceAlpha);
p.EdgeColor = 'none';
p = patch(secondOdorXpatch, yPatch.*2,patchColor, 'FaceAlpha', patchFaceAlpha);
p.EdgeColor = 'none';

mypsth(raster1, smoothKernel, color1);
mypsth(raster2, smoothKernel, color2);

xlabel('Time relative to CS(sec)');ylabel('Firing rate (Hz)')
set(gcf, 'Renderer', 'painters')
set(gca, 'FontSize', 14')
box off;
set(gcf, 'Renderer', 'painters')
xlim(summaryGraphXLim)

set(groot, 'DefaultTextColor', 'k'); % Default text color
set(groot, 'DefaultAxesXColor', 'k'); % Default X-axis color
set(groot, 'DefaultAxesYColor', 'k'); % Default Y-axis color
