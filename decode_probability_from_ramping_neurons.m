function [] = decode_probability_from_ramping_neurons(rampingNeurons, bgWin, fgWin, nReps)

%% Ramping neurons
rampingSessionsInds = find(rampingNeurons(1).allDelayActiveNeurons > 0);
% Find the rasters of the ramping neurons
high_rasters_ramping = rampingNeurons(1).high_rasters(rampingSessionsInds);
low_rasters_ramping = rampingNeurons(1).low_rasters(rampingSessionsInds);

evokedFiringRates_high_ramping = computeEvokedFiringRates(high_rasters_ramping, bgWin, fgWin);
evokedFiringRates_low_ramping = computeEvokedFiringRates(low_rasters_ramping, bgWin, fgWin);

%% Non ramping
nonRampingInds = setdiff(1:length(rampingNeurons(1).allDelayActiveNeurons), rampingSessionsInds);


%% Decoder
for ind = 1:nReps
    %--------- Ramping -----
%Create the activity matrix
decoderMatrix_ramping = equalizeAndStackTrials(evokedFiringRates_high_ramping, evokedFiringRates_low_ramping, 0);
% create labels
numTrials = size(decoderMatrix_ramping,1);
labels = [zeros(numTrials/2, 1); ones(numTrials/2, 1)]; % 0 for first half, 1 for second half
shuffled_labels = labels(randsample(length(labels), length(labels)));
%Decode
[accuracy_ramping(ind)] = leaveOneOutDecoder(decoderMatrix_ramping, labels, '', 0);
[accuracy_ramping_shuffled(ind)] = leaveOneOutDecoder(decoderMatrix_ramping, shuffled_labels, '', 0);


%------non-ramping---------
% rand the same number of non-ramping neurons
currRandNeurons = randsample(nonRampingInds, length(rampingSessionsInds));
high_rasters_non_ramping = rampingNeurons(1).high_rasters(currRandNeurons);
low_rasters_non_ramping = rampingNeurons(1).low_rasters(currRandNeurons);

evokedFiringRates_high_non_ramping = computeEvokedFiringRates(high_rasters_non_ramping, bgWin, fgWin);
evokedFiringRates_low_non_ramping = computeEvokedFiringRates(low_rasters_non_ramping, bgWin, fgWin);

%Create the activity matrix
decoderMatrix_non_ramping = equalizeAndStackTrials(evokedFiringRates_high_non_ramping, evokedFiringRates_low_non_ramping, 0);
% create labels
numTrials = size(decoderMatrix_non_ramping,1);
labels = [zeros(numTrials/2, 1); ones(numTrials/2, 1)]; % 0 for first half, 1 for second half
shuffled_labels = labels(randsample(length(labels), length(labels)));
%Decode
[accuracy_non_ramping(ind)] = leaveOneOutDecoder(decoderMatrix_non_ramping, labels, '', 0);
[accuracy_non_ramping_shuffled(ind)] = leaveOneOutDecoder(decoderMatrix_non_ramping, shuffled_labels, '', 0);


clc;disp(['Iteration ' num2str(ind) '/' num2str(nReps)])
end

%stat
p_ramping_vs_shuffled = two_sample_bootstrap(accuracy_ramping, accuracy_ramping_shuffled, 10000, 0);
p_non_ramping_vs_shuffled = two_sample_bootstrap(accuracy_non_ramping, accuracy_non_ramping_shuffled, 10000, 0);
%% Plot
figure;
boxplot([accuracy_ramping' accuracy_ramping_shuffled' accuracy_non_ramping', accuracy_non_ramping_shuffled']);
set(gca, 'FontSize', 18);box off;
ylabel('Decoder accuracy'); set(gca, 'XTickLabel', {'Ramping', 'Shuffled', 'Non-ramping', 'Shuffled'})
xtickangle(45);ylim([0 1]);
hold all;
plot([0 5], [.5 .5], 'k--')












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

function [accuracy, normalizedConfMat] = leaveOneOutDecoder(dataMatrix, labels, titleString, plotFlag)
% leaveOneOutDecoder Performs a leave-one-out binary decoding and plots a confusion matrix.
%
% Inputs:
%   dataMatrix - trials x neurons matrix, where each row represents a trial
%                and each column represents a neuron.
%   labels     - Binary labels (0/1) for the trials, size is trials x 1.
%
% Outputs:
%   accuracy   - Overall decoding accuracy (correct predictions / total trials).
%   predictions - Predicted labels for each trial.

% Ensure the labels vector has the same number of rows as dataMatrix
if size(dataMatrix, 1) ~= length(labels)
    error('The number of rows in dataMatrix must match the number of labels.');
end

% Number of trials
numTrials = size(dataMatrix, 1);

% Initialize predicted labels
predictions = zeros(numTrials, 1);

% Leave-One-Out Cross-Validation
for i = 1:numTrials
    % Split data into training and testing sets
    testSample = dataMatrix(i, :); % Leave out one sample for testing
    trainData = dataMatrix([1:i-1, i+1:end], :);
    trainLabels = labels([1:i-1, i+1:end]);
    
    % Train a linear SVM model
    model = fitcsvm(trainData, trainLabels, 'KernelFunction', 'linear');
    
    % Predict the label for the test sample
    predictions(i) = predict(model, testSample);
end

% Compute accuracy
accuracy = mean(predictions == labels);

% Compute confusion matrix
confusionMat = confusionmat(labels, predictions);

% Normalize confusion matrix for better visualization
normalizedConfMat = confusionMat ./ sum(confusionMat, 2);

% Plot the confusion matrix
if plotFlag
    %     figure;
    imagesc(normalizedConfMat); % Display as an image
    colormap('hot'); % Use a colormap for visualization
    colorbar; % Add color bar to indicate scale
    axis square;
    
    % Annotate the plot
    xticks([1 2]);
    yticks([1 2]);
    xticklabels({'Predicted 0', 'Predicted 1'});
    yticklabels({'Actual 0', 'Actual 1'});
    xlabel('Predicted Label');
    ylabel('Actual Label');
    title([titleString 'Accuracy: ', num2str(accuracy * 100, '%.2f'), '%)']);
    
    % Add values to the confusion matrix
    for i = 1:2
        for j = 1:2
            text(j, i, num2str(confusionMat(i, j)), ...
                'HorizontalAlignment', 'center', 'Color', 'white', 'FontWeight', 'bold');
        end
    end
end
end
