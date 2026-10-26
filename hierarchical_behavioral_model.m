%% =========================================
%   HIERARCHICAL MODEL: BIAS + DISCRIMINATION
% ==========================================



%% -------- INPUT DATA --------
% context: Nx1 (1=A, 0=B)
% cs:      Nx1 (1=CS+, 0=CS-)
% lick:    Nx1 (1=lick, 0=no lick)
% RT_mouse: Nx1 (first lick latency, NaN if no lick)

currSession = allMiceBehavior(9).data(3);

context = currSession.A_B_indices';
cs = currSession.CS_plus_minus';
lick = currSession.sufficientLicks';

for trialInd = 1:size(currSession.lickRaster,2)
    if isempty(currSession.lickRaster(trialInd).times)
        RT_mouse(trialInd,1) = NaN;
    else
        RT_mouse(trialInd,1) = currSession.lickRaster(trialInd).times(1);
    end
end


% force column vectors
context = context(:);
cs      = cs(:);
lick    = lick(:);
RT_mouse = RT_mouse(:);

N = length(context);

%% -------- INITIAL PARAMETERS --------
% [alpha_ctx, alpha_cs, beta, w_ctx, w_cs, RT_scale, RT_offset]

init_params = [0.05, 0.1, 5, 1, 2, 1, 0.2];

options = optimset('Display','iter','MaxIter',500);

%% -------- FIT MODEL --------
best_params = fminsearch(@(p) loss_function(p, context, cs, lick, RT_mouse), init_params, options);

disp('Fitted parameters:');
disp(best_params);

%% -------- RUN MODEL --------
out = run_model_bias(context, cs, best_params);

%% -------- COMPUTE CORRECT (FOR DISPLAY ONLY) --------
correct = double(cs == lick);

%% =========================================
%               PLOTS
% ==========================================

figure;

%% ---- 1. Performance ----
subplot(3,2,1)
plot(movmean(correct,20),'k','LineWidth',2)
title('Mouse Performance')
ylim([0 1])

%% ---- 2. Lick probability ----
subplot(3,2,2)
plot(out.p_lick,'r')
title('Model P(lick)')

%% ---- 3. False alarms (CS-) ----
subplot(3,2,3)

FA_A = mean(lick(context==1 & cs==0));
FA_B = mean(lick(context==0 & cs==0));

bar([FA_A, FA_B])
set(gca,'XTickLabel',{'A','B'})
title('False Alarms (CS-)')

%% ---- 4. Reaction time ----
subplot(3,2,4)

valid = ~isnan(RT_mouse);

plot(RT_mouse(valid),'k'); hold on;
plot(out.RT(valid),'r');

legend('Mouse','Model')
title('Reaction Time')

%% ---- 5. Latent: P(CS+ | context) ----
subplot(3,2,5)

plot(out.V_ctx_hist(:,1),'b'); hold on;
plot(out.V_ctx_hist(:,2),'r');

legend('A','B')
title('P(CS+ | context)')

%% ---- 6. Bias vs discrimination ----
subplot(3,2,6)

plot(out.EV_ctx,'k'); hold on;
plot(out.V_cs_trace,'g');

legend('Context bias','CS value')
title('Bias vs Discrimination')

%% =========================================
%        POSTERIOR COMPUTATION
% ==========================================

% P(A | CS+)
P_A_given_CSplus = out.V_ctx_hist(:,1) ./ ...
    (out.V_ctx_hist(:,1) + out.V_ctx_hist(:,2));

figure;
plot(P_A_given_CSplus,'k','LineWidth',2)
title('Posterior: P(A | CS+)')
ylabel('Probability'); xlabel('Trial')

%% =========================================
%           MODEL FUNCTIONS
% ==========================================

function out = run_model_bias(context, cs, params)

alpha_ctx = params(1);
alpha_cs  = params(2);
beta      = params(3);
w_ctx     = params(4);
w_cs      = params(5);
RT_scale  = params(6);
RT_offset = params(7);

N = length(context);

ctx_idx = context + 1;
cs_idx  = cs + 1;

V_ctx = 0.5 * ones(2,1);
V_cs  = zeros(2,1);

p_lick = zeros(N,1);
RT     = zeros(N,1);

EV_ctx = zeros(N,1);
V_cs_trace = zeros(N,1);

V_ctx_hist = zeros(N,2);

for t = 1:N
    
    c = ctx_idx(t);
    s = cs_idx(t);
    
    % ---- Bias (context) ----
    P_cs_plus = V_ctx(c);
    EV = P_cs_plus * V_cs(1) + (1 - P_cs_plus) * V_cs(2);
    
    % ---- Discrimination (CS) ----
    Vstim = V_cs(s);
    
    % ---- Decision ----
    Q = w_ctx * EV + w_cs * Vstim;
    
    p_lick(t) = sigmoid(beta * Q);
    RT(t)     = RT_offset + RT_scale * exp(-Q);
    
    % store latent variables
    EV_ctx(t) = EV;
    V_cs_trace(t) = Vstim;
    V_ctx_hist(t,:) = V_ctx;
    
    % ---- Learning ----
    r = cs(t);
    
    V_cs(s) = V_cs(s) + alpha_cs * (r - V_cs(s));
    V_ctx(c) = V_ctx(c) + alpha_ctx * (r - V_ctx(c));
end

out.p_lick = p_lick;
out.RT = RT;

out.EV_ctx = EV_ctx;
out.V_cs_trace = V_cs_trace;
out.V_ctx_hist = V_ctx_hist;

end

function L = loss_function(params, context, cs, lick, RT_mouse)

out = run_model_bias(context, cs, params);

p = out.p_lick;
RT_model = out.RT;

lick = lick(:);
RT_mouse = RT_mouse(:);
RT_model = RT_model(:);

N = length(lick);

% ---- Choice likelihood ----
loglik = 0;
for t = 1:N
    if lick(t) == 1
        p_obs = p(t);
    else
        p_obs = 1 - p(t);
    end
    p_obs = max(min(p_obs,1-1e-6),1e-6);
    loglik = loglik + log(p_obs);
end

% ---- RT error ----
valid = ~isnan(RT_mouse);
RT_error = sum((RT_mouse(valid) - RT_model(valid)).^2) / sum(valid);

lambda = 0.1;

L = -loglik + lambda * RT_error;

end

function y = sigmoid(x)
y = 1 ./ (1 + exp(-x));
end