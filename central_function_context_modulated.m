function [] = central_function_context_modulated(allMiceData, fgPeriod,bgPeriod, brainRegion)

%bgPeriod = time of baseline activity
%fgPeriod = time of activity to analyze.
%brainRegion = 'PC' or 'OFC'

%% detect context-modulated neurons
[csStruct] = analyze_context_modulated_neurons(allMiceData, fgPeriod, bgPeriod, brainRegion);

%%
srCriterion = .7;csPlus_B_fr = [];csMinus_B_fr = [];
for ind = 1:size(csStruct,2)
    
    % TT names
    TTnames{ind} = csStruct(ind).TTname;
    
    % odor response
    csPlusResponses(ind) = csStruct(ind).CSplus.odor_response;
    csMinusResponses(ind) = csStruct(ind).CSminus.odor_response;
    
    %context modulated
    csPlus_context_mod(ind) = csStruct(ind).CSplus.h_context_modulated(1);
    csMinus_context_mod(ind) = csStruct(ind).CSminus.h_context_modulated(1);
    
    context_modulation_matrix_CSplus(ind,:) = csStruct(ind).CSplus.h_context_modulated;
    context_modulation_matrix_CSminus(ind,:) = csStruct(ind).CSminus.h_context_modulated;
    
    csPlus_H_L_fr(:,ind) = [(csStruct(ind).CSplus.H_fr) ; (csStruct(ind).CSplus.L_fr)];
    csMinus_H_L_fr(:,ind) = [(csStruct(ind).CSminus.H_fr) ; (csStruct(ind).CSminus.L_fr)];
    
    %B
    if ~isempty(csStruct(ind).CSplus.B_fr)
        csPlus_B_fr(ind) = (csStruct(ind).CSplus.B_fr);
        csMinus_B_fr(ind) = (csStruct(ind).CSminus.B_fr);
    else
        csPlus_B_fr(ind) = NaN;
        csMinus_B_fr(ind) = NaN;
    end
    
    baselineRates{ind} = computeBaselineFiringRate([csStruct(ind).CSplus.H_raster csStruct(ind).CSplus.L_raster ... 
        csStruct(ind).CSminus.H_raster csStruct(ind).CSminus.L_raster], [-4 -3]);
    
    csPlus_H_rasters{ind} = csStruct(ind).CSplus.H_raster;
    csPlus_L_rasters{ind} = csStruct(ind).CSplus.L_raster;
    
    csMinus_H_rasters{ind} = csStruct(ind).CSminus.H_raster;
    csMinus_L_rasters{ind} = csStruct(ind).CSminus.L_raster;
    
    success_rates(ind) = csStruct(ind).CSplus.successRate;
end


%% Venn of odor responses
bothResponding = csPlusResponses.*csMinusResponses;
% figure;
% venn([sum(csPlusResponses) sum(csMinusResponses)], sum(bothResponding))

plot_venn(sum(csPlusResponses), sum(csMinusResponses), sum(bothResponding))
%% define context-modualted neurons
csPlus_response_and_modulated = csPlus_context_mod.*csPlusResponses;
csMinus_response_and_modulated = csMinus_context_mod.*csMinusResponses;

%both
bothResponding = csPlusResponses.*csMinusResponses;
bothModulated = sum(csPlus_response_and_modulated.*csMinus_response_and_modulated);

sensory_neurons =  sum(~csPlus_context_mod.*csPlusResponses)+sum(~csMinus_context_mod.*csMinusResponses)-sum(bothResponding);

csPlus_modulation_rate = nansum(csPlus_response_and_modulated) ./ sum(csPlusResponses);
csMinus_modulation_rate = nansum(csMinus_response_and_modulated) ./ sum(csMinusResponses);

successRates_binary = logical(success_rates > srCriterion);

