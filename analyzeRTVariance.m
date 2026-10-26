function out = analyzeRTVariance(T, varargin)
%ANALYZERTVARIANCE Per-session RT/promptness variance by context.
%
%   out = analyzeRTVariance(T)
%   out = analyzeRTVariance(T, 'dvColumn', 'RT_trace')
%
%   THE VARIANCE-SHRINKAGE TEST (model-based vs. model-free):
%   A fixed-learning-rate RW/TD-chain value has roughly constant
%   trial-to-trial noise around its estimate throughout learning. A
%   Bayesian learner's posterior CONCENTRATES with experience
%   (uncertainty ~ 1/n, n = trials of that context type seen so far). So:
%   does RT (or promptness) variance on A/B trials keep shrinking across
%   sessions even AFTER the mean A-B difference (analyzeLearning.m) has
%   plateaued? If yes, that's a signature of something closer to genuine
%   probabilistic inference over the transition structure, and critically
%   it doesn't require committing to which point-estimate model produced
%   the mean effect -- it's a distinct, complementary test.
%
%   Also returns a Bayesian-model PREDICTED variance trajectory
%   (Beta-distribution variance of the fitted posterior) for direct
%   overlay against the observed variance decline.

p = inputParser;
addParameter(p, 'dvColumn', 'RT');
parse(p, varargin{:});
dvColumn = p.Results.dvColumn;

promptness = nan(height(T),1);
valid = ~isnan(T.(dvColumn)) & T.(dvColumn) > 0;
promptness(valid) = 1 ./ T.(dvColumn)(valid);

sessList = unique(T.session);
nSess = numel(sessList);

varA = nan(nSess,1); varB = nan(nSess,1);
nA   = nan(nSess,1); nB   = nan(nSess,1);

for i = 1:nSess
    s = sessList(i);
    a = T.session==s & T.context=='A' & ~isnan(promptness);
    b = T.session==s & T.context=='B' & ~isnan(promptness);
    varA(i) = var(promptness(a));
    varB(i) = var(promptness(b));
    nA(i) = sum(a); nB(i) = sum(b);
end

out.sessList = sessList;
out.varA = varA;
out.varB = varB;
out.varPooled = (varA.*nA + varB.*nB) ./ (nA+nB);
out.nA = nA; out.nB = nB;

good = ~isnan(out.varPooled);
if sum(good) >= 3
    pTrend = polyfit(sessList(good), out.varPooled(good), 1);
    out.trendSlope = pTrend(1);   % negative slope = shrinking variance, consistent w/ Bayesian
else
    out.trendSlope = NaN;
end

% --- Beta-posterior predicted variance trajectory (normative Bayesian) ---
% Var[Beta(a,b)] = ab / ((a+b)^2 (a+b+1)) -- using running trial counts
% per context across the WHOLE concatenated session history in T.
ctxA = T.context=='A'; ctxB = T.context=='B';
csP  = double(T.cs=='CS+');
nTotal = height(T);
aA=1; bA=1; aBc=1; bBc=1;
predVarA = nan(nTotal,1); predVarB = nan(nTotal,1);
for t = 1:nTotal
    predVarA(t) = aA*bA / ((aA+bA)^2 * (aA+bA+1));
    predVarB(t) = aBc*bBc / ((aBc+bBc)^2 * (aBc+bBc+1));
    if ctxA(t)
        if csP(t)==1, aA=aA+1; else, bA=bA+1; end
    elseif ctxB(t)
        if csP(t)==1, aBc=aBc+1; else, bBc=bBc+1; end
    end
end
predVarPooled = nan(nSess,1);
for i = 1:nSess
    rows = T.session==sessList(i);
    predVarPooled(i) = mean([predVarA(rows); predVarB(rows)], 'omitnan');
end
out.bayesPredictedVarPooled = predVarPooled;
end
