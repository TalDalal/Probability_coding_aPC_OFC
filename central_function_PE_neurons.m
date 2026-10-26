function [] = central_function_PE_neurons(allMiceData, bgPeriod, fgPeriod)
% allMiceData = allMiceData_OFC_SILENCING;

% learning criterion
srCriterion = 0.7;
% to define response;
pValueTH = 0.05;
%% central_function_PE_neurons
[output_CSplus] = detect_PE_neurons(allMiceData, bgPeriod,fgPeriod, 'CS+', pValueTH);

[output_CSminus] = detect_PE_neurons(allMiceData, bgPeriod,fgPeriod, 'CS-', pValueTH);

%% Success rates for each neuron
[allNeurons_SR] = getSuccessRatesForEachNeuron(allMiceData, 'PC');
allNeurons_SR = mean(allNeurons_SR(:,2:3), 2);

%% pie chart of sensory and modulated neurons
expertIndices = find(allNeurons_SR > 0);
numCSplusResponding = output_CSplus.numOfRespondingNeurons(expertIndices);
numCSminusResponding = output_CSminus.numOfRespondingNeurons(expertIndices);
bothResponding = numCSplusResponding + numCSminusResponding;

bothModulated = output_CSplus.modulationMat(expertIndices) + output_CSminus.modulationMat(expertIndices);


%pie chart of modulated and sensory neurons
plotNeuronPieChart(length(find(bothModulated > 0)), length(find(bothResponding > 0)))

% numCSplusResponding = output_CSplus.numOfRespondingNeurons;
% numCSminusResponding = output_CSminus.numOfRespondingNeurons;
% bothResponding = numCSplusResponding + numCSminusResponding;
% 
% bothModulated = output_CSplus.modulationMat + output_CSminus.modulationMat;
% 
% 
% %pie chart of modulated and sensory neurons
% plotNeuronPieChart(length(find(bothModulated > 0)), length(find(bothResponding > 0)))


[percentModulated] = movingWindowModulation(allMiceData);
%% percentage of modulated neurons for CS+\-
% bar grapgh of precentage modulated
plotModulatedNeuronPercentages([sum(output_CSplus.modulationMat) sum(output_CSminus.modulationMat) length(find(bothModulated==2))], ...
    [sum(numCSplusResponding) sum(numCSminusResponding) length(find(bothResponding==2))])

%% percentage of PE
modulatedCSplus_minus_response_H_vs_L(allMiceData, 'no', [0 1], srCriterion);
% modulated_H_CSplus = output_CSplus.evokedFR_high(find(output_CSplus.modulationMat > 0));
% modulated_L_CSplus = output_CSplus.evokedFR_low(find(output_CSplus.modulationMat > 0));
%
% H_larger_rate_CSplus = length(find((modulated_H_CSplus - modulated_L_CSplus) > 0))./length(find(output_CSplus.modulationMat > 0));
% H_smaller_rate_CSplus = 1-H_larger_rate_CSplus;
%
%
% [p, h] = two_sample_prop_test(H_larger_rate_CSplus, length(find(output_CSplus.modulationMat > 0)), H_smaller_rate_CSplus, length(find(output_CSplus.modulationMat > 0)));
%
% [p_H_L_CSplus] = twoSampleProportionTest(H_larger_rate_CSplus, H_smaller_rate_CSplus, length(find(output_CSplus.modulationMat > 0)), length(find(output_CSplus.modulationMat > 0)));

%% decode probability from PE neurons
decoderPlotFlag = 0;
if decoderPlotFlag
    [accuracy_CSplus, accuracy_CSminus, allConfMat_CSplus, allConfMat_CSminus] = run_PE_neurons_decoder(output_CSplus, output_CSminus,'Modulated', 500);
    
%     figure;
%     subplot (2,2,1)
%     plotConfusionMatrix(allConfMat_CSplus, ['CS+, ' num2str(mean(accuracy_CSplus))])
%     
%     subplot (2,2,2)
%     plotConfusionMatrix(allConfMat_CSminus, ['CS-, ' num2str(mean(accuracy_CSminus))])
    
    figure;
    subplot(1,2,1)
    barwitherr([std(accuracy_CSplus) std(accuracy_CSminus)], mean([accuracy_CSplus' accuracy_CSminus']))
    ylim([0 1]);title('Context-modulated');set(gca, 'XTickLabel', {'CS+', 'CS-'});box off
    
    %--------SENSORY neurons----
    [accuracy_CSplus_sensory, accuracy_CSminus_sensory, allConfMat_CSplus, allConfMat_CSminus] = run_PE_neurons_decoder(output_CSplus, output_CSminus,'Sensory', 500);
        subplot(1,2,2)
    barwitherr([std(accuracy_CSplus_sensory) std(accuracy_CSminus_sensory)], mean([accuracy_CSplus_sensory' accuracy_CSminus_sensory']))
    ylim([0 1]);title('Context-modulated');set(gca, 'XTickLabel', {'CS+', 'CS-'});box off

