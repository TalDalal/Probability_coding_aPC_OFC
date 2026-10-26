function [] = detect_context_modulated_neurons(allMiceData, fgPeriod, bgPeriod)
%% Params
winSize = .3;
smoothKernel = 0.05;
bgPeriod = [-4 -3];
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green
globalWindow = [0 1];
CSplusColor = [154, 52, 52]./255;
CSminusColor = [154, 103, 51]./255;
c = 0;CSminusResponse_count = 0;CSplusResponse_count = 0;countBoth_CSplus_minus_response = 0;

%% init

CSplus_struct.H_larger_CS_plus = [];CSplus_struct.H_smaller_CS_plus = [];
CSplus_struct.H_larger_CS_minus = [];CSplus_struct.H_smaller_CS_minus = [];

CSplus_struct.H_larger_CS_plus_fr = [];CSplus_struct.H_smaller_CS_plus_fr = [];
CSplus_struct.H_larger_CS_minus_fr = [];CSplus_struct.H_smaller_CS_minus_fr = [];
CSplus_struct.H_larger_CS_plus_fr_SENSORY = [];CSplus_struct.H_smaller_CS_plus_fr_SENSORY = [];
CSplus_struct.H_larger_CS_minus_fr_SENSORY = [];CSplus_struct.H_smaller_CS_minus_fr_SENSORY = [];

CSminus_struct = CSplus_struct;

countBothOdorsModulationByProb = [];

%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    mouseData = allMiceData(miceInd).allRecs;
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        params = mouseData(recInd).data;
        
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                [CSplus_struct] = check_context_modulation(unitInd, params, fgPeriod,bgPeriod, 'CS+', CSplus_struct);
                %------------------CS- ---------------
                [CSplus_struct] = check_context_modulation(unitInd, params, fgPeriod,bgPeriod, 'CS-', CSminus_struct);
                
                if validCSplusResponse & validCSminusResponse
                    countBoth_CSplus_minus_response = countBoth_CSplus_minus_response + 1;
                    if h_fr_CSplus & h_fr_CSminus
                        countBothOdorsModulationByProb(end+1) = 1;
                    end
                end
                
                
                
                modulatedResponse_CSplus(c) = h_fr_CSplus;
                modulatedResponse_CSminus(c) = h_fr_CSminus;
                
                
            end
        end
    end
end
% General Modulation
movingResponse_CSplus = 100.*(nansum(modulatedResponse_CSplus)./length(modulatedResponse_CSplus));
movingResponse_CSminus = 100.*(nansum(modulatedResponse_CSminus)./length(modulatedResponse_CSminus));

%Modulation to cS+ H>L or H<L
moving_H_larger_CSplus = 100.*(nansum(H_larger_CS_plus))./CSplusResponse_count;
moving_H_smaller_CSplus = 100.*(nansum(H_smaller_CS_plus))./CSplusResponse_count;

%Modulation to cS- H>L or H<L
moving_H_larger_CSminus = 100.*(nansum(H_larger_CS_minus))./CSminusResponse_count;
moving_H_smaller_CSminus = 100.*(nansum(H_smaller_CS_minus))./CSminusResponse_count;

% % responding to CS+\-
movingCSplus_response_count = (CSplusResponse_count./length(modulatedResponse_CSplus)).*100;
movingCSminus_response_count = (CSminusResponse_count./length(modulatedResponse_CSplus)).*100;

modulatedResponse_CSminus = [];modulatedResponse_CSplus = [];


%% plot the % response over the stimulus duration
figure;
bar([moving_H_larger_CSplus moving_H_smaller_CSplus ; moving_H_larger_CSminus moving_H_smaller_CSminus], 'stacked')
set(gca, 'XTickLabel', {'CS+', 'CS-'});ylabel('% neurons modulated by probability');set(gca, 'FontSize', 18);box off;

% stat - modulated units vs alpha
[pCSplus_proportionModulated] = oneSampleProportionTest([moving_H_larger_CSplus + moving_H_smaller_CSplus]./100, 0.05, CSplusResponse_count)
[pCSminus_proportionModulated] = oneSampleProportionTest([moving_H_larger_CSminus + moving_H_smaller_CSminus]./100, 0.05, CSminusResponse_count)

