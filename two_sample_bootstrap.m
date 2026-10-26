function p_value = two_sample_bootstrap(data1, data2, num_bootstraps, plot_flag)
    % TWO_SAMPLE_BOOTSTRAP performs a two-sample bootstrap test.
    % 
    % Inputs:
    %   - data1: Vector of data from sample 1
    %   - data2: Vector of data from sample 2
    %   - num_bootstraps: Number of bootstrap iterations (e.g., 1000)
    %   - plot_flag: Boolean to indicate whether to plot the distribution (true/false)
    %
    % Output:
    %   - p_value: Calculated p-value of the test

    % Ensure inputs are column vectors
    data1 = data1(:);
    data2 = data2(:);

    % Combine data and calculate observed statistic
    combined_data = [data1; data2];
    observed_stat = mean(data1) - mean(data2);
    
    % Initialize bootstrap distribution
    bootstrap_diffs = zeros(num_bootstraps, 1);

    % Perform bootstrap resampling
    for i = 1:num_bootstraps
        % Resample with replacement
        resample1 = combined_data(randi(length(combined_data), size(data1)));
        resample2 = combined_data(randi(length(combined_data), size(data2)));
        
        % Compute bootstrap difference
        bootstrap_diffs(i) = mean(resample1) - mean(resample2);
    end

    % Calculate p-value
    p_value = mean(abs(bootstrap_diffs) >= abs(observed_stat));

    % Plot the bootstrap distribution if requested
    if plot_flag
        figure;
        histogram(bootstrap_diffs, 'Normalization', 'pdf', 'EdgeColor', 'none');
        hold on;
        y_limits = ylim;
        line([observed_stat, observed_stat], y_limits, 'Color', 'r', 'LineWidth', 1.5, 'LineStyle', '--');
        xlabel('Bootstrap Difference in Means');
        ylabel('Density');
        title('Bootstrap Distribution');
        legend('Bootstrap Distribution', 'Observed Statistic', 'Location', 'Best');
        hold off;
    end
end