%     subplot (2,2,3)
%     plotConfusionMatrix(allConfMat_CSplus, ['CS+, ' num2str(mean(accuracy_CSplus))])
%     
%     subplot (2,2,4)
%     plotConfusionMatrix(allConfMat_CSminus, ['CS-, ' num2str(mean(accuracy_CSminus))])
end

%% PCA
pcaPlotFlag = 0;
if pcaPlotFlag == 1;
    [decoderMat_CSplus, decoderMat_CSminus, labels_csPlus, labels_csMinus] =  ...
        prepareDataForProbClassifier(output_CSplus, output_CSminus, 'Sensory');
    highProbColor = [0,169,137]./255;%green
    lowProbColor = [171,62,143]./255;%purple
    figure;
    subplot(1,2,1)
    plotPcaSpheres(decoderMat_CSplus, 2, [highProbColor; lowProbColor])
    
    subplot(1,2,2)
    plotPcaSpheres(decoderMat_CSminus, 2, [highProbColor; lowProbColor])
end

%% CV
cvPlotFlag = 0;
if cvPlotFlag == 1;
    [allCV_H, allCV_L, allP] = moving_CV(output_CSplus, output_CSminus, 'Modulated');
end


%% Odor discrimination by prior
odorDiscriminationFlag = 1;
if odorDiscriminationFlag 
    figure;
    % odorDiscriminationDecoderByPrior(output_CSplus, output_CSminus,'bothModulated');
    
    % %----------PE---------
    [high_pred_accu, low_pred_accu, allConfMat_high_pred, allConfMat_low_pred] = ...
        run_odor_identity_decoder(output_CSplus, output_CSminus,'bothModulated', 100);
    %
%     figure;
%     subplot (2,2,1)
%     plotConfusionMatrix(allConfMat_high_pred, 'high prob')
%     title([' High prob ' num2str(mean(high_pred_accu))])
%     
%     
%     subplot (2,2,2)
%     plotConfusionMatrix(allConfMat_low_pred, 'low prob')
%     title([' Low prob ' num2str(mean(low_pred_accu))])
    %stat
    pPE_idenityDecoding = two_sample_bootstrap(high_pred_accu, low_pred_accu, 10000, 0);
    
    figure;
    subplot(1,2,1)
    barwitherr([std(high_pred_accu) std(low_pred_accu)], mean([high_pred_accu' low_pred_accu']))
    ylim([0.5 1.05]);set(gca, 'XTickLabel', {'predicted', 'unpredicted'});box off;title('Context-modulated')
    
    %--------SENSORY neurons----
    [high_pred_accu, low_pred_accu, allConfMat_high_pred, allConfMat_low_pred] = ...
        run_odor_identity_decoder(output_CSplus, output_CSminus,'bothSensory', 100);
    
%     subplot (2,2,3)
%     plotConfusionMatrix(allConfMat_high_pred, 'high prob')
%     title([' High prob ' num2str(mean(high_pred_accu))])
%     
%     subplot (2,2,4)
%     plotConfusionMatrix(allConfMat_low_pred, 'low prob')
%     title([' Low prob ' num2str(mean(low_pred_accu))])
    %stat
    pSensory_idenityDecoding = two_sample_bootstrap(high_pred_accu, low_pred_accu, 10000, 0);

    subplot(1,2,2)
    barwitherr([std(high_pred_accu) std(low_pred_accu)], mean([high_pred_accu' low_pred_accu']))
    ylim([0.5 1.05]);set(gca, 'XTickLabel', {'predicted', 'unpredicted'});box off;title('Sensory')
end

%% PE neurons as a function of success rate
figure;
[allNeurons_SR] = getSuccessRatesForEachNeuron(allMiceData);
allNeurons_SR = mean(allNeurons_SR(:,2:3), 2);
% succes rate of PE neurons
pe_successRate = allNeurons_SR(find(output_CSplus.modulationMat > 0))';
csPlus_successRate = allNeurons_SR(find(output_CSplus.numOfRespondingNeurons > 0))';


plot_neuron_success_rate_ratio(csPlus_successRate, pe_successRate)


% fr_high_PE_CSplus = output_CSplus.evokedFR_high(find(output_CSplus.modulationMat > 0));
% fr_low_PE_CSplus = output_CSplus.evokedFR_high(find(output_CSplus.modulationMat > 0));

