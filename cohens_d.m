function d = cohens_d(x, y, type)
    % Computes Cohen's d for independent or paired samples
    % x: First sample (vector)
    % y: Second sample (vector)
    % type: 'independent' (default) or 'paired'
    % d: Cohen's d effect size
    
    if nargin < 3
        type = 'independent'; % Default to independent samples
    end
    
    if strcmp(type, 'independent')
        % Compute means
        mean_x = mean(x);
        mean_y = mean(y);
        
        % Compute standard deviations
        std_x = std(x, 1); % Use N (population standard deviation)
        std_y = std(y, 1);
        
        % Compute pooled standard deviation
        n_x = length(x);
        n_y = length(y);
        pooled_std = sqrt(((n_x - 1) * std_x^2 + (n_y - 1) * std_y^2) / (n_x + n_y - 2));
        
        % Compute Cohen's d
        d = (mean_x - mean_y) / pooled_std;
    elseif strcmp(type, 'paired')
        if length(x) ~= length(y)
            error('Input vectors must have the same length for paired samples');
        end
        
        % Compute differences
        diff_values = x - y;
        
        % Compute mean and standard deviation of differences
        mean_diff = mean(diff_values);
        std_diff = std(diff_values, 1); % Use N (population standard deviation)
        
        % Compute Cohen's d for paired samples
        d = mean_diff / std_diff;
    else
        error('Invalid type. Use "independent" or "paired".');
    end
end
