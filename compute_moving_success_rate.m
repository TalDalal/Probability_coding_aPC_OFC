function metrics = compute_moving_success_rate(cs_vector, lick_vector, window_size, ...
                                             success_criterion, hit_criterion, fa_criterion)
% compute_learning_metrics Computes success rate, HIT rate, and FALSE ALARM rate
% over trials using a moving window, and identifies the number of trials until
% each measure crosses its respective criterion.
%
% Inputs:
%   cs_vector        - Binary vector (1 for CS+ trials, 0 for CS- trials)
%   lick_vector      - Binary vector (1 for lick, 0 for no lick)
%   window_size      - Size of the moving window (e.g., 20 trials)
%   success_criterion - Learning criterion for success rate (default: 0.7)
%   hit_criterion     - Learning criterion for HIT rate (default: 0.8)
%   fa_criterion      - Learning criterion for FALSE ALARM rate (default: 0.2)
%
% Output:
%   metrics - A structure containing:
%     success_rate       - Vector of success rates for each window
%     hit_rate_vec       - Vector of HIT rates for each window
%     fa_rate_vec        - Vector of FALSE ALARM rates for each window
%     success_trials_to_criterion - Trials to cross success criterion
%     hit_trials_to_criterion     - Trials to cross HIT criterion
%     fa_trials_to_criterion      - Trials to cross FALSE ALARM criterion

    if nargin < 4, success_criterion = 0.7; end
    if nargin < 5, hit_criterion = 0.8; end
    if nargin < 6, fa_criterion = 0.2; end

    % Ensure inputs are column vectors
    if isrow(cs_vector), cs_vector = cs_vector'; end
    if isrow(lick_vector), lick_vector = lick_vector'; end

    % Number of trials
    num_trials = length(cs_vector);
    assert(num_trials == length(lick_vector), 'Vectors must have the same length.');

    % Initialize vectors
    success_rate = NaN(num_trials - window_size + 1, 1);
    hit_rate_vec = NaN(num_trials - window_size + 1, 1);
    fa_rate_vec = NaN(num_trials - window_size + 1, 1);

    % Sliding window loop
    for i = 1:(num_trials - window_size + 1)
        % Get current window
        window_cs = cs_vector(i:i + window_size - 1);
        window_lick = lick_vector(i:i + window_size - 1);
        
        % Compute HIT and FALSE ALARM rates
        hits = sum(window_lick & window_cs); % Licks on CS+ trials
        false_alarms = sum(window_lick & ~window_cs); % Licks on CS- trials
        total_cs_plus = sum(window_cs); % Total CS+ trials
        total_cs_minus = sum(~window_cs); % Total CS- trials
        
        % Avoid division by zero
        hit_rate = hits / total_cs_plus; % HIT rate
        if total_cs_plus == 0, hit_rate = 0; end
        
        fa_rate = false_alarms / total_cs_minus; % FALSE ALARM rate
        if total_cs_minus == 0, fa_rate = 0; end

        % Save rates
        hit_rate_vec(i) = hit_rate;
        fa_rate_vec(i) = fa_rate;

        % Compute success rate
        success_rate(i) = (hit_rate + (1 - fa_rate)) / 2;
    end

    % Find first crossings of the criterion
    success_first_cross_idx = find(success_rate >= success_criterion, 1);
    hit_first_cross_idx = find(hit_rate_vec >= hit_criterion, 1);
    fa_first_cross_idx = find(fa_rate_vec <= fa_criterion, 1);

    % Calculate trials to cross each criterion
    success_trials_to_criterion = success_first_cross_idx + window_size - 1;
    hit_trials_to_criterion = hit_first_cross_idx + window_size - 1;
    fa_trials_to_criterion = fa_first_cross_idx + window_size - 1;

    % Set to NaN if no crossing is found
    if isempty(success_first_cross_idx), success_trials_to_criterion = NaN; end
    if isempty(hit_first_cross_idx), hit_trials_to_criterion = NaN; end
    if isempty(fa_first_cross_idx), fa_trials_to_criterion = NaN; end

    % Output as a structure
    metrics = struct();
    metrics.success_rate = success_rate;
    metrics.hit_rate_vec = hit_rate_vec;
    metrics.fa_rate_vec = fa_rate_vec;
    metrics.success_trials_to_criterion = success_trials_to_criterion;
    metrics.hit_trials_to_criterion = hit_trials_to_criterion;
    metrics.fa_trials_to_criterion = fa_trials_to_criterion;
end
