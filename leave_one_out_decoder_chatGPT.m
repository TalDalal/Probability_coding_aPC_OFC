
function [] = leave_one_out_decoder_chatGPT(data, labels)
% Number of observations
numObservations = length(data);


% Initialize variables
binSize = 10;
numBins = round(numObservations / binSize);
successRate = zeros(numBins, 1);
standardError = zeros(numBins, 1);
numOfK = 10;
numBootstrapIter = 20;

% Leave-bin-out cross-validation
for bin = 1:numBins
    % Define the indices for the current bin
    endIdx = min(bin * binSize, numObservations);
    
    % Initialize success rates for the bin
    successRatesBin = zeros(numBootstrapIter, 1);
    
    for trial = 1:numBootstrapIter
        % Select data points for the current iteration with replacements
        selectedIdx = randsample(numObservations, endIdx, true);
        selectedData = data(selectedIdx); % Updated to 1D vector
        selectedLabels = labels(selectedIdx);
        
        % Train a classifier on the selected data
        %Higher values of NumNeighbors can lead to smoother decision 
        %boundaries but may also increase the risk of misclassification.
        %Lower values can capture local patterns more precisely but may be
        %more sensitive to noise
        classifier = fitcknn(selectedData, selectedLabels, 'NumNeighbors', numOfK);

        % Predict the labels of the current bin
        predictedLabels = predict(classifier, selectedData); % Updated to 1D vector

        % Check if the predictions match the true labels
        correctPredictions = sum(predictedLabels == selectedLabels);
        successRatesBin(trial) = correctPredictions / endIdx;
    end
    
    % Calculate success rate and standard error for the bin
    successRate(bin) = mean(successRatesBin);
    standardError(bin) = std(successRatesBin);% / sqrt(numBootstrapIter);
end

% Compute cumulative number of observations
cumulativeNumObservations = (1:binSize:numObservations)';

% Plot the success rate and standard error
figure;

% Subplot 1: Line plot
subplot(1, 2, 1);
errorbar(cumulativeNumObservations, successRate, standardError, 'b-', 'LineWidth', 2);
xlabel('Number of Observations');
ylabel('Success Rate');
title('Leave-Bin-Out Decoder');
grid on;

% Subplot 2: Bar graph for the last element
subplot(1, 2, 2);
bar(successRate(end));
hold on;
errorbar(1, successRate(end), standardError(end), 'k.', 'LineWidth', 2);
ylabel('Success Rate');
title('Success Rate in Last Bin');
xticks([]);
grid on;

% Adjust the subplot positions
set(gcf, 'position', [100, 100, 1000, 400]);
 