%% Compute the rate of PE given the prediction difference
% Compute_rate_of_CM_for_prediction_diff;
% 
% MI_and_PE_rate;
%% Percent of PE neurons per odor
figure;
subplot(1,3,1)
pie([sum(csPlus_response_and_modulated), sum(csPlusResponses)-sum(csPlus_response_and_modulated)])
title(['CS+, N = ' num2str(sum(csPlusResponses))])
subplot(1,3,2)
pie([sum(csMinus_response_and_modulated), sum(csMinusResponses)-sum(csMinus_response_and_modulated)])
title(['CS-, N = ' num2str(sum(csMinusResponses))])
subplot(1,3,3)
pie([sum(bothModulated), sum(bothResponding)-sum(bothModulated)])
title(['Both, N = ' num2str(sum(bothResponding))])


%% % of context modulated (i.e. odor selectiveity analysis)
figure;
subplot(1,3,1)
pie_modulation_percentage_CS(csPlusResponses, csPlus_context_mod,csMinusResponses, csMinus_context_mod);title('Pooled')

subplot(1,3,3)
pie_modulation_percentage_CS(csPlusResponses.*successRates_binary, csPlus_context_mod.*successRates_binary,csMinusResponses.*successRates_binary, csMinus_context_mod.*successRates_binary);title('Expert')

subplot(1,3,2)
pie_modulation_percentage_CS(csPlusResponses.*~successRates_binary, csPlus_context_mod.*~successRates_binary,csMinusResponses.*~successRates_binary, csMinus_context_mod.*~successRates_binary);title('Naive')


%% PE as a function of learning
pe_sr = success_rates(find(csPlus_response_and_modulated+csMinus_response_and_modulated > 0)).*100;
figure;
histogram(pe_sr, 7, 'Normalization', 'probability')
xlim([50 100]);set(gca, 'FontSize', 18);box off;
xlabel('Performance (%)');ylabel('Prediction-error neurons count')

%% PE modulation index
H_L_CSplus_PE_FR = csPlus_H_L_fr(:,find(csPlus_response_and_modulated > 0));
H_L_CSminus_PE_FR = csMinus_H_L_fr(:,find(csMinus_response_and_modulated > 0));

MI_csPlus = abs((H_L_CSplus_PE_FR(1,:) - H_L_CSplus_PE_FR(2,:))./(H_L_CSplus_PE_FR(1,:) + H_L_CSplus_PE_FR(2,:)))


%% PE along learning

% 
% % Divide odor response to naive and expert
% expert_CSplus_response = sum(csPlusResponses.*successRates_binary);
% naive_CSplus_response = sum(csPlusResponses.*~successRates_binary);
% 
% expert_CSminus_response = sum(csMinusResponses.*successRates_binary);
% naive_CSminus_response = sum(csMinusResponses.*~successRates_binary);
% 
% % Find context-modulated neurons in naive and expert
% csPlus_response_and_modulated_expert = sum(csPlus_response_and_modulated.*successRates_binary);
% csPlus_response_and_modulated_naive = sum(csPlus_response_and_modulated.*~successRates_binary);
% 
% csMinus_response_and_modulated_expert = sum(csMinus_response_and_modulated.*successRates_binary);
% csMinus_response_and_modulated_naive = sum(csMinus_response_and_modulated.*~successRates_binary);
% 
% figure;
% subplot(2,2,1)
% pie([csPlus_response_and_modulated_naive naive_CSplus_response-csPlus_response_and_modulated_naive]);title('CS+')
% 
% 
% subplot(2,2,2)
% pie([csPlus_response_and_modulated_expert expert_CSplus_response-csPlus_response_and_modulated_expert]);title('CS+')
% 
% subplot(2,2,3)
% pie([csMinus_response_and_modulated_naive naive_CSminus_response-csMinus_response_and_modulated_naive]);title('CS-')
% 
% subplot(2,2,4)
% pie([csMinus_response_and_modulated_expert expert_CSminus_response-csMinus_response_and_modulated_expert]);title('CS-')

%% firing rate change dist of context-modulated neurons
csPlus_context_modulated_firing = csPlus_H_L_fr(:,find(csPlus_response_and_modulated > 0));
csMinus_context_modulated_firing = csMinus_H_L_fr(:,find(csMinus_response_and_modulated > 0));

