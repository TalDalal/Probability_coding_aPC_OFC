function results = fitRTModels(T, varargin)
%FITRTMODELS Fit the same 5 context-value models to a continuous RT DV.
%
%   results = fitRTModels(T)
%   results = fitRTModels(T, 'dvColumn', 'RT_trace')
%
%   T: table from loadMouseData.m. Must contain the RT-derived columns
%   produced when allMiceBehavior(...).data(...).lickRaster is present:
%     RT        - latency to first lick after context-odor ONSET (t=-2),
%                 window [-2,0). Default DV -- precedes the CS entirely,
%                 so it's the cleanest read on the learned transition
%                 model.
%     RT_trace  - latency to first lick after context-odor OFFSET (t=-1),
%                 window [-1,0). Purest anticipation: no odor physically
%                 present anymore, response can only reflect memory.
%     RT_CS     - latency to first lick after CS onset, window [0,2).
%
%   Rather than raw RT (right-skewed), the DV modeled is
%   PROMPTNESS = 1/RT (LATER-model framework, Carpenter & Williams 1995),
%   which tends to be closer to linear-in-value and roughly Gaussian.
%   Trials with no anticipatory lick (RT = NaN) are excluded listwise --
%   use nLicks_context (well-defined incl. zero) via a logistic model
%   (same pattern as fitBehaviorModels.m) if missingness is a concern,
%   especially in early/novice sessions where anticipatory licking may
%   be rare.
%
%   Fits: promptness(t) = b0 + b1*Vctx(t) + noise, per value model.
%   Value-model learning-rate/weight params are optimized by fminsearch;
%   the linear link (b0,b1) is closed-form (ordinary least squares via
%   mldivide) given those params, so no Optimization/Statistics Toolbox
%   is required anywhere in this file.
%
%   AIC/BIC here use a Gaussian likelihood and are comparable to EACH
%   OTHER (same DV, same 5 models) but NOT to the Bernoulli-likelihood
%   AIC/BIC from fitBehaviorModels.m.
%
%   See also fitBehaviorModels, getValueModels, analyzeRTVariance.

p = inputParser;
addParameter(p, 'dvColumn', 'RT');
parse(p, varargin{:});
dvColumn = p.Results.dvColumn;

keep = (T.context=='A' | T.context=='B') & ~isnan(T.(dvColumn)) & T.(dvColumn) > 0;
if any(~keep)
    fprintf('fitRTModels: using %d/%d trials with a valid %s.\n', ...
        sum(keep), height(T), dvColumn);
end
Tk = T(keep,:);

context = double(Tk.context == 'B') + 1;
csPlus  = double(Tk.cs == 'CS+');
reward  = Tk.reward(:);
promptness = 1 ./ Tk.(dvColumn);
N = height(Tk);

models = getValueModels();
opts = optimset('Display','off','MaxFunEvals',5000,'MaxIter',5000);

results = struct('name',{},'nParams',{},'paramsFit',{},'nll',{},'aic',{},'bic',{},'Vctx',{},'yhat',{});

for m = 1:numel(models)
    mdl = models(m);
    nValuePars = mdl.nValuePars;

    objFun = @(vt) rtSSE(vt, mdl.fun, context, csPlus, reward, promptness);
    if nValuePars > 0
        vtFit = fminsearch(objFun, zeros(1,nValuePars), opts);
    else
        vtFit = [];
    end
    valuePars = sig(vtFit);
    Vctx = mdl.fun(valuePars, context, csPlus, reward);

    % closed-form linear fit given Vctx: promptness = b0 + b1*Vctx
    X = [ones(N,1), Vctx];
    b = ridgeOLS(X, promptness);
    yhat = X*b;
    resid = promptness - yhat;
    sigma2 = mean(resid.^2);
    nll = 0.5*N*log(2*pi*sigma2) + 0.5*sum(resid.^2)/sigma2;

    totalPars = nValuePars + 3;   % value pars + b0 + b1 + sigma

    r.name      = mdl.name;
    r.nParams   = totalPars;
    r.paramsFit = struct('valuePars', valuePars, 'b0', b(1), 'b1', b(2), 'sigma', sqrt(sigma2));
    r.nll       = nll;
    r.aic       = 2*nll + 2*totalPars;
    r.bic       = 2*nll + totalPars*log(N);
    r.Vctx      = Vctx;
    r.yhat      = yhat;
    results(end+1) = r; %#ok<AGROW>
end
end

function sse = rtSSE(vt, valueFun, context, csPlus, reward, promptness)
valuePars = sig(vt);
Vctx = valueFun(valuePars, context, csPlus, reward);
N = numel(promptness);
X = [ones(N,1), Vctx];
b = ridgeOLS(X, promptness);
resid = promptness - X*b;
sse = sum(resid.^2);
end

function b = ridgeOLS(X, yv)
%RIDGEOLS Tiny scale-aware ridge-regularized OLS.
% Avoids rank-deficient warnings / unstable min-norm solutions when a
% regressor column is (near-)constant -- which happens here whenever a
% value model's learning-rate parameter is pushed toward an extreme
% (e.g. alpha~0) during the fminsearch search, making Vctx ~constant and
% collinear with the intercept. lambda is tied to trace(X'X) so it's
% negligible for well-conditioned data and only stabilizes the
% degenerate cases.
lambda = 1e-6 * trace(X'*X) / size(X,2);
b = (X'*X + lambda*eye(size(X,2))) \ (X'*yv);
end

function s = sig(x)
s = 1 ./ (1+exp(-x));
end