function [] = allSessionsLickPSTH_OFCsilencingAfterLearning(allMiceData, srCriterion)

lickSmoothKernel = 0.07;
sessionsCounter = 0;
beforeCounter = 0; afterCounter = 0; washoutCounter = 0;

highLickRasterBefore  = []; lowLickRasterBefore  = [];
highLickRasterAfter   = []; lowLickRasterAfter   = [];
highLickRasterWashout = []; lowLickRasterWashout = [];

H_RT_before  = []; L_RT_before  = [];
H_RT_after   = []; L_RT_after   = [];
H_RT_washout = []; L_RT_washout = [];

% per-session storage, used to build the per-session PSTH figure (fig 2)
sessionPhase      = {};   % 'Before' / 'After' / 'Washout'
sessionHighRaster = {};
sessionLowRaster  = {};

for mouseInd = 1:size(allMiceData,2)
    
    allRecs = allMiceData(mouseInd).allRecs;
    
    for recInd = 1:size(allRecs,2)
        
        if allRecs(recInd).sessionNum > 0 & ... % not pretraining
                allRecs(recInd).data.successRate.A > srCriterion & ...
                allRecs(recInd).data.successRate.C > srCriterion % ONLY experiment sessions above criterion
            
            % figure out which odor (A/C) was the "high" vs "low" probability one
            if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                highLetter = 'A'; lowLetter = 'C';
            else
                highLetter = 'C'; lowLetter = 'A';
            end
            
            highRaster = allRecs(recInd).data.LickRaster.hit.(highLetter);
            lowRaster  = allRecs(recInd).data.LickRaster.hit.(lowLetter);
            highRT     = mean(allRecs(recInd).data.firstLickLatency.(highLetter));
            lowRT      = mean(allRecs(recInd).data.firstLickLatency.(lowLetter));
            
            beforeAfterLabel = allRecs(recInd).beforeAfterInjection;
            if iscell(beforeAfterLabel)
                beforeAfterLabel = beforeAfterLabel{1};
            end
            
            switch lower(beforeAfterLabel)
                case 'before'
                    highLickRasterBefore = [highLickRasterBefore highRaster];
                    lowLickRasterBefore  = [lowLickRasterBefore  lowRaster];
                    H_RT_before(end+1) = highRT; %#ok<AGROW>
                    L_RT_before(end+1) = lowRT;  %#ok<AGROW>
                    beforeCounter = beforeCounter + 1;
                    phaseLabel = 'Before';
                    
                case 'after'
                    highLickRasterAfter = [highLickRasterAfter highRaster];
                    lowLickRasterAfter  = [lowLickRasterAfter  lowRaster];
                    H_RT_after(end+1) = highRT; %#ok<AGROW>
                    L_RT_after(end+1) = lowRT;  %#ok<AGROW>
                    afterCounter = afterCounter + 1;
                    phaseLabel = 'After';
                    
                case 'washout'
                    highLickRasterWashout = [highLickRasterWashout highRaster];
                    lowLickRasterWashout  = [lowLickRasterWashout  lowRaster];
                    H_RT_washout(end+1) = highRT; %#ok<AGROW>
                    L_RT_washout(end+1) = lowRT;  %#ok<AGROW>
                    washoutCounter = washoutCounter + 1;
                    phaseLabel = 'Washout';
                    
                otherwise
                    warning('Unrecognized beforeAfterInjection value "%s" (mouse %d, rec %d). Skipping.', ...
                        beforeAfterLabel, mouseInd, recInd);
                    continue
            end
            
            % stash this session's rasters for the per-session PSTH figure
            sessionPhase{end+1}      = phaseLabel;    %#ok<AGROW>
            sessionHighRaster{end+1} = highRaster;    %#ok<AGROW>
            sessionLowRaster{end+1}  = lowRaster;     %#ok<AGROW>
            
            sessionsCounter = sessionsCounter + 1;
        end
    end
    
end

fprintf('Sessions included -> Sham: %d, JH60: %d, Washout: %d (total %d)\n', ...
    beforeCounter, afterCounter, washoutCounter, sessionsCounter);

