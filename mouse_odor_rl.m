function mouse_odor_rl(num_trials, context, cs)
    %% Mouse Odor Discrimination Simulation (Reinforcement Learning)
    if nargin < 1, num_trials = 1000; end
    if nargin < 2, use_input_data = false; else, use_input_data = true; end

    %% Parameters
    alpha = 0.01;        % Learning rate (Rescorla-Wagner)
    beta = 0.2;          % Reward sensitivity
    rt_change_correct = -0.001; % Reaction time change if correct
    rt_change_incorrect = 0.001; % Reaction time change if incorrect
    rt_natural_increase = 0.005; % Natural increase in reaction time over trials
    rt_bounds = [-2, 2]; % Reaction time limits
    window_size = 50;    % Sliding window for significance test
    sig_threshold = 0.05; % Threshold for significant difference

    %% Context probabilities
    context_prob = [0.5, 0.5]; % Equal probability for H and L
    cs_prob_H = [0.75, 0.25];  % P(CS+ | H) = 0.75, P(CS- | H) = 0.25
    cs_prob_L = [0.25, 0.75];  % P(CS+ | L) = 0.25, P(CS- | L) = 0.75

    %% Initialization
    V_H = 0.5; V_L = 0.5; % Initial values of associative strength
    rt_H = 0; rt_L = 0;   % Initial reaction times
    V_H_values = nan(num_trials,1); % Store learning values
    V_L_values = nan(num_trials,1);
    rt_H_values = nan(num_trials,1); % Store reaction times
    rt_L_values = nan(num_trials,1);
    conv_trials = []; % Store trials where RL model converges

    %% Generate data if not provided
    if ~use_input_data
        context = rand(num_trials,1) < context_prob(1); % Generate context data
        cs = (rand(num_trials,1) < cs_prob_H(1)) .* context + (rand(num_trials,1) < cs_prob_L(1)) .* ~context; % Generate stimulus data
    end

    %% Simulation loop
    prev_rewards_H = [];
    prev_rewards_L = [];
    for t = 1:num_trials
        
        %Once performance converged to maximal, slow the natural increase in RT
%         if ~isempty(conv_trials)
%             rt_natural_increase = 0.001;
%         end
        
        curr_context = context(t);
        curr_cs = cs(t);
        reward = curr_cs; % Reward is given for CS+, none for CS-

        if curr_context == 1
            prev_rewards = prev_rewards_H;
        else
            prev_rewards = prev_rewards_L;
        end

        % Modify rt_change_correct based on previous rewards
        if length(prev_rewards) >= 2 && all(prev_rewards(1:2) == 1)
            adj_rt_change_correct = 3 * rt_change_correct;
        elseif length(prev_rewards) >= 1 && prev_rewards(1) == 1
            adj_rt_change_correct = 2 * rt_change_correct;
        elseif length(prev_rewards) >= 2 && all(prev_rewards(1:2) == 0)
            adj_rt_change_correct = rt_change_correct / 3;
        elseif length(prev_rewards) >= 1 && prev_rewards(1) == 0
            adj_rt_change_correct = rt_change_correct / 2;
        else
            adj_rt_change_correct = rt_change_correct;
        end

        if curr_context == 1 % Context H
            V_H = V_H + alpha * (reward - V_H);
            rt_H = rt_H + (adj_rt_change_correct * reward + rt_change_incorrect * (1 - reward)) + rt_natural_increase * t / num_trials;
            rt_H = min(max(rt_H, rt_bounds(1)), rt_bounds(2));
            prev_rewards_H = [reward, prev_rewards_H(1:min(length(prev_rewards_H),1))];
        else % Context L
            V_L = V_L + alpha * (reward - V_L);
            rt_L = rt_L + (adj_rt_change_correct * reward + rt_change_incorrect * (1 - reward)) + rt_natural_increase * t / num_trials;
            rt_L = min(max(rt_L, rt_bounds(1)), rt_bounds(2));
            prev_rewards_L = [reward, prev_rewards_L(1:min(length(prev_rewards_L),1))];
        end

        V_H_values(t) = V_H;
        V_L_values(t) = V_L;
        rt_H_values(t) = rt_H;
        rt_L_values(t) = rt_L;

        if abs(V_H - 0.75) < 0.01 && isempty(conv_trials)
            conv_trials = [conv_trials, t];
        elseif abs(V_L - 0.25) < 0.01 && isempty(conv_trials)
            conv_trials = [conv_trials, t];
        end
    end

    %% Post-simulation sliding window significance test
    sig_trials = [];
    for t = window_size:num_trials
        p_value = ranksum(rt_H_values(t-window_size+1:t), rt_L_values(t-window_size+1:t));
        if p_value < sig_threshold
            sig_trials = [sig_trials, t];
        end
    end

    %% Plot results
    figure;
    subplot(2,1,1);
    plot(V_H_values, 'Color', [0,169,137]./255, 'LineWidth', 2); hold on;
    plot(V_L_values, 'Color', [171,62,143]./255, 'LineWidth', 2);
%     legend('Context H', 'Context L');
    xlabel('Trials'); ylabel('Associative Strength');
    title('Rescorla-Wagner Learning');box off
    for t = conv_trials
        plot([t, t], ylim, '--k', 'LineWidth', 1.5);
    end

    subplot(2,1,2);
    plot(rt_H_values, 'Color', [0,169,137]./255, 'LineWidth', 2); hold on;
    plot(rt_L_values, 'Color', [171,62,143]./255, 'LineWidth', 2);
%     legend('Context H', 'Context L');
    xlabel('Trials'); ylabel('Reaction Time (s)');
    title('Reaction Times');box off
    if ~isempty(sig_trials)
        plot([sig_trials(1), sig_trials(1)], ylim, '--r', 'LineWidth', 1.5);
    end
end
