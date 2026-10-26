function [chi2stat, p] = chi2GOF(vec1, vec2)
    % Check if input vectors have the same length
    if length(vec1) ~= length(vec2)
        error('Input vectors must have the same length.');
    end
    
    % Convert percent values to counts by assuming total sum as 100 for each vector
    counts1 = vec1 / 100 * sum(vec1); 
    counts2 = vec2 / 100 * sum(vec2);
    
    % Chi-square calculation
    observed = counts1;
    expected = counts2;
    
    % Remove bins where expected counts are zero to avoid division errors
    validBins = expected > 0;
    observed = observed(validBins);
    expected = expected(validBins);
    
    % Compute the chi-square statistic
    chi2stat = sum((observed - expected).^2 ./ expected);
    
    % Degrees of freedom
    df = length(observed) - 1;
    
    % Calculate p-value
    p = 1 - chi2cdf(chi2stat, df);
    
    % Display results
    fprintf('Chi-square Statistic: %.4f\n', chi2stat);
    fprintf('p-value: %.4f\n', p);
end
