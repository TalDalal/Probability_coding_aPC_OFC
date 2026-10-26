function T = loadMouseData(allMiceBehavior, mouseIdx)
%LOADMOUSEDATA Concatenate all sessions for one mouse into a trial table.
%
%   T = loadMouseData(allMiceBehavior, mouseIdx)
%
%   Builds a chronological, trial-by-trial table across all sessions for
%   one mouse, ready for behavioral modeling (fitBehaviorModels.m,
%   fitRTModels.m) and learning-curve analysis (analyzeLearning.m,
%   analyzeRTVariance.m).
%
% ============================ ASSUMPTIONS =============================
% Edit the flags/lists/windows below if any of these don't match your data.
%
%   1) allMiceBehavior(mouseIdx).data(s).Atrials / .Btrials, and
%      .lickRaster(trial), all index into the SAME chronological
%      per-session trial numbering as CS_plus_minus / sufficientLicks.
%
%   2) CS_plus_minus: "CS+" trials are the LARGER of the two unique
%      values found (handles 0/1, 1/2, -1/1 coding automatically).
%
%   3) Reward is delivered deterministically on every CS+ trial (100%
%      validity), independent of licking. Set REWARD_CONTINGENT_ON_LICK
%      = true below if reward actually requires sufficientLicks==1.
%
%   4) lickRaster(trial).times: lick times in seconds, relative to CS
%      odor onset (t=0). Context odor is on from t=-2 to t=-1. Windows
%      below define which licks count as "context-epoch", "trace-epoch"
%      (post-context-odor-offset, pre-CS -- purest anticipation signal,
%      no odor physically present), and "CS-epoch".
%      If lickRaster isn't present for a session, falls back to
%      searching for a flat scalar RT field (RT_FIELD_CANDIDATES), else
%      NaN.
% ========================================================================

REWARD_CONTINGENT_ON_LICK = false;
RT_FIELD_CANDIDATES = {'RT','rt','RTs','latency','lickLatency', ...
    'lick_latency','responseTime','firstLickTime','respLatency','rxnTime', ...
    'RT_CS','decisionRT'};

CONTEXT_WINDOW     = [-2, 0];     % context-odor onset to CS onset (odor-on + trace)
TRACE_WINDOW       = [-1, 0];     % post-context-odor-offset to CS onset (odor absent)
CS_WINDOW          = [0, 2];      % CS onset to ~reward delivery
CONTEXT_EXT_WINDOW = [-2, 0.5];   % extended: pre-CS + first 0.5s of CS odor
CONTEXT_FULL_WINDOW = [-2, 1];    % full: pre-CS + entire CS presentation
EARLY_CS_WINDOW    = [0, 0.5];    % first 0.5s of CS odor ALONE -- use this to check
                                   % whether CS+/CS- already differ before pooling
                                   % CONTEXT_EXT_WINDOW across CS identity, e.g.:
                                   %   csP = T.cs=='CS+'; csM = T.cs=='CS-';
                                   %   mean(T.nLicks_earlyCS(csP)), mean(T.nLicks_earlyCS(csM))
                                   % If these are close, discrimination hasn't kicked in
                                   % yet and pooling both CS types in the extended
                                   % window (as done here, matching CONTEXT_WINDOW's
                                   % logic) is still valid. If CS+ is already much
                                   % higher, pull the window boundary back toward 0.

data  = allMiceBehavior(mouseIdx).data;
nSess = numel(data);

mouse       = [];
session     = [];
sessNum     = [];
trialInSess = [];
globalTrial = [];
context     = categorical([]);
cs          = categorical([]);
reward      = [];
lick        = [];
RT          = [];        % latency to first lick after context-odor onset
nLicks_context = [];
RT_trace    = [];        % latency to first lick after context-odor OFFSET (trace period)
nLicks_trace = [];
RT_CS       = [];        % latency to first lick after CS onset
nLicks_CS   = [];
RT_contextExt = [];      % latency to first lick, extended window [-2, +0.5]
nLicks_contextExt = [];
RT_contextFull = [];     % latency to first lick, full window [-2, +1]
nLicks_contextFull = [];
RT_earlyCS  = [];        % latency to first lick within [0, +0.5] alone
nLicks_earlyCS = [];

