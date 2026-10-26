function [chi2stat, p, df] = chiSquareGOF(observed, expected)
% chiSquareGOF computes the Chi-square goodness-of-fit test.
%
%   Inputs:
%       observed - vector of observed frequencies
%       expected - vector of expected frequencies (same size as observed)
%
%   Outputs:
%       chi2stat - chi-square statistic
%       p        - p-value of the test
%       df       - degrees of freedom

    % Input validation
    if length(observed) ~= length(expected)
        error('Observed and expected vectors must be the same length.');
    end

    if any(expected == 0)
        error('Expected frequencies must be greater than zero.');
    end

    % Compute chi-square statistic
    chi2stat = sum((observed - expected).^2 ./ expected);

    % Degrees of freedom
    df = length(observed) - 1;

    % Compute p-value
    p = 1 - chi2cdf(chi2stat, df);
end
