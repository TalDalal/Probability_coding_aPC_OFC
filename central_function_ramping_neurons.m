function [rampingNeurons] = central_function_ramping_neurons(allMiceData, bgPeriod, fgPeriod, brainRegion)

% allMiceData = allMiceData_OFC_SILENCING;
%% Analyze and detect ramping neurons
[rampingNeurons] = psth_delay_modulated_neurons(allMiceData, fgPeriod, bgPeriod, [-2 0], 'allTrials', 2, brainRegion);
rampingSessionsInds = find(rampingNeurons(1).allDelayActiveNeurons > 0);
%%
% figure;
% subplotRows = 4;subplotCols = 3;
% %% Ramping neurons across SRs
rampingSR = rampingNeurons(1).meanSuccessRates(rampingSessionsInds);
% 
[allNeurons_SR] = getSuccessRatesForEachNeuron(allMiceData, brainRegion);
allNeurons_SR = mean(allNeurons_SR(:,2:3), 2);
% 
% % subplot(subplotRows,subplotCols,1)
% figure;
% plot_neuron_success_rate_ratio(allNeurons_SR, rampingSR, rampingNeurons)

%% % ramping neurons
[taskModulationMat] = taskModulatedNeurons(allMiceData, 0.01, [-2 -1; -.33 0 ; 0 1], [-4 -3], brainRegion);

plotNeuronPieChart(length(rampingNeurons(1).Low_responding_exc_inds)+length(rampingNeurons(2).Low_responding_exc_inds), length(find(sum(abs(taskModulationMat),2) >0)))
%% % ramping for H L and both and ramping selectivity
H_rampimng = sum(rampingNeurons(1).responseMat_High);
L_rampimng = sum(rampingNeurons(1).responseMat_Low);
M_rampimng = nansum(rampingNeurons(1).responseMat_M);
both_ramping = sum(rampingNeurons(1).responseMat_Low.*rampingNeurons(1).responseMat_High);

% subplot(subplotRows,subplotCols,2)
figure
plot_venn_diagram(H_rampimng, L_rampimng, both_ramping)
% venn([H_rampimng, L_rampimng], both_ramping)
legend('H', 'L')



figure;
plot_response_rate([H_rampimng, M_rampimng, L_rampimng], [length(rampingNeurons(1).responseMat_High) sum(~isnan(rampingNeurons(1).responseMat_M)) length(rampingNeurons(1).responseMat_High)])
%% corr between ramping and RT
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

[sessions] = getSessionsData(allMiceData, brainRegion);
rampingSessions = sessions(rampingSessionsInds);


%Evoked activity
Z_evokedRamping_High_vec = rampingNeurons(1).Z_evokedRamping_High_vec(rampingSessionsInds);
Z_evokedRamping_Low_vec = rampingNeurons(1).Z_evokedRamping_Low_vec(rampingSessionsInds);


[meanRT_high, meanRT_low] = corrBetweenRampingLickOnset(sessions, rampingNeurons);

% subplot(subplotRows,subplotCols,3)
figure
subplot(1,2,1)
scatter_with_lsline(meanRT_high, Z_evokedRamping_High_vec, highProbColor)
% subplot(subplotRows,subplotCols,3)
subplot(1,2,2)
scatter_with_lsline(meanRT_low, Z_evokedRamping_Low_vec, lowProbColor)

[r,p] = corrcoef(Z_evokedRamping_High_vec, meanRT_high);
disp(['A context: r = ' num2str(r(1,2)) ', p = ' num2str(p(1,2))])
[r,p] = corrcoef(Z_evokedRamping_Low_vec, meanRT_low);
disp(['B context: r = ' num2str(r(1,2)) ', p = ' num2str(p(1,2))])

%% Activity during CS+\-
% CSplusActivityDuringRamping_H = rampingNeurons(1).high_CS_plus_Raster(rampingSessionsInds);
% CSplusActivityDuringRamping_L = rampingNeurons(1).low_CS_plus_Raster(rampingSessionsInds);
% for ind = 1:size(rampingSessionsInds,2)
%     CSplusActivityDuringRamping{ind} = [CSplusActivityDuringRamping_H{ind} CSplusActivityDuringRamping_L{ind}];
% end
% [Z_CSplus_H] = convertRasterPlotsToZvalues(CSplusActivityDuringRamping, [-4 -3], [0 1]);

%% Firing rate H M L
%Evoked activity
Z_evokedRamping_High_vec = rampingNeurons(1).Z_evokedRamping_High_vec(rampingSessionsInds);
Z_evokedRamping_Low_vec = rampingNeurons(1).Z_evokedRamping_Low_vec(rampingSessionsInds);
Z_evokedRamping_Medium_vec = rampingNeurons(1).Z_evokedRamping_Medium_vec(rampingSessionsInds);
Z_evokedRamping_Medium_vec(isinf(Z_evokedRamping_Medium_vec)) = [];

[~,p_h_vs_l_rampZ] = ttest(Z_evokedRamping_High_vec, Z_evokedRamping_Low_vec);
[~,p_h_vs_m_rampZ] = ttest(Z_evokedRamping_High_vec(~isinf(Z_evokedRamping_Medium_vec)), Z_evokedRamping_Medium_vec);
[~,p_l_vs_m_rampZ] = ttest(Z_evokedRamping_Low_vec(~isinf(Z_evokedRamping_Medium_vec)), Z_evokedRamping_Medium_vec);

