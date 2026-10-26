function [] = plotPSTHduringDelay(bgPeriod, psthTimeWin, pValueTH, trialsIncluded)

%trialsIncluded = allTrials; CS+ or CS-


%% settings
CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];
minMaxPatch = [-2 6];

[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number

%% Get the sessions nums and binary response mat
[successRates] = getSuccessRatesForEachNeuron(allMiceData);


%% Get binary mat of active neurons
[activityMat_High, activityMat_Low] = responondingNeuronsWithinATimeWindow(allMiceData, pValueTH, bgPeriod, psthTimeWin, trialsIncluded);

%% Get the PSTH from all neurons
[PSTHstruct] = getPSTHfromAllNeurons(allMiceData, trialsIncluded);

%% Find the relevant neurons - naive vs expert, responding and inh vs exc

% Neurons recorded in naive and expert performance
srCriterion = 0.8;
meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';
allSessions = [naiveInds ;expertInds];

performaceTitles = {'allSessions'};


%Neurons that responded to both odors
activeNeurons = find(activityMat_High ~= 0 & activityMat_Low ~= 0);
responseDirectionHigh = activityMat_High;responseDirectionLow = activityMat_Low;


%%
fig = figure;

for performanceInd = 1:length(performaceTitles)
    naiveOrExpert = performaceTitles{performanceInd};
    
    switch naiveOrExpert
        case 'naive'
            performanceInds = naiveInds;
        case 'expert'
            performanceInds = expertInds;
        case 'allSessions'
            performanceInds = allSessions;
    end
    
    
    % Neurons that responded in excitation
    %--------- High ------
    %     A_responding_exc_inds = intersect(intersect(activeNeurons ,performanceInds),find(responseDirectionHigh(:)==1));
    A_responding_exc_inds = intersect(find(responseDirectionHigh(:)==1) ,performanceInds);
    A_responding_exc_struct = PSTHstruct(A_responding_exc_inds);
    % Normalize psths
    [A_responding_exc, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(A_responding_exc_struct,bgPeriod, psthTimeWin, 'High');
    
    
    %------LOW---------
    C_responding_exc_inds = intersect(find(responseDirectionLow(:)==1) ,performanceInds);
    C_responding_exc_struct = PSTHstruct(C_responding_exc_inds);
    % Normalize psths
    [C_responding_exc] = normalizePSTHsAndSortToExcorInh(C_responding_exc_struct, bgPeriod, psthTimeWin, 'Low');
    
    
    
    subplot(1,length(performaceTitles),performanceInd)
    hold all;
    
    %Odor markers
    
    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
    errorbar_patch(psthTimeVecForPlot, mean(A_responding_exc),std(A_responding_exc)./sqrt(size(A_responding_exc,1)), AColor);
    
    errorbar_patch(psthTimeVecForPlot, mean(C_responding_exc),std(C_responding_exc)./sqrt(size(C_responding_exc,1)), CColor);

    
    set(gcf, 'Renderer', 'painters');
    set(gca, 'FontSize', 15);box off;
    %     title([naiveOrExpert ' N: High exc., ' num2str(length(A_responding_exc_inds)), ...
    %         ' High inh., ' num2str(length(A_responding_inh_inds)), ...
    %         ' Low exc., ' num2str(length(C_responding_exc_inds)), ...
    %         ' Low inh., ' num2str(length(C_responding_inh_inds))])
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