% stat - modulated units rate by probability
[p_H_L_CSplus] = twoSampleProportionTest(moving_H_larger_CSplus./100, moving_H_smaller_CSplus./100, CSplusResponse_count, CSplusResponse_count)
[p_H_L_CSminus] = twoSampleProportionTest(moving_H_larger_CSminus./100, moving_H_smaller_CSminus./100, CSminusResponse_count, CSminusResponse_count)

%% Firing rate plot
figure;
subplot(1,2,1)
violinplot_with_mean_single_side({H_larger_CS_plus_fr(:,1), H_larger_CS_plus_fr(:,2), H_smaller_CS_plus_fr(:,1), H_smaller_CS_plus_fr(:,2)}, ...
    {'H', 'L','H', 'L'}, [highProbColor; lowProbColor;highProbColor; lowProbColor], 0, 0)
title('CS+, H > L (left), H < L (right)')
ylabel('Evoked firing rate (Hz)')
hold all
plot([1:2], H_larger_CS_plus_fr(:,1:2), '-ok')
plot([3:4], H_smaller_CS_plus_fr(:,1:2), '-ok');

subplot(1,2,2)
violinplot_with_mean_single_side({H_larger_CS_minus_fr(:,1), H_larger_CS_minus_fr(:,2), H_smaller_CS_minus_fr(:,1), H_smaller_CS_minus_fr(:,2)}, ...
    {'H', 'L','H', 'L'}, [highProbColor; lowProbColor;highProbColor; lowProbColor], 0, 0)
title('CS-, H > L (left), H < L (right)')
ylabel('Evoked firing rate (Hz)')
hold all
plot([1:2], H_larger_CS_minus_fr(:,1:2), '-ok')
plot([3:4], H_smaller_CS_minus_fr(:,1:2), '-ok');

%CS+
[~,p_H_CSplus] = ttest2(H_larger_CS_plus_fr(:,1), H_smaller_CS_plus_fr(:,1));
[~,p_L_CSplus] = ttest2(H_larger_CS_plus_fr(:,2), H_smaller_CS_plus_fr(:,2));

%CS-
[~,p_H_CSminus] = ttest2(H_larger_CS_minus_fr(:,1), H_smaller_CS_minus_fr(:,1));
[~,p_L_CSminus] = ttest2(H_larger_CS_minus_fr(:,2), H_smaller_CS_minus_fr(:,2));
%% proportion of modulation within each odor
%CS+
% totalPercentModulated_CSplus = moving_H_larger_CSplus+moving_H_smaller_CSplus;
%
% percent_H_larger_CSplus = (moving_H_larger_CSplus./totalPercentModulated_CSplus).*100;
% percent_H_smaller_CSplus = (moving_H_smaller_CSplus./totalPercentModulated_CSplus).*100;
figure
plot_modulated_neurons([size(H_larger_CS_plus_fr,1) size(H_smaller_CS_plus_fr,1)] , [size(H_larger_CS_minus_fr,1) size(H_smaller_CS_minus_fr,1)])
title('PE neurons')
figure
plot_modulated_neurons([size(H_larger_CS_plus_fr_SENSORY,1) size(H_smaller_CS_plus_fr_SENSORY,1)] , [size(H_larger_CS_minus_fr_SENSORY,1) size(H_smaller_CS_minus_fr_SENSORY,1)])
title('Sensory')

outputData.H_larger_CS_plus_fr = H_larger_CS_plus_fr;
outputData.H_smaller_CS_plus_fr = H_smaller_CS_plus_fr;

outputData.H_larger_CS_minus_fr = H_larger_CS_minus_fr;
outputData.H_smaller_CS_minus_fr = H_smaller_CS_minus_fr;

%-restrict the analysis to naive data
H_larger_CS_plus_fr_naive = H_larger_CS_plus_fr(find(H_larger_CS_plus_fr(:,3) < srCriterion),:);
H_smaller_CS_plus_fr_naive = H_smaller_CS_plus_fr(find(H_smaller_CS_plus_fr(:,3) < srCriterion),:);

