%% Compute the X separately for H_vs_M and H_vs_L
[H_vs_M] = modulatedCSplus_minus_response_H_vs_L_vs_M(allMiceData, [0 1], .7, 'M_vs_H');
close all
[L_vs_M] = modulatedCSplus_minus_response_H_vs_L_vs_M(allMiceData, [0 1], .7, 'M_vs_L');
close all

[H_vs_L] = modulatedCSplus_minus_response_H_vs_L(allMiceData, 'no', [0 1], .7);
close all;

numPEneurons_CSplus_25 = size(H_larger_CS_plus_fr,1) + size(H_smaller_CS_plus_fr,1);
numPEneurons_CSminus_25 = size(H_larger_CS_minus_fr,1) + size(H_smaller_CS_minus_fr,1);
 
numPEneurons_CSplus_50 = size(H_vs_L.H_larger_CS_plus_fr,1) + size(H_vs_L.H_smaller_CS_plus_fr,1);
numPEneurons_CSminus_50 = size(H_vs_L.H_larger_CS_minus_fr,1) + size(H_vs_L.H_smaller_CS_minus_fr,1);
%%
%CS+
H_larger_CS_plus_fr = [H_vs_M.H_larger_CS_plus_fr ; L_vs_M.H_larger_CS_plus_fr];
H_smaller_CS_plus_fr = [H_vs_M.H_smaller_CS_plus_fr ; L_vs_M.H_smaller_CS_plus_fr];
%CS-
H_larger_CS_minus_fr = [H_vs_M.H_larger_CS_minus_fr ; L_vs_M.H_larger_CS_minus_fr];
H_smaller_CS_minus_fr = [H_vs_M.H_smaller_CS_minus_fr ; L_vs_M.H_smaller_CS_minus_fr];

numPEneurons_CSplus = size(H_larger_CS_plus_fr,1) + size(H_smaller_CS_plus_fr,1);
numPEneurons_CSminus = size(H_larger_CS_minus_fr,1) + size(H_smaller_CS_minus_fr,1);
%%
figure
[numNeuronsPE] = plot_modulated_neurons([size(H_larger_CS_plus_fr,1) size(H_smaller_CS_plus_fr,1)] , ...
    [size(H_larger_CS_minus_fr,1) size(H_smaller_CS_minus_fr,1)], 'PE');

CSplusTotalNeurons = size(H_larger_CS_plus_fr,1) + size(H_smaller_CS_plus_fr,1);
CSminusTotalNeurons = size(H_larger_CS_minus_fr,1) + size(H_smaller_CS_minus_fr,1);

clc
twoSampleProportionTest(size(H_larger_CS_plus_fr,1)/CSplusTotalNeurons, size(H_smaller_CS_plus_fr,1)/CSplusTotalNeurons, CSplusTotalNeurons, CSplusTotalNeurons)
twoSampleProportionTest(size(H_larger_CS_minus_fr,1)/CSminusTotalNeurons, size(H_smaller_CS_minus_fr,1)/CSminusTotalNeurons, CSminusTotalNeurons, CSminusTotalNeurons)


%%
figure;
diff_25_CSplus = (size(H_smaller_CS_plus_fr,1) - size(H_larger_CS_plus_fr,1))./numPEneurons_CSplus;
diff_25_CSminus = (size(H_larger_CS_minus_fr,1) - size(H_smaller_CS_minus_fr,1))./numPEneurons_CSminus;

diff_50_CSplus = (size(H_vs_L.H_smaller_CS_plus_fr,1) - size(H_vs_L.H_larger_CS_plus_fr,1))./numPEneurons_CSplus_50;
diff_50_CSminus = (size(H_vs_L.H_larger_CS_minus_fr,1) - size(H_vs_L.H_smaller_CS_minus_fr,1))./numPEneurons_CSminus_50;

actualProbs = [.25 .50];
CSplusColor = [154,52,52]./255;
CSminusColor = [153,102,51]./255;

scatter(actualProbs, [diff_25_CSplus diff_50_CSplus], 200, 's', 'MarkerFaceColor', CSplusColor, 'MarkerEdgeColor', 'none')
hold all
scatter(actualProbs, [diff_25_CSminus diff_50_CSminus], 200, 's', 'MarkerFaceColor', CSminusColor, 'MarkerEdgeColor', 'none')
plot([0 .8], [0 .8], 'k--'); set(gca, 'FontSize', 18);box off;
xlabel('Actual probability difference between conditions');
ylabel('Difference in percentage of neurons that increase or suppress their activity when odor is predicted')
xlim([.2 .6])
ylim([.2 .6])
%% Functions
function [numNeurons] = plot_modulated_neurons(cs_plus, cs_minus, neuronsType)
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
numNeurons = total_plus + total_minus;

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
if strcmpi(neuronsType, 'PE')
    plot(x_positions, [pct_plus(1), pct_minus(1)], 'k--', 'LineWidth', 1.2);
    plot(x_positions, [pct_plus(2), pct_minus(2)], 'k--', 'LineWidth', 1.2);
end

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
