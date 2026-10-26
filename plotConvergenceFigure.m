function plotConvergenceFigure(allMiceBehavior, varargin)
%PLOTCONVERGENCEFIGURE Model-vs-mouse convergence figure.
%
%   plotConvergenceFigure(allMiceBehavior)
%   plotConvergenceFigure(allMiceBehavior, 'sessionBinSize', 2)
%
%   Two-panel figure for the revision:
%     (left)  A simple trial-by-trial Rescorla-Wagner estimate of
%             P(CS+|context), separately tracked for context A and B,
%             converging over sessions toward the TRUE generative
%             transition probabilities (0.75 for A, 0.25 for B).
%     (right) The mouse's own pre-CS(+early CS) context-epoch anticipatory
%             licking (nLicks_contextExt, window [-2,+0.5s] rel. CS onset),
%             A-minus-B, across the same sessions.
%
%   'sessionBinSize' (default 2) averages that many consecutive sessions
%   into one x-axis point in BOTH panels, applied identically to the
%   model trajectory and the behavioral trajectory so the two remain
%   directly comparable on the same binned session axis.
%
%   The point: a trial-by-trial learner needs only the experienced
%   context/CS history to recover the task's true statistics, and the
%   session-by-session TIMECOURSE over which the mouse's own behavior
%   separates by context tracks that same acquisition process -- i.e.
%   the animal's behavior is consistent with having learned the
%   context->CS+ transition structure, on a timescale matching a simple
%   trial-by-trial learning process.
%
%   Self-contained: only requires loadMouseData.m, fitBehaviorModels.m,
%   getValueModels.m, analyzeLearning.m on the path (uses each mouse's
%   own fitted Flat-model learning rate for the left panel).

p = inputParser;
addParameter(p, 'sessionBinSize', 2);
addParameter(p, 'nShuffles', 50);
parse(p, varargin{:});
binSize = p.Results.sessionBinSize;
nShuffles = p.Results.nShuffles;

