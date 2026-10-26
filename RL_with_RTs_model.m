
%% Mouse Odor Discrimination Simulation (Reinforcement Learning)
clc; clear; close all;

%% Parameters
num_trials = 1000;   % Total trials
alpha = 0.01;        % Learning rate (Rescorla-Wagner)
beta = 0.2;          % Reward sensitivity
rt_change_correct = -0.0005; % Reaction time change if correct
rt_change_incorrect = 0.0005; % Reaction time change if incorrect
rt_natural_increase = 0.005; % Natural increase in reaction time over trials
rt_bounds = [-2, 2]; % Reaction time limits
window_size = 5;    % Sliding window for significance test
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

prev_H_rewards = [];
prev_L_rewards = [];

%% Simulation loop
for t = 1:num_trials
    
    %Once performance converged to maximal, slow the natural increase in RT
    if ~isempty(conv_trials)
        rt_natural_increase = 0.001;
    end
    % Choose context (H or L)
    context = rand < context_prob(1); % 1 for H, 0 for L
    
    % Choose stimulus based on context
    if context == 1
        cs = rand < cs_prob_H(1); % 1 for CS+, 0 for CS-
    else
        cs = rand < cs_prob_L(1);
    end
    
    % Determine reward
    reward = cs; % Reward is given for CS+, none for CS-
    
    % Adjust rt_change_correct based on past trials
    if context == 1 % Context H
        if length(prev_H_rewards) >= 2 && prev_H_rewards(end) == 1 && prev_H_rewards(end-1) == 1
            adj_rt_change_correct = 3 * rt_change_correct;
        elseif length(prev_H_rewards) >= 1 && prev_H_rewards(end) == 1
            adj_rt_change_correct = 2 * rt_change_correct;
        elseif length(prev_H_rewards) >= 2 && prev_H_rewards(end) == 0 && prev_H_rewards(end-1) == 0
            adj_rt_change_correct = rt_change_correct / 3;
        elseif length(prev_H_rewards) >= 1 && prev_H_rewards(end) == 0
            adj_rt_change_correct = rt_change_correct / 2;
        else
            adj_rt_change_correct = rt_change_correct;
        end
        V_H = V_H + alpha * (reward - V_H);
        rt_H = rt_H + (adj_rt_change_correct * reward + rt_change_incorrect * (1 - reward)) + rt_natural_increase * t / num_trials;
        rt_H = min(max(rt_H, rt_bounds(1)), rt_bounds(2));
        prev_H_rewards = [prev_H_rewards, reward];
        if length(prev_H_rewards) > 2
            prev_H_rewards(1) = [];
        end
    else % Context L
        if length(prev_L_rewards) >= 2 && prev_L_rewards(end) == 1 && prev_L_rewards(end-1) == 1
            adj_rt_change_correct = 3 * rt_change_correct;
        elseif length(prev_L_rewards) >= 1 && prev_L_rewards(end) == 1
            adj_rt_change_correct = 2 * rt_change_correct;
        elseif length(prev_L_rewards) >= 2 && prev_L_rewards(end) == 0 && prev_L_rewards(end-1) == 0
            adj_rt_change_correct = rt_change_correct / 3;
        elseif length(prev_L_rewards) >= 1 && prev_L_rewards(end) == 0
            adj_rt_change_correct = rt_change_correct / 2;
        else
            adj_rt_change_correct = rt_change_correct;
        end
        V_L = V_L + alpha * (reward - V_L);
        rt_L = rt_L + (adj_rt_change_correct * reward + rt_change_incorrect * (1 - reward)) + rt_natural_increase * t / num_trials;
        rt_L = min(max(rt_L, rt_bounds(1)), rt_bounds(2));
        prev_L_rewards = [prev_L_rewards, reward];
        if length(prev_L_rewards) > 2
            prev_L_rewards(1) = [];
        end
    end
    
    % Store values
    V_H_values(t) = V_H;
    V_L_values(t) = V_L;
    rt_H_values(t) = rt_H;
    rt_L_values(t) = rt_L;
    
    % Check for convergence
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
legend('Context H', 'Context L');
xlabel('Trials'); ylabel('Associative Strength');
title('Rescorla-Wagner Learning');
for t = conv_trials
    plot([t, t], ylim, '--k', 'LineWidth', 1.5);
end

subplot(2,1,2);
plot(rt_H_values, 'Color', [0,169,137]./255, 'LineWidth', 2); hold on;
plot(rt_L_values, 'Color', [171,62,143]./255, 'LineWidth', 2);
legend('Context H', 'Context L');
xlabel('Trials'); ylabel('Reaction Time (s)');
title('Reaction Times');
if ~isempty(sig_trials)
    plot([sig_trials(1), sig_trials(1)], ylim, '--r', 'LineWidth', 1.5);
end

