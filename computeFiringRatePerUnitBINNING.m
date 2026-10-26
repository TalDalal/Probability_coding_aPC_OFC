function [params] = computeFiringRatePerUnitBINNING(params)
%%
events = params.NeuralData.Events;
params.baselineWin = 2000;
params.firingRateBin = 100;%ms

% the analysis window
analysisWin = [-params.baselineWin-params.ISIbetweenOdors-params.odor_duration ... 
    :params.firingRateBin: ...
    params.odor_duration*4]./1000;
params.firingRateAnalysisBins = analysisWin;

if isfield(params, 'SingleOdorsExp') & params.SingleOdorsExp == 1
    trialsToAnalyze = 1:size(events,2);
else % Case of a regular run with odors per trial
    trialsToAnalyze = params.targetOdorIndices;
end
%% Compute the firing rate matrix (trials X firing per bin) for all units

for clusInd = 1:length(params.NeuralData.Spikes)
    
    firingRateMatPerUnit = nan(length(params.targetOdorIndices), size(analysisWin,2)-1);
    %The spikes of the current unit
    currSpikes = params.NeuralData.Spikes{clusInd}.t;
    
    % RUn over all trials - we set the second odor as the zero point
    c = 0;
    for trialInd = trialsToAnalyze
        c = c + 1;
        %current trial
        currEvent = events(1,trialInd);
        
        for currBinInd = 1:length(analysisWin)-1
            
            currPart = length(currSpikes(find(currSpikes >=  currEvent + analysisWin(currBinInd) ...
                & currSpikes < currEvent + analysisWin(currBinInd+1))))./(params.firingRateBin./1000);
            firingRateMatPerUnit(c, currBinInd) = currPart;
            currPart = [];
        end
        
    end
    params.firingRates(clusInd).firingRateByBIn = firingRateMatPerUnit;
end