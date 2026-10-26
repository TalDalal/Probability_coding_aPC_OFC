function plotRegressionWithCI(x, y, color, plotDataPoints, odorType)
    % Ensure inputs are column vectors
    x = x(:);
    y = y(:);

    % Calculate Pearson correlation
    [r, p] = corr(x, y);

    % Fit linear regression model
    mdl = fitlm(x, y);
    
    % Generate regression line
    xFit = linspace(min(x), max(x), 100)';
    [yFit, yCI] = predict(mdl, xFit);

    % Plot data points
%     figure;
    hold on;
    if plotDataPoints
        scatter(x, y, 36, color, 'filled', 'MarkerFaceAlpha', 0.5, 'DisplayName', 'Data');
    end

    % Plot regression line
    plot(xFit, yFit, 'LineWidth', 1.5, 'Color', color, 'DisplayName', 'Regression Line');

    % Plot confidence interval
    fill([xFit; flipud(xFit)], [yCI(:,1); flipud(yCI(:,2))], color, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', '95% CI');

    % Annotate plot
    xlabel('X');
    ylabel('Y');
    title([odorType '; ' sprintf('r = %.2f, p = %.3g', r, p)]);
    legend;
    grid on;
    hold off;
end