%% Venn between ramping and PE neurons
ramp_PE_Flag = 0;
if ramp_PE_Flag == 1
    [rampingNeurons] = psth_delay_modulated_neurons(allMiceData, [-.33 0], [-4 -3], [-2 0], 'allTrials', 2);
    %%
    rampingInds = find(rampingNeurons(1).allDelayActiveNeurons > 0);
    PEinds = find(bothModulated > 0);
    
    plot_neuron_venn(rampingInds, PEinds)
end

%% Overlap responses - H and CS+\L and CS+

overlappingResponsesToCSodors(allMiceData, 0.01, [-4 -3; -2 -1; 0 1])






end

%% Functions
function plotModulatedNeuronPercentages(modulatedCounts, totalCounts)
% Ensure inputs are vectors of the same length
if length(modulatedCounts) ~= length(totalCounts)
    error('modulatedCounts and totalCounts must have the same length.');
end

% Conditions
conditions = {'CS+', 'CS-', 'CS+ & CS-'};
if length(modulatedCounts) ~= length(conditions)
    error('This function expects data for exactly 3 conditions.');
end

% Calculate percentages and SEM
percentages = (modulatedCounts ./ totalCounts) * 100;
sems = sqrt((percentages / 100) .* (1 - percentages / 100) ./ totalCounts) * 100;

% Perform one-sample proportion test for 5% (chance)
chanceProportion = 0.05;
pValuesOneSample = zeros(size(modulatedCounts));
for i = 1:length(modulatedCounts)
    % Binomial test using exact probability
    [~, pValuesOneSample(i)] = prop_test(modulatedCounts(i), totalCounts(i), chanceProportion);
end

% Perform two-sample proportion test (CS+ vs CS-)
[pTwoSample, hTwoSample] = two_sample_prop_test(modulatedCounts(1), totalCounts(1), modulatedCounts(2), totalCounts(2));

% Create bar plot
figure;
barHandle = bar(percentages, 'FaceColor', 'flat');
hold on;

