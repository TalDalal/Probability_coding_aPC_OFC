function p_value = twoSampleProportionTest(p_hat1, p_hat2, n1, n2)
    % This function performs a two-sample proportion test
    % p_hat1: Sample proportion for group 1
    % p_hat2: Sample proportion for group 2
    % n1: Sample size for group 1
    % n2: Sample size for group 2
    % Returns the p-value for the test
    
    % Combined sample proportion (pooled proportion)
    p_pooled = (p_hat1 * n1 + p_hat2 * n2) / (n1 + n2);
    
    % Calculate the Z-score
    z = (p_hat1 - p_hat2) / sqrt(p_pooled * (1 - p_pooled) * (1/n1 + 1/n2));
    
    % Calculate the p-value for a two-tailed test
    p_value = 2 * (1 - normcdf(abs(z)));
end