gT = 0;
for s = 1:nSess
    d = data(s);
    nTrials = numel(d.CS_plus_minus);

    % --- context labels ---
    ctx = repmat(categorical({'?'}), nTrials, 1);
    ctx(d.Atrials) = categorical({'A'});
    ctx(d.Btrials) = categorical({'B'});

    % --- CS identity (robust to 0/1, 1/2, -1/1 coding) ---
    csRaw = d.CS_plus_minus(:);
    u = unique(csRaw);
    if numel(u) ~= 2
        warning('loadMouseData:csCoding', ...
            'Mouse %d Session %d: CS_plus_minus does not have exactly 2 unique values.', ...
            mouseIdx, d.sessNum);
    end
    csPlusCode = max(u);   % ASSUMPTION: larger value = CS+
    csLabel = repmat(categorical({'CS-'}), nTrials, 1);
    csLabel(csRaw == csPlusCode) = categorical({'CS+'});

    % --- reward ---
    if REWARD_CONTINGENT_ON_LICK
        rew = double(csLabel == 'CS+') .* double(d.sufficientLicks(:));
    else
        rew = double(csLabel == 'CS+');
    end

    % --- lick-raster-derived RT / count features ---
    rt_ctx   = nan(nTrials,1); n_ctx   = nan(nTrials,1);
    rt_trace = nan(nTrials,1); n_trace = nan(nTrials,1);
    rt_cs    = nan(nTrials,1); n_cs    = nan(nTrials,1);
    rt_ctxExt = nan(nTrials,1); n_ctxExt = nan(nTrials,1);
    rt_ctxFull = nan(nTrials,1); n_ctxFull = nan(nTrials,1);
    rt_earlyCS = nan(nTrials,1); n_earlyCS = nan(nTrials,1);

    if isfield(d, 'lickRaster')
        if numel(d.lickRaster) ~= nTrials
            warning('loadMouseData:lickRasterLength', ...
                'Mouse %d Session %d: numel(lickRaster)=%d but nTrials=%d.', ...
                mouseIdx, d.sessNum, numel(d.lickRaster), nTrials);
        end
        for tr = 1:min(nTrials, numel(d.lickRaster))
            lt = d.lickRaster(tr).times(:);

            cw = lt(lt >= CONTEXT_WINDOW(1) & lt < CONTEXT_WINDOW(2));
            n_ctx(tr) = numel(cw);
            if ~isempty(cw), rt_ctx(tr) = min(cw) - CONTEXT_WINDOW(1); end

            tw = lt(lt >= TRACE_WINDOW(1) & lt < TRACE_WINDOW(2));
            n_trace(tr) = numel(tw);
            if ~isempty(tw), rt_trace(tr) = min(tw) - TRACE_WINDOW(1); end

            sw = lt(lt >= CS_WINDOW(1) & lt < CS_WINDOW(2));
            n_cs(tr) = numel(sw);
            if ~isempty(sw), rt_cs(tr) = min(sw) - CS_WINDOW(1); end

            ew = lt(lt >= CONTEXT_EXT_WINDOW(1) & lt < CONTEXT_EXT_WINDOW(2));
            n_ctxExt(tr) = numel(ew);
            if ~isempty(ew), rt_ctxExt(tr) = min(ew) - CONTEXT_EXT_WINDOW(1); end

            fw = lt(lt >= CONTEXT_FULL_WINDOW(1) & lt < CONTEXT_FULL_WINDOW(2));
            n_ctxFull(tr) = numel(fw);
            if ~isempty(fw), rt_ctxFull(tr) = min(fw) - CONTEXT_FULL_WINDOW(1); end

            ec = lt(lt >= EARLY_CS_WINDOW(1) & lt < EARLY_CS_WINDOW(2));
            n_earlyCS(tr) = numel(ec);
            if ~isempty(ec), rt_earlyCS(tr) = min(ec) - EARLY_CS_WINDOW(1); end
        end
    else
        fn  = fieldnames(d);
        hit = intersect(RT_FIELD_CANDIDATES, fn, 'stable');
        if ~isempty(hit)
            rt_ctx = double(d.(hit{1})(:));
        end
    end

    mouse       = [mouse;       repmat(mouseIdx, nTrials,1)]; %#ok<AGROW>
    session     = [session;     repmat(s, nTrials,1)];
    sessNum     = [sessNum;     repmat(d.sessNum, nTrials,1)];
    trialInSess = [trialInSess; (1:nTrials)'];
    globalTrial = [globalTrial; (gT+1:gT+nTrials)'];
    context     = [context;     ctx];
    cs          = [cs;          csLabel];
    reward      = [reward;      rew(:)];
    lick        = [lick;        double(d.sufficientLicks(:))];
    RT             = [RT;             rt_ctx];
    nLicks_context = [nLicks_context; n_ctx];
    RT_trace       = [RT_trace;       rt_trace];
    nLicks_trace   = [nLicks_trace;   n_trace];
    RT_CS          = [RT_CS;          rt_cs];
    nLicks_CS      = [nLicks_CS;      n_cs];
    RT_contextExt      = [RT_contextExt;      rt_ctxExt];
    nLicks_contextExt  = [nLicks_contextExt;  n_ctxExt];
    RT_contextFull     = [RT_contextFull;     rt_ctxFull];
    nLicks_contextFull = [nLicks_contextFull; n_ctxFull];
    RT_earlyCS         = [RT_earlyCS;         rt_earlyCS];
    nLicks_earlyCS     = [nLicks_earlyCS;     n_earlyCS];

    gT = gT + nTrials;
end

T = table(mouse, session, sessNum, trialInSess, globalTrial, ...
          context, cs, reward, lick, RT, nLicks_context, ...
          RT_trace, nLicks_trace, RT_CS, nLicks_CS, ...
          RT_contextExt, nLicks_contextExt, RT_contextFull, nLicks_contextFull, ...
          RT_earlyCS, nLicks_earlyCS);

nUndefCtx = sum(T.context == '?');
if nUndefCtx > 0
    warning('loadMouseData:undefinedContext', ...
        'Mouse %d: %d trials belong to neither Atrials nor Btrials.', ...
        mouseIdx, nUndefCtx);
end

if all(isnan(T.RT))
    warning('loadMouseData:noRT', ...
        ['No lickRaster / RT data found for mouse %d. T.RT is all NaN -- ' ...
         'RT-based models (fitRTModels.m) will have nothing to fit.'], mouseIdx);
end
end