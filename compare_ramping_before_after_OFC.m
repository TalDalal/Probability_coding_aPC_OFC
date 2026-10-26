function [] = compare_ramping_before_after_OFC(allMiceData, allMiceData_OFC_SILENCING, fgPeriod, bgPeriod)
%% Analyze and detect ramping neurons
[rampingNeurons] = psth_delay_modulated_neurons(allMiceData, fgPeriod, bgPeriod, [-2 0], 'allTrials', 2);
rampingSessionsInds = find(rampingNeurons(1).allDelayActiveNeurons > 0);

[rampingNeurons_OFC] = psth_delay_modulated_neurons(allMiceData_OFC_SILENCING, fgPeriod, bgPeriod, [-2 0], 'allTrials', 2);
rampingSessionsInds_OFC = find(rampingNeurons_OFC(1).allDelayActiveNeurons > 0);

close all

%% Ramping %
[modulatedNeurons_control] = taskModulatedNeurons(allMiceData, 0.01, [-2 -1; -.33 0 ; 0 1], [-4 -3]);
taskModulated_control = length(find(sum(abs(modulatedNeurons_control),2) >0));

[modulatedNeurons_ofc] = taskModulatedNeurons(allMiceData_OFC_SILENCING, 0.01, [-2 -1; -.33 0 ; 0 1], [-4 -3]);
taskModulated_ofc = length(find(sum(abs(modulatedNeurons_ofc),2) >0));


%% Firing rate
%control
Z_evokedRamping_High_control = rampingNeurons(1).Z_evokedRamping_High_vec(rampingSessionsInds);
Z_evokedRamping_Low_control = rampingNeurons(1).Z_evokedRamping_Low_vec(rampingSessionsInds);

[~,p_h_vs_l_control] = ttest(Z_evokedRamping_High_control, Z_evokedRamping_Low_control);

H_L_SE = std([Z_evokedRamping_High_control' Z_evokedRamping_Low_control'])./sqrt(length(Z_evokedRamping_High_control));
H_L_mean = mean([Z_evokedRamping_High_control' Z_evokedRamping_Low_control']);

%OFC
Z_evokedRamping_High_OFC = rampingNeurons_OFC(1).Z_evokedRamping_High_vec(rampingSessionsInds_OFC);
Z_evokedRamping_Low_OFC = rampingNeurons_OFC(1).Z_evokedRamping_Low_vec(rampingSessionsInds_OFC);

[~,p_h_vs_l_ofc] = ttest(Z_evokedRamping_High_OFC, Z_evokedRamping_Low_OFC);

H_L_OFC_SE = std([Z_evokedRamping_High_OFC' Z_evokedRamping_Low_OFC'])./sqrt(length(Z_evokedRamping_High_OFC));
H_L_OFC_mean = mean([Z_evokedRamping_High_OFC' Z_evokedRamping_Low_OFC']);

%% plot
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green


figure;
subplot(1,2,1)
responseRate_control = length(rampingSessionsInds_OFC)./taskModulated_control;
responseRate_ofc = length(rampingSessionsInds)./taskModulated_ofc;
plot_neuron_response_rate(responseRate_ofc, taskModulated_ofc, responseRate_control, taskModulated_control)


plotData{1} = Z_evokedRamping_High_control;plotData{2} = Z_evokedRamping_Low_control;
plotData{3} = Z_evokedRamping_High_OFC;plotData{4} = Z_evokedRamping_Low_OFC;

subplot(1,2,2)
categories = {'Control - H','Control - L', 'OFC suppression - H' , 'OFC suppression - L'};
colors = [highProbColor;lowProbColor ; highProbColor;lowProbColor];
violinplot_with_mean_single_side(plotData, categories, colors, 0, 0)
hold all;
plot(1:2, [Z_evokedRamping_High_control ; Z_evokedRamping_Low_control], 'Color', [.5 .5 .5])
plot(3:4, [Z_evokedRamping_High_OFC ; Z_evokedRamping_Low_OFC], 'Color', [.5 .5 .5])

% barwitherr([H_L_SE(1) H_L_SE(2) H_L_OFC_SE(1) H_L_OFC_SE(2)], [H_L_mean(1) H_L_mean(2) H_L_OFC_mean(1) H_L_OFC_mean(2)]);
set(gca, 'FontSize', 18);box off;
ylabel('Z-score'); %set(gca, 'XTickLabel', {'H', 'L' 'H - OFC suppressed', 'L - OFC suppressed'})
title(['P control = ' num2str(p_h_vs_l_control) '; P OFC suppression = ' num2str(p_h_vs_l_ofc)])


end
% Script to compare and visualize response rates between two conditions

function plot_neuron_response_rate(rate1, n1, rate2, n2)
    % Inputs:
    %   rate1 - rate of responding neurons in condition 1 (proportion)
    %   n1 - total number of neurons in condition 1
    %   rate2 - rate of responding neurons in condition 2 (proportion)
    %   n2 - total number of neurons in condition 2

    % Calculate percentages and standard errors
    perc1 = rate1 * 100; % Convert proportion to percentage
    perc2 = rate2 * 100;
    se1 = sqrt(rate1 * (1 - rate1) / n1) * 100; % Binomial SE
    se2 = sqrt(rate2 * (1 - rate2) / n2) * 100;

    % Perform two-sample proportion test
    p = prop_test([rate1 * n1, rate2 * n2], [n1, n2]);

    % Plot
%     figure;
    hold on;
    bar(1, perc1, 'FaceColor', [0.2, 0.6, 0.8]);
    bar(2, perc2, 'FaceColor', [0.8, 0.4, 0.4]);
    errorbar([1, 2], [perc1, perc2], [se1, se2], 'k.', 'LineWidth', 1.5);

    % Add significance asterisk if p < 0.05
    if p < 0.05
        plot([1, 2], [max(perc1 + se1, perc2 + se2) + 2, max(perc1 + se1, perc2 + se2) + 2], 'k-', 'LineWidth', 1.5);
        text(1.5, max(perc1 + se1, perc2 + se2) + 3, '*', 'FontSize', 14, 'HorizontalAlignment', 'center');
    end

    % Customize plot
    set(gca, 'XTick', [1, 2], 'XTickLabel', {'Condition 1', 'Condition 2'}, 'FontSize', 12);
    ylabel('Ramping Neurons (%)', 'FontSize', 14);
    ylim([0, max(perc1 + se1, perc2 + se2) + 10]);
    title('Response Rates with Binomial SE', 'FontSize', 16);
    box on;
    hold off;

    % Display p-value in the command window
    fprintf('p-value from two-sample proportion test: %.4f\n', p);
end

function p = prop_test(successes, totals)
    % Perform a two-sample proportion test
    % successes: vector of successes for each group
    % totals: vector of total counts for each group

    p1 = successes(1) / totals(1);
    p2 = successes(2) / totals(2);
    pooled_p = sum(successes) / sum(totals);
    se = sqrt(pooled_p * (1 - pooled_p) * (1/totals(1) + 1/totals(2)));
    z = (p1 - p2) / se;
    p = 2 * (1 - normcdf(abs(z))); % Two-tailed test
end


