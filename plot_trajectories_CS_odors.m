function [] = plot_trajectories_CS_odors(allMiceData,srCriterion, timeVec, refTimeRange,  brainRegion)
% brainRegion = 'PC';srCriterion = .7;
[outputStruct] = detect_delay_modulated_neurons(allMiceData, [-4 -3], [-2 -1], 'allTrials', 2, brainRegion);

high_data = outputStruct.high_CS_plus_Raster;
low_data = outputStruct.low_CS_plus_Raster;


%% Get SR
[successRates] = getSuccessRatesForEachNeuron(allMiceData, brainRegion);
meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';
%% Buld the data
highMatrix = nan(size(high_data, 2), length(timeVec)-1);
lowMatrix = highMatrix;
for timeInd = 1:size(timeVec,2)-1
    evokedFiringRates_high = computeEvokedFiringRates(high_data, [-4 -3], [timeVec(timeInd) timeVec(timeInd+1)]);
    evokedFiringRates_low = computeEvokedFiringRates(low_data, [-4 -3], [timeVec(timeInd) timeVec(timeInd+1)]);

    
    for neuronInd = 1:size(evokedFiringRates_high,2)
        highMatrix(neuronInd, timeInd) = mean(evokedFiringRates_high{neuronInd});
        lowMatrix(neuronInd, timeInd) = mean(evokedFiringRates_low{neuronInd});
    end
end

naiveHighMatrix = highMatrix(naiveInds, :);
expertHighMatrix = highMatrix(expertInds, :);

naiveLowMatrix = lowMatrix(naiveInds, :);
expertLowMatrix = lowMatrix(expertInds, :);

%%
figure;
pcLim = [-50 60];

subplot (2,2,1)
[mahal_naive_H, dims_naive_H] = plotPCATrajectory(naiveHighMatrix, timeVec(1:end-1), refTimeRange);
ylim(pcLim); xlim(pcLim)

subplot (2,2,2)
[mahal_naive_L] = plotPCATrajectory(naiveLowMatrix, timeVec(1:end-1), refTimeRange);

ylim(pcLim); xlim(pcLim)

subplot (2,2,3)
[mahal_expert_H] = plotPCATrajectory(expertHighMatrix, timeVec(1:end-1), refTimeRange);
ylim(pcLim); xlim(pcLim)

subplot (2,2,4)
[mahal_expert_L] = plotPCATrajectory(expertLowMatrix, timeVec(1:end-1), refTimeRange);
ylim(pcLim); xlim(pcLim)



end
%% Functions
function evokedFiringRates = computeEvokedFiringRates(dataCell, bgTimes, fgTimes)
% computeEvokedFiringRates Computes evoked firing rates for each neuron.
%
% Inputs:
%   dataCell - 1xN cell array, where each cell contains a structure with trials.
%              Each trial has a 'times' field with spike times.
%   bgTimes  - 1x2 vector specifying the background time window (default: [-4 -3]).
%   fgTimes  - 1x2 vector specifying the foreground time window (default: [0 1]).
%
% Output:
%   evokedFiringRates - 1xN cell array, where each cell contains a vector of
%                       evoked firing rates for each trial of the corresponding neuron.

if nargin < 2 || isempty(bgTimes)
    bgTimes = [-4 -3];
end
if nargin < 3 || isempty(fgTimes)
    fgTimes = [0 1];
end

% Initialize output cell array
evokedFiringRates = cell(1, numel(dataCell));

% Loop over each neuron (cell in the cell array)
for neuronIdx = 1:numel(dataCell)
    neuronData = dataCell{neuronIdx};
    numTrials = numel(neuronData);
    evokedRates = zeros(1, numTrials);
    
    % Loop over each trial
    for trialIdx = 1:numTrials
        spikeTimes = neuronData(trialIdx).times;
        
        % Compute firing rate for background window
        bgSpikes = sum(spikeTimes >= bgTimes(1) & spikeTimes < bgTimes(2));
        bgFiringRate = bgSpikes / diff(bgTimes);
        
        % Compute firing rate for foreground window
        fgSpikes = sum(spikeTimes >= fgTimes(1) & spikeTimes < fgTimes(2));
        fgFiringRate = fgSpikes / diff(fgTimes);
        
        % Compute evoked firing rate
        evokedRates(trialIdx) = fgFiringRate - bgFiringRate;
    end
    
    % Store evoked firing rates for this neuron
    evokedFiringRates{neuronIdx} = evokedRates;
end
end
function outputMatrix = equalizeAndStackTrials(cellArray1, cellArray2, removeTooFewTrialsFlag)
% equalizeAndStackTrials Equalizes trial counts between two conditions and stacks them.
%
% Inputs:
%   cellArray1 - 1xN cell array, where each cell contains firing rates (vector) for a neuron across trials (Condition 1).
%   cellArray2 - 1xN cell array, where each cell contains firing rates (vector) for a neuron across trials (Condition 2).
%
% Output:
%   outputMatrix - trials x neurons matrix, where each column contains
%                  equalized trials from Condition 1 stacked with trials from Condition 2.

% Ensure the inputs are cell arrays of the same size
if numel(cellArray1) ~= numel(cellArray2)
    error('The two input cell arrays must have the same number of neurons.');
end

% Number of neurons
numNeurons = numel(cellArray1);

% check for global min # trials
for iNeuron = 1:numNeurons
    % Get the trial data for the current neuron
    trials1 = cellArray1{iNeuron};
    trials2 = cellArray2{iNeuron};
    
    % Determine the minimum number of trials
    allMinTrials(iNeuron) = min(length(trials1), length(trials2));
    
    
end
if removeTooFewTrialsFlag
    tooFewTrials = find(allMinTrials < 10);
    cellArray1(tooFewTrials) = [];
    cellArray2(tooFewTrials) = [];
    allMinTrials(tooFewTrials) = [];
end

minTrials = min(allMinTrials);

% Process each neuron
for iNeuron = 1:length(cellArray1)
    
    trials1 = cellArray1{iNeuron};
    trials2 = cellArray2{iNeuron};
    
    % Randomly select minTrials trials from each condition
    selectedTrials1 = trials1(randsample(length(trials1), minTrials));
    selectedTrials2 = trials2(randsample(length(trials2), minTrials));
    
    % Stack the selected trials
    stackedTrials = [selectedTrials1(:); selectedTrials2(:)];
    
    % Insert into the output matrix
    outputMatrix(1:length(stackedTrials), iNeuron) = stackedTrials;
end

% Remove extra preallocated rows
%     outputMatrix = outputMatrix(~all(isnan(outputMatrix), 2), :);
end