H_larger_CS_minus_fr_naive = H_larger_CS_minus_fr(find(H_larger_CS_minus_fr(:,3) < srCriterion),:);
H_smaller_CS_minus_fr_naive = H_smaller_CS_minus_fr(find(H_smaller_CS_minus_fr(:,3) < srCriterion),:);

figure
plot_modulated_neurons([size(H_larger_CS_plus_fr_naive,1) size(H_smaller_CS_plus_fr_naive,1)] , [size(H_larger_CS_minus_fr_naive,1) size(H_smaller_CS_minus_fr_naive,1)])
title('PE neurons - NAIVE')

%% Correlation between response modulation and firing rate
figure;
subplot(1,2,1)
corr_PE_strength_firing_rate(H_larger_CS_plus_fr_SENSORY, H_smaller_CS_plus_fr_SENSORY,'CS+', CSplusColor, 0)
hold on;
corr_PE_strength_firing_rate(H_larger_CS_plus_fr, H_smaller_CS_plus_fr,'CS+', CSplusColor, 1 )

subplot(1,2,2)
corr_PE_strength_firing_rate(H_larger_CS_minus_fr_SENSORY, H_smaller_CS_minus_fr_SENSORY,'CS-', CSminusColor, 0)
hold on;
corr_PE_strength_firing_rate(H_larger_CS_minus_fr, H_smaller_CS_minus_fr,'CS-', CSminusColor, 1)

end

function [outStruct] = check_context_modulation(unitInd, params, fgPeriod,bgPeriod, stimType, outStruct)

CSResponse_count = 0;
currSessionSR = mean([params.successRate.A params.successRate.C]);
currUnitFR = params.firingRates(unitInd).firingRateByBIn;
%---- time indices----
frAnalysisIndices = find(params.firingRateAnalysisBins >= fgPeriod(1) & params.firingRateAnalysisBins <= fgPeriod(2));
fullOdorDurationAnalysisIndices = find(params.firingRateAnalysisBins >= fgPeriod(1) & params.firingRateAnalysisBins <= fgPeriod(2));
baselineDurationAnalysisIndices = find(params.firingRateAnalysisBins >= bgPeriod(1) & params.firingRateAnalysisBins <= bgPeriod(2));

%------------------CS+ or CS- ---------------
cs_response = [];
if strcmpi(stimType, 'CS+')
    Atrials = params.targetTrials.A;
    Ctrials = params.targetTrials.C;
elseif strcmpi(stimType, 'CS-')
    Atrials = params.tMinusTrials.A;
    Ctrials = params.tMinusTrials.C;
end

%test response to the odor
odorDurationFr = mean(currUnitFR([Atrials Ctrials], fullOdorDurationAnalysisIndices),2);
baselineDurationFr = mean(currUnitFR([Atrials Ctrials], baselineDurationAnalysisIndices),2);

[cs_response,~] = ttest(odorDurationFr, baselineDurationFr);
outStruct.cs_response = cs_response;
outStruct.evokedOdorResponse = mean(odorDurationFr-baselineDurationFr);

% Compare the firing rate between probabilities 
A_fr = mean(currUnitFR(Atrials, frAnalysisIndices),2);
C_fr = mean(currUnitFR(Ctrials, frAnalysisIndices),2);
[h_context_modulated] = ttest2(A_fr, C_fr);

outStruct.h_context_modulated = h_context_modulated;