% compte rate of increasing and decreasing firing rates
csPlus_context_modulation_rates = [length(find(csPlus_context_modulated_firing(1,:) < csPlus_context_modulated_firing(2,:)))
length(find(csPlus_context_modulated_firing(1,:) > csPlus_context_modulated_firing(2,:)))];

csMinus_context_modulation_rates = [length(find(csMinus_context_modulated_firing(1,:) > csMinus_context_modulated_firing(2,:)))
    length(find(csMinus_context_modulated_firing(1,:) < csMinus_context_modulated_firing(2,:)))];

SPE_rates_CSplus = (csPlus_context_modulation_rates')./sum(csPlus_context_modulation_rates);
SPE_rates_CSminus = (csMinus_context_modulation_rates')./sum(csMinus_context_modulation_rates);

% figure;
% bar([SPE_rates_CSplus ; SPE_rates_CSminus], 'stacked')
% box off;set(gca, 'XTickLabel', {'CS+', 'CS-'});ylabel( '% of context-modulated neurons');set(gca, 'FontSize', 18)

figure;
subplot(2,1,1)
pie(SPE_rates_CSplus');title('CS+')

subplot(2,1,2)
pie(SPE_rates_CSminus');title('CS-')

%% Firing rates of SPE
figure;
subplot(1,4,1)
graphXlim = [-10 35];
scatter(csPlus_context_modulated_firing(1,:), csPlus_context_modulated_firing(2,:))
hold on;
plot([-10 35], [-10 35], 'k--')
xlim(graphXlim);title('CS+');ylabel('Firing rate 25% predicted (Hz)');xlabel('Firing rate 75% predicted (Hz)')

subplot(1,4,2)
scatter(csMinus_context_modulated_firing(2,:), csMinus_context_modulated_firing(1,:))
hold on;
plot([-10 35], [-10 35], 'k--')
xlim(graphXlim);title('CS-')

%---------- odor-selective PE
subplot(1,4,3)
plot_bar_with_points(diff(csPlus_context_modulated_firing), diff(csMinus_H_L_fr(:,find(csPlus_response_and_modulated > 0))))
title('CS+ context-modulated');ylabel('Firing rate context A - context B (Hz)');set(gca, 'XTickLabel', {''})
subplot(1,4,4)
plot_bar_with_points(diff(csMinus_context_modulated_firing), diff(csPlus_H_L_fr(:,find(csMinus_response_and_modulated > 0))))
title('CS- context-modulated');ylabel('Firing rate context A - context B (Hz)');set(gca, 'XTickLabel', {''})

%% decode probability from PE neurons
decoderPlotFlag = 0;
if decoderPlotFlag
    
    rasters.csPlus_H_modulated_rasters = csPlus_H_rasters(find(csPlus_response_and_modulated > 0));
    rasters.csPlus_L_modulated_rasters = csPlus_L_rasters(find(csPlus_response_and_modulated > 0));
    rasters.csMinus_H_modulated_rasters = csMinus_H_rasters(find(csMinus_response_and_modulated > 0));
    rasters.csMinus_L_modulated_rasters = csMinus_L_rasters(find(csMinus_response_and_modulated > 0));
    
    figure;subplot(1,2,1)
    run_PE_neurons_decoder(rasters, 100, [-4 -3], [0 1]);
    title('Context-modulated');
    
    rasters.csPlus_H_modulated_rasters = csPlus_H_rasters(find(csPlus_response_and_modulated == 0));
    rasters.csPlus_L_modulated_rasters = csPlus_L_rasters(find(csPlus_response_and_modulated == 0));
    rasters.csMinus_H_modulated_rasters = csMinus_H_rasters(find(csMinus_response_and_modulated == 0));
    rasters.csMinus_L_modulated_rasters = csMinus_L_rasters(find(csMinus_response_and_modulated == 0));
    
    subplot(1,2,2)
    run_PE_neurons_decoder(rasters, 100, [-4 -3], [0 1]);
    title('Sensory');

end
%% PSTHs
%----CS+----
% rasters.csPlus_H_smaller_H = csPlus_H_rasters(find(csPlus_context_mod.*csPlusResponses.*logical(diff(csPlus_H_L_fr) > 0) > 0));
% rasters.csPlus_H_smaller_L = csPlus_L_rasters(find(csPlus_context_mod.*csPlusResponses.*logical(diff(csPlus_H_L_fr) > 0) > 0));
% 
% rasters.csPlus_H_larger_H = csPlus_H_rasters(find(csPlus_context_mod.*csPlusResponses.*logical(diff(csPlus_H_L_fr) < 0) > 0));
% rasters.csPlus_H_larger_L = csPlus_L_rasters(find(csPlus_context_mod.*csPlusResponses.*logical(diff(csPlus_H_L_fr) < 0) > 0));
% 
% %----CS- ----
% rasters.csMinus_H_smaller_H = csMinus_H_rasters(find(csMinus_context_mod.*csMinusResponses.*logical(diff(csMinus_H_L_fr) < 0) > 0));
% rasters.csMinus_H_smaller_L = csMinus_L_rasters(find(csMinus_context_mod.*csMinusResponses.*logical(diff(csMinus_H_L_fr) < 0) > 0));
% 
% rasters.csMinus_H_larger_H = csMinus_H_rasters(find(csMinus_context_mod.*csMinusResponses.*logical(diff(csMinus_H_L_fr) > 0) > 0));
% rasters.csMinus_H_larger_L = csMinus_L_rasters(find(csMinus_context_mod.*csMinusResponses.*logical(diff(csMinus_H_L_fr) > 0) > 0));


lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

psthXlim = [-.5 2];

% figure;
% subplot(2,2,1)
% hold all
% plotPSTH(rasters.csPlus_H_smaller_H, [-4 -3], .07, highProbColor)
% plotPSTH(rasters.csPlus_H_smaller_L, [-4 -3], .07, lowProbColor)
% title('CS+ SPE');xlim(psthXlim);xlabel('Time relative to CS (sec)');ylabel('Z-score')
% 
% 
% subplot(2,2,3)
% hold all
% plotPSTH(rasters.csPlus_H_larger_H, [-4 -3], .07, highProbColor)
% plotPSTH(rasters.csPlus_H_larger_L, [-4 -3], .07, lowProbColor)
% xlim(psthXlim);title('CS+ oSPE')
% 
% subplot(2,2,2)
% hold all
% plotPSTH(rasters.csMinus_H_smaller_H, [-4 -3], .07, highProbColor)
% plotPSTH(rasters.csMinus_H_smaller_L, [-4 -3], .07, lowProbColor)
% title('CS-');xlim(psthXlim);title('CS- SPE')
% 
% subplot(2,2,4)
% hold all
% plotPSTH(rasters.csMinus_H_larger_H, [-4 -3], .07, highProbColor)
% plotPSTH(rasters.csMinus_H_larger_L, [-4 -3], .07, lowProbColor)
% xlim(psthXlim);title('CS- oSPE')

%----POOLED
rasters.csPlus_H_modulated_rasters = csPlus_H_rasters(find(csPlus_response_and_modulated > 0));
rasters.csPlus_L_modulated_rasters = csPlus_L_rasters(find(csPlus_response_and_modulated > 0));
rasters.csMinus_H_modulated_rasters = csMinus_H_rasters(find(csMinus_response_and_modulated > 0));
rasters.csMinus_L_modulated_rasters = csMinus_L_rasters(find(csMinus_response_and_modulated > 0));

baseline_CSplus_modulated = baselineRates(find(csPlus_response_and_modulated > 0));
baseline_CSminus_modulated = baselineRates(find(csMinus_response_and_modulated > 0));

figure;
subplot(1,2,1)
hold all
[psths_CSplus_H,t] = plotPSTH(rasters.csPlus_H_modulated_rasters,baseline_CSplus_modulated, [-4 -3], .07, highProbColor);
[psths_CSplus_L] = plotPSTH(rasters.csPlus_L_modulated_rasters,baseline_CSplus_modulated, [-4 -3], .07, lowProbColor);
title('CS+ SPE');xlim(psthXlim);xlabel('Time relative to CS (sec)');ylabel('Z-score')

subplot(1,2,2)
hold all
[psths_CSminus_H,t] = plotPSTH(rasters.csMinus_H_modulated_rasters,baseline_CSminus_modulated, [-4 -3], .07, highProbColor);
[psths_CSminus_L] = plotPSTH(rasters.csMinus_L_modulated_rasters,baseline_CSminus_modulated, [-4 -3], .07, lowProbColor);
title('CS- SPE');xlim(psthXlim);xlabel('Time relative to CS (sec)');ylabel('Z-score')



end







function [] = pie_modulation_percentage_CS(csPlusResponses, csPlus_context_mod,csMinusResponses, csMinus_context_mod)
csPlus_response_and_modulated = csPlus_context_mod.*csPlusResponses;
csMinus_response_and_modulated = csMinus_context_mod.*csMinusResponses;

%both
bothResponding = csPlusResponses.*csMinusResponses;
bothModulated = sum(csPlus_response_and_modulated.*csMinus_response_and_modulated);

sensory_neurons =  sum(~csPlus_context_mod.*csPlusResponses)+sum(~csMinus_context_mod.*csMinusResponses)-sum(bothResponding);

csPlus_modulation_rate = nansum(csPlus_response_and_modulated) ./ sum(csPlusResponses);
csMinus_modulation_rate = nansum(csMinus_response_and_modulated) ./ sum(csMinusResponses);



% figure;
pie([sum(csPlus_response_and_modulated)-bothModulated/2, bothModulated, sum(csMinus_response_and_modulated)-bothModulated/2, sensory_neurons])
legend('CS+', 'CS-', 'Sensory')
end

function [psth_mat, t] = plotPSTH(rasterStruct,baselineFR, bgPeriod, psthKernel, clr)
psth_mat = [];
for ind = 1:size(rasterStruct,2)
    currRaster = rasterStruct{ind};
%     baselineFR = computeBaselineFiringRate(currRaster, bgPeriod);
    % z-score the psth
    [R,t] = mypsth(currRaster, psthKernel, 'n');
    Z_psth = (R - mean(baselineFR{ind}))./std(baselineFR{ind});
    
    if length(t) < 401
        Z_psth = nan(1,401);
    else
    
    startLoc = find(t > bgPeriod(2),1);
    locsToCut = startLoc:startLoc+400;
    Z_psth = Z_psth(locsToCut);
    t = t(locsToCut);
    end
%     Z_psth = abs(Z_psth);
    psth_mat(end+1, :) = Z_psth;
end
psth_mat(find(isinf(psth_mat(:,1))==1),:) = [];
errorbar_patch(t, nanmean(psth_mat), nanstd(psth_mat)./sqrt(size(psth_mat,1)), clr)
end

function baselineFR = computeBaselineFiringRate(data, baselinePeriod)
    % Ensure baselinePeriod is a 2-element vector
    if length(baselinePeriod) ~= 2
        error('baselinePeriod must be a 2-element vector specifying the start and end of the period in seconds.');
    end
    
    % Calculate the duration of the baseline period
    baselineDuration = abs(diff(baselinePeriod));
    
    % Initialize baseline firing rate vector
    numTrials = length(data);
    baselineFR = zeros(1, numTrials);
    
    % Loop through each trial
    for i = 1:numTrials
        % Extract spike times for the current trial
        spikeTimes = data(i).times;
        
        % Count spikes within the baseline period
        numSpikes = sum(spikeTimes >= baselinePeriod(1) & spikeTimes <= baselinePeriod(2));
        
        % Compute firing rate for the baseline period
        baselineFR(i) = numSpikes / baselineDuration;
    end
end
               






function [] = run_PE_neurons_decoder(rasters, nBoot, bg, fg)


for ind = 1:nBoot
    [decoderMat_CSplus, decoderMat_CSminus, labels_csPlus, labels_csMinus] =  ...
        prepareDataForProbClassifier(rasters, bg, [fg(1) fg(2)]);
    
    [accuracy_CSplus(ind)] = leaveOneOutDecoder(decoderMat_CSplus, labels_csPlus, 'CS+', 0);
    %     allConfMat_CSplus = allConfMat_CSplus + confMat_CSplus;
    
    [accuracy_CSminus(ind)] = leaveOneOutDecoder(decoderMat_CSminus, labels_csMinus, 'CS-', 0);
    %     allConfMat_CSminus = allConfMat_CSminus + confMat_CSminus;
    
    clc
    disp(['Iteration # ' num2str(ind) '/' num2str(nBoot)])
end

% allConfMat_CSplus = allConfMat_CSplus./nBoot;
% allConfMat_CSminus = allConfMat_CSminus./nBoot;
% 
% mean_accuracy_CSplus = mean(accuracy_CSplus);
% mean_accuracy_CSminus = mean(accuracy_CSminus);

% figure;
% barwitherr([std(accuracy_CSplus) std(accuracy_CSminus)], mean([accuracy_CSplus' accuracy_CSminus']))
boxplot([accuracy_CSplus' accuracy_CSminus'] )
ylim([0 1]);set(gca, 'XTickLabel', {'CS+', 'CS-'});box off


end


function [decoderMat_CSplus, decoderMat_CSminus, labels_csPlus, labels_csMinus] = prepareDataForProbClassifier(rasters, bg, fg)


%CS+
PE_rasters_H_CSplues = rasters.csPlus_H_modulated_rasters;
PE_firingRate_H_CSplus = computeEvokedFiringRates(PE_rasters_H_CSplues, bg, fg);

PE_rasters_L_CSplues = rasters.csPlus_L_modulated_rasters;
PE_firingRate_L_CSplus = computeEvokedFiringRates(PE_rasters_L_CSplues, bg, fg);


decoderMat_CSplus = equalizeAndStackTrials(PE_firingRate_H_CSplus, PE_firingRate_L_CSplus, 0);
numTrials_csPlus = size(decoderMat_CSplus,1);
labels_csPlus = [zeros(numTrials_csPlus/2, 1); ones(numTrials_csPlus/2, 1)]; % 0 for first half, 1 for second half

%CS-
PE_rasters_H_CSminus = rasters.csMinus_H_modulated_rasters;
PE_firingRate_H_CSminus = computeEvokedFiringRates(PE_rasters_H_CSminus, bg, fg);

PE_rasters_L_CSminus = rasters.csMinus_L_modulated_rasters;
PE_firingRate_L_CSminus = computeEvokedFiringRates(PE_rasters_L_CSminus, bg, fg);


decoderMat_CSminus = equalizeAndStackTrials(PE_firingRate_H_CSminus, PE_firingRate_L_CSminus, 0);
numTrials_csminus = size(decoderMat_CSminus,1);
labels_csMinus = [zeros(numTrials_csminus/2, 1); ones(numTrials_csminus/2, 1)]; % 0 for first half, 1 for second half
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
        evokedRates(trialIdx) = fgFiringRate ;%- bgFiringRate;
    end
    
    % Store evoked firing rates for this neuron
    evokedFiringRates{neuronIdx} = evokedRates;
end
end

function plot_bar_with_points(vec1, vec2)
    % Check inputs
    if nargin < 2
        error('Function requires two input vectors.');
    end
    
    % Compute means and standard errors
    means = [mean(vec1), mean(vec2)];
    sems = [std(vec1) / sqrt(length(vec1)), std(vec2) / sqrt(length(vec2))];
    
    % Perform t-test
    [~, p] = ttest(vec1, vec2);
    
    % Plot bar graph
%     figure;
    hold all;
    bar(1:2, means, 'FaceColor', 'w', 'EdgeColor', 'k');
    errorbar(1:2, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
    
    % Plot individual data points and lines if vectors are the same size
%     if length(vec1) == length(vec2)
%         x_positions = [ones(size(vec1)); 2 * ones(size(vec2))]';
%         plot([vec1 ;vec2], 'k-', 'HandleVisibility', 'off');
%         scatter(x_positions(:,1), vec1, 'ko');
%         scatter(x_positions(:,2), vec2, 'ko');
%     else
%         scatter(ones(size(vec1)), vec1, 'ko', 'jitter', 'on', 'jitterAmount', 0.1);
%         scatter(2 * ones(size(vec2)), vec2, 'ko', 'jitter', 'on', 'jitterAmount', 0.1);
%     end
    
    % Add significance asterisk if p < 0.05
    if p < 0.05
        y_max = max([vec1 vec2]) + max(sems) * 1.5;
        plot([1, 2], [y_max, y_max], 'k', 'LineWidth', 1.5);
        text(1.5, y_max * 1.05, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    
    % Formatting
    xlim([0.5, 2.5]);
    xticks([1, 2]);
    set(gca, 'XTickLabel', {'Vec1', 'Vec2'}, 'FontSize', 14);
    ylabel('Value');
    box off;
    hold off;
end

function plot_venn(cs_plus_count, cs_minus_count, overlap_count)
    % Plot a proportional 2-set Venn diagram with labeled group sizes

    % Normalize colors
   cs_plus_color = [154 52 52]/255;
    cs_minus_color = [154 103 51]/255;

    % Circle radii proportional to sqrt(area)
    r1 = sqrt(cs_plus_count / pi);
    r2 = sqrt(cs_minus_count / pi);

    % Solve for distance d between centers given overlap
    d = solve_circle_overlap(r1, r2, overlap_count);

    % Circle centers
    center1 = [-d/2, 0];
    center2 = [d/2, 0];

    % Circle resolution
    theta = linspace(0, 2*pi, 300);

    % Generate circle coordinates
    x1 = r1 * cos(theta) + center1(1);
    y1 = r1 * sin(theta) + center1(2);

    x2 = r2 * cos(theta) + center2(1);
    y2 = r2 * sin(theta) + center2(2);

    % Plot
    figure;
    fill(x1, y1, cs_plus_color, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on;
    fill(x2, y2, cs_minus_color, 'FaceAlpha', 0.5, 'EdgeColor', 'none');

    % Labels
    text(center1(1), center1(2) + r1 + 0.1, sprintf('CS+\n%d', cs_plus_count), ...
        'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
    text(center2(1), center2(2) + r2 + 0.1, sprintf('CS-\n%d', cs_minus_count), ...
        'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');

    % Overlap label (at midpoint)
    text(0, 0, num2str(overlap_count), ...
        'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

    axis equal;
    axis off;
end

function d = solve_circle_overlap(r1, r2, target_overlap)
    % Numerically solve for distance between centers for given overlap

    % Convert area to radius
    A_target = target_overlap;

    % Objective: difference between desired and actual overlap
    fun = @(d) abs(overlap_area(r1, r2, d) - A_target);

    % Solve using fminbnd (bounded minimization)
    d = fminbnd(fun, abs(r1 - r2), r1 + r2);
end

function A = overlap_area(r1, r2, d)
    % Compute area of intersection between two circles with radii r1, r2 at distance d

    if d >= r1 + r2
        A = 0;
        return
    elseif d <= abs(r1 - r2)
        A = pi * min(r1, r2)^2;
        return
    end

    part1 = r1^2 * acos((d^2 + r1^2 - r2^2) / (2*d*r1));
    part2 = r2^2 * acos((d^2 + r2^2 - r1^2) / (2*d*r2));
    part3 = 0.5 * sqrt((-d + r1 + r2)*(d + r1 - r2)*(d - r1 + r2)*(d + r1 + r2));

    A = part1 + part2 - part3;
end

