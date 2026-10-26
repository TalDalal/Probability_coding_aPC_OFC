function [] = trajectoryPCA(allMiceData, srCriterion, timeVec, refTimeRange, analyzeM, brainRegion)

%timeVec = time bins used for the trajectory analysis.
%refTimeRange = the time we refer as baseline.
%analyzeM = binary flag for plotting the M context or not.
%brainRegion = 'PC' or 'OFC'

%% Extract data
[outputStruct] = detect_delay_modulated_neurons(allMiceData, [-4 -3], [-2 -1], 'allTrials', 2, brainRegion);

% -----For all trials (good for analysis up to the CS odor)
high_data = outputStruct.highRaster;
low_data = outputStruct.lowRaster;
if analyzeM
   M_data = outputStruct.M_raster;
end
% % -----For CS+ trials (good for analysis up to the CS odor)
% high_data = outputStruct.high_CS_plus_Raster;
% low_data = outputStruct.low_CS_plus_Raster;
% if analyzeM
%    M_data = outputStruct.M_raster;
% end

% % -----For CS- trials (good for analysis up to the CS odor)
% high_data = outputStruct.high_CS_minus_Raster;
% low_data = outputStruct.low_CS_minus_Raster;
% if analyzeM
%    M_data = outputStruct.M_raster;
% end

%% Get SR
[successRates] = getSuccessRatesForEachNeuron(allMiceData, brainRegion);
meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';
%% Buld the data
highMatrix = nan(size(high_data, 2), length(timeVec)-1);
lowMatrix = highMatrix;M_matrix = highMatrix;
for timeInd = 1:size(timeVec,2)-1
    evokedFiringRates_high = computeEvokedFiringRates(high_data, [-4 -3], [timeVec(timeInd) timeVec(timeInd+1)]);
    evokedFiringRates_low = computeEvokedFiringRates(low_data, [-4 -3], [timeVec(timeInd) timeVec(timeInd+1)]);
    if analyzeM
      evokedFiringRates_M = computeEvokedFiringRates(M_data, [-4 -3], [timeVec(timeInd) timeVec(timeInd+1)]);  
    end
    
    for neuronInd = 1:size(evokedFiringRates_high,2)
        highMatrix(neuronInd, timeInd) = mean(evokedFiringRates_high{neuronInd});
        lowMatrix(neuronInd, timeInd) = mean(evokedFiringRates_low{neuronInd});
        if analyzeM
            M_matrix(neuronInd, timeInd) = mean(evokedFiringRates_M{neuronInd});
        end
    end
end

naiveHighMatrix = highMatrix(naiveInds, :);
expertHighMatrix = highMatrix(expertInds, :);

naiveLowMatrix = lowMatrix(naiveInds, :);
expertLowMatrix = lowMatrix(expertInds, :);

if analyzeM
    valid_M_Neurons = find(isnan(M_matrix(:,1)) > 0, 1);
    M_matrix(valid_M_Neurons:end, :) = [];
    M_naive = naiveInds(find(naiveInds < valid_M_Neurons));
    M_expert = expertInds(find(expertInds < valid_M_Neurons));
    
    naiveM_Matrix = M_matrix(M_naive, :);
    expertM_Matrix = M_matrix(M_expert, :);
    
    figure;pcLim = [-50 50];
    subplot (2,1,1)
    [mahal_naive_M] = plotPCATrajectory(naiveM_Matrix, timeVec(1:end-1), refTimeRange);
    title('M - naive')
    ylim(pcLim); xlim(pcLim)
    subplot (2,1,2)
    [mahal_expert_M] = plotPCATrajectory(expertM_Matrix, timeVec(1:end-1), refTimeRange);
    title('M - expert')
    ylim(pcLim); xlim(pcLim)

end
%% Plot
pcLim = [-50 60];
% figure;
% subplot (1,2,1)
% plotPCATrajectory(highMatrix, timeVec(1:end-1))
% title('High')
% ylim(pcLim); xlim(pcLim)
% subplot (1,2,2)
% plotPCATrajectory(lowMatrix, timeVec(1:end-1))
% title('Low')
% ylim(pcLim); xlim(pcLim)



figure;
subplot (2,2,1)
[mahal_naive_H, dims_naive_H] = plotPCATrajectory(naiveHighMatrix, timeVec(1:end-1), refTimeRange);
title('High - naive')
ylim(pcLim); xlim(pcLim)
subplot (2,2,2)
[mahal_naive_L] = plotPCATrajectory(naiveLowMatrix, timeVec(1:end-1), refTimeRange);
title('Low - naive')
ylim(pcLim); xlim(pcLim)

subplot (2,2,3)
[mahal_expert_H] = plotPCATrajectory(expertHighMatrix, timeVec(1:end-1), refTimeRange);
title('High - expert')
ylim(pcLim); xlim(pcLim)
subplot (2,2,4)
[mahal_expert_L] = plotPCATrajectory(expertLowMatrix, timeVec(1:end-1), refTimeRange);
title('Low - expert')
ylim(pcLim); xlim(pcLim)

figure;
plot(timeVec(1:end-1), mahal_naive_H - mahal_naive_L)
hold on
plot(timeVec(1:end-1), mahal_expert_H - mahal_expert_L)
legend('naive', 'expert');
set(gca, 'FontSize', 18);box off
ylabel({'Mahalanobis distance', '(H - L)'});xlabel('Time relative to CS (sec)');
xlim([-3 0]);
%% Plot distance relative to baseline
figure;
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green
M_ProbColor = [51,51,102]./255;%blue

plot(timeVec(1:end-1), mahal_expert_H, 'LineWidth', 2, 'Color', highProbColor)
hold on;
plot(timeVec(1:end-1), mahal_expert_L, 'LineWidth', 2, 'Color', lowProbColor)
hold on;
if analyzeM
plot(timeVec(1:end-1), mahal_expert_M, 'LineWidth', 2, 'Color', M_ProbColor)
legend('A', 'B', 'M');
else
    legend('A', 'B');
end
set(gca, 'FontSize', 18);box off
ylabel({'Mahalanobis distance', 'relative to baseline'});xlabel('Time relative to CS (sec)');
xlim([-.5 0]);title('Expert')

%---For naive
figure;

plot(timeVec(1:end-1), mahal_naive_H, 'LineWidth', 2, 'Color', highProbColor)
hold on;
plot(timeVec(1:end-1), mahal_naive_L, 'LineWidth', 2, 'Color', lowProbColor)
hold on;
if analyzeM
plot(timeVec(1:end-1), mahal_naive_M, 'LineWidth', 2, 'Color', M_ProbColor)
legend('A', 'B', 'M');
else
    legend('A', 'B');
end
set(gca, 'FontSize', 18);box off
ylabel({'Mahalanobis distance', 'relative to baseline'});xlabel('Time relative to CS (sec)');
xlim([-.5 0]);title('Naive')

end









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