% Add error bars
errorbar(1:length(percentages), percentages, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

% Add chance line
%     yline(chanceProportion * 100, 'k--', 'Chance', 'FontSize', 12, ...
%           'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');

% Customize plot
set(gca, 'XTickLabel', conditions, 'FontSize', 14);
ylabel('Modulated Neurons (%)', 'FontSize', 16);
ylim([0, max(percentages + sems) + 10]);

% Set bar colors
barHandle.CData(1, :) = [0.7 0.2 0.2]; % Red for CS+
barHandle.CData(2, :) = [0.2 0.2 0.7]; % Blue for CS-
barHandle.CData(3, :) = [0.2 0.7 0.2]; % Green for CS+ & CS-

% Remove grid and title
grid off;
box off;

% Display p-values in console
disp('P-values for one-sample proportion tests (5% chance):');
for i = 1:length(pValuesOneSample)
    fprintf('%s: p = %.3f\n', conditions{i}, pValuesOneSample(i));
end

fprintf('\nP-value for two-sample proportion test (CS+ vs CS-):\n');
fprintf('p = %.3f (h = %d)\n', pTwoSample, hTwoSample);

hold off;
end

function [h, p] = prop_test(successes, trials, p0)
% Perform one-sample proportion test using exact binomial
% successes: number of successes
% trials: number of trials
% p0: hypothesized proportion
p = 2 * min(binocdf(successes, trials, p0), 1 - binocdf(successes - 1, trials, p0));
h = p < 0.05; % Null hypothesis rejected if p < 0.05
end

function [p, h] = two_sample_prop_test(successes1, trials1, successes2, trials2)
% Perform two-sample proportion test (z-test approximation)
% successes1, trials1: successes and trials for first condition
% successes2, trials2: successes and trials for second condition

% Proportions
p1 = successes1 / trials1;
p2 = successes2 / trials2;

% Pooled proportion
p_pooled = (successes1 + successes2) / (trials1 + trials2);

% Standard error
se = sqrt(p_pooled * (1 - p_pooled) * (1/trials1 + 1/trials2));

% z-statistic
z = (p1 - p2) / se;

% p-value (two-tailed test)
p = 2 * (1 - normcdf(abs(z)));

% Hypothesis result
h = p < 0.05; % Null hypothesis rejected if p < 0.05
end


function plotNeuronPieChart(modulatedCount, totalCount)
% Validate inputs
if modulatedCount > totalCount
    error('The number of modulated neurons cannot exceed the total number of recorded neurons.');
end

% Calculate counts and percentages for the two categories
sensoryCount = totalCount - modulatedCount;
data = [modulatedCount, sensoryCount];
percentages = data / totalCount * 100;

% Create the pie chart
figure;
p = pie(data);

% Customize text labels for pie chart sections
for i = 1:2:length(p)
    % Every second handle is a text object
    textHandle = p(i+1);
    if i == 1
        % First segment (modulated neurons)
        textHandle.String = sprintf('Modulated\n%.1f%%', percentages(1));
    else
        % Second segment (sensory neurons)
        textHandle.String = sprintf('Sensory\n%.1f%%', percentages(2));
    end
end

% Customize the appearance
colormap([0.7 0.2 0.2; 0.2 0.7 0.2]); % Red for modulated, green for sensory
title('Neuron Distribution', 'FontSize', 16);
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

function [decoderMat_CSplus, decoderMat_CSminus, labels_csPlus, labels_csMinus] = prepareDataForProbClassifier(output_CSplus, output_CSminus, neuronsFlag)

fg = [0 1];
bg = [-4 -3];

switch neuronsFlag
    case 'Sensory'
        neuronsToAnalyze_CSplus = find(output_CSplus.modulationMat==0);
        neuronsToAnalyze_CSminus = find(output_CSminus.modulationMat==0);
    case 'Modulated'
        neuronsToAnalyze_CSplus = find(output_CSplus.modulationMat>0);
        neuronsToAnalyze_CSminus = find(output_CSminus.modulationMat>0);
    case 'All'
        neuronsToAnalyze_CSplus = 1:length(output_CSplus.modulationMat);
        neuronsToAnalyze_CSminus = 1:length(output_CSminus.modulationMat);
        
    case 'odorResponding'
        neuronsToAnalyze_CSplus = find((output_CSplus.numOfRespondingNeurons + output_CSminus.numOfRespondingNeurons) > 0);
        neuronsToAnalyze_CSminus = neuronsToAnalyze_CSplus;
        
    case 'bothModulated'
        neuronsToAnalyze_CSplus = find((output_CSplus.modulationMat + output_CSminus.modulationMat) > 0);
        neuronsToAnalyze_CSminus = neuronsToAnalyze_CSplus;
        
    case 'bothSensory'
        neuronsToAnalyze_CSplus = find((output_CSplus.modulationMat + output_CSminus.modulationMat) == 0);
        neuronsToAnalyze_CSminus = neuronsToAnalyze_CSplus;
end
%CS+
PE_rasters_H_CSplues = output_CSplus.high_CS_plus_Raster(neuronsToAnalyze_CSplus);
PE_firingRate_H_CSplus = computeEvokedFiringRates(PE_rasters_H_CSplues, bg, fg);

PE_rasters_L_CSplues = output_CSplus.low_CS_plus_Raster(neuronsToAnalyze_CSplus);
PE_firingRate_L_CSplus = computeEvokedFiringRates(PE_rasters_L_CSplues, bg, fg);


decoderMat_CSplus = equalizeAndStackTrials(PE_firingRate_H_CSplus, PE_firingRate_L_CSplus, 0);
numTrials_csPlus = size(decoderMat_CSplus,1);
labels_csPlus = [zeros(numTrials_csPlus/2, 1); ones(numTrials_csPlus/2, 1)]; % 0 for first half, 1 for second half

%CS-
PE_rasters_H_CSminus = output_CSminus.high_CS_minus_Raster(neuronsToAnalyze_CSminus);
PE_firingRate_H_CSminus = computeEvokedFiringRates(PE_rasters_H_CSminus, bg, fg);

PE_rasters_L_CSminus = output_CSminus.low_CS_minus_Raster(neuronsToAnalyze_CSminus);
PE_firingRate_L_CSminus = computeEvokedFiringRates(PE_rasters_L_CSminus, bg, fg);


decoderMat_CSminus = equalizeAndStackTrials(PE_firingRate_H_CSminus, PE_firingRate_L_CSminus, 0);
numTrials_csminus = size(decoderMat_CSminus,1);
labels_csMinus = [zeros(numTrials_csminus/2, 1); ones(numTrials_csminus/2, 1)]; % 0 for first half, 1 for second half
end

function [percentModulated, sems] = movingWindowModulation(allMiceData)
winSize = 0.25;
timeVec = 0:.1:1;
for timeInd = 1:length(timeVec)
    [output_CSplus] = detect_PE_neurons(allMiceData, [-4 -3],[timeVec(timeInd) timeVec(timeInd)+winSize], 'CS+', 0.05);
    [output_CSminus] = detect_PE_neurons(allMiceData, [-4 -3],[timeVec(timeInd) timeVec(timeInd)+winSize], 'CS-', 0.05);
    
    %% pie chart of sensory and modulated neurons
    
    %     numCSplusResponding = output_CSplus.numOfRespondingNeurons;
    %     numCSminusResponding = output_CSminus.numOfRespondingNeurons;
    bothResponding = length(find(output_CSplus.modulationMat > 0)) + length(find(output_CSminus.numOfRespondingNeurons > 0));
    
    bothModulated = length(find(output_CSplus.modulationMat > 0)) + length(find(output_CSminus.modulationMat > 0));
    
    
    %pie chart of modulated and sensory neurons
    percentModulated(timeInd) = (bothModulated./bothResponding).*100;
    sems(timeInd) = sqrt((percentModulated(timeInd) / 100) .* (1 - percentModulated(timeInd) / 100) ./ bothResponding) * 100;
    %     sems(timeInd) = sqrt(((percentModulated(timeInd)./100) .* (1 - percentModulated(timeInd))./100) ./ bothResponding./100).*100;
    
    
    
    
end
figure;
errorbar_patch(timeVec, percentModulated, sems);
xlabel('Time relative to CS (sec)'); ylabel('Modulated neurons (%)');
set(gca, 'FontSize', 18);box off;
hold on;
plot([timeVec(1) timeVec(end)], [5 5], 'k--')
end


function [accuracy_CSplus, accuracy_CSminus, allConfMat_CSplus, allConfMat_CSminus] = run_PE_neurons_decoder(output_CSplus, output_CSminus,neuronsFlag, nBoot)

allConfMat_CSplus = zeros(2);allConfMat_CSminus = allConfMat_CSplus;
for ind = 1:nBoot
    [decoderMat_CSplus, decoderMat_CSminus, labels_csPlus, labels_csMinus] =  ...
        prepareDataForProbClassifier(output_CSplus, output_CSminus, neuronsFlag);
    
    [accuracy_CSplus(ind), confMat_CSplus] = leaveOneOutDecoder(decoderMat_CSplus, labels_csPlus, 'CS+', 0);
    allConfMat_CSplus = allConfMat_CSplus + confMat_CSplus;
    
    [accuracy_CSminus(ind), confMat_CSminus] = leaveOneOutDecoder(decoderMat_CSminus, labels_csMinus, 'CS-', 0);
    allConfMat_CSminus = allConfMat_CSminus + confMat_CSminus;
end

allConfMat_CSplus = allConfMat_CSplus./nBoot;
allConfMat_CSminus = allConfMat_CSminus./nBoot;
end


function [] = plotConfusionMatrix(confMat, CSodorType)
imagesc(confMat); % Display as an image
colormap bone; % Use a colormap for visualization
colorbar; % Add color bar to indicate scale
axis square;

% Annotate the plot
xticks([1 2]);
yticks([1 2]);
xticklabels({'H', 'L'});
yticklabels({'H', 'L'});
xlabel('Predicted Label');
ylabel('Actual Label');
title(CSodorType);
caxis([0 1])
end

function [allCV_H, allCV_L, allP] = moving_CV(output_CSplus, output_CSminus, neuronsFlag)
winSize = 0.25;
timeVec = 0:.1:1;
bg = [-4 -3];fg = [0 1]

switch neuronsFlag
    case 'Sensory'
        neuronsToAnalyze_CSplus = find(output_CSplus.modulationMat==0);
        neuronsToAnalyze_CSminus = find(output_CSminus.modulationMat==0);
    case 'Modulated'
        neuronsToAnalyze_CSplus = find(output_CSplus.modulationMat>0);
        neuronsToAnalyze_CSminus = find(output_CSminus.modulationMat>0);
end



%CS+
PE_rasters_H_CSplues = output_CSplus.high_CS_plus_Raster(neuronsToAnalyze_CSplus);
PE_firingRate_H_CSplus = computeEvokedFiringRates(PE_rasters_H_CSplues, bg, fg);

PE_rasters_L_CSplues = output_CSplus.low_CS_plus_Raster(neuronsToAnalyze_CSplus);
PE_firingRate_L_CSplus = computeEvokedFiringRates(PE_rasters_L_CSplues, bg, fg);

[output] = plotCVComparison(PE_firingRate_H_CSplus, PE_firingRate_L_CSplus, 0);

allCV_H = [output.meanH ; output.sem_H];
allCV_L = [output.meanL ; output.sem_L];
allP = output.p;



[output] = plotCVComparison(PE_firingRate_H_CSplus, PE_firingRate_L_CSplus, 0);

allCV_H = [output.meanH ; output.sem_H];
allCV_L = [output.meanL ; output.sem_L];
allP = output.p;



end

function [output] = plotCVComparison(H, L, plotFlag)
% Validate inputs
if length(H) ~= length(L)
    error('H and L must have the same length (one CV value per neuron).');
end

% Compute CV for each neuron in both conditions
CV_H = cellfun(@(x) abs(std(abs(x)) / mean(abs(x))), H, 'UniformOutput', true);
CV_L = cellfun(@(x) abs(std(abs(x)) / mean(abs(x))), L, 'UniformOutput', true);

% Remove neurons with zero or NaN means
CV_H = CV_H(~isnan(CV_H) & ~isinf(CV_H));
CV_L = CV_L(~isnan(CV_L) & ~isinf(CV_L));

% Compute means and SEMs
mean_H = mean(CV_H);
sem_H = std(CV_H) / sqrt(length(CV_H));
mean_L = mean(CV_L);
sem_L = std(CV_L) / sqrt(length(CV_L));

% Perform paired t-test
[h, p] = ttest(CV_H, CV_L, 'Tail', 'both');

if plotFlag
    % Plot bar graph
    figure;
    barData = [mean_H, mean_L];
    semData = [sem_H, sem_L];
    barHandle = bar(barData, 'FaceColor', 'flat');
    hold on;
    
    % Add error bars
    errorbar(1:2, barData, semData, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
    
    % Customize bar colors
    barHandle.CData(1, :) = [0.7, 0.2, 0.2]; % Red for H
    barHandle.CData(2, :) = [0.2, 0.2, 0.7]; % Blue for L
    
    % Add labels and title
    set(gca, 'XTickLabel', {'H', 'L'}, 'FontSize', 14);
    ylabel('Coefficient of Variation (CV)', 'FontSize', 16);
    ylim([0, max(barData + semData) + 0.1]);
    
    % Add asterisk and p-value if significant
    if h
        % Plot asterisk above bars
        yMax = max(barData + semData);
        line([1, 2], [yMax + 0.05, yMax + 0.05], 'Color', 'k', 'LineWidth', 1.5); % Line above bars
        text(1.5, yMax + 0.07, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');
        
        % Display p-value
        text(1.5, yMax + 0.03, sprintf('p = %.3f', p), 'FontSize', 12, 'HorizontalAlignment', 'center');
    end
    
    % Remove grid and finalize plot
    grid off;
    box off;
    hold off;
end

output.meanH = mean_H;
output.meanL = mean_L;
output.sem_H = sem_H;
output.sem_L = sem_L;
output.p = p;
end


function [] = odorDiscriminationDecoderByPrior(output_CSplus, output_CSminus,neuronsFlag)

allConfMat_highPred = zeros(2);allConfMat_lowPred = allConfMat_highPred;
% for ind = 1:nBoot
[decoderMat_CSplus, decoderMat_CSminus, labels_csPlus, labels_csMinus] =  ...
    prepareDataForProbClassifier(output_CSplus, output_CSminus, neuronsFlag);

% divide the data to creaste matrix of neurons with high prediction \
% low about the odor
highlyPredicted = [decoderMat_CSplus(1:size(decoderMat_CSplus,1)/2, :) ; decoderMat_CSminus((size(decoderMat_CSminus,1)/2)+1:end, :)];
lowPredicted = [decoderMat_CSplus((size(decoderMat_CSplus,1)/2)+1:end, :) ; decoderMat_CSminus(1:size(decoderMat_CSminus,1)/2, :)];


%     [highlyPredicted_accuracy(ind), confMat_highlyPred] = leaveOneOutDecoder(highlyPredicted, labels_csPlus, 'CS+', 0);
%     allConfMat_highPred = allConfMat_highPred + confMat_highlyPred;
%
%     [lowPredicted_accuracy(ind), confMat_lowPred] = leaveOneOutDecoder(lowPredicted, labels_csMinus, 'CS-', 0);
%     allConfMat_lowPred = allConfMat_lowPred + confMat_lowPred;

binaryDecodingWithShuffle(highlyPredicted, labels_csPlus, 10, 100);
binaryDecodingWithShuffle(lowPredicted, labels_csMinus, 10, 100);

% end

% allConfMat_highPred = allConfMat_highPred./nBoot;
% allConfMat_lowPred = allConfMat_lowPred./nBoot;
end

function binaryDecodingWithShuffle(neuronData, labels, interval, reps)
% Perform binary decoding with shuffled labels for comparison
%
% Inputs:
%   neuronData: Trials � Neurons matrix
%   labels: Binary labels for trials (optional; generated if not provided)
%   interval: Step size for percentage of neurons (e.g., 20 for 20%)
%   reps: Number of repetitions for random subsets

if nargin < 2 || isempty(labels)
    % Generate labels if not provided
    labels = [zeros(size(neuronData, 1) / 2, 1); ones(size(neuronData, 1) / 2, 1)];
end

if nargin < 3 || isempty(interval)
    interval = 20; % Default interval (20%)
end

if nargin < 4 || isempty(reps)
    reps = 50; % Default repetitions
end

% Validate inputs
[numTrials, numNeurons] = size(neuronData);
if length(labels) ~= numTrials
    error('The number of labels must match the number of trials.');
end

if mod(numTrials, 2) ~= 0 || ~all(ismember(labels, [0, 1]))
    error('Labels must contain an equal number of 0s and 1s.');
end

% Percentage intervals for neurons
percentages = interval:interval:100; % E.g., 20%, 40%, ..., 100%
numNeuronsPerPercentage = round(percentages / 100 * numNeurons);

% Initialize results
realAccuracy = zeros(length(numNeuronsPerPercentage), reps);
shuffledAccuracy = zeros(length(numNeuronsPerPercentage), reps);

% Loop over percentage of neurons
for i = 1:length(numNeuronsPerPercentage)
    k = numNeuronsPerPercentage(i); % Number of neurons to use
    
    for r = 1:reps
        % Randomly select k neurons
        selectedNeurons = randperm(numNeurons, k);
        
        % Perform classification with real labels
        realAccuracy(i, r) = classifyData(neuronData(:, selectedNeurons), labels);
        
        % Perform classification with shuffled labels
        shuffledLabels = labels(randperm(numTrials));
        shuffledAccuracy(i, r) = classifyData(neuronData(:, selectedNeurons), shuffledLabels);
    end
end

% Compute mean and SEM
meanRealAccuracy = mean(realAccuracy, 2);
semRealAccuracy = std(realAccuracy, [], 2) ;%/ sqrt(reps);

meanShuffledAccuracy = mean(shuffledAccuracy, 2);
semShuffledAccuracy = std(shuffledAccuracy, [], 2);% / sqrt(reps);

% Plot results
%     figure;
hold all;

% Plot real accuracy
errorbar(percentages, meanRealAccuracy, semRealAccuracy, 'o-', 'LineWidth', 1.5, 'DisplayName', 'Real');

% Plot shuffled accuracy
errorbar(percentages, meanShuffledAccuracy, semShuffledAccuracy, 'o--', 'LineWidth', 1.5, 'DisplayName', 'Shuffled');

% Draw chance level
chanceLevel = 50; % In percentage
plot([min(percentages), max(percentages)], [chanceLevel, chanceLevel], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Chance');

% Customize plot
xlabel('Neurons (%)', 'FontSize', 18);
ylabel('Accuracy (%)', 'FontSize', 18);
%     ylim([40, 100]);
legend('Location', 'southeast');
%     grid on;
box off;
set(gca, 'FontSize', 18);box off;
ylim([0 110])
title(num2str(size(neuronData,2)))
end

function acc = classifyData(neuronData, labels)
% Perform leave-one-out binary classification and return accuracy
%
% Inputs:
%   neuronData: Trials � Selected Neurons matrix
%   labels: Binary labels (0 or 1)
%
% Output:
%   acc: Classification accuracy (%)

numTrials = size(neuronData, 1);
predictedLabels = zeros(numTrials, 1);

% Leave-one-out loop
for i = 1:numTrials
    % Training set excludes the current trial
    trainIdx = setdiff(1:numTrials, i);
    testIdx = i;
    
    trainData = neuronData(trainIdx, :);
    trainLabels = labels(trainIdx);
    testData = neuronData(testIdx, :);
    
    % Train SVM model
    model = fitcsvm(trainData, trainLabels, 'KernelFunction', 'linear');
    
    % Test the model
    predictedLabels(testIdx) = predict(model, testData);
end

% Compute accuracy
acc = mean(predictedLabels == labels) * 100; % Accuracy as percentage
end

function [high_pred, low_pred, allConfMat_high_pred, allConfMat_low_pred] = run_odor_identity_decoder(output_CSplus, output_CSminus,neuronsFlag, nBoot)

plotFlag = 0;
allConfMat_high_pred = zeros(2);allConfMat_low_pred = allConfMat_high_pred;
for ind = 1:nBoot
    [decoderMat_CSplus, decoderMat_CSminus, labels_csPlus, labels_csMinus] =  ...
        prepareDataForProbClassifier(output_CSplus, output_CSminus, neuronsFlag);
    
    
    % divide the data to creaste matrix of neurons with high prediction \
    % low about the odor
    highlyPredicted = [decoderMat_CSplus(1:size(decoderMat_CSplus,1)/2, :) ; decoderMat_CSminus((size(decoderMat_CSminus,1)/2)+1:end, :)];
    lowPredicted = [decoderMat_CSplus((size(decoderMat_CSplus,1)/2)+1:end, :) ; decoderMat_CSminus(1:size(decoderMat_CSminus,1)/2, :)];
    
    
    [high_pred(ind), confMat_high_pred] = leaveOneOutDecoder(highlyPredicted, labels_csPlus, 'CS+', plotFlag);
    allConfMat_high_pred = allConfMat_high_pred + confMat_high_pred;
    
    [low_pred(ind), confMat_low_pred] = leaveOneOutDecoder(lowPredicted, labels_csMinus, 'CS-', plotFlag);
    allConfMat_low_pred = allConfMat_low_pred + confMat_low_pred;
end

allConfMat_high_pred = allConfMat_high_pred./nBoot;
allConfMat_low_pred = allConfMat_low_pred./nBoot;
end

function plot_neuron_success_rate_ratio(total_success_rates, subset_success_rates)
% Define bins for the 0.5 to 1 range with intervals of 0.1
bin_edges = 0.5:0.1:1;
bin_centers = bin_edges(1:end-1) + 0.05;  % Center of each bin for plotting
total_bin_counts = zeros(1, length(bin_edges)-1);
subset_bin_counts = zeros(1, length(bin_edges)-1);

% Bin total success rates
for i = 1:length(bin_edges)-1
    % Count neurons in each bin for the total array
    total_bin_counts(i) = sum(total_success_rates >= bin_edges(i) & total_success_rates < bin_edges(i+1));
    
    % Count neurons in each bin for the subset array
    subset_bin_counts(i) = sum(subset_success_rates >= bin_edges(i) & subset_success_rates < bin_edges(i+1));
end

% Compute the ratio of subset to total for each bin (as a percentage)
ratio = (subset_bin_counts ./ total_bin_counts) * 100;
% Handle any NaNs due to division by zero
ratio(isnan(ratio)) = 0;

% Plot the ratio in a histogram
bar(bin_centers, ratio, 'FaceColor', [0.2, 0.6, 0.8], 'EdgeColor', 'k');
xlabel('Performance (%)'), ylabel('Neurons count');
title('% of ramping neurons');
ylim([0, 100]);set(gca, 'FontSize', 18);box off;xtickangle(45)
set(gca, 'XTick', bin_centers, 'XTickLabel', arrayfun(@(x) sprintf('%.0f-%.0f%%', x*100, (x+0.1)*100), bin_edges(1:end-1), 'UniformOutput', false));
end

function plot_neuron_venn(ramping_neurons, pe_neurons)
    % PLOT_NEURON_VENN plots a Venn diagram of neuron ID groups and their intersection.
    %
    % Inputs:
    %   - ramping_neurons: Vector of neuron IDs classified as ramping neurons.
    %   - pe_neurons: Vector of neuron IDs classified as PE neurons.
    %
    % The function computes the percentage of each group out of the total
    % unique IDs and their intersection and visualizes the results.

    % Ensure inputs are column vectors
    ramping_neurons = unique(ramping_neurons(:));
    pe_neurons = unique(pe_neurons(:));

    % Compute total unique IDs
    all_neurons = [ramping_neurons; pe_neurons];

    % Compute group sizes and percentages
    total_neurons = numel(all_neurons);
    n_ramping = numel(ramping_neurons);
    n_pe = numel(pe_neurons);
    intersection = intersect(ramping_neurons, pe_neurons);
    n_intersection = numel(intersection);

    pct_ramping = (n_ramping / total_neurons) * 100;
    pct_pe = (n_pe / total_neurons) * 100;
    pct_intersection = (n_intersection / total_neurons) * 100;

    % Data for Venn diagram
    data = [n_ramping, n_pe, n_intersection];

    % Plot Venn diagram
    figure;
    venn(data, 'FaceColor', {[0.6 0.8 1], [1 0.6 0.6]}, 'EdgeColor', 'black');

    % Annotate percentages
    xlim_vals = xlim;
    ylim_vals = ylim;

    text(mean(xlim_vals) - 3, ylim_vals(2) * 0.9, ...
        sprintf('Ramping: %.1f%%', pct_ramping), ...
        'HorizontalAlignment', 'center', 'FontSize', 12);

    text(mean(xlim_vals) + 3, ylim_vals(2) * 0.9, ...
        sprintf('PE: %.1f%%', pct_pe), ...
        'HorizontalAlignment', 'center', 'FontSize', 12);

    text(mean(xlim_vals), ylim_vals(2) * 0.8, ...
        sprintf('Intersection: %.1f%%', pct_intersection), ...
        'HorizontalAlignment', 'center', 'FontSize', 12);

    % Add title
%     title('Neuron Classification Venn Diagram');
end


