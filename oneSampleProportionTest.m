
function p_value = oneSampleProportionTest(p_hat, p0, n)
    % This function performs a one-sample proportion test
    % p_hat: Sample proportion
    % p0: Hypothesized proportion under the null hypothesis
    % n: Total number of observations
    % Returns the p-value for the test
    
    % Calculate the Z-score
    z = (p_hat - p0) / sqrt(p0 * (1 - p0) / n);
    
    % Calculate the p-value for a two-tailed test
    p_value = 2 * (1 - normcdf(abs(z)));
end