% context colors (shared by both panels' A/B color coding)
colorA = [0,169,137]./255;   % green
colorB = [171,62,143]./255;  % purple

nMice = numel(allMiceBehavior);
VA_bySess = cell(nMice,1);
VB_bySess = cell(nMice,1);
VAideal_bySess = cell(nMice,1);
VBideal_bySess = cell(nMice,1);
VAshuf_bySess = cell(nMice,1);
VBshuf_bySess = cell(nMice,1);
behavDiff_bySess = cell(nMice,1);
alphaByMouse = nan(nMice,1);
aTrialsPerSess = nan(nMice,1);
maxSess = 0;

for m = 1:nMice
    T = loadMouseData(allMiceBehavior, m);
    keep = T.context=='A' | T.context=='B';
    T = T(keep,:);

    context = double(T.context=='B')+1;   % 1=A, 2=B
    csPlus  = double(T.cs=='CS+');
    reward  = T.reward(:);

    % this mouse's own fitted Flat-model learning rate
    res = fitBehaviorModels(T);
    names = {res.name};
    alpha = res(strcmp(names,'Flat')).paramsFit.valuePars(1);

    [VA, VB] = computeContextValueTraces(context, reward, alpha);
    [VA_ideal, VB_ideal] = computeContextValueTracesIdeal(context, reward);
    [VA_shuf, VB_shuf] = computeContextValueTracesShuffled(context, csPlus, alpha, nShuffles);

    sessList = unique(T.session);
    nSess = numel(sessList);
    maxSess = max(maxSess, nSess);
    vaS = nan(1,nSess); vbS = nan(1,nSess);
    vaIdealS = nan(1,nSess); vbIdealS = nan(1,nSess);
    vaShufS = nan(1,nSess); vbShufS = nan(1,nSess);
    for i = 1:nSess
        rows = find(T.session==sessList(i));
        vaS(i) = VA(rows(end));   % belief at END of session i
        vbS(i) = VB(rows(end));
        vaIdealS(i) = VA_ideal(rows(end));
        vbIdealS(i) = VB_ideal(rows(end));
        vaShufS(i) = VA_shuf(rows(end));
        vbShufS(i) = VB_shuf(rows(end));
    end
    VA_bySess{m} = vaS;
    VB_bySess{m} = vbS;
    VAideal_bySess{m} = vaIdealS;
    VBideal_bySess{m} = vbIdealS;
    VAshuf_bySess{m} = vaShufS;
    VBshuf_bySess{m} = vbShufS;
    alphaByMouse(m) = alpha; %#ok<AGROW>
    aTrialsPerSess(m) = sum(context==1) / nSess; %#ok<AGROW>

    % validity check: has CS discrimination started by 0.5s into the CS?
    % (all trials pooled regardless of CS identity in the extended window
    % below is only valid if this check comes back similar)
    csP = T.cs=='CS+'; csM = T.cs=='CS-';
    fprintf('Mouse %d: mean licks in [0,0.5s] post-CS -- CS+: %.3f, CS-: %.3f\n', ...
        m, mean(T.nLicks_earlyCS(csP),'omitnan'), mean(T.nLicks_earlyCS(csM),'omitnan'));

    % --- confound check for the pooled [-2,+1] window ---
    % null prediction if the mouse used ONLY CS identity (no context use
    % at all): diff_AB = 0.5*(mean_resp_CS+ - mean_resp_CS-), purely from
    % A being CS+-enriched (75%) vs B (25%). Observed diff exceeding this
    % is evidence of genuine context modulation, not just the mixture.
    muPlus  = mean(T.nLicks_contextFull(T.cs=='CS+'), 'omitnan');
    muMinus = mean(T.nLicks_contextFull(T.cs=='CS-'), 'omitnan');
    nullDiff = 0.5*(muPlus - muMinus);
    obsDiff  = mean(T.nLicks_contextFull(T.context=='A'),'omitnan') - ...
               mean(T.nLicks_contextFull(T.context=='B'),'omitnan');
    % confound-free control: hold CS identity fixed, compare context only
    diffWithinCSplus  = mean(T.nLicks_contextFull(T.context=='A' & T.cs=='CS+'),'omitnan') - ...
                         mean(T.nLicks_contextFull(T.context=='B' & T.cs=='CS+'),'omitnan');
    diffWithinCSminus = mean(T.nLicks_contextFull(T.context=='A' & T.cs=='CS-'),'omitnan') - ...
                         mean(T.nLicks_contextFull(T.context=='B' & T.cs=='CS-'),'omitnan');
    fprintf(['Mouse %d [-2,+1] window: observed A-B=%.3f, mixture-only null=%.3f (excess=%.3f) | ' ...
             'within CS+ A-B=%.3f, within CS- A-B=%.3f\n'], ...
        m, obsDiff, nullDiff, obsDiff-nullDiff, diffWithinCSplus, diffWithinCSminus);

    L = analyzeLearning(T, 'dvColumn','nLicks_contextFull');
    behavDiff_bySess{m} = L.diffAB(:)';
end

% --- quantitative justification for the observed convergence timescale ---
% n_eps = ln(eps)/ln(1-alpha)  (trials of that context needed to close to
% within a fraction eps of the initial-condition bias; eps=0.05 is the
% standard "95%-of-the-way-to-asymptote" convention). Converted to
% sessions using each mouse's own average A-trials/session, then
% averaged across mice -- this is a genuine model prediction (alpha was
% fit independently to licking, not tuned to match this number).
eps_conv = 0.05;
nTrialsTo95 = log(eps_conv) ./ log(1 - alphaByMouse);
nSessionsTo95 = nTrialsTo95 ./ aTrialsPerSess;
fprintf('\nConvergence timescale (from fitted alpha, not tuned to this plot):\n');
fprintf('  mean alpha (Flat model)      = %.4f\n', mean(alphaByMouse));
fprintf('  mean A-trials per session    = %.1f\n', mean(aTrialsPerSess));
fprintf('  trials to 95%% of asymptote   = %.0f\n', mean(nTrialsTo95));
fprintf('  sessions to 95%% of asymptote = %.1f  (mean across mice)\n', mean(nSessionsTo95));
fprintf('  session-bins (size %d) to 95%% = %.1f\n', binSize, mean(nSessionsTo95)/binSize);

% --- ideal-observer benchmark: Beta(1,1) prior = 2 "pseudo-trials" of
% weight; prior's residual influence = 2/(n+2), which drops below eps
% at n = 2/eps - 2 (exact, no per-mouse alpha needed -- this bound
% doesn't depend on the data at all, only on the prior and threshold) ---
nTrialsToIdeal95 = 2/eps_conv - 2;
nSessionsToIdeal95 = nTrialsToIdeal95 ./ aTrialsPerSess;
fprintf('\nIdeal-observer (Bayes-optimal, no forgetting) benchmark:\n');
fprintf('  trials to 95%% of asymptote   = %.0f  (fixed; independent of the data)\n', nTrialsToIdeal95);
fprintf('  sessions to 95%% of asymptote = %.1f  (mean across mice)\n', mean(nSessionsToIdeal95));
fprintf('  ==> fitted model is ~%.1fx slower than the theoretical fastest-possible learner\n\n', ...
    mean(nSessionsTo95)/mean(nSessionsToIdeal95));

VAmat = nan(nMice,maxSess); VBmat = nan(nMice,maxSess); Bmat = nan(nMice,maxSess);
VAidealMat = nan(nMice,maxSess); VBidealMat = nan(nMice,maxSess);
VAshufMat = nan(nMice,maxSess); VBshufMat = nan(nMice,maxSess);
for m = 1:nMice
    VAmat(m,1:numel(VA_bySess{m})) = VA_bySess{m};
    VBmat(m,1:numel(VB_bySess{m})) = VB_bySess{m};
    VAidealMat(m,1:numel(VAideal_bySess{m})) = VAideal_bySess{m};
    VBidealMat(m,1:numel(VBideal_bySess{m})) = VBideal_bySess{m};
    VAshufMat(m,1:numel(VAshuf_bySess{m})) = VAshuf_bySess{m};
    VBshufMat(m,1:numel(VBshuf_bySess{m})) = VBshuf_bySess{m};
    Bmat(m,1:numel(behavDiff_bySess{m})) = behavDiff_bySess{m};
end

% --- bin every `binSize` consecutive sessions into one point, identically
% for both panels, so the model and behavioral traces stay comparable ---
VAmat = binColumns(VAmat, binSize);
VBmat = binColumns(VBmat, binSize);
VAidealMat = binColumns(VAidealMat, binSize);
VBidealMat = binColumns(VBidealMat, binSize);
VAshufMat = binColumns(VAshufMat, binSize);
VBshufMat = binColumns(VBshufMat, binSize);
Bmat  = binColumns(Bmat,  binSize);
nBins = size(VAmat,2);
binAxis = 1:nBins;
binLabels = cell(1,nBins);
for b = 1:nBins
    firstSess = (b-1)*binSize + 1;
    lastSess  = min(b*binSize, maxSess);
    if firstSess == lastSess
        binLabels{b} = sprintf('%d', firstSess);
    else
        binLabels{b} = sprintf('%d-%d', firstSess, lastSess);
    end
end

figure('Name','Model vs. mouse convergence', 'Position',[100 100 950 420]);

subplot(1,2,1); hold on;
yline(0.75,'--','Color',[0.6 0.6 0.6],'LineWidth',1);
yline(0.25,'--','Color',[0.6 0.6 0.6],'LineWidth',1);
yline(0.5,':','Color',[0.75 0.75 0.75],'LineWidth',1);   % no-learning / chance reference
plot(binAxis, mean(VAidealMat,1,'omitnan'), '--', 'Color',colorA, 'LineWidth',1.2);
plot(binAxis, mean(VBidealMat,1,'omitnan'), '--', 'Color',colorB, 'LineWidth',1.2);
plot(binAxis, mean(VAshufMat,1,'omitnan'), ':', 'Color',colorA, 'LineWidth',1.5);
plot(binAxis, mean(VBshufMat,1,'omitnan'), ':', 'Color',colorB, 'LineWidth',1.5);
seA = std(VAmat,0,1,'omitnan')./sqrt(sum(~isnan(VAmat),1));
seB = std(VBmat,0,1,'omitnan')./sqrt(sum(~isnan(VBmat),1));
errorbar(binAxis, mean(VAmat,1,'omitnan'), seA, '-o', 'Color',colorA, ...
    'LineWidth',2, 'MarkerFaceColor',colorA);
errorbar(binAxis, mean(VBmat,1,'omitnan'), seB, '-o', 'Color',colorB, ...
    'LineWidth',2, 'MarkerFaceColor',colorB);
set(gca,'XTick',binAxis,'XTickLabel',binLabels);
xlabel(sprintf('Session (bins of %d)', binSize)); ylabel('Model estimate of P(CS+ | context)');
legend({'true P=0.75 (A)','true P=0.25 (B)','chance / no learning', ...
    'ideal observer A','ideal observer B','shuffled-order A (same \alpha)','shuffled-order B (same \alpha)', ...
    'fitted model V(A)','fitted model V(B)'}, ...
    'Location','eastoutside','Box','off');
title('Fitted model vs. ideal-observer and shuffled-order benchmarks');
ylim([0 1]);

subplot(1,2,2); hold on;
seD = std(Bmat,0,1,'omitnan')./sqrt(sum(~isnan(Bmat),1));
errorbar(binAxis, mean(Bmat,1,'omitnan'), seD, '-o', 'Color','k', ...
    'LineWidth',2, 'MarkerFaceColor','k');
yline(0,'k--');
set(gca,'XTick',binAxis,'XTickLabel',binLabels);
xlabel(sprintf('Session (bins of %d)', binSize)); ylabel('Anticipatory licks: context A - context B ([-2, +1s] rel. CS)');
title('Mouse behavior separates by context on a parallel timescale');

end

% ---------------------------------------------------------------------
function binnedMat = binColumns(mat, binSize)
%BINCOLUMNS Average every binSize consecutive columns (sessions) together.
% Uses omitnan so a mouse with fewer total sessions than others still
% contributes to earlier bins without distorting later ones.
[nRows, nCols] = size(mat);
nBins = ceil(nCols / binSize);
binnedMat = nan(nRows, nBins);
for b = 1:nBins
    idx = (b-1)*binSize+1 : min(b*binSize, nCols);
    binnedMat(:,b) = mean(mat(:,idx), 2, 'omitnan');
end
end

% ---------------------------------------------------------------------
function [VA, VB] = computeContextValueTraces(context, reward, alpha)
% Full trajectory of the RW estimate of P(CS+|A) and P(CS+|B) after
% EVERY trial (held constant between updates of that context) -- unlike
% the "prospective" Vctx used for model fitting, this keeps both series
% alive at every timepoint so they can be plotted together.
N = numel(context);
VA = zeros(N,1); VB = zeros(N,1);
vA = 0.5; vB = 0.5;
for t = 1:N
    if context(t)==1
        vA = vA + alpha*(reward(t)-vA);
    else
        vB = vB + alpha*(reward(t)-vB);
    end
    VA(t) = vA; VB(t) = vB;
end
end

% ---------------------------------------------------------------------
function [VAmean, VBmean] = computeContextValueTracesShuffled(context, csTrue, alpha, nShuffles)
%COMPUTECONTEXTVALUETRACESSHUFFLED "Shuffled order" reference.
% Same fitted alpha, same RW recursion (computeContextValueTraces), but
% the CS+/CS- identity is randomly permuted WITHIN each context before
% each run (exact per-context base rate preserved -- still 0.75/0.25 --
% only the trial-by-trial SEQUENCE is destroyed). Averaged over
% nShuffles repeats. This answers: "if this same learning rate had been
% applied to a randomly reordered but statistically identical history,
% what would the trajectory look like?" If the real (solid) trajectory
% tracks this shuffled reference closely, the specific order isn't doing
% much beyond what the aggregate base rate already implies; a real
% trajectory that's a notably different shape (see
% permutationControlAlpha.m for the matching statistical test against
% the animal's actual licking, not just this trajectory-shape check)
% would suggest something beyond simple stationary RW updating.
N = numel(context);
VAsum = zeros(N,1); VBsum = zeros(N,1);
idxA = find(context==1); idxB = find(context==2);
for k = 1:nShuffles
    csShuf = csTrue;
    csShuf(idxA) = csShuf(idxA(randperm(numel(idxA))));
    csShuf(idxB) = csShuf(idxB(randperm(numel(idxB))));
    [VA_k, VB_k] = computeContextValueTraces(context, csShuf, alpha);   % reward == CS+ in this task
    VAsum = VAsum + VA_k;
    VBsum = VBsum + VB_k;
end
VAmean = VAsum / nShuffles;
VBmean = VBsum / nShuffles;
end

% ---------------------------------------------------------------------
function [VA, VB] = computeContextValueTracesIdeal(context, reward)
%COMPUTECONTEXTVALUETRACESIDEAL "Ideal observer" reference.
% Beta-Bernoulli posterior mean, uniform Beta(1,1) prior, NO forgetting --
% i.e. every past trial of that context is weighted EQUALLY (unlike the
% fitted RW model, which downweights old evidence geometrically at rate
% 1-alpha). This is the maximally data-efficient, minimum-variance
% unbiased estimator of P(CS+|context) achievable from the same
% trial-by-trial information -- the fastest any unbiased learner could
% possibly converge given this data. Comparing the fitted-alpha RW
% trajectory against this tells you whether the animal's inferred
% updating is close to that ceiling or well below it.
N = numel(context);
VA = zeros(N,1); VB = zeros(N,1);
aA=1; bA=1; aB=1; bB=1;   % Beta(1,1) uniform prior
for t = 1:N
    if context(t)==1
        if reward(t)==1, aA=aA+1; else, bA=bA+1; end
    else
        if reward(t)==1, aB=aB+1; else, bB=bB+1; end
    end
    VA(t) = aA/(aA+bA);
    VB(t) = aB/(aB+bB);
end
end