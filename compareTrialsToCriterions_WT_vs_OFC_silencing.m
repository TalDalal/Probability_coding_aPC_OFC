function [] = compareTrialsToCriterions_WT_vs_OFC_silencing(allMiceData, allMiceData_OFC_SILENCING, winSize)
%WT    
[wt] = trialToCriterionAcrossMice(allMiceData, winSize);
%OFC_silencing
[ofc_silencing] = trialToCriterionAcrossMice(allMiceData_OFC_SILENCING, winSize);

% all
plot_trials_to_criterion(wt(:,1), ofc_silencing(:,1), 'successRate')
plot_trials_to_criterion(wt(:,2), ofc_silencing(:,2), 'Hit')
plot_trials_to_criterion(wt(:,3), ofc_silencing(:,3), 'FA')

end

function plot_trials_to_criterion(data1, data2, titleString)
% plot_trials_to_criterion Plots mean ± 1 SEM bar graph with scatter points
% for two input vectors, performs an unpaired t-test, and displays the p-value.
%
% Inputs:
%   data1 - First input vector of trials to criterion (control group)
%   data2 - Second input vector of trials to criterion (OFC silencing group)

    % Calculate means and SEM
    mean1 = mean(data1, 'omitnan');
    mean2 = mean(data2, 'omitnan');
    sem1 = std(data1, 'omitnan') / sqrt(length(data1));
    sem2 = std(data2, 'omitnan') / sqrt(length(data2));

    % Bar graph with transparency
    figure;
    hold on;
    bar(1, mean1, 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.6); % Gray, transparent
    bar(2, mean2, 'FaceColor', [1 1 0], 'EdgeColor', 'none', 'FaceAlpha', 0.6); % Yellow, transparent

    % Error bars
    errorbar(1, mean1, sem1, 'k', 'LineWidth', 1.5);
    errorbar(2, mean2, sem2, 'k', 'LineWidth', 1.5);

    % Scatter points in bar colors with gray edge
    scatter(ones(size(data1)) * 1, data1, 50, 'MarkerFaceColor', [0.5 0.5 0.5], ...
        'MarkerEdgeColor', [0.8 0.8 0.8], 'jitter', 'on', 'jitterAmount', 0.1); % Control points
    scatter(ones(size(data2)) * 2, data2, 50, 'MarkerFaceColor', [1 1 0], ...
        'MarkerEdgeColor', [0.8 0.8 0.8], 'jitter', 'on', 'jitterAmount', 0.1); % OFC silencing points

    % Perform unpaired t-test
    [~, p] = ttest2(data1, data2);

    % Add asterisk if p < 0.05
    if p < 0.05
        y_max = max([mean1 + sem1, mean2 + sem2]);
        line([1, 2], [y_max + 1, y_max + 1], 'Color', 'k', 'LineWidth', 1.5); % Line between bars
        text(1.5, y_max + 1.5, '*', 'FontSize', 20, 'HorizontalAlignment', 'center');
    end

    % Add p-value as the title
    title([sprintf('p = %.4f', p) '; ' titleString], 'FontSize', 14);

    % Labels and formatting
    xlim([0.5, 2.5]);
    xticks([1, 2]);
    xticklabels({'Control', 'OFC Silencing'}); % Updated group names
    ylabel('Trials to Criterion');
    set(gca, 'FontSize', 14, 'Box', 'off');

    hold off;
end
