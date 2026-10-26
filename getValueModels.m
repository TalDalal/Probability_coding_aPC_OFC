function models = getValueModels()
%GETVALUEMODELS Registry of context-value learning models.
%
%   models = getValueModels()
%
%   Shared by fitBehaviorModels.m (licking DV) and fitRTModels.m
%   (RT/promptness DV) so both operate on IDENTICAL value definitions.
%   Returns a struct array with fields .name, .nValuePars, .fun
%   (function handle with signature Vctx = fun(pars, context, csPlus, reward),
%   pars already transformed to (0,1); context is 1=A/2=B; csPlus is
%   1/0; reward is 1/0; Vctx is Nx1, the PROSPECTIVE value of the
%   context shown on trial t, computed only from trials before t).
%
%     Null      - no learning: fixed context-identity indicator
%     Flat      - context value updated DIRECTLY from trial reward (RW)
%     TDchain   - context value bootstraps off VALUE OF THE CS just
%                 revealed; CS value itself updates from reward
%                 (2-stage TD / model-free chaining)
%     Bayesian  - Beta-Bernoulli posterior over P(CS+|context) with a
%                 leak/forgetting param (model-based)
%     Hybrid    - w*Bayesian + (1-w)*Flat, w fit per mouse

models = struct('name', {}, 'nValuePars', {}, 'fun', {});
models(end+1) = struct('name','Null',     'nValuePars',0, 'fun', @nullValue);
models(end+1) = struct('name','Flat',     'nValuePars',1, 'fun', @flatValue);
models(end+1) = struct('name','TDchain',  'nValuePars',2, 'fun', @tdChainValue);
models(end+1) = struct('name','Bayesian', 'nValuePars',1, 'fun', @bayesValue);
models(end+1) = struct('name','Hybrid',   'nValuePars',3, 'fun', @hybridValue);
end

% ============================ VALUE MODELS ==============================
function Vctx = nullValue(~, context, ~, ~)
Vctx = double(context==1);   % 1 for A, 0 for B
end

function Vctx = flatValue(pars, context, ~, reward)
alpha = pars(1);
N = numel(context);
V = [0.5 0.5];   % [V_A, V_B] init
Vctx = zeros(N,1);
for t = 1:N
    c = context(t);
    Vctx(t) = V(c);
    V(c) = V(c) + alpha*(reward(t) - V(c));   % update AFTER outcome observed
end
end

function Vctx = tdChainValue(pars, context, csPlus, reward)
alpha_ctx = pars(1);
alpha_cs  = pars(2);
N = numel(context);
Vc = [0.5 0.5];   % [V_A, V_B]
Vk = [0.5 0.5];   % [V_CS-, V_CS+]   (index 1 = CS-, 2 = CS+)
Vctx = zeros(N,1);
for t = 1:N
    c = context(t);
    k = csPlus(t) + 1;
    Vctx(t) = Vc(c);
    delta_ctx = Vk(k) - Vc(c);              % bootstrap off CS value just revealed
    Vc(c) = Vc(c) + alpha_ctx*delta_ctx;
    delta_cs = reward(t) - Vk(k);
    Vk(k) = Vk(k) + alpha_cs*delta_cs;
end
end

function Vctx = bayesValue(pars, context, csPlus, ~)
gamma = pars(1);   % leak toward flat prior; 1 = no forgetting
N = numel(context);
a = [1 1];  b = [1 1];   % Beta(1,1) prior per context, [A B]
Vctx = zeros(N,1);
for t = 1:N
    c = context(t);
    Vctx(t) = a(c) / (a(c)+b(c));
    a(c) = gamma*a(c) + (1-gamma)*1;
    b(c) = gamma*b(c) + (1-gamma)*1;
    if csPlus(t)==1
        a(c) = a(c) + 1;
    else
        b(c) = b(c) + 1;
    end
end
end

function Vctx = hybridValue(pars, context, csPlus, reward)
alpha = pars(1);
gamma = pars(2);
w     = pars(3);
Vmf = flatValue(alpha, context, csPlus, reward);
Vmb = bayesValue(gamma, context, csPlus, reward);
Vctx = w.*Vmb + (1-w).*Vmf;
end