validCSplusResponse = ~isnan(cs_response) & cs_response;
if validCSplusResponse
    CSResponse_count =  1;
    outStruct.CSResponse_count = CSResponse_count;
    % probability modulation test
    if ~isnan(h_context_modulated)
        %----- Sensory neurons -----
        if params.probability.A > params.probability.C & ~h_context_modulated% Sensory neuron - no modulation by prob
            if mean(A_fr) > mean(C_fr)
                outStruct.H_larger_CS_plus_fr_SENSORY(end+1,:) = [mean(A_fr) mean(C_fr)]-mean(baselineDurationFr);
            elseif mean(A_fr) < mean(C_fr)
                outStruct.H_smaller_CS_plus_fr_SENSORY(end+1,:) = [mean(A_fr) mean(C_fr)]-mean(baselineDurationFr);
            end
        elseif params.probability.A < params.probability.C & ~h_context_modulated
            if mean(A_fr) > mean(C_fr)
                outStruct.H_smaller_CS_plus_fr_SENSORY(end+1,:) = [mean(C_fr) mean(A_fr)]-mean(baselineDurationFr);
                
            elseif mean(A_fr) < mean(C_fr)
                outStruct.H_larger_CS_plus_fr_SENSORY(end+1,:) = [mean(C_fr) mean(A_fr)]-mean(baselineDurationFr);
            end
            
            %----- PE neurons -----
        elseif params.probability.A > params.probability.C & h_context_modulated
            
            
            if mean(A_fr) > mean(C_fr)
                
                outStruct.H_larger_CS_plus(end+1) = h_context_modulated;
                outStruct.H_larger_CS_plus_fr(end+1,:) = [[mean(A_fr) mean(C_fr)]-mean(baselineDurationFr) currSessionSR];
                %                                   H_larger_CS_plus_fr(end+1,:) = [[mean(A_fr) mean(C_fr)] currSessionSR];
                
            elseif mean(A_fr) < mean(C_fr)
                
                outStruct.H_smaller_CS_plus(end+1) = h_context_modulated;
                outStruct.H_smaller_CS_plus_fr(end+1,:) = [[mean(A_fr) mean(C_fr)]-mean(baselineDurationFr) currSessionSR];
                %                                 H_smaller_CS_plus_fr(end+1,:) = [[mean(A_fr) mean(C_fr)] currSessionSR];
                
            end
        elseif params.probability.A < params.probability.C & h_context_modulated
            
            
            if mean(A_fr) > mean(C_fr)
                
                outStruct.H_smaller_CS_plus(end+1) = h_context_modulated;
                outStruct.H_smaller_CS_plus_fr(end+1,:) = [[mean(C_fr) mean(A_fr)]-mean(baselineDurationFr) currSessionSR];
                %                                 H_smaller_CS_plus_fr(end+1,:) = [[mean(C_fr) mean(A_fr)] currSessionSR];
                
            elseif mean(A_fr) < mean(C_fr)
                
                outStruct.H_larger_CS_plus(end+1) = h_context_modulated;
                outStruct.H_larger_CS_plus_fr(end+1,:) = [[mean(C_fr) mean(A_fr)]-mean(baselineDurationFr) currSessionSR];
                %                                 H_larger_CS_plus_fr(end+1,:) = [[mean(C_fr) mean(A_fr)] currSessionSR];
            end
        end
    end
end

A_fr = [];C_fr = [];Araster = [];Craster = [];

end


function [] = corr_PE_strength_firing_rate(larger_fr, smaller_fr,odorType, color, plotDataPoints)

L_CS = [larger_fr(:,2) ; smaller_fr(:,2)];
H_CS = [larger_fr(:,1) ; smaller_fr(:,1)];


if strcmpi(odorType, 'CS-')
    delta_H_L_CS = (H_CS - L_CS);
    plotRegressionWithCI(H_CS, delta_H_L_CS, color, plotDataPoints, odorType)
    xlabel('Unpredicted (H) evoked firing rate (Hz)');ylabel('Unpredicted (H) - predicted (L) evoked firing rate (Hz)');
elseif strcmpi(odorType, 'CS+')
    delta_H_L_CS = (L_CS - H_CS);
    plotRegressionWithCI(L_CS, delta_H_L_CS, color, plotDataPoints, odorType)
    xlabel('Unpredicted (L) evoked firing rate (Hz)');ylabel('Unpredicted (L) - predicted (H) evoked firing rate (Hz)');
end

% [r_corr_csPlus,p_corr_csPlus] = corrcoef(L_CSplus, delta_H_L_CSplus);
set(gca, 'FontSize', 18);box off;

% title([num2str(odorType) ', r = ' num2str(r_corr_csPlus(2)) ', p = ' num2str(p_corr_csPlus(2))])
end

function plot_modulated_neurons(cs_plus, cs_minus)
% PLOT_MODULATED_NEURONS plots percentages of neurons from two vectors
% and connects corresponding points with lines.
%
% Inputs:
%   - cs_plus: 1x2 vector with counts of neurons for CS+.
%   - cs_minus: 1x2 vector with counts of neurons for CS-.
%
% The function computes percentages, plots them with SEM, and connects
% related points with lines.
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