%% plot settings
firstOdorTimes  = [-allRecs(1).data.ISIbetweenOdors-allRecs(1).data.odor_duration, -allRecs(1).data.odor_duration]./1000;
secondOdorTimes = [0, allRecs(1).data.odor_duration]./1000;
GoOdorColor = [.5 .5 .5];
transpValue = .2;   % patch alpha - lower this further for even more transparency
highColor = [0,169,137]./255;   % green
lowColor  = [171,62,143]./255;  % purple
orangeColor = [1 0.55 0];

XLIM_fig1 = [-1 2];   % pooled PSTH figure
XLIM_fig2 = [-1 4];   % per-session PSTH figure
YLIM = [0 11];

allPhaseNames = {'Before', 'After', 'Washout'};
allPlotTitles = {'Sham', 'JH60', 'Washout'};
allHighRasterByPhase = {highLickRasterBefore, highLickRasterAfter, highLickRasterWashout};
allLowRasterByPhase  = {lowLickRasterBefore,  lowLickRasterAfter,  lowLickRasterWashout};
phaseCounts = [beforeCounter, afterCounter, washoutCounter];

% only keep phases that actually have sessions (e.g. drop Washout if a
% mouse/dataset never had washout sessions)
keepPhase = phaseCounts > 0;
phaseNames = allPhaseNames(keepPhase);
plotTitles = allPlotTitles(keepPhase);
highRasterByPhase = allHighRasterByPhase(keepPhase);
lowRasterByPhase  = allLowRasterByPhase(keepPhase);
nPhases = sum(keepPhase);

%% Figure 1: pooled PSTH - Sham / JH60 / (Washout if present)
figure;
for p = 1:nPhases
    subplot(1,nPhases,p);
    hold all;
    addGrayEpochPatches(firstOdorTimes, secondOdorTimes, YLIM, GoOdorColor, transpValue);
    
    objsBefore = allchild(gca);
    mypsth(highRasterByPhase{p}, lickSmoothKernel, highColor);
    objsAfterHigh = allchild(gca);
    highLineH = findobj(setdiff(objsAfterHigh, objsBefore, 'stable'), 'flat', 'Type', 'line');
    
    mypsth(lowRasterByPhase{p},  lickSmoothKernel, lowColor);
    objsAfterLow = allchild(gca);
    lowLineH = findobj(setdiff(objsAfterLow, objsAfterHigh, 'stable'), 'flat', 'Type', 'line');
    
    set(gca, 'FontSize', 18); box off;
    title(plotTitles{p});
    xlim(XLIM_fig1); ylim(YLIM);
    xlabel('Time from CS+ odor (sec)');
    if p == 1
        ylabel('Lick rate (Hz)');
        % legend only on the first panel - mypsth also draws a shaded SEM
        % patch, so we grab just the mean-trace Line handles for it
        legend([highLineH(1) lowLineH(1)], ...
            {'Context A (P(CS+) = 0.75)', 'Context B (P(CS+) = 0.25)'}, ...
            'Location', 'best');
        legend boxoff
    end
    
    if strcmpi(phaseNames{p}, 'After')
        % flag the JH60 (after-injection) panel with an orange bar
        barY = YLIM(2) - 0.04*(YLIM(2)-YLIM(1));
        plot(XLIM_fig1, [barY barY], 'Color', orangeColor, 'LineWidth', 5);
    end
end

%% Figure 2: per-session PSTH - one subplot per session (1 x N), grouped by phase
nSessionsTotal = length(sessionPhase);
figure;
subplotInd = 0;
for p = 1:nPhases
    idx = find(strcmpi(sessionPhase, phaseNames{p}));
    for k = idx
        subplotInd = subplotInd + 1;
        subplot(1, nSessionsTotal, subplotInd);
        hold all;
        addGrayEpochPatches(firstOdorTimes, secondOdorTimes, YLIM, GoOdorColor, transpValue);
        
        mypsth(sessionHighRaster{k}, lickSmoothKernel, highColor);
        mypsth(sessionLowRaster{k},  lickSmoothKernel, lowColor);
        
        set(gca, 'FontSize', 18); box off;
        title(plotTitles{p});
        xlim(XLIM_fig2); ylim(YLIM);
        if subplotInd == 1
            xlabel('Time from CS+ odor (sec)');
            ylabel('Lick rate (Hz)');
        end
        
        if strcmpi(phaseNames{p}, 'After')
            % flag after-injection (JH60) sessions with an orange bar
            barY = YLIM(2) - 0.04*(YLIM(2)-YLIM(1));
            plot(XLIM_fig2, [barY barY], 'Color', orangeColor, 'LineWidth', 5);
        end
    end
