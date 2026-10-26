function out = analyzeLearning(T, varargin)
%ANALYZELEARNING Session-level learning curves + trial-history GLM.
%
%   out = analyzeLearning(T)
%   out = analyzeLearning(T, 'dvColumn', 'nLicks_context')
%
%   T: table from loadMouseData.m (one mouse, all sessions concatenated).
%
%   'dvColumn' selects which behavioral measure defines the A-vs-B
%   "learning" signal. Default 'lick' (= sufficientLicks, POST-CS decision
%   window) matches the original panel, but note this is CONFOUNDED with
%   CS discrimination: because A is 75%/25% CS+/CS- and B is the reverse,
%   even a mouse with zero context learning that purely discriminates
%   CS+ vs CS- will show nonzero diffAB = 0.5*(P(lick|CS+)-P(lick|CS-)).
%   For the confound-free, PRE-CS test of context-driven expectation, use:
%       'nLicks_context'  - lick count in [-2,0) rel. to CS (context epoch)
%       'nLicks_trace'    - lick count in [-1,0) (odor-absent trace period)
%   (both well-defined even at zero, unlike RT which is NaN if no lick
%   occurred). To test a different time window entirely, edit
%   CONTEXT_WINDOW / TRACE_WINDOW / CS_WINDOW at the top of
%   loadMouseData.m and rerun it -- that's where window boundaries live.
%
%   Computes, per session:
%     - mean(dvColumn | context=A), mean(dvColumn | context=B), and their
%       difference (chance/no-learning = 0)
%     - mean RT per context (if T.RT is available; otherwise NaN)
%   Fits an exponential-rise curve to the A-B difference across sessions:
%       diff(s) = dInf * (1 - exp(-(s-1)/tau))
%   giving a quantitative "sessions-to-asymptote" time constant tau and
%   asymptotic sensitivity dInf.
%
%   Also fits a trial-history logistic GLM (on sufficientLicks specifically,
%   regardless of dvColumn):
%       lick(t) ~ context(t) + cs(t) + context(t-1) + cs(t-1) + reward(t-1)
%   to check whether behavior is explained by immediate trial history
%   (priming) rather than a stable learned representation.

p = inputParser;
addParameter(p, 'dvColumn', 'lick');
parse(p, varargin{:});
dvColumn = p.Results.dvColumn;
out.dvColumn = dvColumn;

sessList = unique(T.session);
nSess = numel(sessList);

pA  = nan(nSess,1); pB  = nan(nSess,1);
rtA = nan(nSess,1); rtB = nan(nSess,1);

for i = 1:nSess
    s = sessList(i);
    rows = T.session==s;
    a = rows & T.context=='A';
    b = rows & T.context=='B';
    pA(i) = mean(T.(dvColumn)(a), 'omitnan');
    pB(i) = mean(T.(dvColumn)(b), 'omitnan');
    rtA(i) = mean(T.RT(a), 'omitnan');
    rtB(i) = mean(T.RT(b), 'omitnan');
end

diffAB = pA - pB;

% --- fit exponential learning curve ---
sessAx  = (1:nSess)';
expFun  = @(p,s) p(1).*(1-exp(-(s-1)./max(p(2),1e-3)));
objFun  = @(p) sum((expFun(p,sessAx) - diffAB).^2);
p0      = [max(diffAB,[],'omitnan'), max(nSess/3,1)];
pFit    = fminsearch(objFun, p0, optimset('Display','off'));

out.sessList = sessList;
out.pLick_A  = pA;
out.pLick_B  = pB;
out.diffAB   = diffAB;
out.rt_A     = rtA;
out.rt_B     = rtB;
out.learningCurveFit.dInf = pFit(1);
out.learningCurveFit.tau  = pFit(2);
out.learningCurveFit.pred = expFun(pFit, sessAx);

% --- trial-history logistic GLM ---
ctxA    = double(T.context=='A');
csP     = double(T.cs=='CS+');
ctxA_l1 = [NaN; ctxA(1:end-1)];
csP_l1  = [NaN; csP(1:end-1)];
rew_l1  = [NaN; T.reward(1:end-1)];

X = [ctxA, csP, ctxA_l1, csP_l1, rew_l1];
good = all(~isnan(X),2);

out.historyGLM.coefNames = {'intercept','context(t)=A','cs(t)=+', ...
    'context(t-1)=A','cs(t-1)=+','reward(t-1)'};
if exist('glmfit','file')
    [b,~,stats] = glmfit(X(good,:), T.lick(good), 'binomial','link','logit');
    out.historyGLM.beta = b;
    out.historyGLM.se   = stats.se;
    out.historyGLM.p    = stats.p;
else
    warning('analyzeLearning:noGLM', ...
        'glmfit not found (needs Statistics Toolbox); skipping history GLM.');
    out.historyGLM.beta = [];
    out.historyGLM.se   = [];
    out.historyGLM.p    = [];
end
end