function violinplot_with_mean_single_side(data, categories, colors, dataPointsFlag, pairedDataFlag)
    % violinplot_with_mean_single_side generates paired one-sided violin plots
    % for each category, showing individual data points and the mean value.
    %
    % INPUTS:
    % - data: A cell array where each cell contains a vector of data points for each category
    % - categories: A cell array or string array of category labels for the x-axis
    % - colors: (Optional) A matrix of RGB colors for each category (rows must match the number of categories)
    % - dataPointsFlag: Boolean flag to show individual data points
    % - pairedDataFlag: Boolean flag to connect paired data points with lines across categories

    numCategories = numel(data);

    if nargin < 3
        % Generate default color scheme if not provided
        colors = lines(numCategories);
    end

    % Set up the figure and axes
    hold on;

    % Determine paired data size if pairedDataFlag is true
    if pairedDataFlag
        minDataLength = min(cellfun(@numel, data));
    else
        minDataLength = 0;
    end

    % Loop through each category and generate the violin plot
    for i = 1:numCategories
        % Extract data for the current category
        currentData = data{i};

        % Calculate the kernel density estimate (KDE)
        bandwidth = 0.1 * (max(currentData) - min(currentData)); % Adjust for less stretching
        [f, xi] = ksdensity(currentData, 'Bandwidth', bandwidth);

        % Trim the density to zero in regions without data points
        dataMin = min(currentData);
        dataMax = max(currentData);
        validIdx = (xi >= dataMin) & (xi <= dataMax);
        f = f(validIdx);
        xi = xi(validIdx);

        % Scale the KDE to fit within the current category width
        f = f / max(f) * 0.4;  % Scale to 40% of the width of a category

        % Flip odd-numbered categories to face left
        if mod(i, 2) == 1
            f = -f;
        end

        % Plot the one-sided violin shape
        fill(i + [f, zeros(1, numel(f))], [xi, fliplr(xi)], ...
             colors(i, :), 'FaceAlpha', 1, 'EdgeColor', 'k');

        % Plot the mean
        meanValue = nanmean(currentData);
        plot([i-.2 i+.2], [meanValue meanValue], 'LineWidth', 1, 'Color', 'k')

        if dataPointsFlag
            % Overlay individual data points
            jitterAmount = 0.05; % Control the amount of jitter
            jitteredX = i + jitterAmount * randn(size(currentData));
            scatter(jitteredX, currentData, 15, 'MarkerFaceColor', [.5 .5 .5], 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', .7);
        end
    end

    % If paired data, connect paired points with lines
    if pairedDataFlag && minDataLength > 1
        for j = 1:minDataLength
            % Extract paired data points across categories for each index
            pairedY = cellfun(@(x) x(j), data);
            plot(1:numCategories, pairedY, '-k', 'LineWidth', 0.5, 'Color', [0.5 0.5 0.5]);
        end
    end

    % Set x-axis labels
    set(gca, 'XTick', 1:numCategories, 'XTickLabel', categories, 'TickLabelInterpreter', 'none');
    xtickangle(45);
    set(gca, 'FontSize', 18);
    box off;

    hold off;
    xlim([0.5, numCategories + 0.5]);
end
