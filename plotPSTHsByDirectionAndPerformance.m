function [neuronIndices, alltrialsActivity] = plotPSTHsByDirectionAndPerformance(allMiceData, analysisTimeWin, pValueTH, cueOrCSodor)

CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
%% Get the sessions nums and binary response mat
[alltrialsActivity, binaryResponseMat] = testTrialPartsSignificance(allMiceData, analysisTimeWin, pValueTH);

% Fnd the session number
for trialsInd = 1:size(alltrialsActivity,2)
    SR_vec(trialsInd,:) = alltrialsActivity(trialsInd).successRates;
end

%% Get the PSTH from all neurons
[fullDataStruct] = convertdifferentMiceDataIntoSingleStruct(allMiceData, 'PC');% unifies the structures

if strcmpi(cueOrCSodor, 'cue')
    [outputStruct] = plotNeuronMatricesForHighAndLowConditions(fullDataStruct, [-2 -1], [-2 -.3], 300);
    
elseif strcmpi(cueOrCSodor, 'CS')
    [outputStruct] = plotNeuronMatricesForHighAndLowConditions(fullDataStruct, [0 1], [0 1], 300);
end
% close all
responseDirection = [outputStruct.responseDirection_A;outputStruct.responseDirection_C];

allPSTHs_A = outputStruct.allPSTHs_A;
allPSTHs_C = outputStruct.allPSTHs_C;

%% Extract only the excitatory responding neurons

%Neurons recorded in naive and expert performance
srCriterion = 0.8;
meanSuccessRates = mean([SR_vec(:,2)';SR_vec(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';

performaceTitles = {'naive', 'expert'};
fig = figure;
for performanceInd = 1:length(performaceTitles)
    naiveOrExpert = performaceTitles(performanceInd);
    
    if strcmpi(naiveOrExpert, 'naive')
        performanceInds = naiveInds;
    elseif strcmpi(naiveOrExpert, 'expert')
        performanceInds = expertInds;
        
    else
        performanceInds = 1:size(allPSTHs_A,1);
    end
    
    %Neurons that responded to both codors
    both_Response = find(binaryResponseMat(:,1) > 0 & binaryResponseMat(:,2) > 0);
    
    
    %--------- High ------
    A_responding_exc_inds = intersect(intersect(both_Response ,performanceInds),find(responseDirection(1,:)==1));
    A_responding_exc = allPSTHs_A(A_responding_exc_inds,:);
    
    A_responding_inh_inds = intersect(intersect(both_Response ,performanceInds),find(responseDirection(1,:)==-1));
    A_responding_inh = allPSTHs_A(A_responding_inh_inds,:);
    
    %------LOW---------
    C_responding_exc_inds = intersect(intersect(both_Response ,performanceInds),find(responseDirection(2,:)==1));
    C_responding_exc = allPSTHs_C(C_responding_exc_inds,:);
    
    C_responding_inh_inds = intersect(intersect(both_Response ,performanceInds),find(responseDirection(2,:)==-1));
    C_responding_inh = allPSTHs_C(C_responding_inh_inds,:);
    
    
    minMaxPlot = [-15 10];
    cutTimeBins = outputStruct.cutTimeBins;
    
    
    subplot(1,2,performanceInd)
    hold all;
    
    %Odor markers
    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPlot(1) minMaxPlot(1) minMaxPlot(2) minMaxPlot(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
    errorbar_patch(cutTimeBins, mean(A_responding_exc),std(A_responding_exc)./sqrt(size(A_responding_exc,1)), AColor);
%     errorbar_patch(cutTimeBins, mean(A_responding_inh),std(A_responding_inh)./sqrt(size(A_responding_inh,1)), AColor, '--');
    
    errorbar_patch(cutTimeBins, mean(C_responding_exc),std(C_responding_exc)./sqrt(size(C_responding_exc,1)), CColor);
%     errorbar_patch(cutTimeBins, mean(C_responding_inh),std(C_responding_inh)./sqrt(size(C_responding_inh,1)), CColor, '--');
    set(gcf, 'Renderer', 'painters');
    set(gca, 'FontSize', 18);box off;
    title([naiveOrExpert{1} ' Exc; N = ' num2str(length(A_responding_exc_inds)) ' Inh; N =  ' num2str(length(A_responding_inh_inds))])
    xlim([-2.5 .2])
    
    
end
han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
set(gca, 'FontSize', 18);
han.YLabel.Visible='on';
ylabel(han,'Firing rate (Hz)');
xlabel(han,'Time relative to CS (S)');


%-Output
neuronIndices.high_exc = A_responding_exc_inds;
neuronIndices.high_inh = A_responding_inh_inds;
neuronIndices.low_exc = C_responding_exc_inds;
neuronIndices.low_inh = C_responding_inh_inds;