end

%% Figure 3: mean lick rate in the -2 to 1 s window, mean +/- SEM per phase
rateWindow = [-1 1];
sessionMeanRateHigh = nan(1, nSessionsTotal);
sessionMeanRateLow  = nan(1, nSessionsTotal);
for k = 1:nSessionsTotal
    sessionMeanRateHigh(k) = computeMeanRateInWindow(sessionHighRaster{k}, rateWindow);
    sessionMeanRateLow(k)  = computeMeanRateInWindow(sessionLowRaster{k},  rateWindow);
end

figure;
hold all;
hHighErr = gobjects(1, nPhases);
hLowErr  = gobjects(1, nPhases);
for p = 1:nPhases
    inPhase = strcmpi(sessionPhase, phaseNames{p});
    highVals = sessionMeanRateHigh(inPhase);
    lowVals  = sessionMeanRateLow(inPhase);
    
    hHighErr(p) = errorbar(p, mean(highVals), std(highVals)./sqrt(numel(highVals)), ...
        'Color', highColor, 'LineWidth', 2, 'Marker', 'o');
    hLowErr(p)  = errorbar(p, mean(lowVals), std(lowVals)./sqrt(numel(lowVals)), ...
        'Color', lowColor, 'LineWidth', 2, 'Marker', 'o');
end
set(gca, 'XTick', 1:nPhases, 'XTickLabel', plotTitles, 'FontSize', 18); box off;
xlim([0.5 nPhases+0.5]);
ylabel(sprintf('Mean lick rate, %g to %g s (Hz)', rateWindow(1), rateWindow(2)));
legend([hHighErr(1) hLowErr(1)], ...
    {'Context A (P = 0.75 CS+)', 'Context B (P = 0.25 CS+)'}, 'Location', 'best');
legend boxoff

%% PLOT RTs (unchanged - Before/After only, as in the original)
figure;
lickData{1} = H_RT_before;
lickData{2} = L_RT_before;
lickData{3} = H_RT_after;
lickData{4} = L_RT_after;
categories = {'H', 'L', 'H', 'L'};
colors = [highColor; lowColor; highColor; lowColor];  % Optional custom colors

violinplot_with_mean_single_side(lickData, categories, colors, 1, 0);
hold all
plot(1:2, [H_RT_before' L_RT_before'], 'k-')
plot(3:4, [H_RT_after' L_RT_after'], 'k-')
ylabel('First lick latency (S)')

end


function addGrayEpochPatches(firstOdorTimes, secondOdorTimes, YLIM, patchColor, patchAlpha)
% Draws two transparent gray patches marking the first/second odor epochs.
% Called before the PSTH lines are plotted so the patches sit behind the data.
patch([firstOdorTimes(1) firstOdorTimes(2) firstOdorTimes(2) firstOdorTimes(1)], ...
    [YLIM(1) YLIM(1) YLIM(2) YLIM(2)], patchColor, ...
    'FaceAlpha', patchAlpha, 'EdgeColor', 'none');
patch([secondOdorTimes(1) secondOdorTimes(2) secondOdorTimes(2) secondOdorTimes(1)], ...
    [YLIM(1) YLIM(1) YLIM(2) YLIM(2)], patchColor, ...
    'FaceAlpha', patchAlpha, 'EdgeColor', 'none');
end


function rate = computeMeanRateInWindow(raster, window)
% raster: 1 x nTrials struct array, each element with a '.times' field
% holding that trial's lick times (s) relative to CS+ onset, for one
% session (same format mypsth consumes).
% window: [tStart tEnd] in seconds.
% Returns the session's mean lick rate (Hz) within that window, pooled
% across trials.
if isempty(raster)
    rate = NaN;
    return
end
nTrials = numel(raster);
counts = arrayfun(@(trial) sum(trial.times >= window(1) & trial.times <= window(2)), raster);
rate = sum(counts) / (nTrials * diff(window));
end