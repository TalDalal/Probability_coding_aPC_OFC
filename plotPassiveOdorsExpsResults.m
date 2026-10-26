function [] = plotPassiveOdorsExpsResults(params)


%% Rasters
params.PSTHsAndRasters.rasterA = params.allRasterPlots(params.clusNum).data(params.Atrials);
params.PSTHsAndRasters.rasterB = params.allRasterPlots(params.clusNum).data(params.Btrials);
params.PSTHsAndRasters.rasterC = params.allRasterPlots(params.clusNum).data(params.Ctrials);
params.PSTHsAndRasters.rasterTplus = params.allRasterPlots(params.clusNum).data(params.TplusTrials);
params.PSTHsAndRasters.rasterTminus = params.allRasterPlots(params.clusNum).data(params.TminusTrials);


%% Plot
clrArray = [155,41,72 ; 255,114,81 ; 255,205,116 ; 85,51,17 ; 153,102,51]./255;

figure;
subplot(2,3,1)
if ~isempty(params.PSTHsAndRasters.rasterA)
    plotRasterPlot(params, params.PSTHsAndRasters.rasterA, clrArray(1,:), 'A')
end
subplot(2,3,2)
if ~isempty(params.PSTHsAndRasters.rasterB)
    plotRasterPlot(params, params.PSTHsAndRasters.rasterB, clrArray(2,:), 'B')
end
subplot(2,3,3)
if ~isempty(params.PSTHsAndRasters.rasterC)
    plotRasterPlot(params, params.PSTHsAndRasters.rasterC, clrArray(3,:), 'C')
end
subplot(2,3,4)
if ~isempty(params.PSTHsAndRasters.rasterTplus)
    plotRasterPlot(params, params.PSTHsAndRasters.rasterTplus, clrArray(4,:), 'T+')
end
subplot(2,3,5)
if ~isempty(params.PSTHsAndRasters.rasterTminus)
    plotRasterPlot(params, params.PSTHsAndRasters.rasterTminus, clrArray(5,:), 'T-')
end

subplot(2,3,6)
plot(1:length(params.odorsTuningCurve), params.odorsTuningCurve, '-sk', 'LineWidth', 2)
hold all;
box off;set(gca, 'FontSize', 14, 'XTickLabel', {'A', 'B', 'C', 'T+', 'T-'})
signifLocs = find(params.pArray < 0.05);
for signifInd = 1:length(signifLocs)
    text(signifLocs(signifInd), params.odorsTuningCurve(signifLocs(signifInd)), '*', 'FontSize', 40)
end