H_L_SE = std([Z_evokedRamping_High_vec' Z_evokedRamping_Low_vec'])./sqrt(length(Z_evokedRamping_High_vec));
H_L_mean = mean([Z_evokedRamping_High_vec' Z_evokedRamping_Low_vec']);

M_SE_mean = [std(Z_evokedRamping_Medium_vec)./sqrt(length(Z_evokedRamping_Medium_vec)) mean(Z_evokedRamping_Medium_vec)];
figure;
barwitherr([H_L_SE(1) M_SE_mean(1) H_L_SE(2)], [H_L_mean(1) M_SE_mean(2) H_L_mean(2)]);
set(gca, 'FontSize', 18);box off;
ylabel('Z-score'); set(gca, 'XTickLabel', {'H', 'M' 'L'})
title(['P H vs L = ' num2str(p_h_vs_l_rampZ) '; P H vs M = ' num2str(p_h_vs_m_rampZ) '; P L vs M = ' num2str(p_l_vs_m_rampZ)])
%% Correlate psth with sniff
% correlationTimeWin = fgPeriod;
% [all_r_high, all_r_low, high_sniff_psths, low_sniff_psths] = correlateRamp_with_sniffs(rampingSessions, rampingNeurons, rampingSessionsInds, correlationTimeWin);
% % subplot(subplotRows,subplotCols,5)
% figure
% categories = {'High', 'Low'};
% colors = [highProbColor; lowProbColor];  % Optional custom colors
% data_sniff_ramp{1} = all_r_high;
% data_sniff_ramp{2} = all_r_low;
% % Call the function
% 
% violinplot_with_mean_single_side(data_sniff_ramp, categories, colors, 1, 0);
% ylabel('Correlation')
% 
% % subplot(subplotRows,subplotCols,6)
% figure;
% plotMeanSEM(high_sniff_psths, highProbColor)
% hold on
% plotMeanSEM(low_sniff_psths, lowProbColor)
%% plot the predicted ramping from the sniffs
% figure;

% %% Ramping by session
% % subplot(subplotRows,subplotCols,7)
% figure;
% rampingBySessions(rampingSessions, rampingNeurons, rampingSessionsInds, [1 2], [-3 0])

%% plot ramping example
% neuronNum = 69;%28 is the example in the figure
% plot_ramping_example(rampingNeurons, neuronNum)

% %% Ramping early sessions
% for sessInd = 1:length(rampingSessions)
%     sessNum(sessInd) = rampingSessions(sessInd).recs.sessionNum;
% end
% 
% earlySessions = find(sessNum==1 | sessNum==2);
% lateSessions = find(sessNum~=1 & sessNum~=2);
% % earlySessions = find(rampingSR <= 0.6);
% % lateSessions = find(rampingSR > 0.8);
% 
% rampDiff_by_sessions{1} = Z_evokedRamping_High_vec(earlySessions) ;
% rampDiff_by_sessions{2} = Z_evokedRamping_Low_vec(earlySessions);
% 
% rampDiff_by_sessions{3} = Z_evokedRamping_High_vec(lateSessions);
% rampDiff_by_sessions{4} = Z_evokedRamping_Low_vec(lateSessions);
% 
% categories = {'Early','Early', 'Late' , 'Late'};
% colors = [highProbColor;lowProbColor ; highProbColor;lowProbColor];
% % subplot(subplotRows,subplotCols,8)
% figure;
% violinplot_with_mean_single_side(rampDiff_by_sessions, categories, colors, 1, 1)

%% Ramping for CS+\-
% subplot(subplotRows,subplotCols,9)
% figure;
% ramping_for_cs_plus_minus(rampingNeurons, rampingSessionsInds, [-3 0.5])

%% Responses to prediciting odors in ramping neurons
% subplot(subplotRows,subplotCols,10)
% figure;
% [low_respondingNeurons, high_respondingNeurons] = responsesToPredictingOdors(rampingNeurons, rampingSessionsInds, 0.01);
% responses_H_L{1} = high_respondingNeurons;
% responses_H_L{2} = low_respondingNeurons;
% 
% plotLabels = {'High', 'Low'};
% subplot(subplotRows,subplotCols,11)
% violinplot_with_mean_single_side(responses_H_L, plotLabels, [highProbColor ; lowProbColor], 1, 1)
% box off;

%% Ramping as the function of sessions
% plotGroupedFiringRates(sessNum, [Z_evokedRamping_High_vec' Z_evokedRamping_Low_vec'], 3)


plot_ramping_vs_success_rate([Z_evokedRamping_High_vec' Z_evokedRamping_Low_vec'], rampingSR)















end
%% -------------Functions--------------
function plot_neuron_success_rate_ratio(total_success_rates, subset_success_rates, rampingNeurons)
% Define bins for the 0.5 to 1 range with intervals of 0.1
bin_edges = [0.5 0.7 1];
bin_centers = bin_edges(1:end-1) + 0.05;  % Center of each bin for plotting
total_bin_counts = zeros(1, length(bin_edges)-1);
subset_bin_counts = zeros(1, length(bin_edges)-1);

