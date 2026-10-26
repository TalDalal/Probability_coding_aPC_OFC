bgPeriod = [-2 -1.5];
psthTimeWin = [-.5 0];
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green
patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];
minMaxPatch = [-1 5];


%% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ HIGH ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%% Get the PSTH from all neurons in CS+ condition
[PSTHstruct_CSplus] = getPSTHfromAllNeurons(allMiceData, 'CS+', 'no');

% Find the PSTH indices from naive and expert state
highInds_EXC = [pooledPSTHstructEXC(1).High_responding_exc_inds ; pooledPSTHstructEXC(2).High_responding_exc_inds];
highPSTHs_EXC_CSplus = PSTHstruct_CSplus(highInds_EXC);
% Subtract baseline
[High_activeNeurons_exc_CSplus, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(highPSTHs_EXC_CSplus,bgPeriod, psthTimeWin, 'High');

%% Get the PSTH from all neurons in CS- condition
[PSTHstruct_CSminus] = getPSTHfromAllNeurons(allMiceData, 'CS-', 'no');

% Find the PSTH indices from naive and expert state
highPSTHs_EXC_CSminus = PSTHstruct_CSminus(highInds_EXC);
% Subtract baseline
[High_activeNeurons_exc_CSminus, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(highPSTHs_EXC_CSminus,bgPeriod, psthTimeWin, 'High');


%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ LOW ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%% Get the PSTH from all neurons in CS+ condition
[PSTHstruct_CSplus] = getPSTHfromAllNeurons(allMiceData, 'CS+', 'no');

% Find the PSTH indices from naive and expert state
lowInds_EXC = [pooledPSTHstructEXC(1).Low_responding_exc_inds ; pooledPSTHstructEXC(2).Low_responding_exc_inds];
lowPSTHs_EXC_CSplus = PSTHstruct_CSplus(lowInds_EXC);
% Subtract baseline
[Low_activeNeurons_exc_CSplus, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(lowPSTHs_EXC_CSplus,bgPeriod, psthTimeWin, 'Low');

%% Get the PSTH from all neurons in CS- condition
[PSTHstruct_CSminus] = getPSTHfromAllNeurons(allMiceData, 'CS-', 'no');

% Find the PSTH indices from naive and expert state
lowPSTHs_EXC_CSminus = PSTHstruct_CSminus(lowInds_EXC);
% Subtract baseline
[Low_activeNeurons_exc_CSminus, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(lowPSTHs_EXC_CSminus,bgPeriod, psthTimeWin, 'Low');


%% plot
figure;
hold all


plot(psthTimeVecForPlot, mean(High_activeNeurons_exc_CSplus),'Color', highProbColor, 'LineWidth', 1.5);
plot(psthTimeVecForPlot, mean(High_activeNeurons_exc_CSminus),'Color', highProbColor,'LineStyle', '--');

plot(psthTimeVecForPlot, mean(Low_activeNeurons_exc_CSplus),'Color', lowProbColor, 'LineWidth', 1.5);
plot(psthTimeVecForPlot, mean(Low_activeNeurons_exc_CSminus),'Color', lowProbColor,'LineStyle', '--');

patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

hold off;
legend('High CS+', 'High CS-', 'Low CS+', 'Low CS-')
set(gca, 'FontSize', 18);
ylabel('Firing rate (Hz)');
xlabel('Time from CS (S)');
set(gcf, 'Renderer', 'painters');

