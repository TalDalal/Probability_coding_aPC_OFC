srCriterion = .7;

[taskModulationMat] = taskModulatedNeurons(allMiceData, 0.01, [-2 -1; -.33 0 ; 0 1], [-4 -3]);
[sr_per_neurons] = getSuccessRatesForEachNeuron(allMiceData);

meanSuccessRates = mean([sr_per_neurons(:,2)';sr_per_neurons(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';


naive_H_L = taskModulationMat(naiveInds, 1:2);
expert_H_L = taskModulationMat(expertInds, 1:2);

figure;
subplot(1,2,1)
plot_response_bars(naive_H_L(:,1), naive_H_L(:,2))
title('Naive')

subplot(1,2,2)
plot_response_bars(expert_H_L(:,1), expert_H_L(:,2))
title('Expert')



function plot_response_bars(vec1, vec2)

    % Colors
    highProbColor = [0,169,137]./255; % green
    lowProbColor  = [171,62,143]./255; % purple

    % Convert to binary: responsive (1) vs non-responsive (0)
    bin1 = vec1 ~= 0;
    bin2 = vec2 ~= 0;

    % Means (%)
    mean1 = mean(bin1) * 100;
    mean2 = mean(bin2) * 100;

    % SEM
    sem1 = std(bin1) / sqrt(length(bin1)) * 100;
    sem2 = std(bin2) / sqrt(length(bin2)) * 100;

    % Plot bars
    b = bar([1 2], [mean1 mean2], 'FaceColor', 'flat');
    hold on;

    % Set colors per bar
    b.CData(1,:) = highProbColor;
    b.CData(2,:) = lowProbColor;

    % Error bars
    errorbar([1 2], [mean1 mean2], [sem1 sem2], ...
        'k', 'LineStyle', 'none', 'LineWidth', 1.5);

    % Axis formatting
    set(gca, 'XTick', [1 2], ...
             'XTickLabel', {'A','B'}, ...
             'FontSize', 14);

    ylabel('Active neurons (%)');
    ylim([0 100]);
    box off;   % cleaner look
    grid off;  % remove grid

    % Add "context" under each tick
    xt = get(gca, 'XTick');
    yt = get(gca, 'YLim');

    % for i = 1:length(xt)
    %     text(xt(i), yt(1) - 5, 'context', ...
    %         'HorizontalAlignment', 'center', ...
    %         'VerticalAlignment', 'top', ...
    %         'FontSize', 12);
    % end

    % Stats (same logic as before)
    total1 = length(vec1);
    total2 = length(vec2);
    prop1 = sum(bin1) / total1;
    prop2 = sum(bin2) / total2;

    p = twoSampleProportionTest(prop1, prop2, total1, total2);
    fprintf('Two-sample proportion test p-value: %.4f\n', p);

end