H_ramping_neurons = rampingNeurons(1).responseMat_High(find(rampingNeurons(1).allDelayActiveNeurons > 0));
L_ramping_neurons = rampingNeurons(1).responseMat_Low(find(rampingNeurons(1).allDelayActiveNeurons > 0));
bothRamping = H_ramping_neurons .* L_ramping_neurons;
% Bin total success rates
for i = 1:length(bin_edges)-1
    % Count neurons in each bin for the total array
    total_bin_counts(i) = sum(total_success_rates >= bin_edges(i) & total_success_rates < bin_edges(i+1));
    
    % Count neurons in each bin for the subset array
    currRampingSRs = subset_success_rates >= bin_edges(i) & subset_success_rates < bin_edges(i+1);
    subset_bin_counts(i) = sum(currRampingSRs);
    
    
    responseMatrix_H_L_Both(:,i) = [sum(H_ramping_neurons(currRampingSRs))-sum(bothRamping(currRampingSRs)) sum(bothRamping(currRampingSRs)) sum(L_ramping_neurons(currRampingSRs))-sum(bothRamping(currRampingSRs))]';
    
end
figure;
subplot(2,1,1)
venn(responseMatrix_H_L_Both([1,3],1), responseMatrix_H_L_Both([2],1));title('Novice');
subplot(2,1,2)
venn(responseMatrix_H_L_Both([1,3],2), responseMatrix_H_L_Both([2],2));title('Expert');

responseMatrix_H_L_Both = (responseMatrix_H_L_Both./sum(responseMatrix_H_L_Both)) .*100;

% Compute the ratio of subset to total for each bin (as a percentage)
ratio = (subset_bin_counts ./ total_bin_counts) * 100;
% Handle any NaNs due to division by zero
ratio(isnan(ratio)) = 0;

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green


colors = [highProbColor;
          [86, 116, 140]./255
          lowProbColor]; 

