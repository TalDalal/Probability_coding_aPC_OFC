function [pooledPSTHstructEXC] = psth_delay_modulated_neurons(allMiceData, fgPeriod, bgPeriod,psthTimeWin, trialsIncluded, numSTDs, brainRegion)
% trialsIncluded = 'allTrials';bgPeriod = [-4 -3];psthTimeWin = [-2 0];
patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];
minMaxPatch = [0 6];
Z_flag = 1;plot_save_flag = 0;

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green
%%
[outputStruct] = detect_delay_modulated_neurons(allMiceData, bgPeriod, fgPeriod, trialsIncluded, numSTDs, brainRegion);


%% Get the sessions nums 
[successRates] = getSuccessRatesForEachNeuron(allMiceData, brainRegion);


%% Get the PSTH from all neurons
[PSTHstruct] = getPSTHfromAllNeurons(allMiceData, trialsIncluded, 'no', brainRegion);

%% Find the relevant neurons - naive vs expert, responding and inh vs exc

% Neurons recorded in naive and expert performance
srCriterion = 0.7;
meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';
performaceTitles = {'naive', 'expert'};

% 
% activeNeuronsExc_High = find(responseMat_High == 1);
% activeNeuronsExc_Low = find(responseMat_Low == 1);

allDelayActiveNeurons = outputStruct.responseMat_High + outputStruct.responseMat_Low;
activeNeuronsExc_High = find(allDelayActiveNeurons > 0);
activeNeuronsExc_Low = find(allDelayActiveNeurons > 0);

pooledPSTHstructEXC(1).allDelayActiveNeurons = allDelayActiveNeurons;
pooledPSTHstructEXC(1).responseMat_High = outputStruct.responseMat_High;
pooledPSTHstructEXC(1).responseMat_Low = outputStruct.responseMat_Low;
pooledPSTHstructEXC(1).responseMat_M = outputStruct.responseMat_M;
pooledPSTHstructEXC(1).high_Low_Flag = outputStruct.high_Low_Flag;

pooledPSTHstructEXC(1).expertInds = expertInds;
pooledPSTHstructEXC(1).naiveInds = naiveInds;
pooledPSTHstructEXC(1).meanSuccessRates = meanSuccessRates;

pooledPSTHstructEXC(1).Z_evokedRamping_High_vec = outputStruct.Z_evokedRamping_High_vec;
pooledPSTHstructEXC(1).Z_evokedRamping_Low_vec = outputStruct.Z_evokedRamping_Low_vec;
pooledPSTHstructEXC(1).Z_evokedRamping_Medium_vec =outputStruct.Z_evokedRamping_M;

pooledPSTHstructEXC(1).high_rasters = outputStruct.highRaster;
pooledPSTHstructEXC(1).low_rasters = outputStruct.lowRaster;
pooledPSTHstructEXC(1).medium_rasters = outputStruct.M_raster;

pooledPSTHstructEXC(1).high_CS_plus_Raster = outputStruct.high_CS_plus_Raster;
pooledPSTHstructEXC(1).high_CS_minus_Raster = outputStruct.high_CS_minus_Raster;

pooledPSTHstructEXC(1).low_CS_plus_Raster = outputStruct.low_CS_plus_Raster;
pooledPSTHstructEXC(1).low_CS_minus_Raster = outputStruct.low_CS_minus_Raster;

pooledPSTHstructEXC(1).high_evoked_activity = outputStruct.high_evoked_activity;
pooledPSTHstructEXC(1).low_evoked_activity = outputStruct.low_evoked_activity;
%% --------- mean PSTHs ----------
fig = figure;

