function results = fitBehaviorModels(T, varargin)
%FITBEHAVIORMODELS Fit MF/MB/hybrid learning models to context-conditioned licking.
%
%   results = fitBehaviorModels(T)
%   results = fitBehaviorModels(T, 'nStarts', 20)
%   results = fitBehaviorModels(T, 'dvColumn', 'nLicks_context')
%
%   'dvColumn' selects the binary DV (values are binarized as >0), default
%   'lick' (= sufficientLicks, post-CS). Pass 'nLicks_context' (or a
%   derived contextAnyLick column) to run the identical model set on
%   pre-CS context-epoch licking instead -- useful as a well-powered,
%   no-missing-data complement to fitRTModels.m, which necessarily drops
%   trials with no anticipatory lick at all.
%
%   T is the table produced by loadMouseData.m (one row per trial, in
%   chronological order across the whole mouse; columns: context, cs,
%   reward, lick, RT, ...).
%
%   All 5 models reduce to a trial-by-trial PROSPECTIVE value
%   V_ctx(t) = anticipated P(reward | context shown on trial t), computed
%   from trials 1..t-1 only (no peeking), mapped to P(sufficient
%   anticipatory licking) via a logistic link, fit by maximum likelihood.
%   Optimization uses fminsearch on sigmoid-transformed learning-
%   rate/weight parameters (keeps them in (0,1) with NO Optimization
%   Toolbox dependency), from 'nStarts' random restarts (default 20) --
%   IMPORTANT for the higher-dimensional TDchain (4 params) and
%   especially Hybrid (5 params) models: Flat and Bayesian value
%   trajectories are often highly correlated here (CS->reward is
%   deterministic), which can make Hybrid's mixing weight w only weakly
%   identified -- a single-start local optimizer can land on w~0 or w~1
%   just from where it started, not from anything about the animal. Only
%   trust an AIC comparison / a fitted w once nStarts is large enough
%   that increasing it further doesn't change the answer (check by
%   re-running with e.g. nStarts=50 and confirming nll/params are
%   essentially unchanged). See also checkHybridIdentifiability.m.
%
%     0 Null      - no learning: fixed effect of context identity only
%                   (floor/control model -- is there even a learned,
%                   evolving representation, or just a static bias?)
%     1 Flat      - context value updated DIRECTLY from trial reward (RW).
%                   Context and CS are not distinguished internally.
%     2 TDchain   - two-stage TD: context value bootstraps off the VALUE
%                   OF THE CS just revealed (not off reward directly);
%                   CS value itself updates from reward. This is the
%                   "model-free chaining / 2nd-order conditioning" story.
%     3 Bayesian  - Beta-Bernoulli posterior over P(CS+|context) with a
%                   forgetting/leak param; explicit model-based inference
%                   of the transition probabilities.
%     4 Hybrid    - w*Bayesian(MB) + (1-w)*Flat(MF); w is fit per mouse
%                   and is your key individual-differences readout.
%
%   NOTE: because CS->reward is DETERMINISTIC (100% validity) in this
%   task, Flat and TDchain make near-identical asymptotic predictions
%   once CS value has converged (see README). The models are still worth
%   fitting/comparing, but don't over-interpret Flat-vs-TDchain AIC
%   differences alone as evidence for/against a state-transition model --
%   the Bayesian-vs-(Flat/TDchain) comparison is the more diagnostic one,
%   and the RT/behavioral-VARIANCE test described in the README is the
%   sharpest dissociation available from behavior alone.
%
%   OUTPUT: results is a 1x5 struct array with fields:
%       .name, .nParams (total, incl. logistic intercept/slope),
%       .paramsFit (.valuePars, .b0, .b1), .nll, .aic, .bic,
%       .Vctx (Nx1 fitted trajectory), .yhat (predicted P(lick))
%
%   See also loadMouseData, analyzeLearning, checkHybridIdentifiability.

p = inputParser;
addParameter(p, 'nStarts', 20);
addParameter(p, 'dvColumn', 'lick');
parse(p, varargin{:});
nStarts = p.Results.nStarts;
dvColumn = p.Results.dvColumn;

% --- drop trials with undefined context or missing DV ---
keep = (T.context=='A' | T.context=='B') & ~isnan(T.(dvColumn));
if any(~keep)
    warning('fitBehaviorModels:dropTrials', ...
        'Dropping %d trials with undefined context or missing %s.', sum(~keep), dvColumn);
    T = T(keep,:);
end

context = double(T.context == 'B') + 1;   % 1 = A, 2 = B
csPlus  = double(T.cs == 'CS+');          % 1 if CS+ trial, else 0
reward  = T.reward(:);
y       = double(T.(dvColumn)(:) > 0);    % binarized DV (works for 0/1 lick, or nLicks_context>0)
N       = height(T);

models = getValueModels();   % shared with fitRTModels.m -- see getValueModels.m

results = struct('name',{},'nParams',{},'paramsFit',{},'nll',{},'aic',{},'bic',{},'Vctx',{},'yhat',{});

opts = optimset('Display','off','MaxFunEvals',5000,'MaxIter',5000);
rng(0);   % reproducible random restarts

for m = 1:numel(models)
    mdl = models(m);
    nValuePars = mdl.nValuePars;
    nPars = nValuePars + 2;            % + logistic intercept (b0) & slope (b1)

    objFun = @(th) negLogLik(th, mdl.fun, nValuePars, context, csPlus, reward, y);

    bestNll = Inf; bestTheta = [];
    for iStart = 1:nStarts
        if iStart == 1
            theta0 = zeros(1, nPars);
            theta0(end-1:end) = [0, 1];   % canonical start: value pars at 0.5, b0=0, b1=1
        else
            theta0 = 2*randn(1, nPars);   % random restart spread across transformed space
        end
        [thetaFit_i, nll_i] = fminsearch(objFun, theta0, opts);
        if nll_i < bestNll
            bestNll = nll_i; bestTheta = thetaFit_i;
        end
    end
    thetaFit = bestTheta; nll = bestNll;

    [Vctx, yhat] = evalModel(thetaFit, mdl.fun, nValuePars, context, csPlus, reward);

    r.name      = mdl.name;
    r.nParams   = nPars;
    r.paramsFit = decodeParams(thetaFit, nValuePars);
    r.nll       = nll;
    r.aic       = 2*nll + 2*nPars;
    r.bic       = 2*nll + nPars*log(N);
    r.Vctx      = Vctx;
    r.yhat      = yhat;
    results(end+1) = r; %#ok<AGROW>
end
end

% =========================== INFRASTRUCTURE ============================
function nll = negLogLik(theta, valueFun, nValuePars, context, csPlus, reward, y)
[~, yhat] = evalModel(theta, valueFun, nValuePars, context, csPlus, reward);
yhat = min(max(yhat, 1e-6), 1-1e-6);   % avoid log(0)
nll = -sum(y.*log(yhat) + (1-y).*log(1-yhat));
end

function [Vctx, yhat] = evalModel(theta, valueFun, nValuePars, context, csPlus, reward)
valuePars = sig(theta(1:nValuePars));      % learning rates / weight constrained to (0,1)
b0 = theta(end-1);
b1 = theta(end);
Vctx = valueFun(valuePars, context, csPlus, reward);
yhat = 1 ./ (1 + exp(-(b0 + b1.*Vctx)));
end

function p = decodeParams(theta, nValuePars)
p.valuePars = sig(theta(1:nValuePars));
p.b0 = theta(end-1);
p.b1 = theta(end);
end

function s = sig(x)
s = 1 ./ (1+exp(-x));
end