% Create stacked bar plot
b = bar(bin_centers, responseMatrix_H_L_Both', 'stacked');

% Change color for each stack
for k = 1:length(b)
    b(k).FaceColor = colors(k, :);
end

[pNaiveExpert] = twoSampleProportionTest(sum(subset_bin_counts(1:2))./sum(total_bin_counts(1:2)), sum(subset_bin_counts(3:end))./sum(total_bin_counts(3:end)),sum(total_bin_counts(1:2)), sum(total_bin_counts(3:end)));
% % Plot the ratio in a histogram
% bar(bin_centers, ratio, 'FaceColor', [0.2, 0.6, 0.8], 'EdgeColor', 'k');
xlabel('Performance (%)'), ylabel('% of ramping neurons');
title(['P naive vs expert = ' num2str(pNaiveExpert)]);
ylim([0, 40]);set(gca, 'FontSize', 18);box off;xtickangle(45)
set(gca, 'XTick', bin_centers, 'XTickLabel', arrayfun(@(x) sprintf('%.0f-%.0f%%', x*100, (x+0.1)*100), bin_edges(1:end-1), 'UniformOutput', false));
end

function plot_venn_diagram(A_only, B_only, AB_overlap)
% Define RGB colors for circles (normalized between 0 and 1)
color_A = [0, 169, 137] / 255;
color_B = [171, 62, 143] / 255;

% Total count for calculating percentages
total = A_only + B_only - AB_overlap ;

% Calculate percentages for each section
percent_A_only = ((A_only-AB_overlap )/ total).*100;
percent_B_only = ((B_only-AB_overlap) / total).*100;
percent_AB_overlap = (AB_overlap / total).*100;

observed = [ percent_A_only percent_B_only percent_AB_overlap];
expected = [33.3 33.3 33.3];

[chi2stat, p, df] = chiSquareGOF(observed, expected);
fprintf('Chi-square = %.2f, df = %d, p = %.4f\n', chi2stat, df, p);

% Create the Venn diagram
%     figure;
venn([A_only, B_only], AB_overlap);

% Customize colors
h = findobj(gca, 'Type', 'patch');
set(h(1), 'FaceColor', color_B, 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Set color for B
set(h(2), 'FaceColor', color_A, 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Set color for A

% Add percentage labels to each section
% Adjust the positions to avoid overlap
text(-3, 0.2, sprintf('A only: %.1f%%', percent_A_only), 'HorizontalAlignment', 'center');
text(3, 0.2, sprintf('B only: %.1f%%', percent_B_only), 'HorizontalAlignment', 'center');
text(0, .2, sprintf('A & B: %.1f%%', percent_AB_overlap), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

% Title and turn off axis for better visualization
title('Venn Diagram');
axis off;
end


function [sessions] = getSessionsData(allMiceData, brainRegion)
c=0;

if nargin < 2
    brainRegion = 'PC';
end
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi(brainRegion,mouseData(recInd).brainRegion)
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                sessions(c).recs = mouseData(recInd);
                
                
            end
        end
    end
end
end

function scatter_with_lsline(x, y, color)
% Scatter plot with filled circles and a linear fit line in specified color
% Inputs:
%   x - vector of x-values (first lick latency in seconds)
%   y - vector of y-values (ramping amplitude in Z-score)
%   color - color of the points and the lsline (e.g., 'r' for red, [0 0.5 0] for green)

% Check if color input is a valid color specification
if ~ischar(color) && ~isnumeric(color)
    error('Color input must be a character or numeric RGB array');
end

% Create scatter plot
scatter(x, y, 50, color, 'filled'); % 50 is the marker size
hold on;

% Add least-squares fit line
lsline_handle = lsline();
set(lsline_handle, 'Color', color, 'LineWidth', 1.5);

% Set labels
xlabel('Reaction time (sec)');
ylabel('Ramping amplitude (Z-score)');

% Release hold
hold off;
end

function [meanRT_high, meanRT_low] = corrBetweenRampingLickOnset(sessions, rampingNeurons)
rampingSessionsInds = find(rampingNeurons(1).allDelayActiveNeurons > 0);
rampingSessions = sessions(rampingSessionsInds);


for rampInd = 1:length(rampingSessions)
    
    if rampingSessions(rampInd).recs.data.probability.A > rampingSessions(rampInd).recs.data.probability.C
        meanRT_high(rampInd) = mean(rampingSessions(rampInd).recs.data.firstLickLatency.A);
        meanRT_low(rampInd) = mean(rampingSessions(rampInd).recs.data.firstLickLatency.C);
        
    else
        
        meanRT_high(rampInd) = mean(rampingSessions(rampInd).recs.data.firstLickLatency.C);
        meanRT_low(rampInd) = mean(rampingSessions(rampInd).recs.data.firstLickLatency.A);
    end
end
end

function [all_r_high, all_r_low, high_sniff_psths, low_sniff_psths, rampingPrediction] = correlateRamp_with_sniffs(rampingSessions, rampingNeurons, rampingSessionsInds, timeWindow)
all_r_high = [];all_r_low = [];high_sniff_psths = [];low_sniff_psths = [];
kernelSize = 0.1;validFlag = 0;

high_rasters = rampingNeurons(1).high_rasters(rampingSessionsInds);
low_rasters = rampingNeurons(1).low_rasters(rampingSessionsInds);

for sessInd = 1:size(rampingSessions,2)
    
    if rampingSessions(sessInd).recs.data.probability.A > rampingSessions(sessInd).recs.data.probability.C
        
        highSniff = rampingSessions(sessInd).recs.data.SniffRaster.A;
        lowSniff = rampingSessions(sessInd).recs.data.SniffRaster.C;
    else
        highSniff = rampingSessions(sessInd).recs.data.SniffRaster.C;
        lowSniff = rampingSessions(sessInd).recs.data.SniffRaster.A;
    end
    if isempty(highSniff(1).times) | isempty(lowSniff(1).times)
        continue;
    end
    [r_high, high_sniff] = computeSniff_psth_corr(highSniff, high_rasters{sessInd}, kernelSize, timeWindow);
    [r_low, low_sniff] = computeSniff_psth_corr(lowSniff, low_rasters{sessInd}, kernelSize, timeWindow);
    
    if ~isempty(r_high) & ~isempty(r_low)
        validFlag = validFlag + 1;
        
        all_r_high(end+1) = r_high;
        all_r_low(end+1) = r_low;
        
        high_sniff_psths(end+1,:) = high_sniff;
        low_sniff_psths(end+1,:) = low_sniff;
        
        
    %Compte the sniff and spike rate in each bin, build a regression model
    %and predict the spike rate during the ramping window.
%    [changeBetweenActualAndPredicted_High] =  computeRatesForRegression(highSniff, high_rasters{sessInd}, abs(timeWindow(1)));
%    
%    [changeBetweenActualAndPredicted_Low] =  computeRatesForRegression(lowSniff, low_rasters{sessInd}, abs(timeWindow(1)));
%    
%    rampingPrediction(validFlag).high = changeBetweenActualAndPredicted_High;
%    rampingPrediction(validFlag).low = changeBetweenActualAndPredicted_Low;
   
   
    end
    

  
   
   
end
end

function [changeBetweenActualAndPredicted] = computeRatesForRegression(spikeStruct, sniffStruct, windowSize)
    % Default window size if not specified
    if nargin < 3
        windowSize = 0.33;
    end

    % Initialize vectors for spike and sniff rates
    spikeRates = [];
    excludedSpikeRates = [];
    sniffRates = [];
    excludedSniffRates = [];

    % Loop over trials
    numTrials = length(spikeStruct);
    for iTrial = 1:numTrials
        % Extract spike and sniff times for the current trial
        spikeTimes = spikeStruct(iTrial).times;
        sniffTimes = sniffStruct(iTrial).times;

        % Compute the windows for the trial
        trialDuration = minmax([spikeTimes(:); sniffTimes(:)]);
        timeEdges = [trialDuration(1):windowSize:-windowSize ];% 0:windowSize:trialDuration(2)]; % Start windows from -3 seconds

        % Calculate spike rates in each window
        spikeCounts = histcounts(spikeTimes, timeEdges);
        spikeRate = spikeCounts / windowSize;

        % Calculate sniff rates in each window
        sniffCounts = histcounts(sniffTimes, timeEdges);
        sniffRate = sniffCounts / windowSize;

        [rampSpikeCount] = histcounts(spikeTimes, [-windowSize 0]);
        [rampSniffCount] = histcounts(sniffTimes, [-windowSize 0]);

        % Separate rates into included and excluded
        excludedSpikeRates = [excludedSpikeRates, rampSpikeCount./windowSize];
        excludedSniffRates = [excludedSniffRates, rampSniffCount./windowSize];
        
        
        spikeRates = [spikeRates, spikeRate];
        sniffRates = [sniffRates, sniffRate];
    end
    
    %Regression model to predict spike rate
    [predictedSpikeRate] = regressionAnalysis(sniffRates, spikeRates, excludedSniffRates);
    close;
    
    %Compute th change between actual and predicted
    changeBetweenActualAndPredicted = (mean((excludedSpikeRates' - predictedSpikeRate)./predictedSpikeRate)).*100;
end



function [r, z_sniff_psth] = computeSniff_psth_corr(sniffRaster, neuralRaster, kernelSize, timeWindow)
r = [];

evokedSniffRate = computeEvokedFiringRate(sniffRaster, [-4 -3], timeWindow);
evokedFiringRate = computeEvokedFiringRate(neuralRaster, [-4 -3], timeWindow);
[r,~] = corr(evokedSniffRate', evokedFiringRate');


%Compute the psth
[r_neu,t_neu] = mypsth(neuralRaster, kernelSize, 'n');
[r_sniff,t_sniff] = mypsth(sniffRaster, kernelSize, 'n');

sniffBGrate = computeBaselineFiringRate(sniffRaster, [-4 -3]);

% Cut it to the requested time
numberOfPoints_sniff = [find(t_sniff > timeWindow(1),1):find(t_sniff > timeWindow(1),1)+ceil(diff(timeWindow)/mean(diff(t_sniff)))];
numberOfPoints_neural = [find(t_neu > timeWindow(1),1):find(t_neu > timeWindow(1),1)+ceil(diff(timeWindow)/mean(diff(t_neu)))];
% startingValue_sniff = find(t_sniff >= timeWindow(1),1);
% startingValue_neu = find(t_neu >= timeWindow(1),1);

if numberOfPoints_sniff(end) < length(r_sniff) & numberOfPoints_neural(end) < length(r_neu)
    
    currSniff = r_sniff(numberOfPoints_sniff);
    currNeu = r_neu(numberOfPoints_neural);
    
    %Correlate
    if ~isempty(currSniff) & ~isempty(currNeu)
%         [r,~] = corr(currSniff', currNeu');
        
        z_sniff_psth = (currSniff - mean(sniffBGrate))./std(sniffBGrate);
    end
end



end

function plotMeanSEM(data, color, lineStyle, time)

    if nargin < 4
        time = 1:size(data, 2);
    end
    
    if nargin < 3
        lineStyle = '-';
    end
    % Check if data input is valid
    if isempty(data) || size(data, 1) < 2
        error('Input data matrix must have at least two rows (neurons) and one column (time).');
    end

    % Calculate mean and SEM across neurons (rows)
    meanValues = mean(data, 1);
    SEM = std(data, 0, 1) / sqrt(size(data, 1));

    % Create x-axis time points based on data size
%     time = 1:size(data, 2);

    % Plot mean and SEM as shaded area
    fill([time, fliplr(time)], ...
         [meanValues + SEM, fliplr(meanValues - SEM)], ...
         color, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on;

    % Plot mean line
    plot(time, meanValues, 'Color', color, 'LineWidth', 2, 'LineStyle', lineStyle);
    
    % Label the axes
    xlabel('Time (sec)');
    ylabel('Z-score');box off;set(gca, 'FontSize', 18);
    
    

    
%     hold off;
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

function [z_psth_high, z_psth_low] = rampingBySessions(rampingSessions, rampingNeurons, rampingSessionsInds, requestedSessions, psthTime)
    
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

    % Find the rasters of the ramping neurons
    high_rasters = rampingNeurons(1).high_rasters(rampingSessionsInds);
    low_rasters = rampingNeurons(1).low_rasters(rampingSessionsInds);
    
    % Find sessions numbers
    for ind = 1:size(rampingSessions,2)
        rampSess(ind) = rampingSessions(ind).recs.sessionNum;
    end
    
    %Find the requested sessions
    currSessions = [];
    for ind = 1:length(requestedSessions)
        currSessions = [currSessions find(rampSess==requestedSessions(ind))];
    end
    
    [z_psth_high, cutTime] = computeZscoreRamp_PSTH(currSessions, high_rasters, psthTime);
    [z_psth_low] = computeZscoreRamp_PSTH(currSessions, low_rasters, psthTime);
    
    
%     figure
    plotMeanSEM(z_psth_high, highProbColor, '-', cutTime)
    hold on
    plotMeanSEM(z_psth_low, lowProbColor, '-', cutTime)
    
end

function [z_psth, cutTime] = computeZscoreRamp_PSTH(currSessions, rasters, psthTime)
z_psth = [];
kernelSize = 0.1;

%z-score each PSTH
for sessInd = 1:length(currSessions)
    currRasters = rasters{currSessions(sessInd)};
    
    %Compute the psth
    [r_neu,t_neu] = mypsth(currRasters, kernelSize, 'n');
    
    %Cut
    numberOfPoints = [find(t_neu > psthTime(1),1):find(t_neu > psthTime(1),1)+ceil(diff(psthTime)/mean(diff(t_neu)))];
    cutPSTH = r_neu(numberOfPoints);
    cutTime = t_neu(numberOfPoints);
    
    %Z-score
    sniffBGrate = computeBaselineFiringRate(currRasters, [-4 -3]);
    z_psth(end+1,:) = (cutPSTH - mean(sniffBGrate))./std(sniffBGrate);
end
end

function plotRasterScatter(data, color)
    % Check if input data is valid
    if isempty(data) || ~isstruct(data) || ~isfield(data, 'times')
        error('Input must be a non-empty structure array with a field named "times".');
    end

    % Validate the color input
    if ~isvector(color) || length(color) ~= 3 || any(color < 0) || any(color > 1)
        error('Color must be a 1x3 RGB vector with values between 0 and 1.');
    end

    % Number of trials
    numTrials = length(data);

    % Initialize figure

    hold on;

    % Loop through each trial to plot spike times
    for i = 1:numTrials
        % Get spike times for the current trial
        spikeTimes = data(i).times;
        
        % Plot spike times as scatter points with specified color
        scatter(spikeTimes, i * ones(size(spikeTimes)), 20, color, 'filled');
    end

    % Set plot limits and labels
    ylim([0, numTrials + 1]);
    xlabel('Time (s)');
    ylabel('Trial');
%     title('Raster Plot (Scatter)');
    set(gca, 'YDir', 'reverse');  % Reverse y-axis so that the first trial is at the top

    hold off;
    axis off
end

function [] = plot_ramping_example(rampingNeurons, neuronNum)

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green


figure
subplot(4,1,1)
plotRasterScatter(rampingNeurons(1).high_rasters{neuronNum}, highProbColor)
subplot(4,1,2)
plotRasterScatter(rampingNeurons(1).low_rasters{neuronNum}, lowProbColor)

subplot(4,1,3:4)
mypsth(rampingNeurons(1).high_rasters{neuronNum}, .1, highProbColor);
hold on
mypsth(rampingNeurons(1).low_rasters{neuronNum}, .1, lowProbColor);
xlabel('TIme (sec)');ylabel('Firing rate (Hz)');
box off;set(gca, 'FontSize', 18);
end

function [] = ramping_for_cs_plus_minus(rampingNeurons, rampingSessionsInds, timeWin)

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

%----- HIGH -----
high_cs_plus = rampingNeurons(1).high_CS_plus_Raster(rampingSessionsInds);
high_cs_minus = rampingNeurons(1).high_CS_minus_Raster(rampingSessionsInds);

[z_high_cs_plus, psthTime] = computeZscoreRamp_PSTH(1:length(high_cs_plus), high_cs_plus, timeWin);
[z_high_cs_minus] = computeZscoreRamp_PSTH(1:length(high_cs_minus), high_cs_minus, timeWin);

%----- LOW -----
low_cs_plus = rampingNeurons(1).low_CS_plus_Raster(rampingSessionsInds);
low_cs_minus = rampingNeurons(1).low_CS_minus_Raster(rampingSessionsInds);

[z_low_cs_plus] = computeZscoreRamp_PSTH(1:length(low_cs_plus), low_cs_plus, timeWin);
[z_low_cs_minus] = computeZscoreRamp_PSTH(1:length(low_cs_minus), low_cs_minus, timeWin);


plotMeanSEM(z_high_cs_plus, highProbColor, '-', psthTime)
hold all;
plotMeanSEM(z_high_cs_minus, highProbColor, '--', psthTime)

plotMeanSEM(z_low_cs_plus, lowProbColor, '-', psthTime)

plotMeanSEM(z_low_cs_minus, lowProbColor, '--', psthTime)
end

function [low_respondingNeurons, high_respondingNeurons] = responsesToPredictingOdors(rampingNeurons, rampingSessionsInds, pValue)

    high_rasters = rampingNeurons(1).high_rasters(rampingSessionsInds);
    low_rasters = rampingNeurons(1).low_rasters(rampingSessionsInds);
    
    
    for ind = 1:length(rampingSessionsInds)
        
        %------HIGH
        currHigh = high_rasters{ind};
        bg_high = computeBaselineFiringRate(currHigh, [-4 -3]);
        fg_high = computeBaselineFiringRate(currHigh, [-2 -1]);
        
        [h,~] = ttest(bg_high, fg_high, 'Alpha', pValue);
        
        evokedResponse_high(ind) = mean(fg_high-mean(bg_high));
        responsesVec_high(ind) = h;
        
        %-----LOW
        currLow = low_rasters{ind};
        bg_low = computeBaselineFiringRate(currLow, [-4 -3]);
        fg_low = computeBaselineFiringRate(currLow, [-2 -1]);
        
        [h,~] = ttest(bg_low, fg_low);
        
        evokedResponse_low(ind) = mean(fg_low-mean(bg_low));
        responsesVec_low(ind) = h;
    end
    
    totalResponses = responsesVec_low+responsesVec_high;
    
    labels = {'No response','Response to one odor','response to both odors'};
    figure;
    subplot(2,1,1)
    pie([length(find(totalResponses==0)) length(find(totalResponses==1)) length(find(totalResponses==2))], labels)
    
    low_respondingNeurons = evokedResponse_low(find(totalResponses > 0));
    high_respondingNeurons = evokedResponse_high(find(totalResponses > 0));
end


function plotGroupedFiringRates(sessions, firingRateMatrix, k)
    % Default grouping parameter
    if nargin < 3
        k = 2; % Default to grouping every 2 sessions
    end

    % Validate input
    if length(sessions) ~= size(firingRateMatrix, 1)
        error('The number of sessions must match the number of rows in firingRateMatrix.');
    end
    
    % Define colors for conditions H and L
    colorH = [0, 169, 137] / 255;
    colorL = [171, 62, 143] / 255;
    
    % Get unique session numbers
    uniqueSessions = unique(sessions);
    
    % Find sessions up to 11, then group the rest into one bin
    sessionCutoff = 12;
    sessionsToGroup = uniqueSessions(uniqueSessions < sessionCutoff);
    numGroups = ceil((length(sessionsToGroup) - 1) / k) + 1; % +1 for the first session separately
    
    % Initialize arrays for means, SEMs, and p-values
    meanFR_H = zeros(numGroups + 1, 1);
    meanFR_L = zeros(numGroups + 1, 1);
    semFR_H = zeros(numGroups + 1, 1);
    semFR_L = zeros(numGroups + 1, 1);
    pValues = zeros(numGroups + 1, 1); % Store p-values for statistical significance
    groupLabels = cell(numGroups + 1, 1);

    % Process the first session separately
    firstSessionIdx = sessions == 1;%uniqueSessions(1);
    if sum(firstSessionIdx) == 0
        sessionsToGroup = [1 sessionsToGroup];
    end
        
    condHData = firingRateMatrix(firstSessionIdx, 1);
    condLData = firingRateMatrix(firstSessionIdx, 2);
    
    meanFR_H(1) = mean(condHData);
    semFR_H(1) = std(condHData) / sqrt(length(condHData));
    meanFR_L(1) = mean(condLData);
    semFR_L(1) = std(condLData) / sqrt(length(condLData));
    [~, pValues(1)] = ttest(condHData, condLData); % Paired t-test for first session
    groupLabels{1} = sprintf('%d', 1);%uniqueSessions(1));
    
    % Process remaining sessions in groups of k up to session 11
    groupIdx = 2;
    for i = 2:k:length(sessionsToGroup)
        if i + k - 1 <= length(sessionsToGroup)
            sessionRange = sessionsToGroup(i:i + k - 1);
        else
            sessionRange = sessionsToGroup(i:end); % Last group may have fewer than k sessions
        end
        
        sessionIdx = ismember(sessions, sessionRange);
        
        % Condition H
        condHData = firingRateMatrix(sessionIdx, 1);
        meanFR_H(groupIdx) = nanmean(condHData);
        semFR_H(groupIdx) = std(condHData) / sqrt(length(condHData));
        
        % Condition L
        condLData = firingRateMatrix(sessionIdx, 2);
        meanFR_L(groupIdx) = nanmean(condLData);
        semFR_L(groupIdx) = std(condLData) / sqrt(length(condLData));
        
        % Paired t-test
        [~, pValues(groupIdx)] = ttest(condHData, condLData);
        
        % Set group label
        groupLabels{groupIdx} = sprintf('%d-%d', sessionRange(1), sessionRange(end));
        groupIdx = groupIdx + 1;
    end
    
    % Group sessions >= sessionCutoff into one bin
    sessionIdx = sessions >= sessionCutoff;
    condHData = firingRateMatrix(sessionIdx, 1);
    condLData = firingRateMatrix(sessionIdx, 2);
    
    meanFR_H(groupIdx) = mean(condHData);
    semFR_H(groupIdx) = std(condHData) / sqrt(length(condHData));
    meanFR_L(groupIdx) = mean(condLData);
    semFR_L(groupIdx) = std(condLData) / sqrt(length(condLData));
    [~, pValues(groupIdx)] = ttest(condHData, condLData);
    groupLabels{groupIdx} = '>12';

    meanFR_H(isnan(meanFR_H)) = 0; semFR_H(isnan(semFR_H)) = 0;
    meanFR_L(isnan(meanFR_L)) = 0;semFR_L(isnan(semFR_L)) = 0;
    % Plotting
    figure;
    hold on;
    
    % Define x-axis
    x = 1:(numGroups + 1);
    
    % Plot H with shaded SEM
    fill([x, fliplr(x)], ...
         [meanFR_H + semFR_H; flipud(meanFR_H - semFR_H)], ...
         colorH, 'FaceAlpha', 0.2, 'EdgeColor', 'none'); % Shaded area for H
    plot(x, meanFR_H, '-o', 'Color', colorH, 'DisplayName', 'H', 'LineWidth', 1.5);
    
    % Plot L with shaded SEM
    fill([x, fliplr(x)], ...
         [meanFR_L + semFR_L; flipud(meanFR_L - semFR_L)], ...
         colorL, 'FaceAlpha', 0.2, 'EdgeColor', 'none'); % Shaded area for L
    plot(x, meanFR_L, '-o', 'Color', colorL, 'DisplayName', 'L', 'LineWidth', 1.5);
    
    % Formatting
    xlabel('Sessions');
    ylabel('Firing Rate (Z-score)');
    title('Mean Firing Rate � 1 SEM for Conditions H and L');
    set(gca, 'XTick', 1:(numGroups + 1), 'XTickLabel', groupLabels, 'XTickLabelRotation', 45);
    legend('show');
    
    % Annotate plot with significance stars
    for j = 1:(numGroups + 1)
        if pValues(j) < 0.001
            text(j, max(meanFR_H(j) + semFR_H(j), meanFR_L(j) + semFR_L(j)) * 1.05, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');
        
        elseif pValues(j) < 0.01
            text(j, max(meanFR_H(j) + semFR_H(j), meanFR_L(j) + semFR_L(j)) * 1.05, '**', 'FontSize', 18, 'HorizontalAlignment', 'center');
       
        elseif pValues(j) < 0.05
            text(j, max(meanFR_H(j) + semFR_H(j), meanFR_L(j) + semFR_L(j)) * 1.05, '***', 'FontSize', 18, 'HorizontalAlignment', 'center');
        end
    end
    hold off;set(gca, 'FontSize', 18);box off;
end

function evokedFR = computeEvokedFiringRate(data, baselinePeriod, fgPeriod)
    % Ensure baselinePeriod and fgPeriod are 2-element vectors
    if length(baselinePeriod) ~= 2 || length(fgPeriod) ~= 2
        error('Both baselinePeriod and fgPeriod must be 2-element vectors specifying the start and end of the period in seconds.');
    end

    % Calculate the durations of the baseline and fg periods
    baselineDuration = abs(diff(baselinePeriod));
    fgDuration = abs(diff(fgPeriod));

    % Initialize evoked firing rate vector
    numTrials = length(data);
    evokedFR = zeros(1, numTrials);

    % Loop through each trial
    for i = 1:numTrials
        % Extract spike times for the current trial
        spikeTimes = data(i).times;

        % Count spikes within the baseline period
        numBaselineSpikes = sum(spikeTimes >= baselinePeriod(1) & spikeTimes <= baselinePeriod(2));

        % Count spikes within the fg period
        numFgSpikes = sum(spikeTimes >= fgPeriod(1) & spikeTimes <= fgPeriod(2));

        % Compute firing rates
        baselineFR = numBaselineSpikes / baselineDuration;
        fgFR = numFgSpikes / fgDuration;

        % Compute evoked firing rate
        evokedFR(i) = fgFR - baselineFR;
    end
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

function [] = plot_ramping_vs_success_rate(z_score_ramping_mat, SR)

% SR_bins = .5:.1:1;
SR_bins = [.5 .7 1];

for ind = 1:length(SR_bins)-1
    
    currPerformance = find(SR >= SR_bins(ind) & SR < SR_bins(ind+1));
    currRamping = z_score_ramping_mat(currPerformance,:);
    if size(currRamping,1) == 1 
        currMeanRamping(:,ind) = currRamping;
        currMeanSE(:,ind) = zeros(1,2);
    else
        currMeanRamping(:,ind) = mean(z_score_ramping_mat(currPerformance,:))';
        currMeanSE(:,ind) = (std(z_score_ramping_mat(currPerformance,:))./sqrt(length(currPerformance)))';
         %stat
        [~,pRTperSRbin(ind)] = ttest(z_score_ramping_mat(currPerformance,1), z_score_ramping_mat(currPerformance,2));
    end
    
   
    N_per_bin(ind) = length(currPerformance);
    
    performanceLabels{ind} = sprintf('%d-%d', SR_bins(ind).*100, SR_bins(ind+1).*100);
    
end

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

figure;
errorbar(1:length(SR_bins)-1, currMeanRamping(1,:), currMeanSE(1,:), '-o', 'DisplayName', 'H', 'LineWidth', 1.5, 'Color', highProbColor);
hold all
errorbar(1:length(SR_bins)-1, currMeanRamping(2,:), currMeanSE(2,:), '-o', 'DisplayName', 'L', 'LineWidth', 1.5, 'Color', lowProbColor);
xlabel('Perfromance (%)');
ylabel('Firing rate (Z-score)');
set(gca, 'XTick', 1:length(SR_bins), 'XTickLabel', performanceLabels, 'XTickLabelRotation', 45);
legend('show');


% Annotate plot with significance stars
for j = 1:length(pRTperSRbin)
    if pRTperSRbin(j) < 0.001
        text(j, max(currMeanRamping(1,j) + currMeanSE(1,j), currMeanRamping(2,j) + currMeanSE(2,j)) * 1.05, '* * *', 'FontSize', 18, 'HorizontalAlignment', 'center');
    elseif pRTperSRbin(j) < 0.01
        text(j, max(currMeanRamping(1,j) + currMeanSE(1,j), currMeanRamping(2,j) + currMeanSE(2,j)) * 1.05, '* *', 'FontSize', 18, 'HorizontalAlignment', 'center');
    elseif pRTperSRbin(j) < 0.05
        text(j, max(currMeanRamping(1,j) + currMeanSE(1,j), currMeanRamping(2,j) + currMeanSE(2,j)) * 1.05, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    
end
hold off;set(gca, 'FontSize', 18);box off;
end

function plot_response_rate(responding, total)
    % Check input validity
    if length(responding) ~= 3 || length(total) ~= 3
        error('Input vectors must have exactly three elements.');
    end
    
    % Compute response rates and SEM
    response_rate = responding ./ total;
    sem = sqrt((response_rate .* (1 - response_rate)) ./ total);

    % Bar plot
    figure;
    hold on;
    bar_handle = bar(response_rate, 'FaceColor', 'flat');
    errorbar(1:3, response_rate, sem, 'k', 'linestyle', 'none', 'linewidth', 1.5);

    % Formatting
    xticklabels({'Condition 1', 'Condition 2', 'Condition 3'});
    ylabel('Response Rate');
    ylim([0 1]);
    set(gca, 'FontSize', 14);
    box off;

    % Perform pairwise statistical comparisons
    comparisons = nchoosek(1:3, 2);
    p_values = zeros(size(comparisons, 1), 1);
    y_max = max(response_rate + sem) * 1.1;

    for i = 1:size(comparisons, 1)
        idx1 = comparisons(i, 1);
        idx2 = comparisons(i, 2);
        
        % Two-sample proportion test
        p_values(i) = prop_test([responding(idx1), responding(idx2)], [total(idx1), total(idx2)]);
        
        % Plot significance lines
        if p_values(i) < 0.05
            x = comparisons(i, :);
            y = y_max + (i * 0.05);
            plot(x, [y y], '-k', 'LineWidth', 1.5);
            text(mean(x), y + 0.02, significance_marker(p_values(i)), 'HorizontalAlignment', 'center', 'FontSize', 14);
        end
    end

    hold off;
end

function p = prop_test(x, n)
    % Two-sample proportion test using normal approximation
    p1 = x(1) / n(1);
    p2 = x(2) / n(2);
    p_combined = (x(1) + x(2)) / (n(1) + n(2));
    se = sqrt(p_combined * (1 - p_combined) * (1/n(1) + 1/n(2)));
    
    % Compute z-score and p-value
    z = (p1 - p2) / se;
    p = 2 * (1 - normcdf(abs(z))); % Two-tailed test
end

function marker = significance_marker(p)
    % Returns the appropriate significance marker
    if p < 0.001
        marker = '***';
    elseif p < 0.01
        marker = '**';
    elseif p < 0.05
        marker = '*';
    else
        marker = 'n.s.';
    end
end