for performanceInd = 1:length(performaceTitles)
    naiveOrExpert = performaceTitles{performanceInd};
    
    switch naiveOrExpert
        case 'naive'
            performanceInds = naiveInds;
        case 'expert'
            performanceInds = expertInds;
    end
    
    
    % Neurons that responded in excitation
    %--------- High ------
    %     A_responding_exc_inds = intersect(intersect(activeNeurons ,performanceInds),find(responseDirectionHigh(:)==1));
    High_responding_exc_inds = intersect(activeNeuronsExc_High ,performanceInds);
    High_responding_exc = [];
    if ~isempty(High_responding_exc_inds)
        High_responding_exc_struct = PSTHstruct(High_responding_exc_inds);
        
        if plot_save_flag
        savePSTHjpeg(High_responding_exc_struct, naiveOrExpert, highProbColor, lowProbColor, 'HIGH')
        end
        
        % Normalize psths
        
        [High_responding_exc, psthTimeVecForPlot] = normalizePSTHsAndSortToExcorInh(High_responding_exc_struct,bgPeriod, psthTimeWin, 'High', Z_flag);
    end

    
    %------LOW---------
    
    Low_responding_exc_inds = intersect(activeNeuronsExc_Low ,performanceInds);
    Low_responding_exc = [];
    if ~isempty(Low_responding_exc_inds)
        Low_responding_exc_struct = PSTHstruct(Low_responding_exc_inds);
        
        if plot_save_flag
        savePSTHjpeg(Low_responding_exc_struct, naiveOrExpert, highProbColor, lowProbColor, 'LOW')
        end
        
        % Normalize psths
        [Low_responding_exc] = normalizePSTHsAndSortToExcorInh(Low_responding_exc_struct, bgPeriod, psthTimeWin, 'Low', Z_flag);
    end
    
    
    if size(High_responding_exc,1) < 2 | size(Low_responding_exc,1) < 2
        continue
    end
    subplot(1,2,performanceInd)
    hold all;
    
    %Odor markers
    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
    %Plot high  excitation
    errorbar_patch(psthTimeVecForPlot, mean(High_responding_exc),std(High_responding_exc)./sqrt(size(High_responding_exc,1)), highProbColor);
    
    %Plot low  excitation
    if size(Low_responding_exc,1) > 1
    errorbar_patch(psthTimeVecForPlot, mean(Low_responding_exc),std(Low_responding_exc)./sqrt(size(Low_responding_exc,1)), lowProbColor);
    end
    
    %Excitation - PSTHs and indices of neurons
    pooledPSTHstructEXC(performanceInd).High_responding_exc = High_responding_exc;
    pooledPSTHstructEXC(performanceInd).High_responding_exc_inds = High_responding_exc_inds;
    pooledPSTHstructEXC(performanceInd).Low_responding_exc = Low_responding_exc;
    pooledPSTHstructEXC(performanceInd).Low_responding_exc_inds = Low_responding_exc_inds;
    
    title(naiveOrExpert)
    set(gcf, 'Renderer', 'painters');
    set(gca, 'FontSize', 18);box off;

    
    
end

han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
set(gca, 'FontSize', 15);
han.YLabel.Visible='on';
if Z_flag
    ylabel(han,'Z-score');
else
    ylabel(han,'Firing rate (Hz)');
end
xlabel(han,'Time relative to CS (S)');
% title(trialsIncluded);


pooledPSTHstructEXC(1).psthTimeVecForPlot = psthTimeVecForPlot;
pooledPSTHstructEXC(1).PSTHstruct = PSTHstruct;
end

function [] = savePSTHjpeg(inputPSTHdata, naiveOrExpert, highProbColor, lowProbColor, probFlag)
psthKernel = 0.07;
    for ind = 1:size(inputPSTHdata,2)
        figure;
        mypsth(inputPSTHdata(ind).rasterHigh, psthKernel, highProbColor)
        hold on;
        mypsth(inputPSTHdata(ind).rasterLow, psthKernel, lowProbColor)
        xlim([-3 .5])
        
        saveas(gca, ['F:\Experiments\2022\Behavior_Probability\head_fixed\Figures\examplesRamping\' naiveOrExpert '_' num2str(ind) '_' probFlag '.jpg'])
        close all
    end
end