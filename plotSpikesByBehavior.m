function [params] = plotSpikesByBehavior(params)
%% Params

%% analyze the requested cluster and TT
plot_M_condition = 1;

%Only if we have a match to the requested cluster and TT.
if ~isempty(params.clusNum)
  
    %------------- all trials -----------
    plotCurrRaster(params, 'allTrials', plot_M_condition)
    
    %------------- CS+ -----------
    plotCurrRaster(params, 'CS+', plot_M_condition)
    
    %------------- CS- -----------
    plotCurrRaster(params, 'CS-', plot_M_condition)

end
end

function [] = plotCurrRaster(params, trialType, plot_M_condition)

patchColor = 'k';
smoothKernel = 0.05;
params.PSTHsmoothKernel = smoothKernel;
patchFaceAlpha = 0.2;
rasterMarkerSize = 1;
firstOdorXpatch = [-params.ISIbetweenOdors-params.odor_duration -params.ISIbetweenOdors -params.ISIbetweenOdors -params.ISIbetweenOdors-params.odor_duration]./1000;
secondOdorXpatch = [0 params.odor_duration params.odor_duration 0]./1000;
yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
summaryGraphXLim = [-params.ISIbetweenOdors-params.odor_duration-2000 params.odor_duration + 3000]./1000;

% FR
currUnitFR = params.firingRates(params.clusNum).firingRateByBIn;
frAnalysisIndices = find(params.firingRateAnalysisBins >=0 & params.firingRateAnalysisBins < 0.5);
p_fr = [];Braster = [];
switch trialType
    case 'allTrials'
        Araster = params.allRasterPlots(params.clusNum).data(params.Atrials);
        if isfield(params, 'Btrials')
            Braster = params.allRasterPlots(params.clusNum).data(params.Btrials);
        end
        Craster = params.allRasterPlots(params.clusNum).data(params.Ctrials);
    case 'CS+'
        
        Araster = params.allRasterPlots(params.clusNum).data(params.targetTrials.A);
        
        if isfield(params, 'Btrials')
            Braster = params.allRasterPlots(params.clusNum).data(params.targetTrials.B);
        end
        
        Craster = params.allRasterPlots(params.clusNum).data(params.targetTrials.C);
        
        A_fr = mean(currUnitFR(params.targetTrials.A, frAnalysisIndices),2);
        C_fr = mean(currUnitFR(params.targetTrials.C, frAnalysisIndices),2);
        [~,p_fr] = ttest2(A_fr, C_fr);
        
    case 'CS-'
        Araster = params.allRasterPlots(params.clusNum).data(params.tMinusTrials.A);
        
        if isfield(params, 'Btrials')
            Braster = params.allRasterPlots(params.clusNum).data(params.tMinusTrials.B);
        end
        
        Craster = params.allRasterPlots(params.clusNum).data(params.tMinusTrials.C);
        
        A_fr = mean(currUnitFR(params.tMinusTrials.A, frAnalysisIndices),2);
        C_fr = mean(currUnitFR(params.tMinusTrials.C, frAnalysisIndices),2);
        [~,p_fr] = ttest2(A_fr, C_fr);
        
end

maxRasterLength = max(size(Craster,2), size(Araster,2));

figure;
if plot_M_condition & ~isempty(Braster)
    subplot(5,1,1)
else
    subplot(4,1,1)
end
hold all;
% p = patch(firstOdorXpatch, yPatch.*length(maxRasterLength),patchColor, 'FaceAlpha', patchFaceAlpha);
% p.EdgeColor = 'none';
% p = patch(secondOdorXpatch, yPatch.*length(maxRasterLength),patchColor, 'FaceAlpha', patchFaceAlpha);
% p.EdgeColor = 'none';

for ind = 1:length(Araster)
    scatter(Araster(ind).times, ind.*ones(1,length(Araster(ind).times)), rasterMarkerSize, params.Acolor, 'filled');
end
plot([(params.delay_to_water+params.odor_duration)./1000 (params.delay_to_water+params.odor_duration)./1000], [0 maxRasterLength], '--b')
title(['A - ' trialType '; P V vs L = ' num2str(p_fr)])
set(gca, 'fontSize', 14);
hold off;
xlim(summaryGraphXLim)
axis off
ylim([0 maxRasterLength])

if plot_M_condition & ~isempty(Braster)
    subplot(5,1,2)
    for ind = 1:length(Braster)
        scatter(Braster(ind).times, ind.*ones(1,length(Braster(ind).times)), rasterMarkerSize, params.Bcolor, 'filled');
        hold on;
    end
    plot([(params.delay_to_water+params.odor_duration)./1000 (params.delay_to_water+params.odor_duration)./1000], [0 maxRasterLength], '--b')
    set(gca, 'fontSize', 14);
    hold off;
    xlim(summaryGraphXLim)
    axis off
    ylim([0 maxRasterLength])

end

if plot_M_condition & ~isempty(Braster)
    subplot(5,1,3)
else
    subplot(4,1,2)
end
hold all;
% p = patch(firstOdorXpatch, yPatch.*length(maxRasterLength),patchColor, 'FaceAlpha', patchFaceAlpha);
% p.EdgeColor = 'none';
% p = patch(secondOdorXpatch, yPatch.*length(maxRasterLength),patchColor, 'FaceAlpha', patchFaceAlpha);
% p.EdgeColor = 'none';

for ind = 1:length(Craster)
    scatter(Craster(ind).times, ind.*ones(1,length(Craster(ind).times)), rasterMarkerSize, params.Ccolor, 'filled');
end
plot([(params.delay_to_water+params.odor_duration)./1000 (params.delay_to_water+params.odor_duration)./1000], [0 maxRasterLength], '--b')
title(['C - ' trialType])
set(gca, 'fontSize', 14);
hold off;
xlim(summaryGraphXLim)
ylim([0 maxRasterLength])
axis off


if plot_M_condition & ~isempty(Braster)
    subplot(5,1,4:5)
else
    subplot(4,1,3:4)
end

hold all
p = patch(firstOdorXpatch, yPatch.*2,patchColor, 'FaceAlpha', patchFaceAlpha);
p.EdgeColor = 'none';
p = patch(secondOdorXpatch, yPatch.*2,patchColor, 'FaceAlpha', patchFaceAlpha);
p.EdgeColor = 'none';

mypsth(Araster, smoothKernel, params.Acolor);
if plot_M_condition & ~isempty(Braster)
   mypsth(Braster, smoothKernel, params.Bcolor);
end
mypsth(Craster, smoothKernel, params.Ccolor);

plot([(params.delay_to_water+params.odor_duration)./1000 (params.delay_to_water+params.odor_duration)./1000], [0 2], '--b')
xlabel('Time relative to CS(sec)');ylabel('Firing rate (Hz)')
set(gcf, 'Renderer', 'painters')
set(gca, 'FontSize', 14')
box off;
set(gcf, 'Renderer', 'painters')
xlim(summaryGraphXLim)
title(['\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', params.highProbColor) '} High', ...
    ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', params.lowProbColor) '} Low'])

set(groot, 'DefaultTextColor', 'k'); % Default text color
set(groot, 'DefaultAxesXColor', 'k'); % Default X-axis color
set(groot, 'DefaultAxesYColor', 'k'); % Default Y-axis color


%stat



end