% Validate inputs
if numel(cs_plus) ~= 2 || numel(cs_minus) ~= 2
    error('Both inputs must be 1x2 vectors.');
end

% Compute total neurons for each input
total_plus = sum(cs_plus);
total_minus = sum(cs_minus);

% Compute percentages
pct_plus = cs_plus / total_plus * 100;
pct_minus = cs_minus / total_minus * 100;

% Compute SEM (binomial distribution)
sem_plus = sqrt((pct_plus .* (100 - pct_plus)) / total_plus);
sem_minus = sqrt((pct_minus .* (100 - pct_minus)) / total_minus);

% Create x positions for plotting
x_positions = [1, 2];

% Plot data
%     figure;
hold on;

% Plot percentages for CS+ and CS- with SEM
errorbar(x_positions(1), pct_plus(1), sem_plus(1), 'o', 'MarkerSize', 8, ...
    'LineWidth', 1.5, 'Color', highProbColor);
errorbar(x_positions(1), pct_plus(2), sem_plus(2), 'o', 'MarkerSize', 8, ...
    'LineWidth', 1.5, 'Color', lowProbColor);

errorbar(x_positions(2), pct_minus(1), sem_minus(1), 'o', 'MarkerSize', 8, ...
    'LineWidth', 1.5, 'Color', highProbColor);
errorbar(x_positions(2), pct_minus(2), sem_minus(2), 'o', 'MarkerSize', 8, ...
    'LineWidth', 1.5, 'Color', lowProbColor);

% Connect corresponding points with lines
plot(x_positions, [pct_plus(1), pct_minus(1)], 'k--', 'LineWidth', 1.2);
plot(x_positions, [pct_plus(2), pct_minus(2)], 'k--', 'LineWidth', 1.2);

% Format plot
xlim([0.5, 2.5]);
ylim([0, 100]);
xticks(x_positions);
xticklabels({'CS+', 'CS-'});
ylabel('% of Modulated Neurons');
%     title('Neuron Percentages for Odors CS+ and CS-');
legend({'CS+ (First)', 'CS+ (Second)', 'CS- (First)', 'CS- (Second)'}, ...
    'Location', 'NorthEast');
hold off;
set(gca, 'FontSize', 18);box off;
end
function bargraph_with_data_points(matrix1, matrix2)
% bargraph_with_data_points generates a bar graph with mean and SEM for two input matrices.
% It overlays individual data points for each matrix, positioned at the center of their respective bars.
%
% INPUTS:
% - matrix1: An N1x2 matrix of data points
% - matrix2: An N2x2 matrix of data points

% Compute mean and SEM for each matrix
mean1 = mean(matrix1);
mean2 = mean(matrix2);

sem1 = std(matrix1) / sqrt(size(matrix1, 1));
sem2 = std(matrix2) / sqrt(size(matrix2, 1));

% Set up the figure
figure;
hold on;

% Plot bar graph with mean values
barMeans = [mean(mean1), mean(mean2)];
b = bar(1:2, barMeans, 'FaceColor', 'flat');
b.CData(1, :) = [0.6, 0.6, 0.6];
b.CData(2, :) = [0.3, 0.3, 0.3];

% Add SEM as error bars at the center of each bar
errorbar(1, mean(barMeans(1)), sem1(1), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
errorbar(2, mean(barMeans(2)), sem2, 'k', 'linestyle', 'none', 'LineWidth', 1.5);

% Overlay individual data points in the center of each bar
jitterAmount = 0.1; % Small horizontal jitter to spread points slightly
for i = 1:size(matrix1, 1)
    scatter(1 + jitterAmount * (rand - 0.5), mean(matrix1(i, :)), 36, 'k', 'filled');
end

for i = 1:size(matrix2, 1)
    scatter(2 + jitterAmount * (rand - 0.5), mean(matrix2(i, :)), 36, 'k', 'filled');
end

% Configure axes and labels
set(gca, 'XTick', 1:2, 'XTickLabel', {'Matrix 1', 'Matrix 2'}, 'FontSize', 12);
ylabel('Mean Value');
box off;

hold off;
end


