function se = binomial_se(p, N)
% BINOMIAL_SE computes the binomial standard error
%   p - probability of success (scalar or vector)
%   N - number of trials (scalar or vector, same size as p if vector)
%
% Example:
%   se = binomial_se(0.6, 100)

    % Input validation (optional, but recommended)
    if any(p < 0 | p > 1)
        error('Probability p must be between 0 and 1');
    end
    if any(N <= 0)
        error('Number of trials N must be positive');
    end

    % Compute standard error
    se = sqrt(p .* (1 - p) ./ N);
end
