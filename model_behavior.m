%% ===============================
% MAIN SCRIPT
% ================================

% clear; clc;

% --- LOAD YOUR DATA HERE ---
context = output.H_L_vec';%: Nx1 (1=A, 2=B)
cs = output.CS_plus_minus';%Nx1 (1=CS+, 2=CS-)
correct = output.lickNoLick';%: Nx1 (1/0)
RT_mouse = output.firstLickLatency';%: Nx1



N = length(context);

% --- INITIAL PARAMETERS ---
init_params = [0.05, 0.05, 5, 1, 0.2];
% [alpha_ctx, alpha_cs, beta, RT_scale, RT_offset]

lb = [0, 0, 0.1, 0];
ub = [1, 1, 20, 10];

% --- FIT ---
options = optimset('Display','iter','MaxIter',500);

best_params = fminsearch(@(p) loss_function(p, context, cs, correct, RT_mouse), init_params, options);

% --- RUN MODEL WITH FITTED PARAMS ---
out = run_model(context, cs, best_params);

% --- PLOTS ---
plot_results(context, cs, correct, RT_mouse, out);

disp('Fitted parameters:');
disp(best_params);



%----------------- FUNCTIONS -----------------
function out = run_model(context, cs, params)

% params:
% [alpha_ctx, alpha_cs, beta, RT_scale, RT_offset]

alpha_ctx = params(1);
alpha_cs  = params(2);
beta      = params(3);
RT_scale  = params(4);
RT_offset = params(5);

N = length(context);

% Convert to indices (1=A,2=B ; 1=CS+,2=CS-)
ctx_idx = context + 1;
cs_idx  = cs + 1;

% Initialize
V_ctx = 0.5 * ones(2,1);   % P(CS+|context)
V_cs  = zeros(2,1);        % value of CS

% Outputs
p_lick_cs    = zeros(N,1);
p_lick_delay = zeros(N,1);
RT           = zeros(N,1);

V_ctx_hist = zeros(N,2);
V_cs_hist  = zeros(N,2);

for t = 1:N
    
    c = ctx_idx(t);
    s = cs_idx(t);
    
    % ---------------------------
    % 1) DELAY PERIOD (context-based expectation)
    % ---------------------------
    P_cs_plus = V_ctx(c);
    Q_delay = P_cs_plus * V_cs(1) + (1 - P_cs_plus) * V_cs(2);
    
    p_lick_delay(t) = sigmoid(beta * Q_delay);
    
    % ---------------------------
    % 2) CS PERIOD (decision)
    % ---------------------------
    Q_cs = V_cs(s);
    
    p_lick_cs(t) = sigmoid(beta * Q_cs);
    
    % Reaction time (for ALL trials)
    RT(t) = RT_offset + RT_scale * exp(-Q_cs);
    
    % ---------------------------
    % 3) LEARNING
    % ---------------------------
    
    % reward depends only on CS+
    r = (cs(t) == 1);
    
    % --- CS learning (reward prediction)
    PE_r = r - V_cs(s);
    V_cs(s) = V_cs(s) + alpha_cs * PE_r;
    
    % --- Context learning (predict CS identity)
    target = cs(t); % 1=CS+, 0=CS-
    PE_ctx = target - V_ctx(c);
    V_ctx(c) = V_ctx(c) + alpha_ctx * PE_ctx;
    
    % Store history
    V_ctx_hist(t,:) = V_ctx;
    V_cs_hist(t,:)  = V_cs;
end

% Output
out.p_lick_cs    = p_lick_cs;
out.p_lick_delay = p_lick_delay;
out.RT           = RT;
out.V_ctx        = V_ctx_hist;
out.V_cs         = V_cs_hist;

end

function y = sigmoid(x)
y = 1 ./ (1 + exp(-x));
end


function L = loss_function(params, context, cs, correct, RT_mouse)

out = run_model(context, cs, params);

p = out.p_lick_cs;
RT_model = out.RT;

N = length(cs);

% ---------------------------
% 1) CHOICE LIKELIHOOD
% ---------------------------
loglik = 0;

for t = 1:N
    
    if cs(t) == 1   % CS+
        p_correct = p(t);
    else            % CS-
        p_correct = 1 - p(t);
    end
    
    p_correct = max(min(p_correct, 1-1e-6), 1e-6);
    
    if correct(t) == 1
        loglik = loglik + log(p_correct);
    else
        loglik = loglik + log(1 - p_correct);
    end
end

% ---------------------------
% 2) RT ERROR (ALL TRIALS)
% ---------------------------
RT_error = sum((RT_mouse - RT_model).^2) / N;

% ---------------------------
% 3) TOTAL LOSS
% ---------------------------
lambda = 0.1; % tune if needed

L = -loglik + lambda * RT_error;

end

function plot_results(context, cs, correct, RT_mouse, out)

figure;

%% ---- Performance ----
subplot(2,2,1)
win = 20;
perf_mouse = movmean(correct, win);

% model predicted correctness
p = out.p_lick_cs;
pred_correct = zeros(size(p));

for t = 1:length(cs)
    if cs(t) == 1
        pred_correct(t) = p(t);
    else
        pred_correct(t) = 1 - p(t);
    end
end

perf_model = movmean(pred_correct, win);

plot(perf_mouse, 'k', 'LineWidth',2); hold on;
plot(perf_model, 'r', 'LineWidth',2);
legend('Mouse','Model');
title('Performance');

%% ---- RT ----
subplot(2,2,2)
plot(RT_mouse, 'k'); hold on;
plot(out.RT, 'r');
legend('Mouse','Model');
title('Reaction Time');

%% ---- Context effect ----
subplot(2,2,3)

A_idx = context == 1;
B_idx = context == 2;

RT_A_mouse = mean(RT_mouse(A_idx));
RT_B_mouse = mean(RT_mouse(B_idx));

RT_A_model = mean(out.RT(A_idx));
RT_B_model = mean(out.RT(B_idx));

bar([RT_A_mouse, RT_B_mouse; RT_A_model, RT_B_model]')
legend('Mouse','Model')
set(gca,'XTickLabel',{'A','B'})
title('Context effect on RT')

%% ---- Latent variable ----
subplot(2,2,4)
plot(out.V_ctx(:,1), 'b'); hold on;
plot(out.V_ctx(:,2), 'r');
legend('A','B');
title('Learned context values');

end